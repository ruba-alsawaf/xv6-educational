#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>  // موديول مهم للربط
#include "dbmanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // إنشاء كائن إدارة الداتابيز
    DbManager dbManager;
    // تمريره للـ QML باسم مستعار "dbManager"
    engine.rootContext()->setContextProperty("dbManager", &dbManager);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("xv6ui", "Main");

    return app.exec();
}