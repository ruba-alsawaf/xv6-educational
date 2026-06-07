import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    id: rootLogin
    anchors.fill: parent
    signal loginSuccess()

    // لوحة تسجيل الدخول الزجاجية المسطحة
    Rectangle {
        width: 380
        height: 400
        anchors.centerIn: parent
        color: "#1AFFFFFF" // لون أبيض شفاف جداً للستايل الزجاجي
        radius: 16
        border.color: "#33FFFFFF"
        border.width: 1

        // تأثير الظل البسيط لعزل اللوحة عن الخلفية
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: "#66000000"
            radius: 24
            samples: 49
        }

        Column {
            anchors.centerIn: parent
            width: parent.width * 0.8
            spacing: 20

            Text {
                text: "Student Login"
                color: "white"
                font.pixelSize: 24
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: usernameInput
                width: parent.width
                placeholderText: "Username (e.g. student)"
                color: "white"
                font.pixelSize: 16
                background: Rectangle {
                    color: "#20FFFFFF"
                    radius: 8
                    border.color: "#40FFFFFF"
                }
            }

            TextField {
                id: passwordInput
                width: parent.width
                placeholderText: "Password (e.g. 1234)"
                color: "white"
                font.pixelSize: 16
                echoMode: TextInput.Password // إخفاء الأحرف بنقاط عادية
                background: Rectangle {
                    color: "#20FFFFFF"
                    radius: 8
                    border.color: "#40FFFFFF"
                }
            }

            Text {
                id: errorText
                text: "Invalid username or password"
                color: "#ff5c5c"
                font.pixelSize: 13
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Button {
                width: parent.width
                height: 45
                text: "Login"
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: parent.pressed ? "#30FFFFFF" : "#50FFFFFF"
                    radius: 8
                    border.color: "#60FFFFFF"
                }
                onClicked: {
                    // استدعاء دالة C++ للتحقق
                    // (تأكدي أن اسم الكائن في main.cpp هو dbManager أو عدليه ليطابقه)
                    var isOk = dbManager.authenticate(usernameInput.text, passwordInput.text);
                    if (isOk) {
                        errorText.visible = false;
                        rootLogin.loginSuccess();
                    } else {
                        errorText.visible = true;
                    }
                }
            }
        }
    }
}