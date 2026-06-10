#include "chatbotclient.h"
#include <QNetworkRequest>
#include <QJsonObject>
#include <QJsonDocument>
#include <QByteArray>

ChatBotClient::ChatBotClient(QObject *parent)
    : QObject(parent), m_networkManager(new QNetworkAccessManager(this))
{
    // ربط استلام الرد بالدالة تبعنا
    connect(m_networkManager, &QNetworkAccessManager::finished,
            this, &ChatBotClient::onReplyFinished);
}

void ChatBotClient::sendMessage(const QString &message)
{
    // رابط السيرفر تبعك
    QUrl url("http://127.0.0.1:8000/chat");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    // تجهيز الداتا بالشكل اللي بيتوقعه الـ API تبعك
    QJsonObject json;
    json["message"] = message;
    QJsonDocument doc(json);

    // إرسال الطلب (POST)
    m_networkManager->post(request, doc.toJson());
}

void ChatBotClient::onReplyFinished(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError) {
        QByteArray response = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(response);
        QJsonObject json = doc.object();

        // استخراج الرد وإرساله للواجهة
        if (json.contains("answer")) {
            emit responseReceived(json["answer"].toString());
        } else {
            emit errorOccurred("Invalid response from server.");
        }
    } else {
        emit errorOccurred("Network error: " + reply->errorString());
    }
    reply->deleteLater();
}
