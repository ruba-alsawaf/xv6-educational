#include "bufferCacheWidget.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QTableWidgetItem>
#include <QTimer>
#include <sqlite3.h>

static const char *DB_PATH = "/mnt/c/Users/ASUS/rubaa/events.db";

BufferCacheWidget::BufferCacheWidget(QWidget *parent) : QWidget(parent) {
    // خطوة جوهرية: مسح أحداث الجلسات السابقة عند تشغيل البرنامج
    //clearOldLogs(); 

    setupUI();
    refreshTimer = new QTimer(this);
    connect(refreshTimer, &QTimer::timeout, this, &BufferCacheWidget::refreshUI);
    refreshTimer->start(2000); 

    connect(levelCombo, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &BufferCacheWidget::onLevelChanged);
    connect(bufferTable, &QTableWidget::cellClicked,
            this, &BufferCacheWidget::onBufferClicked);

    refreshUI();
}

// دالة لتنظيف الجدول حتى لا تظهر بيانات قديمة
void BufferCacheWidget::clearOldLogs() {
    sqlite3 *db = nullptr;
    if (sqlite3_open(DB_PATH, &db) == SQLITE_OK) {
        sqlite3_exec(db, "DELETE FROM fs_events;", nullptr, nullptr, nullptr);
        sqlite3_close(db);
    }
}

void BufferCacheWidget::setupUI() {
    QVBoxLayout *mainLayout = new QVBoxLayout(this);
    QHBoxLayout *topBar = new QHBoxLayout();

    levelCombo = new QComboBox(this);
    levelCombo->addItems({"Level 1 - Beginner (مبسط)", "Level 2 - Advanced (متقدم)"});

    pauseButton = new QPushButton("⏸ Pause", this);
    stepButton = new QPushButton("⏭ Next Step", this);
    stepButton->setEnabled(false);
    statsLabel = new QLabel("Stats: Hits=0 | Misses=0", this);

    topBar->addWidget(new QLabel("View level:", this));
    topBar->addWidget(levelCombo);
    topBar->addWidget(pauseButton);
    topBar->addWidget(stepButton);
    topBar->addStretch();
    topBar->addWidget(statsLabel);
    mainLayout->addLayout(topBar);

    connect(pauseButton, &QPushButton::clicked, this, &BufferCacheWidget::togglePause);
    connect(stepButton, &QPushButton::clicked, this, &BufferCacheWidget::refreshUI);

    // الجدول (Buffer Table)
    bufferTable = new QTableWidget(5, 6, this);
    bufferTable->horizontalHeader()->hide();
    bufferTable->verticalHeader()->hide();
    for (int i = 0; i < 6; ++i) bufferTable->setColumnWidth(i, 110);
    for (int i = 0; i < 5; ++i) bufferTable->setRowHeight(i, 80);

    // صندوق الشرح الجانبي
    explanationBox = new QTextEdit(this);
    explanationBox->setReadOnly(true);
    explanationBox->setPlaceholderText("Explanation will appear here...");

    QHBoxLayout *midLayout = new QHBoxLayout();
    midLayout->addWidget(bufferTable, 2);
    midLayout->addWidget(explanationBox, 1);
    mainLayout->addLayout(midLayout);

    // قائمة الأحداث الأخيرة
    eventList = new QListWidget(this);
    mainLayout->addWidget(new QLabel("Recent Events:", this));
    mainLayout->addWidget(eventList);
}

void BufferCacheWidget::refreshUI() {
    loadBufferState();
    loadRecentEvents();
    // تحديث الإحصائيات
    updateStats();
}

void BufferCacheWidget::updateStats() {
    sqlite3 *db = nullptr;
    if (sqlite3_open(DB_PATH, &db) != SQLITE_OK) return;
    
    sqlite3_stmt *stmt;
    const char *sql = "SELECT SUM(CASE WHEN fs_type=3 THEN 1 ELSE 0 END), SUM(CASE WHEN fs_type=4 THEN 1 ELSE 0 END) FROM fs_events";
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) == SQLITE_OK) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            int hits = sqlite3_column_int(stmt, 0);
            int misses = sqlite3_column_int(stmt, 1);
            statsLabel->setText(QString("Stats: Hits=%1 | Misses=%2").arg(hits).arg(misses));
        }
    }
    sqlite3_finalize(stmt);
    sqlite3_close(db);
}

