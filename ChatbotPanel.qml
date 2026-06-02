import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import xv6ui 1.0

Rectangle {
    id: chatPanel
    radius: 15
    clip: true
    color: Qt.rgba(30/255, 30/255, 30/255, 0.8)
    border.color: Qt.rgba(255, 255, 255, 0.2)
    border.width: 1

    ChatBotClient {
        id: chatClient
        onResponseReceived: function(answer) {
            messageList.model.append({"text": "", "isUser": false})
            typingTimer.fullText = answer
            typingTimer.currentIdx = 0
            typingTimer.start()
        }
        onErrorOccurred: function(errorString) {
            messageList.model.append({"text": "[ERROR]: " + errorString, "isUser": false})
        }
    }

    Timer {
        id: typingTimer
        interval: 30
        repeat: true
        property string fullText: ""
        property int currentIdx: 0
        onTriggered: {
            if (currentIdx <= fullText.length) {
                let lastIdx = messageList.model.count - 1
                messageList.model.setProperty(lastIdx, "text", fullText.substring(0, currentIdx))
                currentIdx++
            } else {
                stop()
            }
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 12

        Text {
            text: "TERMINAL - AI ASSISTANT"
            font { family: "Segoe UI"; pixelSize: 14; weight: Font.Bold; letterSpacing: 1 }
            color: "#ffffff"
        }

        ScrollView {
            id: scrollView
            width: parent.width
            height: parent.height - 80
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            ListView {
                id: messageList
                width: parent.width
                spacing: 20
                model: ListModel {
                    ListElement { text: "XV6 AI Kernel Assistant Initialized..."; isUser: false }
                }
                delegate: Column {
                    width: messageList.width
                    Rectangle {
                        width: Math.min(msgText.implicitWidth + 30, messageList.width * 0.8)
                        height: msgText.implicitHeight + 20
                        radius: 12
                        color: isUser ? Qt.rgba(75/255, 42/255, 192/255, 0.4) : Qt.rgba(255, 255, 255, 0.05)
                        anchors.right: isUser ? parent.right : undefined
                        Text {
                            id: msgText
                            text: model.text
                            color: "#ffffff"
                            font { pixelSize: 15; family: "Segoe UI" }
                            wrapMode: Text.Wrap
                            anchors.centerIn: parent
                            width: parent.width - 30
                        }
                    }
                }
            }
        }

        Row {
            width: parent.width
            height: 45
            spacing: 10

            Rectangle {
                width: parent.width - 55
                height: 45
                radius: 8
                color: Qt.rgba(0, 0, 0, 0.4)
                border.color: Qt.rgba(255, 255, 255, 0.2)

                TextInput {
                    id: chatInput
                    anchors.fill: parent
                    anchors.margins: 12
                    color: "#ffffff"
                    font { pixelSize: 15; family: "Segoe UI" }
                    verticalAlignment: TextInput.AlignVCenter
                    focus: true
                    Keys.onPressed: {
                        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                            sendFunction()
                            event.accepted = true
                        }
                    }
                }
            }

            Rectangle {
                width: 45; height: 45; radius: 8
                color: Qt.rgba(75/255, 42/255, 192/255, 0.8)
                Text { text: "➜"; font.pixelSize: 20; color: "white"; anchors.centerIn: parent }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sendFunction()
                }
            }
        }
    }

    function sendFunction() {
        if(chatInput.text !== "") {
            messageList.model.append({"text": chatInput.text, "isUser": true})
            chatClient.sendMessage(chatInput.text)
            chatInput.text = ""
        }
    }
}
