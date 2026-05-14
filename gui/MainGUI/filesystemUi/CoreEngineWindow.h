#ifndef COREENGINEWINDOW_H
#define COREENGINEWINDOW_H

#include <QMainWindow>
#include <QGridLayout>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QTimer>
#include <QSqlQuery>
#include <QLabel>
#include <QProgressBar>
#include <QLineEdit>
#include <QPushButton>
#include <QTextEdit>
#include <QScrollArea>
#include <QTableWidget>
#include <QFrame>
#include <QWidget>

class CoreEngineWindow : public QMainWindow {
    Q_OBJECT
public:
    explicit CoreEngineWindow(QWidget *parent = nullptr);

private slots:
    void refreshData();
    void refreshTimeline();

private:
    void setupUi();
    void setupDashboard(QGridLayout *layout);
    void setupVisualizer(QVBoxLayout *layout);
    void setupTimeline(QBoxLayout *layout);
    void setupRecentEvents(QBoxLayout *layout);
    void setupInspector(QVBoxLayout *layout);

    void showInspectorForEventId(int eventId);

    QTimer *updateTimer;

    QLabel *lblTotalBuffers;
    QLabel *lblBusyBuffers;
    QLabel *lblFreeBuffers;
    QLabel *lblUsagePercent;
    QProgressBar *usageBar;

    QLabel *lblHits;
    QLabel *lblMisses;
    QLabel *lblHitRate;

    QLabel *lblActiveInodes;
    QLabel *lblUsedInodes;
    QLabel *lblFreeInodes;
    QLabel *lblLockedInodes;

    QLabel *lblLogStatus;
    QLabel *lblLogN;
    QLabel *lblOutstanding;
    QLabel *lblCommitting;

    QLabel *lblInspectorHeader;
    QTextEdit *inspectorDetails;

    QWidget *visualizerContainer;
    QScrollArea *timelineScrollArea;
    QWidget *timelineContent;
    QVBoxLayout *timelineContentLayout;
    QLineEdit *timelinePidInput;
    QPushButton *timelineRefreshButton;
    QTableWidget *recentEventsTable;
};

#endif