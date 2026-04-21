#ifndef BLOCKALLOCATOR_H
#define BLOCKALLOCATOR_H

#include <QWidget>
#include <QTableWidget>
#include <QVBoxLayout>
#include <QHeaderView>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QTimer>

class BlockAllocatorWidget : public QWidget {
    Q_OBJECT
public:
    explicit BlockAllocatorWidget(QWidget *parent = nullptr);

private slots:
    void refreshData();

private:
    QTableWidget *table;
    int lastSeq = 0;
};

#endif