#ifndef INODEWIDGET_H
#define INODEWIDGET_H

#include <QWidget>
#include <QTableWidget>
#include <QMap>
#include <QVBoxLayout>
#include <QTimer>
#include <QSqlQuery>
#include <QSqlError>

struct InodeData {
    int inum;
    int type;
    int ref;
    int nlink;
    uint size;
    int addrs[13]; 
    bool isLocked;
    QString lastOp; // أضيفي هذا السطر
};

class InodeWidget : public QWidget {
    Q_OBJECT
public:
    explicit InodeWidget(QWidget *parent = nullptr);
    void processNewEvent(const InodeData &data); 
    void updateData(const InodeData &data) { processNewEvent(data); }

private slots:
    void updateFromDatabase(); // الدالة اللي ضفناها للتايمر

private:
    QTableWidget *table;
    QMap<int, int> inumToRow; 
    QTimer *dbTimer; 
    void setupUi();
    void updateRow(int row, const InodeData &data);
};

#endif