#include "bCacheBufferTheory.h"
#include <QLabel>
#include <QGroupBox>

TheoryWidget::TheoryWidget(QWidget *parent) : QWidget(parent) {
    QVBoxLayout *mainLayout = new QVBoxLayout(this);

    // شريط علوي للتنقل
    QHBoxLayout *navBar = new QHBoxLayout();
    QPushButton *btn1 = new QPushButton("1. نظرة عامة");
    QPushButton *btn2 = new QPushButton("2. شرح التوابع");
    QPushButton *btn3 = new QPushButton("3. سيناريو العمل");
    navBar->addWidget(btn1);
    navBar->addWidget(btn2);
    navBar->addWidget(btn3);
    mainLayout->addLayout(navBar);

    stack = new QStackedWidget(this);
    setupOverviewPage();
    setupFunctionsPage();
    setupScenarioPage();
    mainLayout->addWidget(stack);

    connect(btn1, &QPushButton::clicked, this, &TheoryWidget::showOverview);
    connect(btn2, &QPushButton::clicked, this, &TheoryWidget::showFunctions);
    connect(btn3, &QPushButton::clicked, this, &TheoryWidget::showScenario);
}

void TheoryWidget::setupOverviewPage() {
    overviewText = new QTextEdit();
    overviewText->setReadOnly(true);
    overviewText->setHtml(R"(
        <div dir='rtl' style='font-family: Arial; font-size: 14pt; line-height: 1.6;'>
            <h2 style='color: #2c3e50;'>طبقة مخزن البفر (Buffer Cache Layer)</h2>
            <p>هذه الطبقة هي المسؤول الأول عن إدارة التعامل بين نظام الملفات والقرص الصلب.</p>
            <b style='color: #e67e22;'>وظائفها الأساسية:</b>
            <ul>
                <li><b>المزامنة:</b> ضمان وجود نسخة واحدة فقط من "البلوك" في الذاكرة لضمان اتساق البيانات.</li>
                <li><b>التخزين المؤقت:</b> الاحتفاظ بالبيانات الأكثر استخداماً لتسريع الوصول إليها.</li>
            </ul>
            <p>تعتمد الطبقة على هيكل بيانات <b>Double Linked List</b> لتطبيق خوارزمية <b>LRU</b> (الأقل استخداماً مؤخراً).</p>
        </div>
    )");
    stack->addWidget(overviewText);
}

void TheoryWidget::setupFunctionsPage() {
    QWidget *page = new QWidget();
    QHBoxLayout *layout = new QHBoxLayout(page);

    functionList = new QListWidget();
    functionList->addItems({"binit", "bget", "bread", "bwrite", "brelse"});
    functionList->setMaximumWidth(150);

    functionDetail = new QTextEdit();
    functionDetail->setReadOnly(true);
    functionDetail->setPlaceholderText("اختر تابعاً لعرض تفاصيله...");

    layout->addWidget(functionList);
    layout->addWidget(functionDetail);
    stack->addWidget(page);

    connect(functionList, &QListWidget::itemClicked, this, &TheoryWidget::onFunctionClicked);
}

