#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "dbmanager.h"
#include "chatbotclient.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // الربط مع الداتابيز
    DbManager dbManager;
    engine.rootContext()->setContextProperty("dbManager", &dbManager);

    // إعدادات المحرك
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // تحميل التطبيق (لازم يكون xv6ui هو اسم المشروع في CMake)
    engine.loadFromModule("xv6ui", "Main");

    return app.exec();
}
