#include "memcatWindow.h"

#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QMessageBox>
#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QUuid>
#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QHeaderView>
#include <QAbstractItemView>
#include <QProcess>

static const QString DB_PATH = "events.db";

static QString findProjectRoot()
{
    QDir dir(QCoreApplication::applicationDirPath());

    for (int i = 0; i < 8; ++i) {
        bool hasMemcat = QFileInfo::exists(dir.filePath("run_memcat_periodic.py"));
        bool hasBuild = QFileInfo::exists(dir.filePath("build_intervals.py"));

        if (hasMemcat && hasBuild) {
            return dir.absolutePath();
        }

        if (!dir.cdUp()) {
            break;
        }
    }

    return QCoreApplication::applicationDirPath();
}

static QString resolveDbPath()
{
    QDir root(findProjectRoot());
    return root.filePath(DB_PATH);
}

MemcatWindow::MemcatWindow(QWidget *parent)
    : QMainWindow(parent),
      memcatCommandTimer(nullptr),
      memEventsTable(nullptr),
      refreshButton(nullptr),
      statusLabel(nullptr),
      qemuProcess(new QProcess(this)),
      ingestorProcess(new QProcess(this))
{
    connectionName = "memcat_connection_" + QUuid::createUuid().toString();

    setupDatabase();
    setupUi();

    connect(qemuProcess, &QProcess::started,
            this, &MemcatWindow::onQemuStarted);

    connect(qemuProcess,
            QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this,
            &MemcatWindow::onQemuFinished);

    connect(ingestorProcess, &QProcess::started,
            this, &MemcatWindow::onIngestorStarted);

    connect(ingestorProcess,
            QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this,
            &MemcatWindow::onIngestorFinished);

    memcatCommandTimer = new QTimer(this);
    connect(memcatCommandTimer, &QTimer::timeout, this, &MemcatWindow::runMemcat);
    memcatCommandTimer->start(5000);

    setWindowTitle("xv6 Memcat Monitor");
    resize(1100, 700);

    startQemuAndIngestor();
}

MemcatWindow::~MemcatWindow()
{
    if (memcatCommandTimer) {
        memcatCommandTimer->stop();
    }

    if (qemuProcess && qemuProcess->state() != QProcess::NotRunning) {
        qemuProcess->terminate();
        qemuProcess->waitForFinished(1500);
        if (qemuProcess->state() != QProcess::NotRunning) {
            qemuProcess->kill();
        }
    }

    if (ingestorProcess && ingestorProcess->state() != QProcess::NotRunning) {
        ingestorProcess->terminate();
        ingestorProcess->waitForFinished(1000);
        if (ingestorProcess->state() != QProcess::NotRunning) {
            ingestorProcess->kill();
        }
    }

    if (db.isOpen()) {
        db.close();
    }

    QSqlDatabase::removeDatabase(connectionName);
}

void MemcatWindow::setupDatabase()
{
    db = QSqlDatabase::addDatabase("QSQLITE", connectionName);
    db.setDatabaseName(resolveDbPath());

    if (!db.open()) {
        showDbError("Opening memcat database");
    }
}

void MemcatWindow::setupUi()
{
    QWidget *central = new QWidget(this);
    setCentralWidget(central);

    QVBoxLayout *mainLayout = new QVBoxLayout(central);

    QHBoxLayout *topBar = new QHBoxLayout();

    refreshButton = new QPushButton("Refresh MEM events", this);
    connect(refreshButton, &QPushButton::clicked, this, &MemcatWindow::loadMemEvents);
    refreshButton->setStyleSheet(
        "QPushButton { background-color: #6c5ce7; color: white; font-weight: bold; padding: 10px; border-radius: 8px; }"
        "QPushButton:hover { background-color: #5a4bcf; }"
    );

    statusLabel = new QLabel("Starting memcat monitor...", this);
    statusLabel->setStyleSheet("font-weight: bold; color: #2c3e50; padding-left: 8px;");

    topBar->addWidget(refreshButton);
    topBar->addStretch();
    topBar->addWidget(statusLabel);

    QLabel *title = new QLabel("Live memcat events", this);
    title->setStyleSheet("font-weight: bold; font-size: 16px; margin-bottom: 10px;");

    memEventsTable = new QTableWidget(this);
    memEventsTable->setColumnCount(9);
    memEventsTable->setHorizontalHeaderLabels({
        "seq", "tick", "cpu", "pid", "type", "source", "name", "old size", "new size"
    });
    memEventsTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    memEventsTable->setAlternatingRowColors(true);
    memEventsTable->setEditTriggers(QAbstractItemView::NoEditTriggers);
    memEventsTable->setSelectionBehavior(QAbstractItemView::SelectRows);

    mainLayout->addLayout(topBar);
    mainLayout->addWidget(title);
    mainLayout->addWidget(memEventsTable, 1);
}

