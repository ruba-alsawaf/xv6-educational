
#include "CoreEngineWindow.h"
#include <QHeaderView>
#include <QSqlDatabase>
#include <QSqlRecord>
#include <QLineEdit>
#include <QPushButton>
#include <QFrame>
#include <QMap>

CoreEngineWindow::CoreEngineWindow(QWidget *parent) : QMainWindow(parent) {
    setStyleSheet("QMainWindow { background-color: #0d1117; }");
    setupUi();

    updateTimer = new QTimer(this);
    connect(updateTimer, &QTimer::timeout, this, &CoreEngineWindow::refreshData);
    updateTimer->start(1000);
}

void CoreEngineWindow::setupUi() {
    auto *centralWidget = new QWidget(this);
    auto *mainLayout = new QVBoxLayout(centralWidget);
    mainLayout->setContentsMargins(16, 16, 16, 16);
    mainLayout->setSpacing(16);

    auto *title = new QLabel("FILE SYSTEM CORE ENGINE");
    title->setStyleSheet("color: #c9d1d9; font-size: 24px; font-weight: bold;");
    mainLayout->addWidget(title);

    auto *dashboardLayout = new QGridLayout();
    dashboardLayout->setSpacing(12);
    dashboardLayout->setColumnStretch(0, 1);
    dashboardLayout->setColumnStretch(1, 1);
    dashboardLayout->setColumnStretch(2, 1);
    dashboardLayout->setColumnStretch(3, 1);
    setupDashboard(dashboardLayout);
    mainLayout->addLayout(dashboardLayout);

    auto *contentLayout = new QHBoxLayout();
    contentLayout->setSpacing(12);
    contentLayout->setStretch(0, 3);
    contentLayout->setStretch(1, 1);

    auto *leftPanel = new QVBoxLayout();
    leftPanel->setSpacing(12);
    setupVisualizer(leftPanel);
    setupTimeline(leftPanel);
    setupRecentEvents(leftPanel);

    auto *rightPanel = new QVBoxLayout();
    rightPanel->setSpacing(12);
    setupInspector(rightPanel);

    contentLayout->addLayout(leftPanel, 3);
    contentLayout->addLayout(rightPanel, 1);
    mainLayout->addLayout(contentLayout);

    setCentralWidget(centralWidget);
}

static QString cardStyleSheet() {
    return "QFrame { background-color: #161b22; border: 1px solid #30363d; border-radius: 14px; }"
           "QLabel { color: #c9d1d9; }";
}

static QLabel *createCardTitle(const QString &text) {
    auto *label = new QLabel(text);
    label->setStyleSheet("color: #8b949e; font-weight: 700; font-size: 12px;");
    return label;
}

static QLabel *createCardValue(const QString &text, const QString &color = "#c9d1d9") {
    auto *label = new QLabel(text);
    label->setStyleSheet(QString("font-size: 22px; font-weight: 700; color: %1;").arg(color));
    return label;
}

