#include "bufferCacheWidget_new.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QTableWidgetItem>
#include <QSlider>
#include <QScrollBar>
#include <QDateTime>
#include <QMessageBox>
#include <QDebug>

static const char *DB_PATH = "/mnt/c/Users/ASUS/rubaa/events.db";

BufferCacheWidget::BufferCacheWidget(QWidget *parent)
    : QWidget(parent) {
    setWindowTitle("Buffer Cache Analyzer - خلل نظام المخزن المؤقت");
    setMinimumSize(1400, 900);

    // فتح قاعدة البيانات
    if (sqlite3_open(DB_PATH, &db) != SQLITE_OK) {
        QMessageBox::critical(this, "خطأ", QString("فشل فتح قاعدة البيانات: %1").arg(DB_PATH));
        return;
    }

    setupUI();
    connectSignals();
    loadAllEventsFromDB();

    // إعداد الـ Auto-Play Timer
    autoPlayTimer = new QTimer(this);
    connect(autoPlayTimer, &QTimer::timeout, this, &BufferCacheWidget::onAutoPlayTimeout);
}

BufferCacheWidget::~BufferCacheWidget() {
    if (db) {
        sqlite3_close(db);
    }
}

void BufferCacheWidget::setupUI() {
    QVBoxLayout *mainLayout = new QVBoxLayout(this);

    // ====== الصف العلوي: التحكم والإحصائيات ======
    QHBoxLayout *topBarLayout = new QHBoxLayout();

    nextButton = new QPushButton("⏭ الخطوة التالية", this);
    prevButton = new QPushButton("⏮ الخطوة السابقة", this);
    playButton = new QPushButton("▶ تشغيل تلقائي", this);
    stopButton = new QPushButton("⏹ إيقاف", this);
    stopButton->setEnabled(false);
    resetButton = new QPushButton("↻ إعادة تعيين", this);

    QLabel *speedTextLabel = new QLabel("السرعة:", this);
    speedSlider = new QSlider(Qt::Horizontal, this);
    speedSlider->setMinimum(500);
    speedSlider->setMaximum(5000);
    speedSlider->setValue(2000);
    speedSlider->setMaximumWidth(150);

    speedLabel = new QLabel("2.0x", this);
    speedLabel->setMaximumWidth(40);

    statsLabel = new QLabel("الإحصائيات: ...", this);

    currentEventLabel = new QLabel("انتظر، جاري تحميل البيانات...", this);
    currentEventLabel->setStyleSheet("font-size: 14px; font-weight: bold; color: #2196F3;");

    topBarLayout->addWidget(nextButton);
    topBarLayout->addWidget(prevButton);
    topBarLayout->addWidget(playButton);
    topBarLayout->addWidget(stopButton);
    topBarLayout->addWidget(resetButton);
    topBarLayout->addSpacing(20);
    topBarLayout->addWidget(speedTextLabel);
    topBarLayout->addWidget(speedSlider);
    topBarLayout->addWidget(speedLabel);
    topBarLayout->addStretch();
    topBarLayout->addWidget(statsLabel);

    mainLayout->addLayout(topBarLayout);

    // ====== عنوان الحدث الحالي ======
    mainLayout->addWidget(currentEventLabel);

    // ====== المنطقة الرئيسية: جداول البفرات والشروحات ======
    mainSplitter = new QSplitter(Qt::Horizontal, this);

    // الجزء الأيسر: جداول البفرات
    QWidget *leftWidget = new QWidget(this);
    QVBoxLayout *leftLayout = new QVBoxLayout(leftWidget);

    QLabel *beforeLabel = new QLabel("حالة البفرات قبل الحدث:", this);
    beforeLabel->setStyleSheet("font-weight: bold; font-size: 12px; color: #555;");
    bufferTableBefore = new QTableWidget(6, 5, this);
    bufferTableBefore->horizontalHeader()->hide();
    bufferTableBefore->verticalHeader()->hide();
    for (int i = 0; i < 5; ++i) bufferTableBefore->setColumnWidth(i, 130);
    for (int i = 0; i < 6; ++i) bufferTableBefore->setRowHeight(i, 80);
    bufferTableBefore->setMaximumHeight(500);

    QLabel *afterLabel = new QLabel("حالة البفرات بعد الحدث:", this);
    afterLabel->setStyleSheet("font-weight: bold; font-size: 12px; color: #555;");
    bufferTableAfter = new QTableWidget(6, 5, this);
    bufferTableAfter->horizontalHeader()->hide();
    bufferTableAfter->verticalHeader()->hide();
    for (int i = 0; i < 5; ++i) bufferTableAfter->setColumnWidth(i, 130);
    for (int i = 0; i < 6; ++i) bufferTableAfter->setRowHeight(i, 80);
    bufferTableAfter->setMaximumHeight(500);

    leftLayout->addWidget(beforeLabel);
    leftLayout->addWidget(bufferTableBefore);
    leftLayout->addWidget(afterLabel);
    leftLayout->addWidget(bufferTableAfter);
    leftLayout->addStretch();

    // الجزء الأيمن: الشروحات
    QWidget *rightWidget = new QWidget(this);
    QVBoxLayout *rightLayout = new QVBoxLayout(rightWidget);

    QLabel *explanationTitle = new QLabel("شرح مفصل للحدث الحالي:", this);
    explanationTitle->setStyleSheet("font-weight: bold; font-size: 12px; color: #555;");
    detailedExplanation = new QTextEdit(this);
    detailedExplanation->setReadOnly(true);
    detailedExplanation->setStyleSheet("QTextEdit { padding: 10px; line-height: 1.6; }");

    QLabel *changesTitle = new QLabel("التغييرات في الحالة:", this);
    changesTitle->setStyleSheet("font-weight: bold; font-size: 12px; color: #555;");
    stateChangesExplanation = new QTextEdit(this);
    stateChangesExplanation->setReadOnly(true);
    stateChangesExplanation->setStyleSheet("QTextEdit { padding: 10px; line-height: 1.6; background-color: #f5f5f5; }");

    rightLayout->addWidget(explanationTitle);
    rightLayout->addWidget(detailedExplanation, 1);
    rightLayout->addWidget(changesTitle);
    rightLayout->addWidget(stateChangesExplanation, 1);

    mainSplitter->addWidget(leftWidget);
    mainSplitter->addWidget(rightWidget);
    mainSplitter->setStretchFactor(0, 1);
    mainSplitter->setStretchFactor(1, 1);

    mainLayout->addWidget(mainSplitter, 1);

    // ====== الجزء السفلي: سجل الأحداث ======
    QLabel *historyLabel = new QLabel("سجل الأحداث (اضغط على أي حدث للذهاب إليه):", this);
    historyLabel->setStyleSheet("font-weight: bold; font-size: 11px; color: #666;");

    eventHistoryList = new QListWidget(this);
    eventHistoryList->setMaximumHeight(150);

    QWidget *bottomWidget = new QWidget(this);
    QVBoxLayout *bottomLayout = new QVBoxLayout(bottomWidget);
    bottomLayout->addWidget(historyLabel);
    bottomLayout->addWidget(eventHistoryList);
    bottomLayout->setContentsMargins(0, 0, 0, 0);

    mainLayout->addWidget(bottomWidget);

    // ====== الألوان والأنماط ======
    setStyleSheet(R"(
        QPushButton {
            padding: 6px 12px;
            font-size: 11px;
            border-radius: 4px;
            border: 1px solid #ddd;
            background-color: #f0f0f0;
        }
        QPushButton:hover {
            background-color: #e0e0e0;
        }
        QPushButton:pressed {
            background-color: #2196F3;
            color: white;
        }
        QLabel {
            color: #333;
        }
        QTextEdit {
            font-family: 'Segoe UI', Arial;
            font-size: 10px;
        }
    )");
}

