#ifndef MEMCATWINDOW_H
#define MEMCATWINDOW_H

#include <QMainWindow>
#include <QTableWidget>
#include <QPushButton>
#include <QTimer>
#include <QSqlDatabase>
#include <QWidget>
#include <QProcess>
#include <QLabel>

class MemcatWindow : public QMainWindow {
    Q_OBJECT

public:
    explicit MemcatWindow(QWidget *parent = nullptr);
    ~MemcatWindow() override;

private slots:
    void loadMemEvents();
    void runMemcat();
    void onQemuStarted();
    void onQemuFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onIngestorStarted();
    void onIngestorFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    void setupDatabase();
    void setupUi();
    void startQemuAndIngestor();
    bool tableExists(const QString &tableName);
    void showDbError(const QString &context);
    void updateStatusLabel(const QString &text, const QString &color = "#2c3e50");

private:
    QString connectionName;
    QSqlDatabase db;
    QTimer *memcatCommandTimer;
    QTableWidget *memEventsTable;
    QPushButton *refreshButton;
    QLabel *statusLabel;
    QProcess *qemuProcess;
    QProcess *ingestorProcess;
};

#endif
