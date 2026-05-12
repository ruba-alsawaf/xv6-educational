#include "blockAllocator.h"

BlockAllocatorWidget::BlockAllocatorWidget(QWidget *parent) : QWidget(parent) {
    mainSplitter = new QSplitter(Qt::Horizontal, this);
    QVBoxLayout *layout = new QVBoxLayout(this);
    layout->addWidget(mainSplitter);

    // الجدول
    QWidget *leftWidget = new QWidget(this);
    QVBoxLayout *leftLayout = new QVBoxLayout(leftWidget);
    table = new QTableWidget(0, 3);
    table->setHorizontalHeaderLabels({"Time (Tick)", "Operation", "Block Number"});
    table->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table->setSelectionBehavior(QAbstractItemView::SelectRows);
    leftLayout->addWidget(table);
    mainSplitter->addWidget(leftWidget);

    // الشرح
    QWidget *rightWidget = new QWidget(this);
    QVBoxLayout *rightLayout = new QVBoxLayout(rightWidget);
    diagramLabel = new QLabel("Select an event to see visual flow");
    diagramLabel->setAlignment(Qt::AlignCenter);
    diagramLabel->setFixedSize(350, 250);
    diagramLabel->setStyleSheet("border: 2px solid #3498db; background: #fdfdfd; border-radius: 10px; font-weight: bold;");
    
    explanationText = new QTextEdit();
    explanationText->setReadOnly(true);
    explanationText->setStyleSheet("background: #ecf0f1; border-radius: 5px; padding: 10px;");
    
    rightLayout->addWidget(new QLabel("<h3>Visual Flow Diagram</h3>"));
    rightLayout->addWidget(diagramLabel);
    rightLayout->addWidget(new QLabel("<h3>Technical Explanation</h3>"));
    rightLayout->addWidget(explanationText);
    mainSplitter->addWidget(rightWidget);

    mainSplitter->setStretchFactor(0, 1);
    mainSplitter->setStretchFactor(1, 1);

    connect(table, &QTableWidget::cellClicked, this, &BlockAllocatorWidget::showDetails);

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

    if (!query.exec()) {
        qWarning() << "BlockAllocator query failed:" << query.lastError().text();
        return;
    }

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

void BlockAllocatorWidget::showDetails(int row) {
    QString op = table->item(row, 1)->text();
    QString block = table->item(row, 2)->text();

    if (op.contains("BALLOC")) {
        diagramLabel->setStyleSheet("background-color: #27ae60; color: white; border-radius: 15px;");
        diagramLabel->setText("BALLOC\nتخصيص بلوك جديد");
        explanationText->setHtml(
            "<h2 style='color:#27ae60;'>BALLOC - تخصيص بلوك</h2>"
            "<p>يبحث النظام عن بلوك فارغ في خريطة البيتات (bitmap) على القرص.</p>"
            "<p><b>الخوارزمية:</b></p>"
            "<ul>"
            "<li>يمر على كل البلوكات من 0 إلى sb.size</li>"
            "<li>يقرأ كل بلوك من خريطة البيتات (BBLOCK)</li>"
            "<li>يفحص كل بت في البلوك (BPB بت لكل بلوك)</li>"
            "<li>إذا وجد بت = 0 (فارغ)، يعينه 1 ويعيد رقم البلوك</li>"
            "</ul>"
            "<p><b>الكود:</b> في <code>balloc()</code> (kernel/fs.c:72):</p>"
            "<pre>for(b = 0; b < sb.size; b += BPB){</pre>"
            "<pre>  bp = bread(dev, BBLOCK(b, sb));</pre>"
            "<pre>  for(bi = 0; bi < BPB; bi++){</pre>"
            "<pre>    if((bp->data[bi/8] & (1 << (bi%8))) == 0){</pre>"
            "<pre>      // تخصيص البلوك</pre>"
            "<pre>      bp->data[bi/8] |= (1 << (bi%8));</pre>"
            "<pre>      log_write(bp);</pre>"
            "<pre>      brelse(bp);</pre>"
            "<pre>      return b + bi;</pre>"
            "<pre>    }</pre>"
            "<pre>  }</pre>"
            "<pre>  brelse(bp);</pre>"
            "<pre>}</pre>"
            "<p>البلوك المُخصص: <b>" + block + "</b></p>"
            "<p><b>الحماية من السباق:</b> Buffer Cache يمنع عمليتين من استخدام نفس بلوك الخريطة في نفس الوقت.</p>");
    } else if (op.contains("BFREE")) {
        diagramLabel->setStyleSheet("background-color: #e74c3c; color: white; border-radius: 15px;");
        diagramLabel->setText("BFREE\nتحرير بلوك");
        explanationText->setHtml(
            "<h2 style='color:#e74c3c;'>BFREE - تحرير بلوك</h2>"
            "<p>يحرر النظام بلوكاً من خلال مسح بته في خريطة البيتات.</p>"
            "<p><b>الخطوات:</b></p>"
            "<ul>"
            "<li>يحسب رقم بلوك الخريطة: BBLOCK(b, sb)</li>"
            "<li>يقرأ بلوك الخريطة من القرص</li>"
            "<li>يجد البيت المقابل للبلوك المُراد تحريره</li>"
            "<li>يضمن أن البيت كان مُعيناً (1) قبل التحرير</li>"
            "<li>يُسح البيت (يُعينه 0)</li>"
            "</ul>"
            "<p><b>الكود:</b> في <code>bfree()</code> (kernel/fs.c:92):</p>"
            "<pre>bp = bread(dev, BBLOCK(b, sb));</pre>"
            "<pre>bi = b % BPB;</pre>"
            "<pre>m = 1 << (bi % 8);</pre>"
            "<pre>if((bp->data[bi/8] & m) == 0)</pre>"
            "<pre>  panic(\"freeing free block\");</pre>"
            "<pre>bp->data[bi/8] &= ~m;</pre>"
            "<pre>log_write(bp);</pre>"
            "<pre>brelse(bp);</pre>"
            "<p>البلوك المُحرر: <b>" + block + "</b></p>"
            "<p><b>الحماية من السباق:</b> نفس آلية bread/brelse تمنع الوصول المتزامن.</p>"
            "<p><b>ملاحظة:</b> يجب استدعاء balloc و bfree داخل معاملة (transaction).</p>");
    } else {
        diagramLabel->setStyleSheet("background-color: #7f8c8d; color: white; border-radius: 15px;");
        diagramLabel->setText("BLOCK ALLOCATOR\nشرح عام");
        explanationText->setHtml(
            "<h2 style='color:#7f8c8d;'>مخصص البلوكات</h2>"
            "<p>يحافظ xv6 على خريطة بيتات (bitmap) على القرص، ببت واحد لكل بلوك.</p>"
            "<p>بت = 0: البلوك فارغ</p>"
            "<p>بت = 1: البلوك مُستخدم</p>"
            "<p>انقر على BALLOC أو BFREE للحصول على شرح تفصيلي مع تتبع الكود.</p>");
    }
}