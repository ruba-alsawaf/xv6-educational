#ifndef BLOCKALLOCATOR_H
#define BLOCKALLOCATOR_H

#include <QWidget>
#include <QTableWidget>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QTimer>
#include <QLabel>
#include <QTextEdit>
#include <QSplitter>

class BlockAllocatorWidget : public QWidget {
    Q_OBJECT
public:
    explicit BlockAllocatorWidget(QWidget *parent = nullptr);

private slots:
    void refreshData();
    void showDetails(int row);

private:
    QTableWidget *table;
    QLabel *diagramLabel;
    QTextEdit *explanationText;
    QSplitter *mainSplitter;
    int lastSeq = 0;
};

#endif