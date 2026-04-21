#include "logWidget.h"
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QSqlQuery>
#include <QHeaderView>
#include <QSqlError>

LogWidget::LogWidget(QWidget *parent) : QWidget(parent) {
    auto mainLayout = new QHBoxLayout(this);
    
    // الجدول
    logTable = new QTableWidget(0, 3);
    logTable->setHorizontalHeaderLabels({"Time", "Operation", "Block"});
    logTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    logTable->setSelectionBehavior(QAbstractItemView::SelectRows);

    // الشرح والرسم
    auto detailLayout = new QVBoxLayout();
    diagramLabel = new QLabel("Select an event to see visual flow");
    diagramLabel->setAlignment(Qt::AlignCenter);
    diagramLabel->setFixedSize(350, 250);
    diagramLabel->setStyleSheet("border: 2px solid #3498db; background: #fdfdfd; border-radius: 10px; font-weight: bold;");
    
    explanationText = new QTextEdit();
    explanationText->setReadOnly(true);
    explanationText->setStyleSheet("background: #ecf0f1; border-radius: 5px; padding: 10px;");
    
    detailLayout->addWidget(new QLabel("<h3>Visual Flow Diagram</h3>"));
    detailLayout->addWidget(diagramLabel);
    detailLayout->addWidget(new QLabel("<h3>Technical Explanation</h3>"));
    detailLayout->addWidget(explanationText);

    mainLayout->addWidget(logTable, 2);
    mainLayout->addLayout(detailLayout, 1);

    connect(logTable, &QTableWidget::cellClicked, this, &LogWidget::showDetails);
    
    QTimer *timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &LogWidget::refreshData);
    timer->start(1000);
}

void LogWidget::refreshData() {
    if (!QSqlDatabase::database().isOpen()) return;

    QSqlQuery query;
    // التعديل هنا: أضفنا شرط WHERE fs_type >= 20
    query.prepare("SELECT tick, op_name, blockno, seq FROM fs_events "
                  "WHERE seq > :last AND fs_type >= 20 " 
                  "ORDER BY seq ASC");
    
    query.bindValue(":last", lastSeq);

    if (!query.exec()) return;

    while (query.next()) {
        int row = logTable->rowCount();
        logTable->insertRow(row);
        
        logTable->setItem(row, 0, new QTableWidgetItem(query.value(0).toString()));
        logTable->setItem(row, 1, new QTableWidgetItem(query.value(1).toString()));
        logTable->setItem(row, 2, new QTableWidgetItem(query.value(2).toString()));
        
        lastSeq = query.value(3).toInt();
        logTable->scrollToBottom();
    }
}

void LogWidget::showDetails(int row) {
    QString op = logTable->item(row, 1)->text();
    QString block = logTable->item(row, 2)->text();

    
    // تغيير لون الخلفية للرسم حسب العملية
    if (op == "COMMIT") {
        diagramLabel->setStyleSheet("background-color: #2ecc71; color: white; border-radius: 15px; font-size: 18px;");
        diagramLabel->setText("⭐⭐ COMMIT POINT ⭐⭐\n[Journaling Complete]");
        explanationText->setHtml("<h2 style='color:#27ae60;'>Atomic Commit</h2>"
                                 "The log header is now updated. If the system crashes now, "
                                 "recovery will REPLAY these blocks.");
    } else if (op == "BEGIN_OP") {
        diagramLabel->setStyleSheet("background-color: #3498db; color: white; border-radius: 15px;");
        diagramLabel->setText("TRANSACTION STARTED\nReserving Log Space...");
        explanationText->setHtml("<h2 style='color:#2980b9;'>Reservation Phase</h2>"
                                 "xv6 prevents log overflow by ensuring this system call "
                                 "won't exceed MAXOPBLOCKS.");
    }

    
     else if (op == "LOG_WRITE") {
        explanationText->setHtml("<b>Step 2: log_write()</b><br>The block is pinned in the cache. <b>Absorption:</b> If the same block is modified again in the same transaction, it won't take a new slot in the log.");
        diagramLabel->setText("CACHE --pin--> LOG SLOT\n(Block: " + block + ")");
    
    } else if (op == "INSTALL") {
        explanationText->setHtml("<b>Step 4: install_trans()</b><br>Data is copied from the log to its home location on disk. The transaction is now safe at home.");
        diagramLabel->setText("LOG [" + block + "] ----> DISK [" + block + "]");
    }
}