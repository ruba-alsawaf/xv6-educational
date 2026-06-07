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

    Q_INVOKABLE bool authenticate(const QString &username, const QString &password);

    Q_INVOKABLE int getQuizScore(const QString &username, const QString &quizName);
    Q_INVOKABLE void saveQuizScore(const QString &username, const QString &quizName, int score);

    Q_INVOKABLE QString getCurrentUser();

    Q_INVOKABLE void logout();

private:
    QSqlDatabase m_db;
    QString m_currentUser;
};

#endif // DBMANAGER_H