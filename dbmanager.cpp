#include "dbmanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QVariantMap>

DbManager::DbManager(QObject *parent) : QObject(parent)
{
    // إعداد الاتصال بقاعدة البيانات
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName("C:/Users/rubaa/OneDrive/Desktop/xv6-educational-main/events.db");

    if (!m_db.open()) {
        qWarning() << "Error: connection with database failed:" << m_db.lastError().text();
    } else {
        qDebug() << "Database: connection ok";
        // تفعيل WAL Mode لمنع قفل قاعدة البيانات
        QSqlQuery pragmaQuery(m_db);
        pragmaQuery.exec("PRAGMA journal_mode=WAL;");
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