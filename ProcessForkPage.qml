import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

ScrollView {
    id: scrollRoot
    anchors.fill: parent
    contentWidth: parent.width
    contentHeight: mainColumn.implicitHeight + 40
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    // متغير لتتبع حالة تشغيل أنيميشن التفريع والـ Fork
    property bool isForked: false

    Column {
        id: mainColumn
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        spacing: 25

        // ==========================================
        // 1. HEADER: عنوان الدرس والهدف التعليمي
        // ==========================================
        Rectangle {
            width: parent.width
            height: 90
            color: Qt.rgba(255, 255, 255, 0.03)
            radius: 14
            border.color: Qt.rgba(139, 92, 246, 0.25)
            border.width: 1

            layer.enabled: true
            layer.effect: Glow {
                radius: 10
                samples: 17
                color: Qt.rgba(139, 92, 246, 0.1)
                spread: 0.1
            }

            Column {
                anchors.fill: parent
                anchors.margins: 15
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    text: "LESSON 2: HOW PROGRAMS ARE BORN (PROCESSES & FORK)"
                    color: "#ffffff"
                    font.family: "Segoe UI"
                    font.bold: true
                    font.pixelSize: 20
                    font.letterSpacing: 0.5
                }
                Text {
                    text: "💡 GOAL: Understand what a Process (PID) is and how a program clones itself using the fork() System Call."
                    color: Qt.rgba(255, 255, 255, 0.6)
                    font.family: "Segoe UI"
                    font.pixelSize: 13
                }
            }
        }

        // ==========================================
        // 2. THREE COLUMNS LAYOUT: الخطوات الثلاثة للدرس
        // ==========================================
        RowLayout {
            width: parent.width
            spacing: 20

            // ------------------------------------------
            // [STEP 1]: البطاقة الأولى - ما هي العملية؟
            // ------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 460
                color: Qt.rgba(255, 255, 255, 0.02)
                radius: 16
                border.color: Qt.rgba(255, 255, 255, 0.08)
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    RowLayout {
                        width: parent.width
                        spacing: 12
                        Rectangle {
                            width: 28; height: 28; radius: 14; color: "#a78bfa"
                            Text { text: "1"; color: "white"; font.bold: true; anchors.centerIn: parent }
                        }
                        ColumnLayout {
                            spacing: 2
                            Text { text: "STEP 1: WHAT IS A PROCESS?"; color: "white"; font.bold: true; font.pixelSize: 14 }
                            Text { text: "Living program in memory"; color: Qt.rgba(255, 255, 255, 0.4); font.pixelSize: 11 }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Item {
                        width: parent.width
                        height: 150

                        Rectangle {
                            id: processBox
                            width: 120; height: 100; radius: 12; anchors.centerIn: parent
                            color: Qt.rgba(255, 255, 255, 0.04); border.color: Qt.rgba(255, 255, 255, 0.2)

                            layer.enabled: true
                            layer.effect: Glow { radius: 6; samples: 11; color: Qt.rgba(255, 255, 255, 0.05) }

                            Column {
                                anchors.centerIn: parent; spacing: 6
                                Text { text: "💻"; font.pixelSize: 22; anchors.horizontalCenter: parent }
                                Text {
                                    text: "User App\nsh (PID 10)"
                                    color: "white"
                                    font.pixelSize: 12
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    anchors.horizontalCenter: parent
                                }
                            }
                        }
                        Text { text: "⚙️ ⚙️"; font.pixelSize: 16; x: parent.width/2 - 75; y: 30 }
                        Text { text: "👤"; font.pixelSize: 20; x: parent.width/2 + 55; y: 30 }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Text {
                        width: parent.width
                        text: "A Process is simply a running program. A static file on the disk becomes a living process with its own private memory space when executed. The OS assigns a unique number called a PID (Process ID) for global tracking."
                        color: Qt.rgba(255, 255, 255, 0.7)
                        wrapMode: Text.WordWrap
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        lineHeight: 1.3
                    }
                }
            }

            // ------------------------------------------
            // [STEP 2]: البطاقة الثانية - الاستنساخ والمحاكاة الحركية
            // ------------------------------------------
            Rectangle {
                id: step2Card
                Layout.fillWidth: true
                Layout.preferredHeight: 460
                color: Qt.rgba(255, 255, 255, 0.02)
                radius: 16
                border.color: scrollRoot.isForked ? "#10b981" : "#8b5cf6"
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    RowLayout {
                        width: parent.width
                        spacing: 12
                        Rectangle {
                            width: 28; height: 28; radius: 14; color: scrollRoot.isForked ? "#10b981" : "#8b5cf6"
                            Text { text: "2"; color: "white"; font.bold: true; anchors.centerIn: parent }
                        }
                        ColumnLayout {
                            spacing: 2
                            Text { text: "STEP 2: CLONING WITH FORK()"; color: "white"; font.bold: true; font.pixelSize: 14 }
                            Text { text: "Click the text block to clone!"; color: Qt.rgba(255, 255, 255, 0.4); font.pixelSize: 11 }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    // مساحة الرسم التفاعلي والمتحرك
                    Item {
                        id: canvasArea
                        width: parent.width
                        height: 150

                        // بروسيس الأب الثابت
                        Rectangle {
                            id: parentProc
                            width: 80; height: 35; radius: 6; x: 10; y: 15
                            color: Qt.rgba(139, 92, 246, 0.1); border.color: "#8b5cf6"
                            Text { text: "PARENT\n(PID 10)"; color: "white"; font.pixelSize: 10; font.bold: true; horizontalAlignment: Text.AlignHCenter; anchors.centerIn: parent }
                        }

                        // بروسيس الابن المنفصل حركياً
                        Rectangle {
                            id: childProc
                            width: 80; height: 35; radius: 6
                            color: Qt.rgba(16, 185, 129, 0.15); border.color: "#10b981"

                            // الحساب الديناميكي لمواقع الانفصال: يبدأ من الأب (10, 15) وينتهي في (210, 95)
                            x: scrollRoot.isForked ? 210 : 10
                            y: scrollRoot.isForked ? 95 : 15
                            opacity: scrollRoot.isForked ? 1.0 : 0.0

                            // المحركات المسؤولة عن الحركة الانسيابية اللطيفة (Smooth Transitions)
                            Behavior on x { NumberAnimation { duration: 600; easing.type: Easing.OutBack } }
                            Behavior on y { NumberAnimation { duration: 600; easing.type: Easing.OutQuad } }
                            Behavior on opacity { NumberAnimation { duration: 400 } }

                            Text { text: "CHILD\n(PID 11)"; color: "white"; font.pixelSize: 10; font.bold: true; horizontalAlignment: Text.AlignHCenter; anchors.centerIn: parent }
                        }

                        // مستطيل زر فحص دالة الـ Fork قابل للنقر لتفعيل الأنيميشن
                        Rectangle {
                            id: forkButton
                            x: 60; y: 55; width: 140; height: 26; radius: 4
                            color: scrollRoot.isForked ? Qt.rgba(16, 185, 129, 0.1) : Qt.rgba(139, 92, 246, 0.1)
                            border.color: scrollRoot.isForked ? "#10b981" : "#c084fc"
                            border.width: 1

                            Text {
                                text: scrollRoot.isForked ? "⚡ fork() Executed!" : "🚀 Click to fork()"
                                color: "white"
                                font.family: "Consolas"
                                font.pixelSize: 11
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    scrollRoot.isForked = !scrollRoot.isForked
                                    forkLineCanvas.requestPaint() // إعادة رسم مسار الخط الملتوي المتزامن
                                }
                            }
                        }

                        // رسم الخط الملتوي المتفاعل ديناميكياً مع الحركة
                        Canvas {
                            id: forkLineCanvas
                            width: parent.width; height: parent.height

                            // نربطه بمتغير الخطوات ليعيد التلوين عند الكبس
                            property bool active: scrollRoot.isForked

                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();

                                // الخط العمودي للأب لأسفل
                                ctx.strokeStyle = "#8b5cf6"; ctx.lineWidth = 2;
                                ctx.beginPath(); ctx.moveTo(50, 52); ctx.lineTo(50, 130); ctx.stroke();

                                // خط التفريغ يظهر ويتحرك فقط عند التفعيل
                                if (active) {
                                    ctx.strokeStyle = "#10b981";
                                    ctx.beginPath();
                                    ctx.moveTo(50, 65);
                                    ctx.bezierCurveTo(50, 110, 150, 110, 205, 112);
                                    ctx.stroke();

                                    // رأس سهم الإشارة للابن
                                    ctx.fillStyle = "#10b981"; ctx.beginPath();
                                    ctx.moveTo(205, 108); ctx.lineTo(212, 112); ctx.lineTo(205, 116); ctx.fill();
                                }
                            }

                            // إعادة الرسم تلقائياً فور تغير الحالة
                            onActiveChanged: requestPaint()
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Text {
                        width: parent.width
                        text: "Processes don't start from scratch in Unix. An existing process clones itself entirely using fork(). Memory space, registers, and files are duplicated into a separate copy. A brand new PID is assigned to the Child."
                        color: Qt.rgba(255, 255, 255, 0.7)
                        wrapMode: Text.WordWrap
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        lineHeight: 1.3
                    }
                }
            }

            // ------------------------------------------
            // [STEP 3]: البطاقة الثالثة - التمايز البرمجي
            // ------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 460
                color: Qt.rgba(255, 255, 255, 0.02)
                radius: 16
                border.color: Qt.rgba(255, 255, 255, 0.08)
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    RowLayout {
                        width: parent.width
                        spacing: 12
                        Rectangle {
                            width: 28; height: 28; radius: 14; color: "#10b981"
                            Text { text: "3"; color: "white"; font.bold: true; anchors.centerIn: parent }
                        }
                        ColumnLayout {
                            spacing: 2
                            Text { text: "STEP 3: DIFFERENTIATION"; color: "white"; font.bold: true; font.pixelSize: 14 }
                            Text { text: "Checking the return values"; color: Qt.rgba(255, 255, 255, 0.4); font.pixelSize: 11 }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Item {
                        width: parent.width
                        height: 150

                        Rectangle {
                            width: parent.width - 20; height: 110; radius: 10; anchors.centerIn: parent
                            color: Qt.rgba(0, 0, 0, 0.2); border.color: Qt.rgba(255, 255, 255, 0.05)

                            Column {
                                anchors.fill: parent; anchors.margins: 12; spacing: 8
                                Text { text: "int pid = fork();"; color: "#a78bfa"; font.family: "Consolas"; font.pixelSize: 11 }

                                // إضاءة الكود المقابل لحالة الفحص النشطة حالياً لتسهيل الفهم التعليمي
                                Text {
                                    text: "if (pid > 0) { /* I am Parent (receives Child PID) */ }"
                                    color: (scrollRoot.isForked) ? "#e2e8f0" : Qt.rgba(255,255,255,0.2)
                                    font.family: "Consolas"; font.pixelSize: 10
                                }
                                Text {
                                    text: "if (pid == 0) { /* I am Child (receives 0) */ }"
                                    color: (scrollRoot.isForked) ? "#6ee7b7" : Qt.rgba(255,255,255,0.2)
                                    font.family: "Consolas"; font.pixelSize: 10
                                    font.bold: scrollRoot.isForked
                                }
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Text {
                        width: parent.width
                        text: "After fork(), both processes execute the exact same next line of code! How do they differentiate? The fork() function returns different values: It returns the Child's real PID to the Parent, but returns 0 to the Child."
                        color: Qt.rgba(255, 255, 255, 0.7)
                        wrapMode: Text.WordWrap
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        lineHeight: 1.3
                    }
                }
            }
        }

        // ==========================================
        // 3. TAKEAWAY FOOTER: شريط الخلاصة البرمجي السفلي
        // ==========================================
        Rectangle {
            width: parent.width
            height: 65
            color: Qt.rgba(139, 92, 246, 0.08)
            radius: 14
            border.color: Qt.rgba(139, 92, 246, 0.35)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Text { text: "🌟"; font.pixelSize: 22; Layout.alignment: Qt.AlignVCenter }

                Text {
                    Layout.fillWidth: true
                    text: "CORE TAKEAWAY: Processes are isolated, living entities tracked by a PID. fork() is the unique, fundamental mechanism used in xv6 to clone and manufacture new concurrent processes."
                    color: "#ffffff"
                    wrapMode: Text.WordWrap
                    font.family: "Segoe UI"
                    font.bold: true
                    font.pixelSize: 12
                    font.letterSpacing: 0.2
                }
            }
        }
    }
}