void BufferCacheWidget::connectSignals() {
    connect(nextButton, &QPushButton::clicked, this, &BufferCacheWidget::onNextStepClicked);
    connect(prevButton, &QPushButton::clicked, this, &BufferCacheWidget::onPreviousStepClicked);
    connect(playButton, &QPushButton::clicked, this, &BufferCacheWidget::onPlayClicked);
    connect(stopButton, &QPushButton::clicked, this, &BufferCacheWidget::onStopClicked);
    connect(resetButton, &QPushButton::clicked, this, &BufferCacheWidget::onResetClicked);
    connect(speedSlider, &QSlider::valueChanged, this, &BufferCacheWidget::onSpeedChanged);
    connect(eventHistoryList, &QListWidget::itemClicked, this, &BufferCacheWidget::onEventListItemClicked);
    connect(bufferTableBefore, &QTableWidget::cellClicked, this, &BufferCacheWidget::onBufferTableClicked);
    connect(bufferTableAfter, &QTableWidget::cellClicked, this, &BufferCacheWidget::onBufferTableClicked);
}

void BufferCacheWidget::loadAllEventsFromDB() {
    if (!db) return;

    events.clear();
    eventHistoryList->clear();

    // استعلام مرن يجلب أي حدث يخص البفر كاش (Buffer Cache)
    const char *sql = R"(
        SELECT seq, tick, fs_type, pid, dev, blockno, old_blockno, buf_id,
               ref_before, ref_after, valid_before, valid_after,
               locked_before, locked_after, lru_before, lru_after,
               name, op_name
        FROM fs_events
        WHERE buf_id >= 0 OR fs_type > 0
        ORDER BY seq ASC
    )";

    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        qWarning() << "SQL Error:" << sqlite3_errmsg(db);
        return;
    }

    while (sqlite3_step(stmt) == SQLITE_ROW) {
        DetailedEvent event;
        event.seq = sqlite3_column_int64(stmt, 0);
        // ... (بقية الأسطر كما هي في كودكِ)
        event.op_name = QString::fromUtf8((const char *)sqlite3_column_text(stmt, 17));

        events.append(event);

        // إضافة نص توضيحي للقائمة السفلية
        QString listItem = QString("#%1 | %2 | Block: %3")
            .arg(event.seq)
            .arg(event.op_name)
            .arg(event.blockno);
        eventHistoryList->addItem(listItem);
    }
    sqlite3_finalize(stmt);

    // التحقق النهائي
    if (events.isEmpty()) {
        currentEventLabel->setText("❌ لا تزال قاعدة البيانات لا تطابق الشروط");
    } else {
        currentEventIndex = 0;
        displayCurrentEvent();
        updateStatistics();
    }
}
void BufferCacheWidget::displayCurrentEvent() {
    if (currentEventIndex < 0 || currentEventIndex >= events.size()) {
        detailedExplanation->setText("لا يوجد حدث لعرضه");
        return;
    }

    const DetailedEvent &event = events[currentEventIndex];

    // تحديث عنوان الحدث
    QString title = QString("الحدث #%1: %2 (%3 ticks)")
        .arg(event.seq)
        .arg(event.op_name)
        .arg(event.tick);
    currentEventLabel->setText(title);

    // تحديث جداول البفرات
    QMap<int, BufferState> statesBefore = getBufferStatesAtSequence(event.seq - 1);
    QMap<int, BufferState> statesAfter = getBufferStatesAtSequence(event.seq);

    displayBufferState(bufferTableBefore, statesBefore, "قبل");
    displayBufferState(bufferTableAfter, statesAfter, "بعد");

    // تحديث الشروحات
    generateDetailedExplanation(event);
    generateStateChangesExplanation(event);

    // تحديث اختيار الحدث في القائمة
    if (currentEventIndex < eventHistoryList->count()) {
        eventHistoryList->setCurrentRow(currentEventIndex);
    }

    // تحديث زر التشغيل
    if (currentEventIndex == events.size() - 1) {
        playButton->setEnabled(false);
        nextButton->setEnabled(false);
    } else {
        playButton->setEnabled(true);
        nextButton->setEnabled(true);
    }

    prevButton->setEnabled(currentEventIndex > 0);
}

