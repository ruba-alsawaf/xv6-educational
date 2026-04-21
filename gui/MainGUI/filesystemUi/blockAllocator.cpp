#include "blockAllocator.h"

BlockAllocatorWidget::BlockAllocatorWidget(QWidget *parent) : QWidget(parent) {
    QVBoxLayout *layout = new QVBoxLayout(this);
    table = new QTableWidget(0, 3);
    table->setHorizontalHeaderLabels({"Time (Tick)", "Operation", "Block Number"});
    table->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    
    layout->addWidget(table);

    QTimer *timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &BlockAllocatorWidget::refreshData);
    timer->start(500); // تحديث كل نصف ثانية
}

void BlockAllocatorWidget::refreshData() {
    QSqlQuery query;
    query.prepare("SELECT tick, op_name, blockno, seq FROM fs_events "
                  "WHERE seq > :last AND fs_type IN (30, 31) "
                  "ORDER BY seq ASC");
    query.bindValue(":last", lastSeq);

    if (query.exec()) {
        while (query.next()) {
            int row = table->rowCount();
            table->insertRow(row);
            
            QString tick = query.value(0).toString();
            QString opName = query.value(1).toString(); // ستكون مثلاً "BALLOC ➕"
            QString blockNo = query.value(2).toString();
            int currentSeq = query.value(3).toInt();

            table->setItem(row, 0, new QTableWidgetItem(tick));
            table->setItem(row, 1, new QTableWidgetItem(opName));
            table->setItem(row, 2, new QTableWidgetItem(blockNo));

            // التلوين باستخدام contains بدلاً من == 
            auto itemOp = table->item(row, 1);
            if(opName.contains("BALLOC")) { 
                itemOp->setForeground(Qt::green);
                itemOp->setText("BALLOC ➕"); // تأكيد النص
            } else if(opName.contains("BFREE")) {
                itemOp->setForeground(Qt::red);
                itemOp->setText("BFREE ➖");
            }

            lastSeq = currentSeq;
        }
        table->scrollToBottom();
    }
}