void TheoryWidget::onFunctionClicked(QListWidgetItem *item) {
    QString name = item->text();
    QString detail;

    if (name == "binit") {
        detail = R"(
            <h3>binit (التهيئة)</h3>
            <p dir='rtl'>يتم استدعاؤه لمرة واحدة عند إقلاع الكيرنل. وظيفته:</p>
            <ul dir='rtl'>
                <li>إنشاء مصفوفة ثابتة من البفرات (NBUF).</li>
                <li>ربط هذه البفرات في <b>قائمة مزدوجة (Circular Doubly Linked List)</b>.</li>
                <li>تجهيز قفل رئيسي للكاش <b>bcache.lock</b> لحماية القائمة من الوصول المتزامن.</li>
            </ul>)";
    } 
    else if (name == "bget") {
        detail = R"(
            <h3>bget (البحث والحجز)</h3>
            <p dir='rtl'>هذا هو التابع الأهم، يقوم بالآتي:</p>
            <ol dir='rtl'>
                <li>يأخذ قفل الكاش العام <b>bcache.lock</b>.</li>
                <li><b>عملية الفحص (Scan):</b> يبحث في القائمة عن البلوك المطلوب (رقم الجهاز ورقم السيكتور).</li>
                <li><b>في حال الـ Hit:</b> يزيد الـ <b>refcnt</b> بمقدار 1، يحرر قفل الكاش العام، ثم يحاول أخذ قفل النوم <b>sleep-lock</b> الخاص بهذا البفر لضمان خصوصية الاستخدام.</li>
                <li><b>في حال الـ Miss:</b> يبحث عن بفر قديم <b>(refcnt == 0)</b>، يبدأ البحث من نهاية القائمة (الأقدم)، يعيد تخصيصه للبلوك الجديد، يصفر الـ <b>valid</b>، يزيد الـ <b>refcnt</b> ويأخذ قفل البفر.</li>
            </ol>)";
    } 
    else if (name == "bread") {
        detail = R"(
            <h3>bread (القراءة الفعالة)</h3>
            <p dir='rtl'>يعتمد على bget للحصول على بفر مقفل:</p>
            <ul dir='rtl'>
                <li>إذا وجد أن <b>valid == 1</b>: فهذا يعني أن البيانات موجودة وجاهزة، يعيد البفر فوراً.</li>
                <li>إذا وجد أن <b>valid == 0</b>: يستدعي تعريف القرص (Disk Driver) ليقرأ البيانات فعلياً من القرص ويضعها في البفر، ثم يضبط <b>valid = 1</b>.</li>
            </ul>)";
    } 
    else if (name == "bwrite") {
        detail = R"(
            <h3>bwrite (الكتابة للديسك)</h3>
            <p dir='rtl'>يجب استدعاؤه قبل تحرير البفر إذا قمنا بتعديل البيانات:</p>
            <ul dir='rtl'>
                <li>يتأكد أن العملية تملك قفل البفر (Locked).</li>
                <li>يطلب من تعريف القرص (virtio_disk_rw) كتابة محتويات البفر الحالية إلى السيكتور المخصص له في الهارد ديسك.</li>
            </ul>)";
    } 
    else if (name == "brelse") {
        detail = R"(
            <h3>brelse (التحرير)</h3>
            <p dir='rtl'>يُستدعى عندما تنتهي العملية من استخدام البفر:</p>
            <ul dir='rtl'>
                <li>يحرر قفل النوم <b>sleep-lock</b> لكي تستطيع عمليات أخرى استخدامه.</li>
                <li>يأخذ قفل الكاش العام <b>bcache.lock</b>.</li>
                <li>ينقص الـ <b>refcnt</b> بمقدار 1.</li>
                <li>إذا أصبح الـ <b>refcnt == 0</b>، يحرك البفر إلى مقدمة القائمة (Head) ليكون هو "الأحدث استخداماً"، مما يحميه من إعادة التدوير فوراً.</li>
            </ul>)";
    }

    functionDetail->setHtml("<div dir='rtl'>" + detail + "</div>");
}

void TheoryWidget::setupScenarioPage() {
    scenarioText = new QTextEdit();
    scenarioText->setReadOnly(true);
    scenarioText->setHtml(R"(
        <div dir='rtl' style='font-family: Arial; font-size: 13pt; line-height: 1.5;'>
            <h2 style='color: #27ae60;'>التسلسل الزمني لعملية القراءة (Scenario)</h2>
            <p>لنتخيل أن عملية تريد قراءة "بلوك 100":</p>
            <b>المرحلة 1: البحث</b>
            <p>تستدعي العملية <b>bread(dev, 100)</b> التي بدورها تنادي <b>bget</b>. هنا يتم أخذ <i>bcache.lock</i> لمنع أي عملية أخرى من تغيير هيكل القائمة.</p>
            
            <b>المرحلة 2: القرار (Hit or Miss)</b>
            <ul>
                <li>إذا وجدناه: نزيد <b>refcnt</b> ونأخذ <i>sleep-lock</i> للبفر ونترك قفل الكاش.</li>
                <li>إذا لم نجده: نبحث عن بفر <b>refcnt == 0</b>، نغير هويته للبلوك 100، نجعل <b>valid = 0</b>، ونأخذ قفله.</li>
            </ul>

            <b>المرحلة 3: جلب البيانات</b>
            <p>بما أننا في <i>bread</i> والبيانات غير صالحة (valid=0)، يذهب الكيرنل للقرص الصلب. العملية "تنام" حتى ينتهي القرص من القراءة.</p>

            <b>المرحلة 4: الانتهاء</b>
            <p>عندما تنهي العملية قراءتها، تستدعي <b>brelse</b>. هذا التابع يحرر القفل ويجعل البفر متاحاً لغيرنا.</p>
        </div>
    )");
    stack->addWidget(scenarioText);
}

void TheoryWidget::showOverview() { stack->setCurrentIndex(0); }
void TheoryWidget::showFunctions() { stack->setCurrentIndex(1); }
void TheoryWidget::showScenario() { stack->setCurrentIndex(2); }