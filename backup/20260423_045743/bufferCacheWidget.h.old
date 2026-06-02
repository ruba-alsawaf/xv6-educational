#ifndef BUFFERCACHEWIDGET_H
#define BUFFERCACHEWIDGET_H

#include <QWidget>
#include <QTableWidget>
#include <QLabel>
#include <QTextEdit>
#include <QListWidget>
#include <QComboBox>
#include <QTimer>
#include <QPushButton>
#include <sqlite3.h>

class BufferCacheWidget : public QWidget {
    Q_OBJECT

public:
    explicit BufferCacheWidget(QWidget *parent = nullptr);

private slots:
    void refreshUI();
    void onLevelChanged(int index);
    void onBufferClicked(int row, int col);
    void togglePause();

private:
    enum Level { Beginner = 0, Advanced = 1 };
    Level currentLevel = Beginner;

    // العناصر التي نستخدمها فعلياً في الـ CPP
    QComboBox *levelCombo;
    QPushButton *pauseButton;
    QPushButton *stepButton;
    QLabel *statsLabel;
    QTableWidget *bufferTable;
    QTextEdit *explanationBox;
    QListWidget *eventList;
    QTimer *refreshTimer;

    int selectedBufId = -1;

    // الدوال المحدثة (تأكدي أن الأسماء تطابق ملف cpp)
    void setupUI();
    void clearOldLogs();           // أضفناها هنا
    void updateStats();            // بديلة لـ loadStats
    void loadBufferState();
    void loadRecentEvents();
    void updateExplanation(int type, int block, int buf, int ref, int lock); // دالة الشرح الموحدة

    QString eventTypeName(int type) const;
};

#endif // BUFFERCACHEWIDGET_H