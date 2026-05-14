#ifndef SCHEDULERWINDOW_H
#define SCHEDULERWINDOW_H

#include <QMainWindow>
#include <QTableWidget>
#include <QPushButton>
#include <QTimer>
#include <QSqlDatabase>
#include <QWidget>
#include <QProcess>
#include <QLabel>
#include <QProgressBar>

class SchedulerWindow : public QMainWindow {
    Q_OBJECT

public:
    explicit SchedulerWindow(QWidget *parent = nullptr);
    ~SchedulerWindow();

private slots:
    void loadCpuStats();
    void runCpuInfo();
    void onQemuStarted();
    void onQemuFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onIngestorStarted();
    void onIngestorFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    void setupDatabase();
    void setupUi();
    void setupCpuStatsTab();
    void startQemuAndIngestor();

    bool tableExists(const QString &tableName);
    void showDbError(const QString &context);
    void updateStatusLabel(const QString &text, const QString &color = "#2c3e50");

private:
    QString connectionName;
    QSqlDatabase db;
    QTimer *cpuInfoTimer;

    QTimer *cpuCmdTimer;

    QProgressBar *cpuUsageBar;
    QLabel *cpuUsageLabel;
    QTableWidget *cpuInfoTable;
    QTableWidget *cpuTimelineTable;
    QTableWidget *procStatsTable;
    QPushButton *cpuStatsRefreshButton;
    QLabel *statusLabel;

    QProcess *qemuProcess;
    QProcess *ingestorProcess;
};

#endif
