#include "dbmanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QVariantMap>
#include <QSqlDatabase>

DbManager::DbManager(QObject *parent) : QObject(parent)
{
    // تعريف المسار وفتح قاعدة البيانات
    QString dbPath = "C:/Users/rubaa/Desktop/xv6-educational-main/events.db";
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dbPath);

    if (!m_db.open()) {
        qWarning() << "❌ Error: Admin connection failed!";
    } else {
        qDebug() << "✅ Admin connected to:" << dbPath;
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
    QSqlQuery query(m_db);
    // إنشاء الجداول إذا لم تكن موجودة
    QStringList tables = {
        "CREATE TABLE IF NOT EXISTS Students (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL UNIQUE, password TEXT NOT NULL)",
        "CREATE TABLE IF NOT EXISTS QuizScores (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, quiz_name TEXT, score INTEGER, UNIQUE(username, quiz_name))"
    };

    for (const QString &sql : tables) {
        if (!query.exec(sql)) {
            qWarning() << "❌ Table error:" << query.lastError().text();
        }
    }
}

bool DbManager::addStudent(const QString &username, const QString &password)
{
    if (!m_db.isOpen()) return false;
    QSqlQuery query(m_db);
    query.prepare("INSERT INTO Students (username, password) VALUES (?, ?)");
    query.addBindValue(username);
    query.addBindValue(password);

    if (!query.exec()) {
        qWarning() << "❌ Add student error:" << query.lastError().text();
        return false;
    }
    return true;
}

QVariantList DbManager::getStudentScores(const QString &username)
{
    QVariantList scores;
    if (!m_db.isOpen()) return scores;

    QSqlQuery query(m_db);
    query.prepare("SELECT quiz_name, score FROM QuizScores WHERE username = ?");
    query.addBindValue(username);

    if (query.exec()) {
        while (query.next()) {
            QVariantMap map;
            map["quizName"] = query.value("quiz_name").toString();
            map["score"] = query.value("score").toInt();
            scores.append(map);
        }
    }
    return scores;
}

QVariantList DbManager::getAllStudents()
{
    QVariantList students;
    if (!m_db.isOpen()) return students;

    QSqlQuery query(m_db);
    if (query.exec("SELECT username FROM Students")) {
        while (query.next()) {
            students.append(query.value(0).toString());
        }
    }
    return students;
}