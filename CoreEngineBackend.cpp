#include "CoreEngineBackend.h"

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QVariantMap>
#include <QMap>
#include <QSqlRecord>
#include <QElapsedTimer>
#include <QSqlError>
#include <QFileInfo>


CoreEngineBackend::CoreEngineBackend(QObject *parent)
    : QObject(parent)
{
    m_db = QSqlDatabase::addDatabase("QSQLITE");


    m_db.setDatabaseName(
        "C:/Users/rubaa/Desktop/xv6-educational-main/events.db"
        );

    qDebug() << QSqlDatabase::drivers();
    if(!m_db.open())
    {
        qDebug() << "Database failed:";
        qDebug() << m_db.lastError().text();
        return;
    }


    qDebug() << "Database connected successfully";

    QFileInfo info(
        "C:/Users/rubaa/Desktop/xv6-educational-main/events.db"
    );

    qDebug() << "DB exists =" << info.exists();
    qDebug() << "DB size =" << info.size();

    QSqlQuery test(m_db);

    if(test.exec("SELECT COUNT(*) FROM fs_events"))
    {
        if(test.next())
        {
            qDebug() << "fs_events rows =" << test.value(0).toInt();
        }
    }
    else
    {
        qDebug() << "COUNT ERROR =" << test.lastError().text();
    }
    QSqlQuery pragma(m_db);
    //pragma.exec("PRAGMA journal_mode=WAL;");

    pragma.exec("PRAGMA busy_timeout=1000;");
    pragma.exec("PRAGMA synchronous=NORMAL;");
    pragma.exec("PRAGMA cache_size=-20000;");
    pragma.exec("PRAGMA temp_store=MEMORY;");


    qDebug() << "Database connected successfully";

    connect(&m_timer,
            &QTimer::timeout,
            this,
            &CoreEngineBackend::refreshData);

    connect(&m_timelineTimer,
            &QTimer::timeout,
            this,
            [this]()
            {
                refreshTimeline("");
            });

    refreshData();
    refreshTimeline("");

    m_timer.start(3000);
    m_timelineTimer.start(3000);
}



int CoreEngineBackend::totalBuffers() const
{
    return m_totalBuffers;
}

int CoreEngineBackend::busyBuffers() const
{
    return m_busyBuffers;
}

int CoreEngineBackend::freeBuffers() const
{
    return m_freeBuffers;
}

double CoreEngineBackend::usagePercent() const
{
    return m_usagePercent;
}

QString CoreEngineBackend::hitRate() const
{
    return m_hitRate;
}

QString CoreEngineBackend::hits() const
{
    return m_hits;
}

QString CoreEngineBackend::misses() const
{
    return m_misses;
}

QString CoreEngineBackend::activeInodes() const
{
    return m_activeInodes;
}

QString CoreEngineBackend::usedInodes() const
{
    return m_usedInodes;
}

QString CoreEngineBackend::freeInodes() const
{
    return m_freeInodes;
}

QString CoreEngineBackend::logStatus() const
{
    return m_logStatus;
}

QString CoreEngineBackend::outstanding() const
{
    return m_outstanding;
}

QString CoreEngineBackend::committing() const
{
    return m_committing;
}

QVariantList CoreEngineBackend::bufferModel() const
{
    return m_bufferModel;
}

QVariantList CoreEngineBackend::timelineModel() const
{
    return m_timelineModel;
}

QVariantList CoreEngineBackend::recentEventsModel() const
{
    return m_recentEventsModel;
}

QString CoreEngineBackend::inspectorText() const
{
    return m_inspectorText;
}
QVariantList CoreEngineBackend::directoryTreeModel() const { return m_directoryTreeModel; }
QVariantList CoreEngineBackend::fdTableModel() const { return m_fdTableModel; }

