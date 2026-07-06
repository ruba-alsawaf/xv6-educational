#include "dbmanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QVariantMap>
#include <QStandardPaths> // 💡 موديول مهم جداً للمسارات الديناميكية
#include <QDir>
#include <QSet>

DbManager::DbManager(QObject *parent) : QObject(parent)
{
    // 1. تحديد مسار ديناميكي آمن ومتوافق مع macOS وويندوز تلقائياً
    QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(appDataPath);
    if (!dir.exists()) {
        dir.mkpath("."); // إنشاء المجلد الخاص بالتطبيق إذا لم يكن موجوداً
    }

    // اسم ملف قاعدة البيانات الخاص بـ xv6
    QString dbPath = dir.filePath("C:/Users/rubaa/Desktop/xv6-educational-main/events.db");

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dbPath);

    // 2. محاولة فتح قاعدة البيانات
    if (!m_db.open()) {
        qWarning() << "❌ Error: database connection failed!" << m_db.lastError().text();
    } else {
        qDebug() << "✅ Database initialized successfully at:" << dbPath;

        // 💡 دمج ميزة الشات بوت: تفعيل WAL Mode لمنع قفل قاعدة البيانات وتسريع الاستعلامات الحية
        QSqlQuery pragmaQuery(m_db);
        pragmaQuery.exec("PRAGMA journal_mode=WAL;");

        // استدعاء دالة الإنشاء التلقائي للمخطط والجداول
        initDatabase();
    }
}

DbManager::~DbManager()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
}

void DbManager::initDatabase()
{
    // حماية: تأكيد أن القاعدة مفتوحة قبل بدء البناء
    if (!m_db.isOpen()) return;

    QSqlQuery query(m_db);

    // قائمة بجميع الجداول الأصلية الخاصة بمشروعك
    QStringList tables = {
        "CREATE TABLE IF NOT EXISTS cpu_metrics(id INTEGER PRIMARY KEY, session_id TEXT, cpu_id TEXT, active INTEGER, current_pid INTEGER, proc_name TEXT, current_state TEXT, context_eip TEXT, context_esp TEXT, busy_percent INTEGER, total_created INTEGER, total_exited INTEGER, ever_running INTEGER, ever_sleeping INTEGER, ever_zombie INTEGER, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)",
        "CREATE TABLE IF NOT EXISTS proc_stats(id INTEGER PRIMARY KEY, session_id TEXT, total_created INTEGER, total_exited INTEGER, current_unused INTEGER, current_used INTEGER, current_sleeping INTEGER, current_runnable INTEGER, current_running INTEGER, current_zombie INTEGER, unique_unused INTEGER, unique_used INTEGER, unique_sleeping INTEGER, unique_running INTEGER, unique_zombie INTEGER, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)",
        "CREATE TABLE IF NOT EXISTS mem_events(id INTEGER PRIMARY KEY AUTOINCREMENT, session_id TEXT NOT NULL, seq INTEGER, tick INTEGER, cpu INTEGER, pid INTEGER, type TEXT, src TEXT, va INTEGER, pa INTEGER, perm TEXT, kind TEXT, name TEXT, old INTEGER, new INTEGER, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)",
        "CREATE TABLE IF NOT EXISTS Students (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL UNIQUE, password TEXT NOT NULL)",
        "CREATE TABLE IF NOT EXISTS QuizScores (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, quiz_name TEXT, score INTEGER, UNIQUE(username, quiz_name))"
    };

    for (const QString &sql : tables) {
        if (!query.exec(sql)) {
            qWarning() << "❌ Error creating table:" << query.lastError().text();
        }
    }

    // الفهارس لسرعة الاستعلام
    query.exec("CREATE INDEX IF NOT EXISTS idx_cpu_metrics_session ON cpu_metrics(session_id)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_proc_stats_session ON proc_stats(session_id)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_mem_events_session_timestamp ON mem_events(session_id, timestamp)");

    // جدول الحضور
    query.exec("CREATE TABLE IF NOT EXISTS Attendance (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, lesson_name TEXT, UNIQUE(username, lesson_name))");

    // إنشاء المستخدم الافتراضي إن لم يكن موجوداً
    query.exec("SELECT COUNT(*) FROM Students WHERE username = 'student1'");
    if (query.next() && query.value(0).toInt() == 0) {
        query.exec("INSERT INTO Students (username, password) VALUES ('student1', '1234')");
        qDebug() << "ℹ️ Default user 'student1' created.";
    }

    qDebug() << "✅ Database schema verified and ready.";
}

