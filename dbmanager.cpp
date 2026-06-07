#include "dbmanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QVariantMap>

DbManager::DbManager(QObject *parent) : QObject(parent)
{
    // 1. تحديد المسار
    QString dbPath = "C:/Users/rubaa/Desktop/xv6-educational-main/events.db";
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dbPath);

    if (!m_db.open()) {
        qWarning() << "Error: connection failed!";
    } else {
        qDebug() << "✅ Database path:" << dbPath;

        QSqlQuery query(m_db);

        // 2. التحقق من الأعمدة (Migration)
        // هذا الكود يفحص هل عمود quiz_name موجود؟
        bool hasQuizColumn = false;
        query.exec("PRAGMA table_info(QuizScores)");
        while (query.next()) {
            if (query.value("name").toString() == "quiz_name") {
                hasQuizColumn = true;
            }
        }

        // إذا لم يكن موجوداً، أضيفيه برمجياً في النسخة التي يقرأ منها البرنامج
        if (!hasQuizColumn) {
            qDebug() << "⚠️ العمود مفقود، جاري التحديث...";
            query.exec("ALTER TABLE QuizScores ADD COLUMN quiz_name TEXT");
        }

        qDebug() << "✅ Database ready with correct schema.";
    }
}
DbManager::~DbManager()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
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
    // (تأكدي من تغيير m_db إلى اسم متغير قاعدة البيانات المستخدم لديكِ في الكلاس)
    if (!m_db.isOpen()) {
        qDebug() << "[ERR] Database is not open!";
        return false;
    }

    QSqlQuery query(m_db);
    query.prepare("SELECT password FROM Students WHERE username = :username");
    query.bindValue(":username", username);

    if (query.exec() && query.next()) {
        QString dbPassword = query.value(0).toString();
        if (password == dbPassword) {
            m_currentUser = username;
            qDebug() << "[OK] Login successful for user:" << username;
            return true;
        }
    }

    qDebug() << "[ERR] Login failed: Invalid username or password.";
    return false;
}

int DbManager::getQuizScore(const QString &username, const QString &quizName) {
    if (!m_db.isOpen()) return -1;

    QSqlQuery query(m_db);
    // نستخدم ? للربط الموضعي (أضمن 100% من الـ :)
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
    // نستخدم ? للربط الموضعي
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
    m_currentUser = ""; // مسح اسم المستخدم الحالي
    qDebug() << "🚪 User logged out.";
}