void BufferCacheWidget::loadBufferState() {
    sqlite3 *db = nullptr;
    if (sqlite3_open(DB_PATH, &db) != SQLITE_OK) return;

    const char *sql = "SELECT buf_id, blockno, refcnt, valid, locked FROM buffer_state ORDER BY buf_id ASC";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            int id = sqlite3_column_int(stmt, 0);
            int block = sqlite3_column_int(stmt, 1);
            int ref = sqlite3_column_int(stmt, 2);
            int valid = sqlite3_column_int(stmt, 3);
            int locked = sqlite3_column_int(stmt, 4);

            int row = id / 6;
            int col = id % 6;

            QString text = QString("Buf %1\nBlk %2\n%3").arg(id).arg(block).arg(locked ? "🔒 BUSY" : "🔓 FREE");
            QTableWidgetItem *item = new QTableWidgetItem(text);
            item->setTextAlignment(Qt::AlignCenter);
            
            // تلوين البفر
            if (locked) item->setBackground(QColor(255, 107, 107)); // أحمر
            else if (!valid) item->setBackground(QColor(255, 230, 100)); // أصفر
            else item->setBackground(QColor(220, 221, 225)); // رمادي

            bufferTable->setItem(row, col, item);
        }
    }
    sqlite3_finalize(stmt);
    sqlite3_close(db);
}

void BufferCacheWidget::loadRecentEvents() {
    sqlite3 *db = nullptr;
    if (sqlite3_open(DB_PATH, &db) != SQLITE_OK) return;

    eventList->clear();
    // جلب آخر 15 حدث
    const char *sql = "SELECT seq, fs_type, buf_id, blockno, ref_after, locked_after FROM fs_events ORDER BY seq DESC LIMIT 15";
    sqlite3_stmt *stmt;
    
    bool first = true;
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            int seq = sqlite3_column_int(stmt, 0);
            int type = sqlite3_column_int(stmt, 1);
            int buf = sqlite3_column_int(stmt, 2);
            int blk = sqlite3_column_int(stmt, 3);
            int ref = sqlite3_column_int(stmt, 4);
            int lock = sqlite3_column_int(stmt, 5);

            // تحديث صندوق الشرح بأحدث حدث فقط
            if (first) {
                updateExplanation(type, blk, buf, ref, lock);
                first = false;
            }

            QString line = QString("#%1 %2 | Buf:%3 Blk:%4").arg(seq).arg(eventTypeName(type)).arg(buf).arg(blk);
            eventList->addItem(line);
        }
    }
    sqlite3_finalize(stmt);
    sqlite3_close(db);
}

void BufferCacheWidget::updateExplanation(int type, int block, int buf, int ref, int lock) {
    QString story;
    if (currentLevel == Beginner) {
        switch(type) {
            case 3: story = "✨ **Cache Hit!**\nالبيانات كانت موجودة في الذاكرة مسبقاً، النظام لم يحتاج للذهاب للقرص الصلب."; break;
            case 4: story = "🔍 **Cache Miss!**\nالبيانات غير موجودة، النظام سيقوم الآن بإفراغ مكان لها."; break;
            case 5: story = "📥 **Disk Load**\nيتم الآن نقل البيانات من القرص الصلب إلى البفر."; break;
            case 7: story = "🔓 **Release**\nانتهى العمل، البفر الآن متاح لبقية العمليات."; break;
            default: story = "xv6 is managing buffers..."; break;
        }
    } else {
        story = QString("📝 **Technical Details:**\n- Event: %1\n- Buffer: %2\n- Block: %3\n- Ref Count: %4\n- State: %5")
                .arg(eventTypeName(type)).arg(buf).arg(block).arg(ref).arg(lock ? "Locked" : "Unlocked");
    }
    explanationBox->setMarkdown(story);
}

QString BufferCacheWidget::eventTypeName(int type) const {
    switch(type) {
        case 2: return "SCANNING";
        case 3: return "HIT";
        case 4: return "MISS/RECYCLE";
        case 5: return "FILL_FROM_DISK";
        case 6: return "WRITE_TO_DISK";
        case 7: return "RELEASE";
        default: return "EVENT";
    }
}

void BufferCacheWidget::togglePause() {
    if (refreshTimer->isActive()) {
        refreshTimer->stop();
        pauseButton->setText("▶ Resume");
        stepButton->setEnabled(true);
    } else {
        refreshTimer->start();
        pauseButton->setText("⏸ Pause");
        stepButton->setEnabled(false);
    }
}

void BufferCacheWidget::onLevelChanged(int index) {
    currentLevel = static_cast<Level>(index);
    refreshTimer->setInterval(currentLevel == Beginner ? 2500 : 800);
    refreshUI();
}


void BufferCacheWidget::onBufferClicked(int row, int col) {
    QTableWidgetItem *item = bufferTable->item(row, col);
    if (!item) return;
    selectedBufId = item->data(Qt::UserRole).toInt();
    refreshUI();
}