QVariantList DbManager::getLatestCpuMetrics()
{
    QVariantList list;
    if (!m_db.isOpen()) {
        if (!m_db.open()) return list;
    }

    // كسر الكاش لضمان جلب البيانات الجديدة الحية
    QSqlQuery pragma(m_db);
    pragma.exec("PRAGMA query_only = OFF;");

    QSqlQuery query(m_db);
    // النسخة الذهبية بالـ UNION ALL لمنع التكرار
    query.prepare(
        "SELECT * FROM ("
        "  SELECT cpu_id, current_pid, current_state, busy_percent "
        "  FROM cpu_metrics WHERE cpu_id='cpu0' ORDER BY id DESC LIMIT 1"
        ") UNION ALL "
        "SELECT * FROM ("
        "  SELECT cpu_id, current_pid, current_state, busy_percent "
        "  FROM cpu_metrics WHERE cpu_id='cpu1' ORDER BY id DESC LIMIT 1"
        ") UNION ALL "
        "SELECT * FROM ("
        "  SELECT cpu_id, current_pid, current_state, busy_percent "
        "  FROM cpu_metrics WHERE cpu_id='cpu2' ORDER BY id DESC LIMIT 1"
        ") ORDER BY cpu_id"
        );

    if (query.exec()) {
        while (query.next()) {
            QVariantMap map;
            map["name"] = query.value("cpu_id").toString().toUpper();

            int pid = query.value("current_pid").toInt();
            QString state = query.value("current_state").toString();

            map["pid"] = (state == "UNUSED") ? "IDLE" : QString("PID %1 (%2)").arg(pid).arg(state.toLower());
            map["state"] = state;
            map["busy"] = query.value("busy_percent").toInt();

            list.append(map);
        }
    } else {
        qWarning() << "Query failed:" << query.lastError().text();
    }

    return list;
}

QVariantList DbManager::getTimelineMetrics()
{
    QVariantList timeline;
    if (!m_db.isOpen()) {
        if (!m_db.open()) return timeline;
    }

    QSqlQuery pragma(m_db);
    pragma.exec("PRAGMA query_only = OFF;");

    QStringList cpus = {"cpu0", "cpu1", "cpu2"};

    for (const QString &cpu : cpus) {
        QVariantMap cpuRow;
        cpuRow["label"] = cpu.toUpper();
        QVariantList blocks;

        QSqlQuery query(m_db);
        query.prepare("SELECT current_pid, current_state, proc_name, context_eip, context_esp "
                      "FROM cpu_metrics "
                      "WHERE cpu_id = :cpuId "
                      "ORDER BY id DESC LIMIT 5");
        query.bindValue(":cpuId", cpu);

        if (query.exec()) {
            while (query.next()) {
                QVariantMap block;
                QString state = query.value("current_state").toString();
                int pid = query.value("current_pid").toInt();

                block["w"] = 2.0;
                block["state"] = state;

                if (state == "UNUSED") {
                    block["c"] = "transparent";
                    block["t"] = "";
                    block["proc_name"] = "";
                    block["eip"] = "0x0";
                    block["esp"] = "0x0";
                } else {
                    block["c"] = "solid";
                    block["t"] = QString("PID %1").arg(pid);
                    block["proc_name"] = query.value("proc_name").toString();
                    block["eip"] = query.value("context_eip").toString();
                    block["esp"] = query.value("context_esp").toString();
                }
                blocks.prepend(block);
            }
        }

        if (blocks.isEmpty()) {
            QVariantMap dummy;
            dummy["w"] = 10.0; dummy["c"] = "transparent"; dummy["t"] = "";
            blocks.append(dummy);
        }

        cpuRow["blocks"] = blocks;
        timeline.append(cpuRow);
    }

    return timeline;
}

int DbManager::getAverageCpuUsage()
{
    if (!m_db.isOpen()) {
        if (!m_db.open()) return 0;
    }

    // كسر الكاش لضمان التحديث المستمر
    QSqlQuery pragma(m_db);
    pragma.exec("PRAGMA query_only = OFF;");

    QSqlQuery query(m_db);

    // ✅ العودة لكودك الذهبي الأصلي اللي كان شغال 100% بدون أي تخبيص
    query.prepare(
        "SELECT current_state FROM cpu_metrics "
        "WHERE id IN ("
        "  SELECT MAX(id) FROM cpu_metrics WHERE cpu_id IN ('cpu0', 'cpu1', 'cpu2') GROUP BY cpu_id"
        ") "
        "ORDER BY cpu_id"
        );

    if (query.exec()) {
        int runningCount = 0;
        int totalCount = 0;
        while (query.next()) {
            if (query.value(0).toString() == "RUNNING") {
                runningCount++;
            }
            totalCount++;
        }
        if (totalCount > 0) {
            return (runningCount * 100) / totalCount;
        }
    } else {
        qWarning() << "❌ CPU Usage Query failed:" << query.lastError().text();
    }

    return 0;
}

