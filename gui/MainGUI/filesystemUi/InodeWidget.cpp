#include "InodeWidget.h"
#include <QHeaderView>
#include <QLabel>

InodeWidget::InodeWidget(QWidget *parent) : QWidget(parent) {
    setupUi();
}

void InodeWidget::setupUi() {
    auto *layout = new QVBoxLayout(this);
    table = new QTableWidget(0, 7);
    table->setHorizontalHeaderLabels({"I-number", "Type", "Ref", "Links", "Size", "Blocks Map", "Lock"});
    
    // تنسيق إضافي لجعل الواجهة احترافية
    table->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table->setStyleSheet("QTableWidget { background-color: #1e1e1e; color: #d4d4d4; gridline-color: #333333; }");
    
    layout->addWidget(table);
}

void InodeWidget::processNewEvent(const InodeData &data) {
    if (data.inum <= 0) return;

    // إذا كان الـ Inode جديداً ولم يكن موجوداً في الجدول
    if (!inumToRow.contains(data.inum)) {
        if (data.ref <= 0) return; // لا تضف Inode غير نشط

        int row = table->rowCount();
        table->insertRow(row);
        inumToRow[data.inum] = row;
        
        for(int i = 0; i < 7; i++) {
            table->setItem(row, i, new QTableWidgetItem());
        }
    }

    int row = inumToRow[data.inum];
    updateRow(row, data);

    // إذا انتهت المراجع (Ref Count = 0)، نحذفه من الجدول لأنه خرج من الذاكرة (itable)
    if (data.ref <= 0) {
        table->removeRow(row);
        inumToRow.remove(data.inum);
    }
}

void InodeWidget::updateRow(int row, const InodeData &data) {
    table->item(row, 0)->setText(QString::number(data.inum));

    QString typeStr = (data.type == 1) ? "📁 Dir" : (data.type == 2) ? "📄 File" : "⚙️ Dev";
    table->item(row, 1)->setText(typeStr);
    table->item(row, 2)->setText(QString::number(data.ref));
    table->item(row, 3)->setText(QString::number(data.nlink));
    table->item(row, 4)->setText(QString::number(data.size) + " B");

    // رسم المربعات بناءً على مصفوفة الأرقام
    QString visualMap = "";
    for (int i = 0; i < 12; i++) {
        visualMap += (data.addrs[i] > 0) ? "■ " : "□ ";
    }
    // البلوك رقم 13 هو الـ Indirect (سهم)
    if(data.addrs[12] > 0) visualMap += " ➔"; 
    
    table->item(row, 5)->setText(visualMap);

    if (data.isLocked) {
        table->item(row, 6)->setText("🔒 Locked");
        table->item(row, 6)->setForeground(Qt::red);
    } else {
        table->item(row, 6)->setText("🔓 Free");
        table->item(row, 6)->setForeground(Qt::green);
    }
}