void BufferCacheWidget::onNextStepClicked() {
    if (currentEventIndex < events.size() - 1) {
        currentEventIndex++;
        displayCurrentEvent();
    }
}

void BufferCacheWidget::onPreviousStepClicked() {
    if (currentEventIndex > 0) {
        currentEventIndex--;
        displayCurrentEvent();
    }
}

void BufferCacheWidget::onPlayClicked() {
    if (!events.isEmpty()) {
        isAutoPlaying = true;
        playButton->setEnabled(false);
        stopButton->setEnabled(true);
        nextButton->setEnabled(false);
        prevButton->setEnabled(false);
        autoPlayTimer->start(autoPlaySpeed);
    }
}

void BufferCacheWidget::onStopClicked() {
    isAutoPlaying = false;
    autoPlayTimer->stop();
    playButton->setEnabled(true);
    stopButton->setEnabled(false);
    nextButton->setEnabled(currentEventIndex < events.size() - 1);
    prevButton->setEnabled(currentEventIndex > 0);
}

void BufferCacheWidget::onAutoPlayTimeout() {
    if (currentEventIndex < events.size() - 1) {
        currentEventIndex++;
        displayCurrentEvent();
    } else {
        onStopClicked();
    }
}

void BufferCacheWidget::onResetClicked() {
    currentEventIndex = 0;
    if (!events.isEmpty()) {
        displayCurrentEvent();
    }
}

void BufferCacheWidget::onSpeedChanged(int value) {
    autoPlaySpeed = value;
    speedLabel->setText(QString("%1x").arg(value / 1000.0, 0, 'f', 1));
    if (autoPlayTimer->isActive()) {
        autoPlayTimer->stop();
        autoPlayTimer->start(autoPlaySpeed);
    }
}