void CoreEngineWindow::setupDashboard(QGridLayout *layout) {
    auto *bufferCard = new QFrame();
    bufferCard->setStyleSheet(cardStyleSheet());
    auto *bufferLayout = new QVBoxLayout(bufferCard);
    bufferLayout->setSpacing(6);
    bufferLayout->addWidget(createCardTitle("BUFFER CACHE"));
    lblTotalBuffers = createCardValue("0", "#58a6ff");
    lblBusyBuffers = new QLabel("Busy: 0");
    lblFreeBuffers = new QLabel("Free: 0");
    lblUsagePercent = createCardValue("0%", "#6f42c1");
    usageBar = new QProgressBar();
    usageBar->setTextVisible(false);
    usageBar->setRange(0, 100);
    usageBar->setFixedHeight(10);
    usageBar->setStyleSheet("QProgressBar { background-color: #0b1117; border: 1px solid #30363d; border-radius: 5px; }"
                            "QProgressBar::chunk { background-color: #238636; border-radius: 5px; }");
    bufferLayout->addWidget(lblTotalBuffers);
    bufferLayout->addWidget(lblBusyBuffers);
    bufferLayout->addWidget(lblFreeBuffers);
    bufferLayout->addWidget(lblUsagePercent);
    bufferLayout->addWidget(usageBar);
    layout->addWidget(bufferCard, 0, 0);

    auto *hitCard = new QFrame();
    hitCard->setStyleSheet(cardStyleSheet());
    auto *hitLayout = new QVBoxLayout(hitCard);
    hitLayout->setSpacing(6);
    hitLayout->addWidget(createCardTitle("HIT RATE"));
    lblHitRate = createCardValue("0%", "#58a6ff");
    lblHits = new QLabel("Hits: 0");
    lblMisses = new QLabel("Misses: 0");
    hitLayout->addWidget(lblHitRate);
    hitLayout->addWidget(lblHits);
    hitLayout->addWidget(lblMisses);
    layout->addWidget(hitCard, 0, 1);

    auto *inodeCard = new QFrame();
    inodeCard->setStyleSheet(cardStyleSheet());
    auto *inodeLayout = new QVBoxLayout(inodeCard);
    inodeLayout->setSpacing(6);
    inodeLayout->addWidget(createCardTitle("INODES"));
    lblActiveInodes = createCardValue("0", "#58a6ff");
    lblUsedInodes = new QLabel("Used: 0");
    lblFreeInodes = new QLabel("Free: 0");
    lblLockedInodes = new QLabel("Locked: 0");
    inodeLayout->addWidget(lblActiveInodes);
    inodeLayout->addWidget(lblUsedInodes);
    inodeLayout->addWidget(lblFreeInodes);
    inodeLayout->addWidget(lblLockedInodes);
    layout->addWidget(inodeCard, 0, 2);

    auto *logCard = new QFrame();
    logCard->setStyleSheet(cardStyleSheet());
    auto *logLayout = new QVBoxLayout(logCard);
    logLayout->setSpacing(6);
    logLayout->addWidget(createCardTitle("LOG STATUS"));
    lblLogStatus = createCardValue("IDLE", "#8b949e");
    lblLogN = new QLabel("Log n: 0");
    lblOutstanding = new QLabel("Outstanding: 0");
    lblCommitting = new QLabel("Committing: 0");
    logLayout->addWidget(lblLogStatus);
    logLayout->addWidget(lblLogN);
    logLayout->addWidget(lblOutstanding);
    logLayout->addWidget(lblCommitting);
    layout->addWidget(logCard, 0, 3);
}

void CoreEngineWindow::setupVisualizer(QVBoxLayout *layout) {
    auto *container = new QFrame();
    container->setStyleSheet(cardStyleSheet());
    auto *containerLayout = new QVBoxLayout(container);
    containerLayout->setSpacing(10);
    auto *title = new QLabel("BUFFER CACHE VISUALIZER");
    title->setStyleSheet("color: #8b949e; font-weight: 700; font-size: 12px;");
    containerLayout->addWidget(title);

    auto *gridFrame = new QFrame();
    gridFrame->setStyleSheet("background-color: #0d1117; border-radius: 12px;");
    auto *grid = new QGridLayout(gridFrame);
    grid->setSpacing(8);
    for(int i = 0; i < 30; ++i) {
        auto *bufLab = new QLabel(QString("Buf %1").arg(i));
        bufLab->setFixedSize(74, 52);
        bufLab->setAlignment(Qt::AlignCenter);
        bufLab->setObjectName(QString("buf_%1").arg(i));
        bufLab->setStyleSheet("background-color: #161b22; border-radius: 8px; color: #8b949e;");
        grid->addWidget(bufLab, i / 6, i % 6);
    }
    containerLayout->addWidget(gridFrame);
    layout->addWidget(container);
}

