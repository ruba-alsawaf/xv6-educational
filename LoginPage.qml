import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    id: rootLogin
    anchors.fill: parent
    signal loginSuccess()

    // ── Animated diagonal lines ────────────────────────────────────────────
    Canvas {
        anchors.fill: parent
        property real t: 0
        NumberAnimation on t { from: 0; to: 1; duration: 6000; loops: Animation.Infinite }
        onTChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.lineWidth = 1
            for (var i = 0; i < 20; i++) {
                var p = (i / 20 + t) % 1.0
                var a = Math.sin(p * Math.PI) * 0.055
                ctx.strokeStyle = "rgba(6,182,212," + a + ")"
                var ox = p * (width + height) - height
                ctx.beginPath(); ctx.moveTo(ox, 0); ctx.lineTo(ox + height, height); ctx.stroke()
            }
        }
    }

    // ── Full-screen scan line ──────────────────────────────────────────────
    Rectangle {
        width: parent.width; height: 2; radius: 1; opacity: 0.6
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.25; color: "#06b6d4" }
            GradientStop { position: 0.5;  color: "#d4a0b8" }
            GradientStop { position: 0.75; color: "#06b6d4" }
            GradientStop { position: 1.0;  color: "transparent" }
        }
        SequentialAnimation on y {
            loops: Animation.Infinite
            NumberAnimation { from: 0; to: rootLogin.height; duration: 4000; easing.type: Easing.InOutSine }
            NumberAnimation { from: rootLogin.height; to: 0; duration: 4000; easing.type: Easing.InOutSine }
        }
    }

    // ── Ambient glow blobs ─────────────────────────────────────────────────
    Rectangle {
        width: 700; height: 700; radius: 350
        x: -180; y: parent.height / 2 - 350
        color: Qt.rgba(6/255,182/255,212/255,0.04)
        layer.enabled: true
        layer.effect: Glow { radius: 200; samples: 33; color: Qt.rgba(6/255,182/255,212/255,0.09) }
    }
    Rectangle {
        width: 550; height: 550; radius: 275
        x: parent.width * 0.55; y: parent.height / 2 - 200
        color: Qt.rgba(212/255,140/255,175/255,0.03)
        layer.enabled: true
        layer.effect: Glow { radius: 160; samples: 33; color: Qt.rgba(212/255,140/255,175/255,0.08) }
    }

    // ══════════════════════════════════════════════════════════════════════
    // SPLIT LAYOUT
    // ══════════════════════════════════════════════════════════════════════
    Row {
        anchors.fill: parent

        // ── LEFT: Brand (58%) ─────────────────────────────────────────────
        Item {
            width: parent.width * 0.58; height: parent.height

            Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left; anchors.leftMargin: parent.width * 0.12
                spacing: 0

                // Live indicator
                Row {
                    spacing: 10
                    Rectangle {
                        width: 8; height: 8; radius: 4
                        color: "#06b6d4"; anchors.verticalCenter: parent.verticalCenter
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { from: 1; to: 0.15; duration: 800 }
                            NumberAnimation { from: 0.15; to: 1; duration: 800 }
                        }
                    }
                    Text {
                        text: "INTERACTIVE OS EXPLORER"
                        color: Qt.rgba(6/255,182/255,212/255, 0.65)
                        font.family: "Segoe UI"; font.pixelSize: 11; font.letterSpacing: 3.5
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Item { height: 28; width: 1 }

                // ── X_RAY animated title ──────────────────────────────
                Item {
                    width: 640; height: 145

                    // Shadow / glow layer behind text
                    Text {
                        text: "X_RAY"
                        font.family: "Segoe UI"; font.pixelSize: 120
                        font.weight: Font.Black; font.letterSpacing: 20
                        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                        color: "#06b6d4"; opacity: 0.18
                        layer.enabled: true
                        layer.effect: Glow { radius: 30; samples: 33; color: "#06b6d4"; spread: 0.15 }
                    }

                    // Main animated title — color cycles
                    Text {
                        id: mainTitle
                        text: "X_RAY"
                        font.family: "Segoe UI"; font.pixelSize: 120
                        font.weight: Font.Black; font.letterSpacing: 20
                        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                        color: "#06b6d4"

                        SequentialAnimation on color {
                            loops: Animation.Infinite
                            ColorAnimation { from: "#06b6d4"; to: "#d4a0b8"; duration: 2200; easing.type: Easing.InOutSine }
                            ColorAnimation { from: "#d4a0b8"; to: "#a78bfa"; duration: 2200; easing.type: Easing.InOutSine }
                            ColorAnimation { from: "#a78bfa"; to: "#06b6d4"; duration: 2200; easing.type: Easing.InOutSine }
                        }
                    }

                    // Reflection / echo strip below title
                    Text {
                        text: "X_RAY"
                        font.family: "Segoe UI"; font.pixelSize: 120
                        font.weight: Font.Black; font.letterSpacing: 20
                        anchors.left: parent.left
                        y: parent.height * 0.72
                        color: mainTitle.color; opacity: 0.08
                        transform: Scale { yScale: -1; origin.y: 0 }
                    }
                }

                Item { height: 24; width: 1 }

                // Tagline — two lines, different weights
                Column {
                    spacing: 10
                    Text {
                        text: "Start your operating system learning journey"
                        color: Qt.rgba(255,255,255,0.55)
                        font.family: "Segoe UI"; font.pixelSize: 16
                    }
                    Text {
                        text: "the way it was always meant to be — interactive."
                        color: Qt.rgba(255,255,255,0.32)
                        font.family: "Segoe UI"; font.pixelSize: 15; font.italic: true
                    }
                }

            }
        }

        // ── Vertical divider ──────────────────────────────────────────────
        Item {
            width: 1; height: parent.height
            Rectangle {
                width: 1; height: parent.height * 0.55
                anchors.verticalCenter: parent.verticalCenter
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.35; color: Qt.rgba(6/255,182/255,212/255,0.3) }
                    GradientStop { position: 0.5;  color: Qt.rgba(212/255,160/255,185/255,0.55) }
                    GradientStop { position: 0.65; color: Qt.rgba(6/255,182/255,212/255,0.3) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }

        // ── RIGHT: Login form (42%) ───────────────────────────────────────
        Item {
            width: parent.width * 0.42; height: parent.height

            Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left; anchors.leftMargin: 80
                width: 300
                spacing: 0

                Text {
                    text: "STUDENT ACCESS"
                    color: "#ffffff"
                    font.family: "Segoe UI"; font.pixelSize: 20
                    font.weight: Font.Bold; font.letterSpacing: 5
                }
                Item { height: 6; width: 1 }
                Text {
                    text: "Sign in to continue"
                    color: Qt.rgba(255,255,255,0.28)
                    font.family: "Segoe UI"; font.pixelSize: 13
                }

                Item { height: 52; width: 1 }

                // Username
                Column { width: parent.width; spacing: 0
                    Text {
                        text: "USERNAME"
                        color: Qt.rgba(6/255,182/255,212/255, 0.65)
                        font.family: "Segoe UI"; font.pixelSize: 10
                        font.letterSpacing: 2.5; font.bold: true
                    }
                    Item { height: 12; width: 1 }
                    TextInput {
                        id: userField
                        width: parent.width; height: 34
                        color: "#ffffff"; font.pixelSize: 16; font.family: "Segoe UI"
                        Text {
                            text: "Enter username"
                            color: Qt.rgba(255,255,255,0.18)
                            font.pixelSize: 16; font.family: "Segoe UI"
                            visible: !parent.text; anchors.verticalCenter: parent.verticalCenter
                        }
                        Keys.onReturnPressed: passField.forceActiveFocus()
                    }
                    Rectangle {
                        width: parent.width; height: 1.5; radius: 1
                        color: userField.activeFocus ? "#06b6d4" : Qt.rgba(255,255,255,0.15)
                        Behavior on color { ColorAnimation { duration: 180 } }
                    }
                }

                Item { height: 36; width: 1 }

                // Password
                Column { width: parent.width; spacing: 0
                    Text {
                        text: "PASSWORD"
                        color: Qt.rgba(212/255,160/255,185/255, 0.65)
                        font.family: "Segoe UI"; font.pixelSize: 10
                        font.letterSpacing: 2.5; font.bold: true
                    }
                    Item { height: 12; width: 1 }
                    TextInput {
                        id: passField
                        width: parent.width; height: 34
                        color: "#ffffff"; font.pixelSize: 16; font.family: "Segoe UI"
                        echoMode: TextInput.Password
                        Text {
                            text: "Enter password"
                            color: Qt.rgba(255,255,255,0.18)
                            font.pixelSize: 16; font.family: "Segoe UI"
                            visible: !parent.text; anchors.verticalCenter: parent.verticalCenter
                        }
                        Keys.onReturnPressed: doLogin()
                    }
                    Rectangle {
                        width: parent.width; height: 1.5; radius: 1
                        color: passField.activeFocus ? "#d4a0b8" : Qt.rgba(255,255,255,0.15)
                        Behavior on color { ColorAnimation { duration: 180 } }
                    }
                }

                Item { height: 16; width: 1 }

                // Error
                Item {
                    width: parent.width
                    height: errorText.visible ? 32 : 0
                    clip: true
                    Behavior on height { NumberAnimation { duration: 180 } }
                    Text {
                        id: errorText
                        text: "⚠   Invalid username or password"
                        color: "#f43f5e"; font.pixelSize: 12; font.family: "Segoe UI"
                        visible: false; anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Item { height: 30; width: 1 }

                // Sign In button
                Item {
                    width: parent.width; height: 52

                    Rectangle {
                        id: signInBtn
                        anchors.fill: parent; radius: 10
                        property bool hov: false
                        color: hov ? Qt.rgba(6/255,182/255,212/255,0.22) : Qt.rgba(6/255,182/255,212/255,0.10)
                        border.color: hov ? "#06b6d4" : Qt.rgba(6/255,182/255,212/255,0.35)
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        // Gradient shimmer top edge
                        Rectangle {
                            width: parent.width - 2; height: 1; radius: 1
                            anchors.top: parent.top; anchors.topMargin: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 0.4; color: Qt.rgba(6/255,182/255,212/255, signInBtn.hov ? 0.6 : 0.25) }
                                GradientStop { position: 0.6; color: Qt.rgba(212/255,160/255,185/255, signInBtn.hov ? 0.6 : 0.25) }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                        }

                        Row {
                            anchors.centerIn: parent; spacing: 12
                            Text {
                                text: "SIGN IN"
                                color: "#ffffff"; font.family: "Segoe UI"
                                font.pixelSize: 13; font.bold: true; font.letterSpacing: 3
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "→"; color: "#06b6d4"
                                font.pixelSize: 16; font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onEntered: signInBtn.hov = true
                            onExited:  signInBtn.hov = false
                            onClicked: doLogin()
                        }
                    }

                    SequentialAnimation {
                        id: shakeAnim
                        NumberAnimation { target: signInBtn; property: "x"; from: -10; to: 10;  duration: 55 }
                        NumberAnimation { target: signInBtn; property: "x"; from:  10; to: -10; duration: 55 }
                        NumberAnimation { target: signInBtn; property: "x"; from:  -5; to:  5;  duration: 45 }
                        NumberAnimation { target: signInBtn; property: "x"; to: 0;              duration: 35 }
                    }
                }

                Item { height: 48; width: 1 }

                Row {
                    spacing: 8
                    Rectangle { width: 18; height: 1; color: Qt.rgba(255,255,255,0.1); anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: "Authorized personnel only"
                        color: Qt.rgba(255,255,255,0.13)
                        font.family: "Segoe UI"; font.pixelSize: 11
                    }
                    Rectangle { width: 18; height: 1; color: Qt.rgba(255,255,255,0.1); anchors.verticalCenter: parent.verticalCenter }
                }
            }
        }
    }

    function doLogin() {
        var ok = dbManager.authenticate(userField.text, passField.text)
        if (ok) { errorText.visible = false; rootLogin.loginSuccess() }
        else    { errorText.visible = true; shakeAnim.start() }
    }
}