void BufferCacheWidget::onEventListItemClicked(QListWidgetItem *item) {
    int index = eventHistoryList->row(item);
    if (index >= 0 && index < events.size()) {
        currentEventIndex = index;
        displayCurrentEvent();
    }
}

void BufferCacheWidget::onBufferTableClicked(int row, int col) {
    // يمكن استخدام هذا لتفصيل معلومات البفر المحدد
    qDebug() << "Buffer cell clicked:" << row << col;
}

void BufferCacheWidget::displayBufferState(QTableWidget *table, const QMap<int, BufferState> &states, const QString &label) {
    table->clearContents();

    int row = 0;
    for (auto it = states.begin(); it != states.end() && row < 6; ++it, ++row) {
        const BufferState &state = it.value();

        for (int col = 0; col < 5; ++col) {
            QTableWidgetItem *item = new QTableWidgetItem();
            item->setTextAlignment(Qt::AlignCenter);

            QString text;
            if (col == 0) {
                text = QString("Buf %1").arg(state.buf_id);
            } else if (col == 1) {
                text = QString("Block %1").arg(state.blockno >= 0 ? QString::number(state.blockno) : "?");
            } else if (col == 2) {
                text = QString("Ref: %1").arg(state.refcnt);
            } else if (col == 3) {
                text = QString("Valid: %1").arg(state.valid ? "✓" : "✗");
            } else if (col == 4) {
                text = QString("%1").arg(state.locked ? "🔒 BUSY" : "🔓 FREE");
            }

            item->setText(text);
            item->setBackground(getBufferColor(state));
            table->setItem(row, col, item);
        }
    }
}

QColor BufferCacheWidget::getBufferColor(const BufferState &state) const {
    if (state.locked) {
        return QColor(255, 107, 107);  // أحمر: مشغول
    } else if (!state.valid) {
        return QColor(255, 230, 100);  // أصفر: غير صالح
    } else {
        return QColor(220, 221, 225);  // رمادي: متاح
    }
}

void BufferCacheWidget::generateDetailedExplanation(const DetailedEvent &event) {
    QString html;
    html += "<html><body style='direction: rtl; font-family: Arial, sans-serif;'>";
    html += "<h3 style='color: #2196F3;'>" + event.op_name + "</h3>";

    html += getEventTypeDescription(event.fs_type);

    html += "<h4>التفاصيل التقنية:</h4>";
    html += "<ul>";
    if (event.buf_id >= 0) {
        html += "<li><b>معرف البفر:</b> " + QString::number(event.buf_id) + "</li>";
    }
    if (event.blockno >= 0) {
        html += "<li><b>رقم البلوك:</b> " + QString::number(event.blockno) + "</li>";
    }
    if (event.dev >= 0) {
        html += "<li><b>الجهاز:</b> " + QString::number(event.dev) + "</li>";
    }
    html += "<li><b>معرف العملية (PID):</b> " + QString::number(event.pid) + "</li>";
    html += "<li><b>Tick:</b> " + QString::number(event.tick) + "</li>";
    html += "</ul>";

    detailedExplanation->setHtml(html);
}

void BufferCacheWidget::generateStateChangesExplanation(const DetailedEvent &event) {
    QString html;
    html += "<html><body style='direction: rtl; font-family: Arial, sans-serif;'>";

    bool hasChanges = false;

    if (event.ref_before != event.ref_after) {
        html += QString("<p>✓ <b>Reference Count:</b> %1 → %2</p>")
            .arg(event.ref_before)
            .arg(event.ref_after);
        hasChanges = true;
    }

    if (event.valid_before != event.valid_after) {
        html += QString("<p>✓ <b>صحة البفر (Valid):</b> %1 → %2</p>")
            .arg(event.valid_before ? "صحيح" : "غير صحيح")
            .arg(event.valid_after ? "صحيح" : "غير صحيح");
        hasChanges = true;
    }

    if (event.locked_before != event.locked_after) {
        html += QString("<p>✓ <b>حالة القفل (Locked):</b> %1 → %2</p>")
            .arg(event.locked_before ? "🔒 مقفول" : "🔓 مفتوح")
            .arg(event.locked_after ? "🔒 مقفول" : "🔓 مفتوح");
        hasChanges = true;
    }

    if (event.lru_before != event.lru_after) {
        html += QString("<p>✓ <b>موضع LRU:</b> %1 → %2</p>")
            .arg(event.lru_before)
            .arg(event.lru_after);
        hasChanges = true;
    }

    if (!hasChanges) {
        html += "<p style='color: #999;'>لا توجد تغييرات في الحالة</p>";
    }

    html += "</body></html>";
    stateChangesExplanation->setHtml(html);
}

