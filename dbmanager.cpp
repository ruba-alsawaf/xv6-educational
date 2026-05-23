#include "dbmanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QVariantMap>

DbManager::DbManager(QObject *parent) : QObject(parent)
{
    // إعداد الاتصال بقاعدة البيانات
    m_db = QSqlDatabase::addDatabase("QSQLITE");

    // تأكدي من تعديل المسار ليتطابق مع مكان وجود ملف الداتابيز الحقيقي عندك
    m_db.setDatabaseName("C:/Users/rubaa/OneDrive/Desktop/xv6-educational-main/events.db");

    if (!m_db.open()) {
        qDebug() << "Error: connection with database failed:" << m_db.lastError().text();
    } else {
        qDebug() << "Database: connection ok";
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
        qDebug() << "Database is NOT open!";
        return list;
    }

    QSqlQuery query;
    query.prepare("SELECT cpu_id, current_pid, current_state, busy_percent "
                  "FROM cpu_metrics "
                  "WHERE cpu_id IN ('cpu0', 'cpu1', 'cpu2') "
                  "ORDER BY id DESC LIMIT 3");

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
        // سطر للتحقق: يطبع عدد العناصر المسترجعة في شاشة الـ Application Output
        qDebug() << "Successfully fetched CPUs count:" << list.size();
    } else {
        qDebug() << "Query failed:" << query.lastError().text();
    }

    return list;
}

QVariantList DbManager::getTimelineMetrics()
{
    QVariantList timeline;
    QStringList cpus = {"CPU0", "CPU1", "CPU2"};

    for (const QString &cpu : cpus) {
        QVariantMap cpuRow;
        cpuRow["label"] = cpu;

        QVariantList blocks;

        QSqlQuery query;
        // جلب آخر 5 لقطات زمنية مخصصة لهذا المعالج بالذات
        query.prepare("SELECT current_pid, current_state "
                      "FROM cpu_metrics "
                      "WHERE cpu_id = :cpuId "
                      "ORDER BY id DESC LIMIT 5");
        query.bindValue(":cpuId", cpu.toLower());

        if (query.exec()) {
            while (query.next()) {
                QVariantMap block;
                QString state = query.value("current_state").toString();
                int pid = query.value("current_pid").toInt();

                // العرض الافتراضي لكل كتلة زمنية مدخلة (يمكنك ضبطه حسب الرغبة)
                block["w"] = 2.0;

                if (state == "UNUSED") {
                    block["c"] = "transparent";
                    block["t"] = "";
                } else {
                    block["c"] = "solid";
                    block["t"] = QString("PID %1").arg(pid);
                }
                // إدراج الكتل في البداية لتظهر مرتبة زمنياً من الأقدم للأحدث
                blocks.prepend(block);
            }
        }

        // إذا كانت الداتابيز فارغة مؤقتاً، نضع كتلة افتراضية فارغة منعاً للأخطاء الرسومية
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
    if (!m_db.isOpen()) return 0;

    QSqlQuery query;
    // حساب الاستهلاك بناءً على كم نواة من النوى الثلاثة الأولى مشغولة بحالة RUNNING فعلياً في آخر لقطة
    query.prepare("SELECT current_state FROM cpu_metrics "
                  "WHERE cpu_id IN ('cpu0', 'cpu1', 'cpu2') "
                  "ORDER BY id DESC LIMIT 3");

    if (query.exec()) {
        int runningCpus = 0;
        while (query.next()) {
            if (query.value(0).toString() == "RUNNING") {
                runningCpus++;
            }
        }
        // حساب النسبة المئوية: (عدد النوى المشغولة / 3) * 100
        return static_cast<int>((runningCpus / 3.0) * 100);
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

    if (!m_db.isOpen()) return states;

    QSqlQuery query;
    // جلب أحدث سجل لقراءة العدادات التراكمية مباشرة
    query.prepare("SELECT total_created, ever_running, ever_sleeping, ever_zombie "
                  "FROM cpu_metrics "
                  "ORDER BY id DESC LIMIT 1");

    if (query.exec() && query.next()) {
        // تمرير القيم التراكمية مباشرة كما هي قادمة من الكيرنل والـ JSON
        states["running"] = query.value("ever_running").toInt();
        states["sleeping"] = query.value("ever_sleeping").toInt();
        states["zombie"] = query.value("ever_zombie").toInt();
        states["total"] = query.value("total_created").toInt();
    }
    return states;
}