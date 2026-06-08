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

    // الدوال المخصصة لإدارة الطلاب
    Q_INVOKABLE bool addStudent(const QString &username, const QString &password);
    Q_INVOKABLE QVariantList getStudentScores(const QString &username);
    Q_INVOKABLE QVariantList getAllStudents();

private:
    QSqlDatabase m_db;
    void initDatabase();
};

#endif // DBMANAGER_H