void CoreEngineWindow::setupTimeline(QBoxLayout *layout) {
    auto *container = new QFrame();
    container->setStyleSheet(cardStyleSheet());
    auto *containerLayout = new QVBoxLayout(container);
    containerLayout->setSpacing(10);
    auto *title = new QLabel("FILE SYSTEM EVENT TIMELINE");
    title->setStyleSheet("color: #8b949e; font-weight: 700; font-size: 12px;");
    containerLayout->addWidget(title);

    auto *filterLayout = new QHBoxLayout();
    auto *pidLabel = new QLabel("PID:");
    pidLabel->setStyleSheet("color: #c9d1d9; font-weight: 600;");
    timelinePidInput = new QLineEdit();
    timelinePidInput->setPlaceholderText("Filter by PID (optional)");
    timelinePidInput->setFixedWidth(140);
    timelinePidInput->setStyleSheet("background-color: #0d1117; border: 1px solid #30363d; border-radius: 6px; color: #c9d1d9; padding: 4px;");
    timelineRefreshButton = new QPushButton("Refresh");
    timelineRefreshButton->setStyleSheet("QPushButton { background-color: #238636; color: white; border-radius: 6px; padding: 6px 12px; }"
                                        "QPushButton:hover { background-color: #2ea043; }");
    filterLayout->addWidget(pidLabel);
    filterLayout->addWidget(timelinePidInput);
    filterLayout->addWidget(timelineRefreshButton);
    filterLayout->addStretch();
    containerLayout->addLayout(filterLayout);

    timelineScrollArea = new QScrollArea();
    timelineScrollArea->setWidgetResizable(true);
    timelineScrollArea->setStyleSheet("QScrollArea { background-color: transparent; border: none; }\n"
                                     "QScrollBar:vertical, QScrollBar:horizontal { background: #0d1117; }");
    timelineContent = new QWidget();
    timelineContentLayout = new QVBoxLayout(timelineContent);
    timelineContentLayout->setSpacing(14);
    timelineContentLayout->setContentsMargins(0, 0, 0, 0);
    timelineScrollArea->setWidget(timelineContent);
    containerLayout->addWidget(timelineScrollArea, 1);

    connect(timelineRefreshButton, &QPushButton::clicked, this, &CoreEngineWindow::refreshTimeline);
    connect(timelinePidInput, &QLineEdit::returnPressed, this, &CoreEngineWindow::refreshTimeline);

    layout->addWidget(container, 2);
}

void CoreEngineWindow::setupRecentEvents(QBoxLayout *layout) {
    auto *container = new QFrame();
    container->setStyleSheet(cardStyleSheet());
    auto *containerLayout = new QVBoxLayout(container);
    containerLayout->setSpacing(10);
    auto *title = new QLabel("RECENT EVENTS LOG");
    title->setStyleSheet("color: #8b949e; font-weight: 700; font-size: 12px;");
    containerLayout->addWidget(title);

    recentEventsTable = new QTableWidget(0, 4);
    recentEventsTable->setHorizontalHeaderLabels({"Layer", "Tick", "PID", "Details"});
    recentEventsTable->setStyleSheet(
        "QTableWidget { background-color: #0d1117; color: #c9d1d9; gridline-color: #30363d; }"
        "QHeaderView::section { background-color: #161b22; color: #c9d1d9; }");
    recentEventsTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    containerLayout->addWidget(recentEventsTable);

    layout->addWidget(container, 1);
}

void CoreEngineWindow::setupInspector(QVBoxLayout *layout) {
    auto *container = new QFrame();
    container->setStyleSheet(cardStyleSheet());
    container->setMinimumWidth(320);
    auto *containerLayout = new QVBoxLayout(container);
    containerLayout->setSpacing(10);
    auto *title = new QLabel("TECHNICAL INSPECTOR");
    title->setStyleSheet("color: #8b949e; font-weight: 700; font-size: 12px;");
    containerLayout->addWidget(title);

    lblInspectorHeader = new QLabel("Select a timeline event to inspect details.");
    lblInspectorHeader->setWordWrap(true);
    lblInspectorHeader->setStyleSheet("color: #c9d1d9; font-size: 13px; margin-bottom: 4px;");
    containerLayout->addWidget(lblInspectorHeader);

    inspectorDetails = new QTextEdit();
    inspectorDetails->setReadOnly(true);
    inspectorDetails->setStyleSheet("QTextEdit { background-color: #0d1117; border: 1px solid #30363d; color: #c9d1d9; }"
                                   "QScrollBar:vertical { background: #0d1117; }");
    inspectorDetails->setMinimumHeight(420);
    containerLayout->addWidget(inspectorDetails);

    layout->addWidget(container);
}

