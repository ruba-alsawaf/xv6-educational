#include "InodeWidget.h"
#include <QHeaderView>
#include <QLabel>
#include <QStringList>

InodeWidget::InodeWidget(QWidget *parent) : QWidget(parent) {
    setupUi();

    // تشغيل التايمر لتحديث البيانات كل ثانية (1000ms)
    dbTimer = new QTimer(this);
    connect(dbTimer, &QTimer::timeout, this, &InodeWidget::updateFromDatabase);
    dbTimer->start(1000); 
}

void InodeWidget::updateFromDatabase() {
    // نجلب آخر 30 حدث (الأحدث أولاً بناءً على id)
    QSqlQuery query("SELECT inum, i_type, ref_after, nlink, i_size, addrs, locked_after, op_name "
                    "FROM fs_events WHERE inum > 0 ORDER BY id DESC LIMIT 100");

    table->setRowCount(0); // تنظيف الجدول بالكامل لإعادة الترتيب

    while (query.next()) {
        InodeData d;
        d.inum = query.value(0).toInt();
        d.type = query.value(1).toInt();
        d.ref = query.value(2).toInt();
        d.nlink = query.value(3).toInt();
        d.size = query.value(4).toUInt();
        
        QStringList addrsList = query.value(5).toString().split(",");
        for(int i=0; i<13 && i<addrsList.size(); i++) d.addrs[i] = addrsList[i].toInt();

        d.isLocked = query.value(6).toInt() == 1;
        d.lastOp = query.value(7).toString();

        // الإضافة هنا ستكون سطر بسطر لأسفل
        int row = table->rowCount();
        table->insertRow(row);
        
        for(int i = 0; i < 8; i++) table->setItem(row, i, new QTableWidgetItem());
        
        updateRow(row, d);
    }
}

void InodeWidget::setupUi() {
    auto *layout = new QVBoxLayout(this);
    
    // إنشاء الجدول بـ 8 أعمدة (إضافة عمود العملية)
    table = new QTableWidget(0, 8); 
    table->setHorizontalHeaderLabels({
        "I-number", "Type", "Ref", "Links", "Size", "Blocks Map", "Lock Status", "Operation"
    });

    // تنسيق الجدول ليكون داكن واحترافي
    table->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table->setSelectionBehavior(QAbstractItemView::SelectRows);
    table->setStyleSheet(
        "QTableWidget { background-color: #1e1e1e; color: #d4d4d4; gridline-color: #333333; font-size: 13px; }"
        "QHeaderView::section { background-color: #2d2d2d; color: #ffffff; padding: 5px; border: 1px solid #444; }"
    );
    
    layout->addWidget(table);
}

void InodeWidget::processNewEvent(const InodeData &data) {
    if (data.inum <= 0) return;

    // إضافة سطر في نهاية الجدول لكل حدث جديد يقرأه الـ Timer
    int row = table->rowCount();
    table->insertRow(row);
    
    // حجز الـ Items في السطر
    for(int i = 0; i < 8; i++) {
        table->setItem(row, i, new QTableWidgetItem());
    }

    updateRow(row, data);
}

void InodeWidget::updateRow(int row, const InodeData &data) {
    // 1. رقم الـ Inode والعملية (لتمييز الحدث)
    table->item(row, 0)->setText(QString::number(data.inum));
    table->item(row, 7)->setText(data.lastOp); // اسم العملية (ILOCK, IUPDATE, etc)
    table->item(row, 7)->setForeground(Qt::cyan);

    // 2. نوع الملف
    QString typeStr;
    if (data.type == 1) typeStr = "📁 Dir";
    else if (data.type == 2) typeStr = "📄 File";
    else if (data.type == 3) typeStr = "⚙️ Dev";
    else typeStr = "❓ Unk (" + QString::number(data.type) + ")"; 
    table->item(row, 1)->setText(typeStr);
    
    // 3. البيانات الرقمية
    table->item(row, 2)->setText(QString::number(data.ref));
    table->item(row, 3)->setText(QString::number(data.nlink));
    table->item(row, 4)->setText(QString::number(data.size) + " B");

    // 4. خريطة البلوكات (Blocks Map)
    QString visualMap = "";
    for (int i = 0; i < 12; i++) {
        visualMap += (data.addrs[i] > 0) ? "■ " : "□ ";
    }
    if(data.addrs[12] > 0) visualMap += " ➔"; 
    table->item(row, 5)->setText(visualMap);

    // 5. حالة القفل (Lock)
    if (data.isLocked) {
        table->item(row, 6)->setText("🔒 Locked");
        table->item(row, 6)->setForeground(Qt::red);
    } else {
        table->item(row, 6)->setText("🔓 Free");
        table->item(row, 6)->setForeground(Qt::green);
    }
}