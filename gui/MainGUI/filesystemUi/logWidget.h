#ifndef LOGWIDGET_H
#define LOGWIDGET_H

#include <QWidget>
#include <QTableWidget>
#include <QLabel>
#include <QTextEdit>
#include <QTimer>

class LogWidget : public QWidget {
    Q_OBJECT
public:
    explicit LogWidget(QWidget *parent = nullptr);

private slots:
    void refreshData();         // التأكد من هذا الاسم
    void showDetails(int row);

private:
    QTableWidget *logTable;
    QLabel *diagramLabel;
    QTextEdit *explanationText;
    int lastSeq = 0;
};
#endif