#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QString> // ضروري جداً
#include "dbmanager.h"

// هذا السطر هو مفتاح الحل، يجب أن يكون موجوداً ليتمكن المترجم من فهم "_s"
using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // تهيئة مدير قاعدة البيانات
    DbManager dbManager;
    engine.rootContext()->setContextProperty("dbManager", &dbManager);

    // استخدام _s الآن سيعمل بدون مشاكل بفضل السطر المضاف في الأعلى
    // الطريقة الصحيحة لكتابة المسار المحلي
    const QUrl url = QUrl::fromLocalFile("C:/Users/rubaa/Documents/xv6_admin/Main.qml");

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);    engine.load(url);
    return app.exec();
}