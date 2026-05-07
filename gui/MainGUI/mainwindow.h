#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

class QPushButton;
class QLabel;

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();
private slots:
    void onSchedulerClicked();
    void onMemcatClicked();
    void onFileSystemClicked();
    void onSyscallClicked();

private:
    QLabel *titleLabel;
    QPushButton *btnScheduler;
    QPushButton *btnMemcat;
    QPushButton *btnFileSystem;
    QPushButton *btnSyscall;
};

#endif
