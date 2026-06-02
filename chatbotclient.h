#ifndef CHATBOTCLIENT_H
#define CHATBOTCLIENT_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QtQml/qqmlregistration.h> // <--- المكتبة السحرية الجديدة

class ChatBotClient : public QObject
{
    Q_OBJECT
    QML_ELEMENT // <--- هاد السطر بيعرّف الكلاس للـ QML فوراً وبدون تعقيد

public:
    explicit ChatBotClient(QObject *parent = nullptr);

    Q_INVOKABLE void sendMessage(const QString &message);

signals:
    void responseReceived(QString answer);
    void errorOccurred(QString errorString);

private slots:
    void onReplyFinished(QNetworkReply *reply);

private:
    QNetworkAccessManager *m_networkManager;
};

#endif // CHATBOTCLIENT_H