void CoreEngineWindow::showInspectorForEventId(int eventId) {
    if (!QSqlDatabase::database().isOpen()) {
        return;
    }

    QSqlQuery query;
    query.prepare("SELECT layer, tick, pid, op_name, details, buf_id, blockno, ref, old_ref, valid, old_valid, log_n, outstanding, committing, inum, inode_type, inode_size, locked, parent_inum, target_inum, offset, elem, path, file_ref, old_file_ref, file_off, old_file_off, readable, writable FROM fs_events WHERE id = ?");
    query.addBindValue(eventId);
    if (!query.exec() || !query.next()) {
        return;
    }

    QString details;
    auto record = query.record();
    auto fieldValue = [&](const char *name) -> QVariant {
        int idx = record.indexOf(name);
        return idx >= 0 ? query.value(idx) : QVariant();
    };

    details += QString("Event ID: %1\n").arg(eventId);
    details += QString("Layer: %1\n").arg(fieldValue("layer").toString());
    details += QString("Operation: %1\n").arg(fieldValue("op_name").toString());
    details += QString("Tick: %1\n").arg(fieldValue("tick").toString());
    details += QString("PID: %1\n\n").arg(fieldValue("pid").toString());

    auto appendField = [&](const char *name, const QString &label) {
        QVariant v = fieldValue(name);
        if (!v.isNull() && !v.toString().isEmpty()) {
            details += QString("%1: %2\n").arg(label, v.toString());
        }
    };

    appendField("details", "Description");
    appendField("buf_id", "Buffer ID");
    appendField("blockno", "Block");
    appendField("ref", "Ref");
    appendField("old_ref", "Old Ref");
    appendField("valid", "Valid");
    appendField("old_valid", "Old Valid");
    appendField("log_n", "Log n");
    appendField("outstanding", "Outstanding");
    appendField("committing", "Committing");
    appendField("inum", "Inode");
    appendField("inode_type", "Inode Type");
    appendField("inode_size", "Inode Size");
    appendField("locked", "Locked");
    appendField("parent_inum", "Parent Inode");
    appendField("target_inum", "Target Inode");
    appendField("offset", "Offset");
    appendField("elem", "Element");
    appendField("path", "Path");
    appendField("file_ref", "File Ref");
    appendField("old_file_ref", "Old File Ref");
    appendField("file_off", "File Offset");
    appendField("old_file_off", "Old File Offset");
    appendField("readable", "Readable");
    appendField("writable", "Writable");

    lblInspectorHeader->setText(QString("Selected event: %1 @ PID %2").arg(fieldValue("op_name").toString(), fieldValue("pid").toString()));
    inspectorDetails->setPlainText(details);
}

