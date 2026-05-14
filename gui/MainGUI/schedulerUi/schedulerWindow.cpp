#include "schedulerWindow.h"

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
#include <QProcess>
#include <QTimer>
#include <QPushButton>
#include <QTableWidget>
#include <QHeaderView>
#include <QAbstractItemView>
#include <QProgressBar>

static const QString DB_PATH = "events.db";

static QString findProjectRoot()
{
    QDir dir(QCoreApplication::applicationDirPath());

    for (int i = 0; i < 8; ++i) {
        bool hasIngest = QFileInfo::exists(dir.filePath("ingest_from_stream.py"));
        bool hasBuild = QFileInfo::exists(dir.filePath("build_intervals.py"));

        if (hasIngest && hasBuild) {
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

SchedulerWindow::SchedulerWindow(QWidget *parent)
    : QMainWindow(parent),
      cpuInfoTimer(nullptr),
      cpuInfoTable(nullptr),
      procStatsTable(nullptr),
      cpuStatsRefreshButton(nullptr),
      statusLabel(nullptr),
      qemuProcess(new QProcess(this)),
      ingestorProcess(new QProcess(this))
{
    connectionName = "scheduler_connection_" + QUuid::createUuid().toString();

    setupDatabase();
    setupUi();

    connect(qemuProcess, &QProcess::started,
            this, &SchedulerWindow::onQemuStarted);

    connect(qemuProcess,
            QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this,
            &SchedulerWindow::onQemuFinished);

    connect(ingestorProcess, &QProcess::started,
            this, &SchedulerWindow::onIngestorStarted);

    connect(ingestorProcess,
            QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this,
            &SchedulerWindow::onIngestorFinished);

    cpuInfoTimer = new QTimer(this);
    connect(cpuInfoTimer, &QTimer::timeout, this, &SchedulerWindow::runCpuInfo);
    cpuInfoTimer->start(5000);  // Run cpuinfo every 5 seconds

    cpuCmdTimer = new QTimer(this);

connect(cpuCmdTimer, &QTimer::timeout, this, [this]() {
    if (qemuProcess && qemuProcess->state() == QProcess::Running) {
        qemuProcess->write("cpuinfo\n");
        qDebug() << "cpuinfo sent to QEMU";
    }
});

cpuCmdTimer->start(5000);
    setWindowTitle("xv6 CPU Info Monitor");
    resize(1000, 700);

    // Start QEMU and ingestor automatically on startup
    startQemuAndIngestor();
}

SchedulerWindow::~SchedulerWindow() {
    if (cpuInfoTimer) {
        cpuInfoTimer->stop();
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

void SchedulerWindow::setupDatabase() {
    db = QSqlDatabase::addDatabase("QSQLITE", connectionName);
    db.setDatabaseName(resolveDbPath());

    if (!db.open()) {
        showDbError("Opening scheduler database");
    }
}

void SchedulerWindow::setupUi() {
    QWidget *central = new QWidget(this);
    setCentralWidget(central);

    QVBoxLayout *mainLayout = new QVBoxLayout(central);

    // Top bar with buttons and status
    QHBoxLayout *topBar = new QHBoxLayout();

    cpuStatsRefreshButton = new QPushButton("Refresh CPU Info", this);
    connect(cpuStatsRefreshButton, &QPushButton::clicked, this, &SchedulerWindow::loadCpuStats);

    cpuStatsRefreshButton->setStyleSheet(
        "QPushButton { background-color: #3498db; color: white; font-weight: bold; padding: 8px; border-radius: 8px; }"
        "QPushButton:hover { background-color: #2980b9; }"
    );

    statusLabel = new QLabel("Initializing...", this);
    statusLabel->setStyleSheet("font-weight: bold; color: #2c3e50; padding-left: 8px;");

    cpuUsageLabel = new QLabel("Total CPU Usage", this);
    cpuUsageLabel->setStyleSheet("font-weight: bold; color: #34495e; padding-left: 8px;");

    cpuUsageBar = new QProgressBar(this);
    cpuUsageBar->setMinimum(0);
    cpuUsageBar->setMaximum(100);
    cpuUsageBar->setTextVisible(true);
    cpuUsageBar->setStyleSheet("QProgressBar { border: 1px solid #bdc3c7; border-radius: 6px; text-align: center; }"
                               "QProgressBar::chunk { background-color: #27ae60; }");

    topBar->addWidget(cpuStatsRefreshButton);
    topBar->addStretch();
    topBar->addWidget(cpuUsageLabel);
    topBar->addWidget(cpuUsageBar);
    topBar->addWidget(statusLabel);

    // CPU Info Table
    cpuInfoTable = new QTableWidget(this);
    cpuInfoTable->setColumnCount(11);
    cpuInfoTable->setHorizontalHeaderLabels({
        "CPU", "Active", "Current PID", "Current Name", "Current Process", "Current State", "Last PID", "Last State", "Busy %", "Active Ticks", "Timestamp"
    });
    cpuInfoTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    cpuInfoTable->setAlternatingRowColors(true);
    cpuInfoTable->setEditTriggers(QAbstractItemView::NoEditTriggers);
    cpuInfoTable->setSelectionBehavior(QAbstractItemView::SelectRows);

    cpuTimelineTable = new QTableWidget(this);
    cpuTimelineTable->setColumnCount(2);
    cpuTimelineTable->setHorizontalHeaderLabels({"CPU", "Recent Process Timeline"});
    cpuTimelineTable->horizontalHeader()->setSectionResizeMode(0, QHeaderView::ResizeToContents);
    cpuTimelineTable->horizontalHeader()->setSectionResizeMode(1, QHeaderView::Stretch);
    cpuTimelineTable->setAlternatingRowColors(true);
    cpuTimelineTable->setEditTriggers(QAbstractItemView::NoEditTriggers);
    cpuTimelineTable->setSelectionBehavior(QAbstractItemView::SelectRows);

    // Process Stats Table
    procStatsTable = new QTableWidget(this);
    procStatsTable->setColumnCount(13);
    procStatsTable->setHorizontalHeaderLabels({
        "Total Created", "Total Exited", "Total CPU Usage %",
        "Current UNUSED", "Current USED", "Current SLEEPING", "Current RUNNABLE", "Current RUNNING", "Current ZOMBIE",
        "Ever RUNNING", "Ever SLEEPING", "Ever ZOMBIE", "Timestamp"
    });
    procStatsTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    procStatsTable->setAlternatingRowColors(true);
    procStatsTable->setEditTriggers(QAbstractItemView::NoEditTriggers);
    procStatsTable->setSelectionBehavior(QAbstractItemView::SelectRows);

    QLabel *cpuLabel = new QLabel("CPU Information", this);
    cpuLabel->setStyleSheet("font-weight: bold; font-size: 14px;");
    QLabel *timelineLabel = new QLabel("CPU Timeline", this);
    timelineLabel->setStyleSheet("font-weight: bold; font-size: 14px;");
    QLabel *procLabel = new QLabel("Process Statistics", this);
    procLabel->setStyleSheet("font-weight: bold; font-size: 14px;");

    mainLayout->addLayout(topBar);
    mainLayout->addWidget(cpuLabel);
    mainLayout->addWidget(cpuInfoTable, 1);
    mainLayout->addWidget(timelineLabel);
    mainLayout->addWidget(cpuTimelineTable, 1);
    mainLayout->addWidget(procLabel);
    mainLayout->addWidget(procStatsTable, 1);
}

void SchedulerWindow::setupCpuStatsTab() {
    // Not used in simplified version
}

void SchedulerWindow::startQemuAndIngestor() {
    if (qemuProcess->state() != QProcess::NotRunning) {
        updateStatusLabel("QEMU is already running", "#d35400");
        return;
    }

    QString projectRoot = findProjectRoot();
    
    updateStatusLabel("Starting QEMU and ingestor...", "#8e44ad");

    // Start QEMU
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

    // Wait a bit for QEMU to start, then start the ingestor
    QTimer::singleShot(2000, [this]() {
        if (ingestorProcess->state() == QProcess::NotRunning) {
            QString projectRoot = findProjectRoot();
            QString pythonBin = "python3";
            
            ingestorProcess->setWorkingDirectory(projectRoot);
            ingestorProcess->start(pythonBin, QStringList() << "run_cpuinfo_periodic.py");
            
            if (!ingestorProcess->waitForStarted(1000)) {
                updateStatusLabel("Note: ingestor not found or failed to start", "#d35400");
            }
        }
    });
}

void SchedulerWindow::runCpuInfo() {
    // Read the last part of the log to check for new CPU info
    // Then update the display
    loadCpuStats();
}

void SchedulerWindow::loadCpuStats() {
    cpuInfoTable->setRowCount(0);
    procStatsTable->setRowCount(0);

    if (!db.isOpen() && !db.open()) {
        return;
    }

    // Load CPU info - get the latest entry for each CPU
    if (tableExists("cpu_info")) {
        QSqlQuery cpuQuery(db);
        cpuQuery.prepare(R"(
            SELECT cpu, active, current_pid, current_name, current_process, current_state, last_pid, last_state, busy_percent, active_ticks, timeline, timestamp
            FROM cpu_info
            WHERE id IN (
                SELECT MAX(id) FROM cpu_info GROUP BY cpu
            )
            ORDER BY cpu ASC
        )");

        if (cpuQuery.exec()) {
            int row = 0;
            while (cpuQuery.next()) {
                cpuInfoTable->insertRow(row);
                cpuInfoTable->setItem(row, 0, new QTableWidgetItem(QString::number(cpuQuery.value(0).toInt())));
                cpuInfoTable->setItem(row, 1, new QTableWidgetItem(cpuQuery.value(1).toInt() ? "Yes" : "No"));
                cpuInfoTable->setItem(row, 2, new QTableWidgetItem(QString::number(cpuQuery.value(2).toInt())));
                cpuInfoTable->setItem(row, 3, new QTableWidgetItem(cpuQuery.value(3).toString()));
                cpuInfoTable->setItem(row, 4, new QTableWidgetItem(cpuQuery.value(4).toString()));
                cpuInfoTable->setItem(row, 5, new QTableWidgetItem(cpuQuery.value(5).toString()));
                cpuInfoTable->setItem(row, 6, new QTableWidgetItem(QString::number(cpuQuery.value(6).toInt())));
                cpuInfoTable->setItem(row, 7, new QTableWidgetItem(cpuQuery.value(7).toString()));
                cpuInfoTable->setItem(row, 8, new QTableWidgetItem(QString::number(cpuQuery.value(8).toInt()) + "%"));
                cpuInfoTable->setItem(row, 9, new QTableWidgetItem(QString::number(cpuQuery.value(9).toULongLong())));
                cpuInfoTable->setItem(row, 10, new QTableWidgetItem(cpuQuery.value(11).toString()));
                row++;
            }

            cpuTimelineTable->setRowCount(0);
            QSqlQuery timelineQuery(db);
            timelineQuery.prepare(R"(
                SELECT cpu, timeline
                FROM cpu_info
                WHERE id IN (
                    SELECT MAX(id) FROM cpu_info GROUP BY cpu
                )
                ORDER BY cpu ASC
            )");
            if (timelineQuery.exec()) {
                int timelineRow = 0;
                while (timelineQuery.next()) {
                    cpuTimelineTable->insertRow(timelineRow);
                    cpuTimelineTable->setItem(timelineRow, 0, new QTableWidgetItem(QString::number(timelineQuery.value(0).toInt())));
                    cpuTimelineTable->setItem(timelineRow, 1, new QTableWidgetItem(timelineQuery.value(1).toString()));
                    timelineRow++;
                }
            }
        }
    }

    // Load process stats - get the latest entry
    if (tableExists("proc_stats")) {
        QSqlQuery procQuery(db);
        procQuery.prepare(R"(
            SELECT total_created, total_exited, total_cpu_usage,
                   current_unused, current_used, current_sleeping, current_runnable, current_running, current_zombie,
                   ever_running, ever_sleeping, ever_zombie,
                   timestamp
            FROM proc_stats
            ORDER BY id DESC
            LIMIT 1
        )");

        if (procQuery.exec()) {
            int row = 0;
            while (procQuery.next()) {
                procStatsTable->insertRow(row);
                for (int col = 0; col < 13; col++) {
                    if (col < 12) {
                        procStatsTable->setItem(row, col, new QTableWidgetItem(QString::number(procQuery.value(col).toULongLong())));
                    } else {
                        procStatsTable->setItem(row, col, new QTableWidgetItem(procQuery.value(col).toString()));
                    }
                }
                if (!procQuery.value(2).isNull()) {
                    cpuUsageBar->setValue(procQuery.value(2).toInt());
                }
                row++;
            }
        }
    }

    updateStatusLabel("CPU Stats updated", "#27ae60");
}

void SchedulerWindow::onQemuStarted() {
    updateStatusLabel("QEMU running...", "#27ae60");
}

void SchedulerWindow::onQemuFinished(int exitCode, QProcess::ExitStatus exitStatus) {
    Q_UNUSED(exitStatus);
    Q_UNUSED(exitCode);

    updateStatusLabel("QEMU finished", "#2c3e50");
    
    // Stop the ingestor as well
    if (ingestorProcess->state() != QProcess::NotRunning) {
        ingestorProcess->terminate();
        ingestorProcess->waitForFinished(1000);
        if (ingestorProcess->state() != QProcess::NotRunning) {
            ingestorProcess->kill();
        }
    }
}

void SchedulerWindow::onIngestorStarted() {
    updateStatusLabel("QEMU running + Ingestor active", "#27ae60");
}

void SchedulerWindow::onIngestorFinished(int exitCode, QProcess::ExitStatus exitStatus) {
    Q_UNUSED(exitStatus);
    Q_UNUSED(exitCode);
    
    updateStatusLabel("Ingestor finished", "#d35400");
}

bool SchedulerWindow::tableExists(const QString &tableName) {
    if (!db.isOpen() && !db.open()) {
        return false;
    }

    return db.tables().contains(tableName);
}

void SchedulerWindow::showDbError(const QString &context) {
    QMessageBox::warning(this,
                         "Database Error",
                         context + "\n\n" + db.lastError().text());
}

void SchedulerWindow::updateStatusLabel(const QString &text, const QString &color) {
    statusLabel->setText(text);
    statusLabel->setStyleSheet(QString("font-weight: bold; color: %1; padding-left: 8px;").arg(color));
}