QVariantMap DbManager::getProcessStatesCount()
{
    QVariantMap states;
    states["running"] = 0;
    states["sleeping"] = 0;
    states["zombie"] = 0;
    states["total"] = 0;

    if (!m_db.isOpen()) {
        if (!m_db.open()) return states;
    }

    QSqlQuery pragma(m_db);
    pragma.exec("PRAGMA query_only = OFF;");

    QSqlQuery query(m_db);

    // ✅ الحل المنطقي الخاص بكِ: جلب العدادات التراكمية (Cumulative) للعمليات التي مرت على النظام
    query.prepare(
        "SELECT total_created, ever_running, ever_sleeping, ever_zombie "
        "FROM cpu_metrics "
        "ORDER BY id DESC LIMIT 1"
        );

    if (query.exec() && query.next()) {
        // سحب القيم التراكمية المحدثة
        states["running"] = query.value("ever_running").toInt();
        states["sleeping"] = query.value("ever_sleeping").toInt();
        states["zombie"] = query.value("ever_zombie").toInt();

        // إجمالي العمليات التي تم خلقها منذ إقلاع الكيرنل
        states["total"] = query.value("total_created").toInt();
    } else {
        qWarning() << "❌ Query failed:" << query.lastError().text();
    }

    return states;
}

bool DbManager::authenticate(const QString &username, const QString &password)
{
    // شرط حماية يمنع الانهيار ويطبع خطأ واضحاً إذا كانت القاعدة مغلقة
    if (!m_db.isOpen()) {
        qWarning() << "❌ [ERR] Authentication failed: Database is not open!";
        return false;
    }

    QSqlQuery query(m_db);
    query.prepare("SELECT password FROM Students WHERE username = :username");
    query.bindValue(":username", username);

    if (query.exec() && query.next()) {
        QString dbPassword = query.value(0).toString();
        if (password == dbPassword) {
            m_currentUser = username;
            qDebug() << "🔓 [OK] Login successful for user:" << username;
            return true;
        }
    }

    qDebug() << "❌ [ERR] Login failed: Invalid username or password.";
    return false;
}

int DbManager::getQuizScore(const QString &username, const QString &quizName) {
    if (!m_db.isOpen()) return -1;

    QSqlQuery query(m_db);
    if (!query.prepare("SELECT score FROM QuizScores WHERE username = ? AND quiz_name = ?")) {
        qWarning() << "❌ Prepare Failed:" << query.lastError().text();
    }

    query.addBindValue(username);
    query.addBindValue(quizName);

    if (query.exec()) {
        if (query.next()) {
            return query.value(0).toInt();
        }
    } else {
        qWarning() << "❌ Get Score SQL Error:" << query.lastError().text();
    }
    return -1;
}

void DbManager::saveQuizScore(const QString &username, const QString &quizName, int score) {
    if (!m_db.isOpen()) return;

    QSqlQuery query(m_db);
    if (!query.prepare("INSERT OR REPLACE INTO QuizScores (username, quiz_name, score) VALUES (?, ?, ?)")) {
        qWarning() << "❌ Prepare Failed:" << query.lastError().text();
    }

    query.addBindValue(username);
    query.addBindValue(quizName);
    query.addBindValue(score);

    if (!query.exec()) {
        qWarning() << "❌ Save Score SQL Error:" << query.lastError().text();
    } else {
        qDebug() << "✅ Success! Score saved for:" << username;
    }
}

QString DbManager::getCurrentUser() {
    return m_currentUser;
}

void DbManager::logout() {
    m_currentUser = ""; // مسح اسم المستخدم الحالي بأمان
    qDebug() << "🚪 User logged out successfully.";
}

void DbManager::markAttended(const QString &username, const QString &lessonName) {
    if (!m_db.isOpen()) return;
    QSqlQuery q(m_db);
    q.prepare("INSERT OR IGNORE INTO Attendance (username, lesson_name) VALUES (?, ?)");
    q.addBindValue(username);
    q.addBindValue(lessonName);
    if (!q.exec()) qWarning() << "❌ markAttended failed:" << q.lastError().text();
    else qDebug() << "✅ Attended:" << username << lessonName;
}

bool DbManager::isAttended(const QString &username, const QString &lessonName) {
    if (!m_db.isOpen()) return false;
    QSqlQuery q(m_db);
    q.prepare("SELECT COUNT(*) FROM Attendance WHERE username = ? AND lesson_name = ?");
    q.addBindValue(username);
    q.addBindValue(lessonName);
    if (q.exec() && q.next()) return q.value(0).toInt() > 0;
    return false;
}

QVariantList DbManager::getAttendedLessons(const QString &username) {
    QVariantList list;
    if (!m_db.isOpen()) return list;
    QSqlQuery q(m_db);
    q.prepare("SELECT lesson_name FROM Attendance WHERE username = ? ORDER BY id ASC");
    q.addBindValue(username);
    if (q.exec()) while (q.next()) list.append(q.value(0).toString());
    return list;
}