void CoreEngineBackend::refreshData()
{
    QElapsedTimer timer;
    timer.start();

    qDebug() << "refreshData START";
    if(!m_db.isOpen())
    {
        if(!m_db.open())
            return;
    }

    QSqlQuery query(m_db);
    QSqlQuery q(m_db);

    if(q.exec("SELECT COUNT(*) FROM fs_events"))
    {
        if(q.next())
        {
            qDebug() << "EVENT COUNT =" << q.value(0).toInt();
        }
    }
    // 1. استعلام موحد للـ BUFFER CACHE (بدلاً من 4 استعلامات!)
    if(query.exec(
            "SELECT COUNT(*), "
            "SUM(CASE WHEN refcnt > 0 THEN 1 ELSE 0 END), "
            "SUM(CASE WHEN refcnt = 0 THEN 1 ELSE 0 END), "
            "ROUND((CAST(SUM(CASE WHEN refcnt > 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100, 2) "
            "FROM buffer_cache_state"))
    {
        if(query.next())
        {
            m_totalBuffers = query.value(0).toInt();
            m_busyBuffers = query.value(1).toInt();
            m_freeBuffers = query.value(2).toInt();
            m_usagePercent = query.value(3).toDouble();
        }
    }
    else
    {
        qDebug() << "buffer_cache_state ERROR:"
                 << query.lastError().text();
    }

    // 2. استعلام موحد للـ INODES (بدلاً من 3 استعلامات!)
    if(query.exec("SELECT "
                   "COUNT(*), "
                   "SUM(CASE WHEN refcnt > 0 THEN 1 ELSE 0 END), "
                   "SUM(CASE WHEN refcnt = 0 THEN 1 ELSE 0 END) "
                   "FROM inode_state"))
    {
        if(query.next()) {
            m_activeInodes = query.value(0).toString();
            m_usedInodes = query.value(1).toString();
            m_freeInodes = query.value(2).toString();
        }
    }

    // 3. استعلام موحد للـ HIT RATE (بدلاً من 3 استعلامات ثقيلة على جدول الأحداث)
    if(query.exec("SELECT "
                   "ROUND((CAST(SUM(CASE WHEN op_name='BGET_HIT' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100, 2), "
                   "SUM(CASE WHEN op_name='BGET_HIT' THEN 1 ELSE 0 END), "
                   "SUM(CASE WHEN op_name='BGET_MISS' THEN 1 ELSE 0 END) "
                   "FROM fs_events WHERE layer='BCACHE' AND op_name IN ('BGET_HIT','BGET_MISS')"))
    {
        if(query.next()) {
            m_hitRate = QString::number(query.value(0).toDouble()) + "%";
            m_hits = query.value(1).toString();
            m_misses = query.value(2).toString();
        }
    }

    // 4. استعلام حالة الـ LOG (كما هو لأنه استعلام خفيف)
    if(query.exec("SELECT outstanding, committing FROM log_state WHERE id = 1")) {
        if(query.next()) {
            int out = query.value(0).toInt();
            int com = query.value(1).toInt();
            m_outstanding = QString::number(out);
            m_committing = QString::number(com);
            m_logStatus = (com > 0) ? "ACTIVE" : ((out > 0) ? "PENDING" : "IDLE");
        }
    }

    // 5. تحديث الـ Buffer Model
    QVariantList newBufferModel;
    if(query.exec("SELECT buf_id, blockno, refcnt, is_valid FROM buffer_cache_state ORDER BY buf_id")) {
        while(query.next()) {
            QVariantMap item;
            item["id"] = query.value(0).toInt();
            item["block"] = query.value(1).toInt();
            item["ref"] = query.value(2).toInt();
            item["valid"] = query.value(3).toInt();
            newBufferModel.append(item);
        }
    }

    m_bufferModel = newBufferModel;

    // 6. تحديث الأحداث الأخيرة RECENT EVENTS
    QVariantList newEventsModel;
    if(query.exec("SELECT layer, tick, pid, details FROM fs_events ORDER BY id DESC LIMIT 10")) {
        while(query.next()) {
            QVariantMap item;
            item["layer"] = query.value(0).toString();
            item["tick"] = query.value(1).toString();
            item["pid"] = query.value(2).toString();
            item["details"] = query.value(3).toString();
            newEventsModel.append(item);
        }
    }
    m_recentEventsModel = newEventsModel;

    // 7. تحديث Directory Tree
    QVariantList newTreeModel;
    QString treeSql = "WITH tree AS (SELECT child_inum, parent_inum, name, path, inode_type, "
                      "(LENGTH(path) - LENGTH(REPLACE(path, '/', ''))) - 1 AS depth "
                      "FROM directory_state WHERE name NOT IN ('.', '..')) "
                      "SELECT printf('%s%s [%s]', substr('                ', 1, depth * 2), "
                      "CASE WHEN name = '/' THEN '/' ELSE '└── ' || name END, "
                      "CASE inode_type WHEN 1 THEN 'DIR' WHEN 2 THEN 'FILE' WHEN 3 THEN 'DEVICE' ELSE 'UNKNOWN' END) "
                      "FROM tree ORDER BY path;";

    if(query.exec(treeSql)) {
        while(query.next()) {
            newTreeModel.append(query.value(0).toString());
        }
    }
    m_directoryTreeModel = newTreeModel;

    // 8. تحديث File Descriptor Table
    QVariantList newFdModel;
    QString fdSql = "SELECT pid, fd_number, "
                    "CASE WHEN file_type IN ('1', 'FD_PIPE', 'PIPE') THEN 'PIPE' "
                    "WHEN file_type IN ('2', 'FD_INODE', 'INODE') THEN 'INODE' "
                    "WHEN file_type IN ('3', 'FD_DEVICE', 'DEVICE') THEN 'DEVICE' "
                    "ELSE COALESCE(file_type, 'UNKNOWN') END AS type, "
                    "CASE WHEN file_type IN ('1', 'FD_PIPE', 'PIPE') THEN 'pipe:[' || COALESCE(file_object_id, inum) || ']' ELSE path END AS target, "
                    "file_off, "
                    "CASE WHEN readable = 1 AND writable = 1 THEN 'RW' WHEN readable = 1 THEN 'R' WHEN writable = 1 THEN 'W' ELSE '-' END AS flags, "
                    "file_ref "
                    "FROM process_fd_state ORDER BY pid, fd_number;";

    if(query.exec(fdSql)) {
        while(query.next()) {
            QVariantMap item;
            item["pid"] = query.value(0).toInt();
            item["fd"] = query.value(1).toInt();
            item["type"] = query.value(2).toString();
            item["target"] = query.value(3).toString();
            item["offset"] = query.value(4).toInt();
            item["flags"] = query.value(5).toString();
            item["ref"] = query.value(6).toInt();
            newFdModel.append(item);
        }
    }
    m_fdTableModel = newFdModel;

    emit dataChanged();
    qDebug() << "bufferModel size =" << m_bufferModel.size();
    qDebug() << "recentEvents size =" << m_recentEventsModel.size();
    qDebug() << "directoryTree size =" << m_directoryTreeModel.size();
    qDebug() << "fdTable size =" << m_fdTableModel.size();

    qDebug() << "refreshData =" << timer.elapsed() << "ms";
}
void CoreEngineBackend::refreshTimeline(QString pid)
{
    QElapsedTimer timer;
    timer.start();

    qDebug() << "refreshTimeline START";
    if(!m_db.isOpen())
    {
        if(!m_db.open())
            return;
    }



    QVariantList newTimelineModel;

    QSqlQuery query(m_db);



    QString sql =
        "SELECT id, tick, pid, layer, op_name "
        "FROM ( "
        "   SELECT id, tick, pid, layer, op_name, "
        "   ROW_NUMBER() OVER ( "
        "       PARTITION BY pid "
        "       ORDER BY id DESC "
        "   ) AS rn "
        "   FROM fs_events ";

    if(!pid.isEmpty())
    {
        sql += " WHERE pid = " + pid;
    }

    sql +=
        ") "
        "WHERE rn <= 15 "
        "ORDER BY pid, tick";


    if(!query.exec(sql))
    {
        qDebug() << "TIMELINE ERROR:"
                 << query.lastError().text();
        return;
    }

    struct Event {
        int id;
        int tick;
        QString layer;
        QString op;
    };

    QMap<int, QList<Event>> pidEvents;

    while(query.next())
    {
        Event e;

        e.id = query.value(0).toInt();
        e.tick = query.value(1).toInt();

        int pidValue = query.value(2).toInt();

        e.layer = query.value(3).toString();
        e.op = query.value(4).toString();
        pidEvents[pidValue].append(e);
    }

    for(auto it = pidEvents.begin(); it != pidEvents.end(); ++it)
    {
        QVariantMap row;

        row["pid"] = it.key();

        QVariantList eventsList;

        for(const Event &e : it.value())
        {
            QVariantMap ev;

            QString color = "#57606a";

            if(e.layer == "BCACHE")
                color = "#238636";
            else if(e.layer == "LOG")
                color = "#1f6feb";
            else if(e.layer == "INODE")
                color = "#bf5af2";
            else if(e.layer == "FS")
                color = "#d29922";

            ev["id"] = e.id;
            ev["tick"] = e.tick;
            ev["op"] = e.op;
            ev["color"] = color;

            eventsList.append(ev);
        }

        row["events"] = eventsList;

        newTimelineModel.append(row);
    }
    qDebug() << "Timeline rows =" << newTimelineModel.size();
    m_timelineModel = newTimelineModel;
    emit timelineChanged();
    qDebug() << "Timeline rows =" << newTimelineModel.size();
    qDebug() << "refreshTimeline =" << timer.elapsed() << "ms";
}

void CoreEngineBackend::inspectEvent(int eventId)
{

    if(!m_db.isOpen())
    {
        if(!m_db.open())
            return;
    }

    QSqlQuery query(m_db);





    query.prepare(
        "SELECT * FROM fs_events WHERE id = ?");

    query.addBindValue(eventId);

    if(query.exec() && query.next())
    {
        QString details;

        QSqlRecord rec = query.record();

        for(int i = 0; i < rec.count(); ++i)
        {
            QString field = rec.fieldName(i);

            QVariant value = query.value(i);

            if(!value.isNull() && !value.toString().isEmpty())
            {
                details += field + ": " + value.toString() + "\n";
            }
        }

        m_inspectorText = details;

        emit inspectorChanged();
    }
}