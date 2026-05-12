#ifndef BUFFERCACHEWIDGET_H
#define BUFFERCACHEWIDGET_H

#include <QWidget>
#include <QTableWidget>
#include <QLabel>
#include <QTextEdit>
#include <QListWidget>
#include <QTimer>
#include <QPushButton>
#include <QSplitter>
#include <QTabWidget>
#include <QMap>
#include <sqlite3.h>

// هيكل لتمثيل حالة البفر
struct BufferState {
    int buf_id;
    int blockno;
    int refcnt;
    int valid;
    int locked;
    int lru_pos;
};

// هيكل لتمثيل الحدث مع معلومات تفصيلية
struct DetailedEvent {
    long seq;
    int type;
    int fs_type;
    int tick;
    int pid;
    int dev;
    int blockno;
    int old_blockno;
    int buf_id;
    int ref_before;
    int ref_after;
    int valid_before;
    int valid_after;
    int locked_before;
    int locked_after;
    int lru_before;
    int lru_after;
    QString name;
    QString op_name;
    QString explanation;  // شرح مفصل
    QMap<int, BufferState> buffer_states_before;  // حالة البفرات قبل
    QMap<int, BufferState> buffer_states_after;   // حالة البفرات بعد
};

class BufferCacheWidget : public QWidget {
    Q_OBJECT

public:
    explicit BufferCacheWidget(QWidget *parent = nullptr);
    ~BufferCacheWidget();

private slots:
    void onNextStepClicked();
    void onPreviousStepClicked();
    void onPlayClicked();
    void onStopClicked();
    void onAutoPlayTimeout();
    void onEventListItemClicked(QListWidgetItem *item);
    void onBufferTableClicked(int row, int col);
    void onResetClicked();
    void onSpeedChanged(int value);

private:
    // عناصر الـ UI
    QTableWidget *bufferTableBefore;      // جدول البفرات قبل الحدث
    QTableWidget *bufferTableAfter;       // جدول البفرات بعد الحدث
    QTextEdit *detailedExplanation;       // شرح مفصل للحدث
    QTextEdit *stateChangesExplanation;   // شرح التغييرات في الحالة
    QListWidget *eventHistoryList;        // قائمة الأحداث
    QLabel *currentEventLabel;            // عنوان الحدث الحالي
    QLabel *statsLabel;                   // الإحصائيات
    QLabel *speedLabel;                   // عرض السرعة
    QPushButton *nextButton;
    QPushButton *prevButton;
    QPushButton *playButton;
    QPushButton *stopButton;
    QPushButton *resetButton;
    QSlider *speedSlider;
    QTimer *autoPlayTimer;
    QSplitter *mainSplitter;
    QSplitter *bottomSplitter;

    // البيانات
    QVector<DetailedEvent> events;        // قائمة الأحداث
    int currentEventIndex = -1;           // الحدث الحالي
    bool isAutoPlaying = false;
    int autoPlaySpeed = 2000;             // milliseconds
    sqlite3 *db = nullptr;

    // الدوال الخاصة
    void setupUI();
    void connectSignals();
    void loadAllEventsFromDB();
    void displayCurrentEvent();
    void displayBufferState(QTableWidget *table, const QMap<int, BufferState> &states, const QString &title);
    void generateDetailedExplanation(const DetailedEvent &event);
    void generateStateChangesExplanation(const DetailedEvent &event);
    QString getEventTypeDescription(int fs_type) const;
    QString getBufferStateDescription(const BufferState &state) const;
    void updateStatistics();
    void highlightChangedBuffers(int prev_idx, int curr_idx);
    DetailedEvent enrichEventWithDetails(const DetailedEvent &basic_event);
    QMap<int, BufferState> getBufferStatesAtSequence(long seq);
    void saveCurrentState();

    // ألوان وأنماط
    QColor getBufferColor(const BufferState &state) const;
};

#endif // BUFFERCACHEWIDGET_H