QString BufferCacheWidget::getEventTypeDescription(int fs_type) const {
    QString desc;

    switch (fs_type) {
        case 3:  // HIT
            desc = "<p><b>شرح:</b> عثرنا على البلوك المطلوب في الـ Cache! "
                   "هذا يعني أن البيانات كانت موجودة بالفعل في الذاكرة، "
                   "لذا لا نحتاج إلى قراءتها من القرص الصلب (أسرع بكثير). "
                   "يُسمى هذا 'Cache Hit' وهو ما نريده دائماً.</p>";
            break;
        case 4:  // MISS
            desc = "<p><b>شرح:</b> لم نجد البلوك في الـ Cache! "
                   "نحتاج الآن إلى إيجاد مكان فارغ (أو قديم غير مستخدم) "
                   "لنضع البلوك الجديد فيه. يُسمى هذا 'Cache Miss'.</p>";
            break;
        case 5:  // FILL
            desc = "<p><b>شرح:</b> جاري الآن نقل البيانات من القرص الصلب "
                   "إلى البفر في الذاكرة. هذا يحتاج وقت أطول. "
                   "بعد انتهاء القراءة، يُصبح البفر 'صحيحاً' (valid).</p>";
            break;
        case 6:  // WRITE
            desc = "<p><b>شرح:</b> جاري كتابة بيانات البفر إلى القرص الصلب. "
                   "هذا يحدث عندما تريد العملية حفظ التعديلات بشكل دائم.</p>";
            break;
        case 7:  // RELEASE
            desc = "<p><b>شرح:</b> انتهينا من استخدام هذا البفر! "
                   "نقلل Reference Count، وإذا وصل إلى صفر، يصبح البفر "
                   "متاحاً للاستخدام من قبل عمليات أخرى. "
                   "كما نحدّث موضعه في LRU (الأقدم استخداماً).</p>";
            break;
        default:
            desc = "<p><b>شرح:</b> حدث عام متعلق بإدارة البفرات.</p>";
    }

    return desc;
}

QMap<int, BufferState> BufferCacheWidget::getBufferStatesAtSequence(long seq) {
    QMap<int, BufferState> states;
    if (!db) return states;

    // استعلام لجلب آخر حالة لكل بفر ظهرت قبل أو عند هذا الـ Sequence
    // هذا سيضمن أننا نرى شكل الـ Cache في تلك اللحظة الزمنية تحديداً
    const char *sql = R"(
        SELECT h.buf_id, h.blockno, h.refcnt, h.valid, h.locked, h.lru_pos
        FROM buffer_history h
        INNER JOIN (
            SELECT buf_id, MAX(seq) as max_seq
            FROM buffer_history
            WHERE seq <= ?
            GROUP BY buf_id
        ) latest ON h.buf_id = latest.buf_id AND h.seq = latest.max_seq
    )";

    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) == SQLITE_OK) {
        sqlite3_bind_int64(stmt, 1, seq); // نربط رقم التسلسل هنا
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            BufferState state;
            state.buf_id = sqlite3_column_int(stmt, 0);
            state.blockno = sqlite3_column_int(stmt, 1);
            state.refcnt = sqlite3_column_int(stmt, 2);
            state.valid = sqlite3_column_int(stmt, 3);
            state.locked = sqlite3_column_int(stmt, 4);
            state.lru_pos = sqlite3_column_int(stmt, 5);
            states[state.buf_id] = state;
        }
        sqlite3_finalize(stmt);
    }
    return states;
}

void BufferCacheWidget::updateStatistics() {
    if (!db) return;

    sqlite3_stmt *stmt;
    const char *sql = "SELECT "
                      "SUM(CASE WHEN fs_type=3 THEN 1 ELSE 0 END) as hits, "
                      "SUM(CASE WHEN fs_type=4 THEN 1 ELSE 0 END) as misses "
                      "FROM fs_events";

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) == SQLITE_OK) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            int hits = sqlite3_column_int(stmt, 0);
            int misses = sqlite3_column_int(stmt, 1);
            int total = hits + misses;
            double hitRate = total > 0 ? (100.0 * hits / total) : 0;

            statsLabel->setText(
                QString("📊 الإحصائيات: Hits=%1 | Misses=%2 | نسبة الإصابة=%3%")
                .arg(hits)
                .arg(misses)
                .arg(hitRate, 0, 'f', 1)
            );
        }
    }
    sqlite3_finalize(stmt);
}