void MemcatWindow::startQemuAndIngestor()
{
    if (qemuProcess->state() != QProcess::NotRunning) {
        updateStatusLabel("QEMU is already running", "#d35400");
        return;
    }

    QString projectRoot = findProjectRoot();
    updateStatusLabel("Starting QEMU and memcat ingestor...", "#8e44ad");

    qemuProcess->setWorkingDirectory(projectRoot);
    qemuProcess->start("bash", QStringList() << "-c" << "make qemu 2>&1 | tee qemu.log");

    if (!qemuProcess->waitForStarted(2000)) {
        QString err = qemuProcess->errorString();
        updateStatusLabel("Failed to start QEMU", "#c0392b");
        QMessageBox::warning(
            this,
            "Start QEMU",
            "Could not start QEMU\n\n"
            "Project root: " + projectRoot + "\n"
            "Error: " + err
        );
        return;
    }

    QTimer::singleShot(2000, [this]() {
        if (ingestorProcess->state() == QProcess::NotRunning) {
            QString projectRoot = findProjectRoot();
            QString pythonBin = "python3";
            ingestorProcess->setWorkingDirectory(projectRoot);
            ingestorProcess->start(pythonBin, QStringList() << "run_memcat_periodic.py");

            if (!ingestorProcess->waitForStarted(1000)) {
                updateStatusLabel("Ingestor failed to start", "#d35400");
            }
        }
    });
}

void MemcatWindow::runMemcat()
{
    if (qemuProcess && qemuProcess->state() == QProcess::Running) {
        qemuProcess->write("memcat\n");
        updateStatusLabel("Sent memcat command to QEMU", "#27ae60");
    }

    loadMemEvents();
}

void MemcatWindow::loadMemEvents()
{
    memEventsTable->setRowCount(0);

    if (!db.isOpen() && !db.open()) {
        return;
    }

    if (!tableExists("mem_events")) {
        updateStatusLabel("Waiting for mem_events table...", "#f39c12");
        return;
    }

    QSqlQuery query(db);
    query.prepare(
        "SELECT seq, ticks, cpu, pid, type, source, name, oldsz, newsz, timestamp "
        "FROM mem_events "
        "ORDER BY id DESC "
        "LIMIT 200"
    );

    if (!query.exec()) {
        showDbError("Loading MEM events");
        return;
    }

    int row = 0;
    while (query.next()) {
        memEventsTable->insertRow(row);
        memEventsTable->setItem(row, 0, new QTableWidgetItem(QString::number(query.value(0).toInt())));
        memEventsTable->setItem(row, 1, new QTableWidgetItem(QString::number(query.value(1).toInt())));
        memEventsTable->setItem(row, 2, new QTableWidgetItem(QString::number(query.value(2).toInt())));
        memEventsTable->setItem(row, 3, new QTableWidgetItem(QString::number(query.value(3).toInt())));
        memEventsTable->setItem(row, 4, new QTableWidgetItem(query.value(4).toString()));
        memEventsTable->setItem(row, 5, new QTableWidgetItem(query.value(5).toString()));
        memEventsTable->setItem(row, 6, new QTableWidgetItem(query.value(6).toString()));
        memEventsTable->setItem(row, 7, new QTableWidgetItem(QString::number(query.value(7).toLongLong())));
        memEventsTable->setItem(row, 8, new QTableWidgetItem(QString::number(query.value(8).toLongLong())));
        row++;
    }

    updateStatusLabel(QString("Loaded %1 mem events").arg(row), "#27ae60");
}

void MemcatWindow::onQemuStarted()
{
    updateStatusLabel("QEMU running...", "#27ae60");
}

void MemcatWindow::onQemuFinished(int /*exitCode*/, QProcess::ExitStatus /*exitStatus*/)
{
    updateStatusLabel("QEMU finished", "#2c3e50");

    if (ingestorProcess->state() != QProcess::NotRunning) {
        ingestorProcess->terminate();
        ingestorProcess->waitForFinished(1000);
        if (ingestorProcess->state() != QProcess::NotRunning) {
            ingestorProcess->kill();
        }
    }
}

void MemcatWindow::onIngestorStarted()
{
    updateStatusLabel("QEMU running + ingestor active", "#27ae60");
}

void MemcatWindow::onIngestorFinished(int /*exitCode*/, QProcess::ExitStatus /*exitStatus*/)
{
    updateStatusLabel("Ingestor finished", "#d35400");
}

bool MemcatWindow::tableExists(const QString &tableName)
{
    if (!db.isOpen() && !db.open()) {
        return false;
    }
    return db.tables().contains(tableName);
}

void MemcatWindow::showDbError(const QString &context)
{
    QMessageBox::warning(this,
                         "Database Error",
                         context + "\n\n" + db.lastError().text());
}

void MemcatWindow::updateStatusLabel(const QString &text, const QString &color)
{
    statusLabel->setText(text);
    statusLabel->setStyleSheet(QString("font-weight: bold; color: %1; padding-left: 8px;").arg(color));
}
