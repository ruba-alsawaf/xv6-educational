#ifndef INODEWIDGET_H
#define INODEWIDGET_H

#include <QWidget>
#include <QTableWidget>
#include <QMap>
#include <QVBoxLayout>

struct InodeData {
    int inum;
    int type;
    int ref;
    int nlink;
    uint size;
    int addrs[13]; // تغيير من QString إلى مصفوفة int
    bool isLocked;
};

class InodeWidget : public QWidget {
    Q_OBJECT
public:
    explicit InodeWidget(QWidget *parent = nullptr);
    void processNewEvent(const InodeData &data); 
    void updateData(const InodeData &data) { processNewEvent(data); } // دالة ربط سريعة

private:
    QTableWidget *table;
    QMap<int, int> inumToRow; 
    void setupUi();
    void updateRow(int row, const InodeData &data);
};

#endif