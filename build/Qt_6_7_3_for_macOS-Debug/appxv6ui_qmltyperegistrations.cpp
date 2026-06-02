/****************************************************************************
** Generated QML type registration code
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <QtQml/qqml.h>
#include <QtQml/qqmlmoduleregistration.h>

#include <chatbotclient.h>


#if !defined(QT_STATIC)
#define Q_QMLTYPE_EXPORT Q_DECL_EXPORT
#else
#define Q_QMLTYPE_EXPORT
#endif
Q_QMLTYPE_EXPORT void qml_register_types_xv6ui()
{
    qmlRegisterTypesAndRevisions<ChatBotClient>("xv6ui", 1);
    qmlRegisterModule("xv6ui", 1, 0);
}

static const QQmlModuleRegistration xv6uiRegistration("xv6ui", qml_register_types_xv6ui);