bool DbManager::changePassword(const QString &username, const QString &oldPassword, const QString &newPassword) {
    if (!m_db.isOpen()) return false;
    QSqlQuery q(m_db);
    q.prepare("SELECT password FROM Students WHERE username = ?");
    q.addBindValue(username);
    if (q.exec() && q.next()) {
        if (q.value(0).toString() != oldPassword) return false;
        QSqlQuery upd(m_db);
        upd.prepare("UPDATE Students SET password = ? WHERE username = ?");
        upd.addBindValue(newPassword);
        upd.addBindValue(username);
        return upd.exec();
    }
    return false;
}

QVariantMap DbManager::getLiveMemoryMetrics()
{
    QVariantMap metrics;
    // قيم افتراضية قياسية لـ 128MB (حجم ذاكرة xv6 الافتراضي)
    // 128MB / 4KB (حجم الصفحة الواحدة) = 32768 صفحة
    metrics["totalPages"] = 32768;
    metrics["freePages"] = 32768;
    metrics["usedPages"] = 0;
    metrics["fragmentation"] = 0;

    if (!m_db.isOpen()) return metrics;

    // كسر الكاش لضمان جلب قراءات حية مستمرة من الهاردسك
    QSqlQuery pragma(m_db);
    pragma.exec("PRAGMA query_only = OFF;");

    // 1. حسابات خريطة الـ 256 مربعاً للشبكة (Grid)
    QVariantList gridStates;

    // النواة في xv6 تحجز أول 4MB دائماً من الذاكرة (أول 8 كتل ثابتة للنظام ولا تتغير)
    for(int i = 0; i < 256; i++) {
        if (i < 8) {
            gridStates.append(2); // 2 = Kernel (Indigo)
        } else {
            gridStates.append(0); // 0 = Free مبدئياً لحين فحص الأحداث
        }
    }

    // 2. جلب أحدث الأحداث من الداتابيز لترجمتها على الشبكة
    // جلب كمية كافية من السجلات لضمان تغطية العناوين النشطة مؤخراً ودعم دقة النمط الزمني
    QSqlQuery memQuery("SELECT type, pa FROM mem_events ORDER BY seq DESC LIMIT 500", m_db);

    if (memQuery.exec()) {
        QSet<int> processedBlocks; // حماية: لتسجيل الحالة الأحدث فقط لكل كتلة ومنع التكرار البصري
        int userUsedBlocks = 0;

        while (memQuery.next()) {
            QString type = memQuery.value("type").toString();
            quint64 pa = memQuery.value("pa").toULongLong();

            // تحويل العنوان الفيزيائي pa إلى الـ Index المقابل له في الـ Grid (0-255)
            // كل كتلة تمثل 512KB أي (0x80000 بايت)
            if (pa >= 0x80000000 && pa <= 0x88000000) {
                int blockIdx = (pa - 0x80000000) / 0x80000;

                // التحقق من الحواف وأن الكتلة ليست تابعة للنواة الثابتة
                if (blockIdx >= 8 && blockIdx < 256) {
                    // إذا لم نقم بتحديث هذه الكتلة من قبل (أي هذا هو الحدث الأحدث لها زمنياً)
                    if (!processedBlocks.contains(blockIdx)) {
                        processedBlocks.insert(blockIdx);

                        if (type == "ALLOC" || type == "GROW") {
                            gridStates[blockIdx] = 1; // 1 = User (Purple)
                            userUsedBlocks++;
                        } else if (type == "FREE") {
                            gridStates[blockIdx] = 0; // 0 = Free (Dark)
                        }
                    }
                }
            }
        }

        // 3. الحسابات الإحصائية الدقيقة المربوطة بالـ Progress Bars بالواجهة
        int kernelBlocks = 8;
        int totalUsedBlocks = userUsedBlocks + kernelBlocks;
        int freeBlocks = 256 - totalUsedBlocks;

        // تحويل الكتل إلى عدد صفحات (كل كتلة 512KB تحتوي على 128 صفحة بحجم 4KB)
        metrics["freePages"] = (freeBlocks * 128);
        metrics["usedPages"] = (totalUsedBlocks * 128);
        metrics["totalPages"] = 32768;

        // حساب نسبة التجزئة الفعلية (Fragmentation) بناءً على الكتل المستهلكة
        metrics["fragmentation"] = freeBlocks > 0 ? (userUsedBlocks * 100) / (userUsedBlocks + freeBlocks) : 0;
    } else {
        qWarning() << "❌ Memory Map Query failed:" << memQuery.lastError().text();
    }

    metrics["gridStates"] = gridStates;
    return metrics;
}
