#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>  // موديول مهم للربط بين C++ و QML
#include "dbmanager.h"
#include "chatbotclient.h" // 💡 استدعاء هيدر الشات بوت الجديد من فرع chat-bot-ui

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // 1. إنشاء الكائنات البرمجية وإعداد الاتصال بالداتابيز
    DbManager dbManager;
    ChatBotClient chatBotClient; // 💡 كائن الشات بوت الجديد

    // 2. تمرير الكائنات إلى الـ QML بأسماء مستعارة (Context Properties)
    engine.rootContext()->setContextProperty("dbManager", &dbManager);
    engine.rootContext()->setContextProperty("chatBotClient", &chatBotClient); // 💡 ربط الشات بوت بالواجهات

    // 3. إعدادات محرك الـ QML والتحقق من سلامة تحميل الملفات
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // 4. تحميل التطبيق الأساسي (اسم الموديول مسجل في CMake بـ xv6ui)
    engine.loadFromModule("xv6ui", "Main");

    return app.exec();
}
