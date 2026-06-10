#ifndef DBMANAGER_H
#define DBMANAGER_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QSqlDatabase>

class DbManager : public QObject
{
    Q_OBJECT
public:
    explicit DbManager(QObject *parent = nullptr);
    ~DbManager();

    // جلب المقاييس اللحظية لمعالجات الـ xv6
    Q_INVOKABLE QVariantList getLatestCpuMetrics();

    // جلب بيانات الخط الزمني (Timeline) للمعالجات
    Q_INVOKABLE QVariantList getTimelineMetrics();

    // حساب متوسط استهلاك الـ CPU
    Q_INVOKABLE int getAverageCpuUsage();

    // جلب عدادات حالات العمليات (Running, Sleeping, Zombie)
    Q_INVOKABLE QVariantMap getProcessStatesCount();

    // نظام التحقق وتسجيل الدخول للطلاب
    Q_INVOKABLE bool authenticate(const QString &username, const QString &password);

    // جلب وحفظ سكورات كويزات الـ CPU والـ OS
    Q_INVOKABLE int getQuizScore(const QString &username, const QString &quizName);
    Q_INVOKABLE void saveQuizScore(const QString &username, const QString &quizName, int score);

    // إدارة جلسة المستخدم الحالي
    Q_INVOKABLE QString getCurrentUser();
    Q_INVOKABLE void logout();

private:
    QSqlDatabase m_db;       // كائن الاتصال بقاعدة البيانات
    QString m_currentUser;   // حفظ اسم الطالب المسجل حالياً
    void initDatabase();     // دالة البناء التلقائي للجداول والفهارس
};

#endif // DBMANAGER_H