void CoreEngineWindow::refreshData() {
    if (!QSqlDatabase::database().isOpen()) {
        return;
    }

    QSqlQuery query;

    if (query.exec("SELECT COUNT(*) AS total_buffers FROM buffer_cache_state")) {
        if (query.next()) {
            lblTotalBuffers->setText(QString::number(query.value(0).toInt()));
        }
    }

    if (query.exec("SELECT COUNT(*) AS busy_buffers FROM buffer_cache_state WHERE refcnt > 0")) {
        if (query.next()) {
            lblBusyBuffers->setText(QString("Busy: %1").arg(query.value(0).toInt()));
        }
    }

    if (query.exec("SELECT COUNT(*) AS free_buffers FROM buffer_cache_state WHERE refcnt = 0")) {
        if (query.next()) {
            lblFreeBuffers->setText(QString("Free: %1").arg(query.value(0).toInt()));
        }
    }

    if (query.exec("SELECT ROUND((CAST(SUM(CASE WHEN refcnt > 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100, 2) AS usage_percent FROM buffer_cache_state")) {
        if (query.next()) {
            double percent = query.value(0).toDouble();
            lblUsagePercent->setText(QString("%1%").arg(QString::number(percent, 'f', 2)));
            usageBar->setValue(int(percent));
        }
    }

    if (query.exec("SELECT COUNT(*) AS hits FROM fs_events WHERE layer='BCACHE' AND op_name='BGET_HIT'")) {
        if (query.next()) {
            lblHits->setText(QString("Hits: %1").arg(query.value(0).toInt()));
        }
    }

    if (query.exec("SELECT COUNT(*) AS misses FROM fs_events WHERE layer='BCACHE' AND op_name='BGET_MISS'")) {
        if (query.next()) {
            lblMisses->setText(QString("Misses: %1").arg(query.value(0).toInt()));
        }
    }

    if (query.exec("SELECT ROUND((CAST(SUM(CASE WHEN op_name='BGET_HIT' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100, 2) AS hit_rate FROM fs_events WHERE layer='BCACHE' AND op_name IN ('BGET_HIT', 'BGET_MISS')")) {
        if (query.next()) {
            lblHitRate->setText(QString("%1%").arg(QString::number(query.value(0).toDouble(), 'f', 2)));
        }
    }

    if (query.exec("SELECT COUNT(*) AS total_inodes FROM inode_state")) {
        if (query.next()) {
            lblActiveInodes->setText(QString::number(query.value(0).toInt()));
        }
    }

    if (query.exec("SELECT COUNT(*) AS used_inodes FROM inode_state WHERE refcnt > 0")) {
        if (query.next()) {
            lblUsedInodes->setText(QString("Used: %1").arg(query.value(0).toInt()));
        }
    }

    if (query.exec("SELECT COUNT(*) AS free_inodes FROM inode_state WHERE refcnt = 0")) {
        if (query.next()) {
            lblFreeInodes->setText(QString("Free: %1").arg(query.value(0).toInt()));
        }
    }

    if (query.exec("SELECT COUNT(*) AS locked_inodes FROM inode_state WHERE is_locked = 1")) {
        if (query.next()) {
            lblLockedInodes->setText(QString("Locked: %1").arg(query.value(0).toInt()));
        }
    }

    if (query.exec("SELECT log_n, outstanding, committing FROM log_state WHERE id = 1")) {
        if (query.next()) {
            int n = query.value(0).toInt();
            int outstanding = query.value(1).toInt();
            int committing = query.value(2).toInt();
            lblLogN->setText(QString("Log n: %1").arg(n));
            lblOutstanding->setText(QString("Outstanding: %1").arg(outstanding));
            lblCommitting->setText(QString("Committing: %1").arg(committing));
            if (committing > 0) {
                lblLogStatus->setText("ACTIVE");
                lblLogStatus->setStyleSheet("font-size: 22px; font-weight: 700; color: #58a6ff;");
            } else if (outstanding > 0) {
                lblLogStatus->setText("PENDING");
                lblLogStatus->setStyleSheet("font-size: 22px; font-weight: 700; color: #d29922;");
            } else {
                lblLogStatus->setText("IDLE");
                lblLogStatus->setStyleSheet("font-size: 22px; font-weight: 700; color: #8b949e;");
            }
        }
    }

    if (query.exec("SELECT buf_id, blockno, refcnt, is_valid FROM buffer_cache_state ORDER BY buf_id")) {
        while (query.next()) {
            int id = query.value(0).toInt();
            int ref = query.value(2).toInt();
            int valid = query.value(3).toInt();
            QLabel *lab = findChild<QLabel *>(QString("buf_%1").arg(id));
            if (lab) {
                if (ref > 0) {
                    lab->setStyleSheet("background-color: #238636; border-radius: 8px; color: white;");
                } else if (valid) {
                    lab->setStyleSheet("background-color: #1f6feb; border-radius: 8px; color: white;");
                } else {
                    lab->setStyleSheet("background-color: #161b22; border-radius: 8px; color: #8b949e;");
                }
            }
        }
    }

    refreshTimeline();

    if (query.exec("SELECT f1.layer, f1.tick, f1.pid, f1.details FROM fs_events f1 INNER JOIN (SELECT layer, MAX(id) AS max_id FROM fs_events GROUP BY layer) f2 ON f1.id = f2.max_id ORDER BY f1.id DESC")) {
        recentEventsTable->setRowCount(0);
        while (query.next()) {
            int row = recentEventsTable->rowCount();
            recentEventsTable->insertRow(row);
            recentEventsTable->setItem(row, 0, new QTableWidgetItem(query.value(0).toString()));
            recentEventsTable->setItem(row, 1, new QTableWidgetItem(query.value(1).toString()));
            recentEventsTable->setItem(row, 2, new QTableWidgetItem(query.value(2).toString()));
            recentEventsTable->setItem(row, 3, new QTableWidgetItem(query.value(3).toString()));
        }
    }
}

static QString timelineEventColor(const QString &layer) {
    if (layer == "BCACHE") {
        return "#238636";
    }
    if (layer == "LOG") {
        return "#1f6feb";
    }
    if (layer == "INODE") {
        return "#bf5af2";
    }
    if (layer == "FS") {
        return "#d29922";
    }
    return "#57606a";
}

