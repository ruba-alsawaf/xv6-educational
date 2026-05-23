#ifndef DBMANAGER_H
#define DBMANAGER_H

#include <QObject>
#include <QVariantList>
#include <QSqlDatabase>

class DbManager : public QObject
{
    Q_OBJECT
public:
    explicit DbManager(QObject *parent = nullptr);
    ~DbManager();

    // الدالة القديمة
    Q_INVOKABLE QVariantList getLatestCpuMetrics();

    // === السطر الذي يجب إضافته هنا لحل المشكلة ===
    Q_INVOKABLE QVariantList getTimelineMetrics();

    Q_INVOKABLE int getAverageCpuUsage();
    Q_INVOKABLE QVariantMap getProcessStatesCount();
private:
    QSqlDatabase m_db;
};

#endif // DBMANAGER_H