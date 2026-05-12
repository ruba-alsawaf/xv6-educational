#include "mainwindow.h"
#include <QApplication>
#include <QSqlDatabase> // أضيفي هذا السطر
#include <QSqlError>    // أضيفي هذا السطر
#include <QDebug>       // أضيفي هذا السطر

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    // إعداد قاعدة البيانات مرة واحدة للتطبيق كاملاً
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("/mnt/c/Users/ASUS/rubaa/events.db");

    if (!db.open()) {
        qDebug() << "Error: connection with database failed" << db.lastError().text();
    } else {
        qDebug() << "Database connected successfully!";
    }
    
    MainWindow w;
    w.show();
    return app.exec();
}