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
    if (op == "BEGIN_OP") {
        diagramLabel->setStyleSheet("background-color: #3498db; color: white; border-radius: 15px;");
        diagramLabel->setText("BEGIN_OP\nتأكد من مساحة اللوغ");
        explanationText->setHtml(
            "<h2 style='color:#2980b9;'>BEGIN_OP</h2>"
            "<p>تبدأ العملية بالتأكد من وجود مساحة كافية في سجل اللوغ (MAXOPBLOCKS). "
            "إذا كان هناك مساحة كافية، يزيد النظام عداد <b>outstanding</b> بمقدار واحد.</p>"
            "<p>هذا يعني أن هناك الآن عملية FS نشطة يمكنها تعديل بلوكات وتسجيلها في نفس سجل اللوغ.</p>"
            "<p><b>مهم:</b> وجود أكثر من عملية نشطة في نفس الوقت لا يعني أنها تعدل نفس البلوك، لكنه يعني أنها تتشارك نفس المعاملة.</p>");
    } else if (op == "LOG_WRITE") {
        diagramLabel->setStyleSheet("background-color: #f39c12; color: black; border-radius: 15px;");
        diagramLabel->setText("LOG_WRITE\nتسجيل البلوك في اللوغ");
        explanationText->setHtml(
            "<h2 style='color:#d35400;'>LOG_WRITE</h2>"
            "<p>عندما يُعدل النظام بلوكاً، يستدعي <b>log_write()</b> ليضيف رقم هذا البلوك إلى مصفوفة <b>log.lh.block</b> في الذاكرة.</p>"
            "<p>إذا كان نفس البلوك قد سجل سابقاً في نفس المعاملة، فإنه لا يكرر إضافته.</p>"
            "<p>ثم يستدعي <b>bpin()</b> على البافر لمنع الـ Buffer Cache من طرده قبل انتهاء الالتزام.</p>"
            "<p>اللوغ نفسه موجود على القرص، لكن الكتابة تمر عبر الـ Buffer Cache: البيانات المعدلة تبقى في الذاكرة حتى تُنقل إلى منطقة اللوغ على القرص.</p>");
    } else if (op == "END_OP") {
        diagramLabel->setStyleSheet("background-color: #9b59b6; color: white; border-radius: 15px;");
        diagramLabel->setText("END_OP\nنهاية العملية");
        explanationText->setHtml(
            "<h2 style='color:#8e44ad;'>END_OP</h2>"
            "<p>عند استدعاء <b>end_op()</b> ينقص النظام العدد <b>outstanding</b> بمقدار واحد.</p>"
            "<p>إذا أصبح <b>outstanding == 0</b> فهذا يعني أن جميع العمليات النشطة انتهت، ويبدأ النظام عملية <b>commit()</b>.</p>"
            "<p>إذا بقي العدد أكبر من صفر، فلن يكتمل الالتزام بعد حتى تنتهي جميع العمليات الأخرى.</p>");
    } else if (op == "WRITE_LOG") {
        diagramLabel->setStyleSheet("background-color: #16a085; color: white; border-radius: 15px;");
        diagramLabel->setText("WRITE_LOG\nكتابة سجل اللوغ");
        explanationText->setHtml(
            "<h2 style='color:#27ae60;'>WRITE_LOG</h2>"
            "<p>تنسخ هذه الخطوة محتوى البلوكات المعدلة من الـ Buffer Cache إلى منطقة اللوغ على القرص.</p>"
        );
    } else if (op == "COMMIT") {
        diagramLabel->setStyleSheet("background-color: #2ecc71; color: white; border-radius: 15px; font-size: 18px;");
        diagramLabel->setText("COMMIT\nنقطة الالتزام");
        explanationText->setHtml(
            "<h2 style='color:#27ae60;'>COMMIT</h2>"
            "<p>عند كتابة هيدر اللوغ إلى القرص، تصبح المعاملة ملتزمة.</p>"
            "<p>الهيدر يحتوي على عدد البلوكات <b>(n)</b> وأرقامها. بعد كتابة هذا الهيدر بنجاح، يمكن للنظام إعادة تنفيذ هذه التعديلات عند الاسترجاع إذا تعطل.</p>"
            "<p>إذا تعطل النظام قبل كتابة الهيدر، فإن التعديلات لا تعتبر ملتزمة.</p>");
    } else if (op == "INSTALL") {
        diagramLabel->setStyleSheet("background-color: #34495e; color: white; border-radius: 15px;");
        diagramLabel->setText("INSTALL\nنقل التعديلات إلى الوجهة الأصلية");
        explanationText->setHtml(
            "<h2 style='color:#2c3e50;'>INSTALL</h2>"
            "<p>بعد نجاح الالتزام، تنفذ <b>install_trans()</b> بنقل البيانات من بلوكات اللوغ على القرص إلى مواقعها الأصلية.</p>"
            
            "<p>بعد النقل يُستدعى <b>bunpin()</b> على البافرات حتى تسمح الـ Buffer Cache بتحريرها لاحقاً.</p>"
            "<p>ثم يُكتب هيدر اللوغ مرة أخرى بقيمة <b>n=0</b> لتفريغ السجل وجعله جاهزاً لعملية جديدة.</p>");
    } else {
        diagramLabel->setStyleSheet("background-color: #7f8c8d; color: white; border-radius: 15px;");
        diagramLabel->setText("LOG EVENT\nشرح عام");
        explanationText->setHtml(
            "<h2 style='color:#7f8c8d;'>حدث في طبقة السجل</h2>"
            "<p>هذا الحدث يمثل خطوة في نظام اللوغ. اختر BEGIN_OP أو LOG_WRITE أو COMMIT أو INSTALL للحصول على شرح تفصيلي لكل مرحلة.</p>");
    }
}