void CoreEngineWindow::refreshTimeline() {
    if (!QSqlDatabase::database().isOpen()) {
        return;
    }

    while (QLayoutItem *item = timelineContentLayout->takeAt(0)) {
        if (auto *widget = item->widget()) {
            widget->deleteLater();
        }
        delete item;
    }

    QString pidStr = timelinePidInput->text().trimmed();
    bool hasFilter = !pidStr.isEmpty();
    int filterPid = -1;
    if (hasFilter) {
        bool ok = false;
        filterPid = pidStr.toInt(&ok);
        if (!ok) {
            auto *errorLabel = new QLabel("Invalid PID filter. Enter a numeric PID.");
            errorLabel->setStyleSheet("color: #f85149; font-size: 13px;");
            timelineContentLayout->addWidget(errorLabel);
            return;
        }
    }

    QSqlQuery query;
    if (!query.exec("SELECT id, tick, pid, layer, op_name FROM fs_events ORDER BY pid ASC, tick ASC")) {
        return;
    }

    struct Event {
        int id;
        int tick;
        int pid;
        QString layer;
        QString op_name;
    };

    QMap<int, QList<Event>> pidEvents;
    int minTick = INT_MAX;
    int maxTick = INT_MIN;

    while (query.next()) {
        Event e;
        e.id = query.value(0).toInt();
        e.tick = query.value(1).toInt();
        e.pid = query.value(2).toInt();
        e.layer = query.value(3).toString();
        e.op_name = query.value(4).toString();

        if (hasFilter && e.pid != filterPid) {
            continue;
        }

        pidEvents[e.pid].append(e);
        minTick = qMin(minTick, e.tick);
        maxTick = qMax(maxTick, e.tick);
    }

    if (pidEvents.isEmpty()) {
        auto *msg = new QLabel(hasFilter ? "No timeline events for the requested PID." : "No timeline events available.");
        msg->setStyleSheet("color: #8b949e; font-size: 13px;");
        timelineContentLayout->addWidget(msg);
        return;
    }

    int totalTicks = qMax(1, maxTick - minTick + 1);
    int widthPerTick = qMax(12, qMin(32, 720 / totalTicks));

    for (auto it = pidEvents.constBegin(); it != pidEvents.constEnd(); ++it) {
        const int pid = it.key();
        const auto events = it.value();
        if (events.isEmpty()) {
            continue;
        }

        auto *rowFrame = new QFrame();
        rowFrame->setStyleSheet("background-color: #0d1117; border: 1px solid #21262d; border-radius: 12px;");
        auto *rowLayout = new QHBoxLayout(rowFrame);
        rowLayout->setContentsMargins(12, 8, 12, 8);
        rowLayout->setSpacing(10);

        auto *pidLabel = new QLabel(QString("PID %1").arg(pid));
        pidLabel->setFixedWidth(68);
        pidLabel->setStyleSheet("color: #8b949e; font-weight: 700;");
        rowLayout->addWidget(pidLabel);

        auto *barRow = new QWidget();
        auto *barLayout = new QHBoxLayout(barRow);
        barLayout->setContentsMargins(0, 0, 0, 0);
        barLayout->setSpacing(6);

        int lastTick = minTick;
        for (const Event &event : events) {
            int duration = qMax(1, event.tick - lastTick + 1);
            int width = qMax(50, duration * widthPerTick);
            auto *segment = new QPushButton(event.op_name);
            segment->setProperty("eventId", event.id);
            segment->setStyleSheet(QString(
                "QPushButton { background-color: %1; color: white; border: none; border-radius: 8px; padding: 6px 10px; min-width: %2px; }"
                "QPushButton:hover { background-color: #58a6ff; }"
            ).arg(timelineEventColor(event.layer)).arg(width));
            connect(segment, &QPushButton::clicked, this, [this, segment]() {
                bool ok = false;
                int eventId = segment->property("eventId").toInt(&ok);
                if (ok) {
                    showInspectorForEventId(eventId);
                }
            });
            barLayout->addWidget(segment);
            lastTick = event.tick + 1;
        }

        rowLayout->addWidget(barRow, 1);
        timelineContentLayout->addWidget(rowFrame);
    }

    timelineContentLayout->addStretch();
}