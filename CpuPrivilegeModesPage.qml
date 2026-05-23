import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

ScrollView {
    id: scrollRoot
    anchors.fill: parent
    contentWidth: parent.width
    contentHeight: mainColumn.implicitHeight + 40
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

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
                    text: "LESSON 5: CPU MODES & PRIVILEGE LEVELS"
                    color: "#ffffff"
                    font { family: "Segoe UI"; bold: true; pixelSize: 20; letterSpacing: 0.5 }
                }
                Text {
                    text: "💡 GOAL: Learn how the CPU enforces hardware-level security by separating User Apps from Kernel execution powers."
                    color: Qt.rgba(255, 255, 255, 0.6)
                    font { family: "Segoe UI"; pixelSize: 13 }
                }
            }
        }

        // ==========================================
        // 2. THREE COLUMNS LAYOUT: الكروت الثلاثة مصفوفة بـ Row عادي
        // ==========================================
        Row {
            width: parent.width
            spacing: 15 // المسافة بين الكروت

            // ------------------------------------------
            // [STEP 1]: الكرت الأول - بيئة المستخدم (User Mode)
            // ------------------------------------------
            Rectangle {
                width: (parent.width - 30) / 3 // حساب العرض بدقة لتقسيم المساحة على 3
                height: 480
                color: Qt.rgba(255, 255, 255, 0.02)
                radius: 16
                border.color: Qt.rgba(255, 255, 255, 0.08)
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Row {
                        width: parent.width
                        spacing: 12
                        Rectangle {
                            width: 28; height: 28; radius: 14; color: "#a78bfa"
                            Text { text: "1"; color: "white"; font.bold: true; anchors.centerIn: parent }
                        }
                        Column {
                            spacing: 2
                            Text { text: "USER MODE"; color: "white"; font { bold: true; pixelSize: 14 } }
                            Text { text: "Restricted C Instructions (Ring 3)"; color: Qt.rgba(255, 255, 255, 0.4); font.pixelSize: 11 }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    // المخطط البصري داخل الكرت
                    Item {
                        width: parent.width
                        height: 180

                        Column {
                            anchors.centerIn: parent
                            spacing: 12

                            Rectangle {
                                width: 120; height: 35; radius: 15; color: Qt.rgba(255, 255, 255, 0.05); border.color: Qt.rgba(255, 255, 255, 0.15)
                                Text { text: "💬 cat utility"; color: "#e2e8f0"; font.pixelSize: 11; anchors.centerIn: parent }
                            }
                            Rectangle {
                                width: 120; height: 35; radius: 15; color: Qt.rgba(255, 255, 255, 0.05); border.color: Qt.rgba(255, 255, 255, 0.15)
                                Text { text: "💬 sh (Shell)"; color: "#e2e8f0"; font.pixelSize: 11; anchors.centerIn: parent }
                            }
                            Text {
                                text: "🔒 No Direct HW Access"; color: "#97969d"; font { bold: true; pixelSize: 11 } anchors.horizontalCenter: parent
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Text {
                        width: parent.width
                        text: "Applications run with lowest privileges. If code inside User Mode crashes or attempts to access raw disk sectors or private system memories directly, the CPU triggers an exception and kills it on the spot. Isolation works perfectly here."
                        color: Qt.rgba(255, 255, 255, 0.7)
                        wrapMode: Text.WordWrap
                        font { family: "Segoe UI"; pixelSize: 12 }
                        lineHeight: 1.35
                    }
                }
            }

            // ------------------------------------------
            // [STEP 2]: الكرت الثاني - جدار الحماية (ecall)
            // ------------------------------------------
            Rectangle {
                width: (parent.width - 30) / 3
                height: 480
                color: Qt.rgba(255, 255, 255, 0.02)
                radius: 16
                border.color: Qt.rgba(139, 92, 246, 0.3)
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Row {
                        width: parent.width
                        spacing: 12
                        Rectangle {
                            width: 28; height: 28; radius: 14; color: "#8b5cf6"
                            Text { text: "2"; color: "white"; font.bold: true; anchors.centerIn: parent }
                        }
                        Column {
                            spacing: 2
                            Text { text: "PRIVILEGE BOUNDARY"; color: "white"; font { bold: true; pixelSize: 14 } }
                            Text { text: "The 'ecall' gatekeeper mechanism"; color: Qt.rgba(255, 255, 255, 0.4); font.pixelSize: 11 }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    // المخطط البصري للعبور والجدار المضيء
                    Item {
                        width: parent.width
                        height: 180

                        Rectangle {
                            id: guardWall
                            width: 6; height: 130; radius: 3; anchors.centerIn: parent
                            color: "#8b5cf6"
                            layer.enabled: true
                            layer.effect: Glow { radius: 10; samples: 13; color: "#8b5cf6"; spread: 0.2 }
                        }

                        Rectangle {
                            width: 32; height: 32; radius: 6; x: parent.width/2 - 55; y: 25
                            color: Qt.rgba(255, 255, 255, 0.05); border.color: Qt.rgba(255, 255, 255, 0.3)
                            Text { text: "U"; color: "white"; font { bold: true; pixelSize: 14 } anchors.centerIn: parent }
                        }

                        Rectangle {
                            width: 32; height: 32; radius: 6; x: parent.width/2 + 25; y: 25
                            color: Qt.rgba(139, 92, 246, 0.2); border.color: "#8b5cf6"
                            Text { text: "S"; color: "#c084fc"; font { bold: true; pixelSize: 14 } anchors.centerIn: parent }
                        }

                        Canvas {
                            anchors.fill: parent
                            onAvailableChanged: if(available) requestPaint()
                            onPaint: {
                                var ctx = getContext("2d"); ctx.reset();
                                ctx.strokeStyle = "#8b5cf6"; ctx.lineWidth = 1.5;
                                ctx.beginPath(); ctx.moveTo(width/2 - 20, 41); ctx.lineTo(width/2 + 20, 41); ctx.stroke();
                                ctx.fillStyle = "#8b5cf6"; ctx.beginPath(); ctx.moveTo(width/2 + 15, 37); ctx.lineTo(width/2 + 22, 41); ctx.lineTo(width/2 + 15, 45); ctx.fill();
                            }
                        }

                        Text { text: "ecall instruction"; color: "#a78bfa"; font { family: "Consolas"; pixelSize: 9 } x: parent.width/2 - 40; y: 65 }
                        Text { text: "👮‍♂️ Guarded Gate"; color: "white"; font.pixelSize: 10; x: parent.width/2 - 35; y: 145 }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Text {
                        width: parent.width
                        text: "To switch modes, programs cannot just jump to kernel code. They must call 'ecall'. This special trap switches the CPU Privilege Register instantly from U (User) to S (Supervisor) and jumps into a single hardware-defined entry point inside the kernel."
                        color: Qt.rgba(255, 255, 255, 0.7)
                        wrapMode: Text.WordWrap
                        font { family: "Segoe UI"; pixelSize: 12 }
                        lineHeight: 1.35
                    }
                }
            }

            // ------------------------------------------
            // [STEP 3]: الكرت الثالث - بيئة الكيرنل (Supervisor Mode)
            // ------------------------------------------
            Rectangle {
                width: (parent.width - 30) / 3
                height: 480
                color: Qt.rgba(255, 255, 255, 0.02)
                radius: 16
                border.color: Qt.rgba(255, 255, 255, 0.08)
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Row {
                        width: parent.width
                        spacing: 12
                        Rectangle {
                            width: 28; height: 28; radius: 14; color: "#10b981"
                            Text { text: "3"; color: "white"; font.bold: true; anchors.centerIn: parent }
                        }
                        Column {
                            spacing: 2
                            Text { text: "SUPERVISOR MODE"; color: "white"; font { bold: true; pixelSize: 14 } }
                            Text { text: "Full Hardware Privilege (Ring 0)"; color: Qt.rgba(255, 255, 255, 0.4); font.pixelSize: 11 }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    // المخطط البصري للقلعة والكيرنل
                    Item {
                        width: parent.width
                        height: 180

                        Rectangle {
                            id: castleBlock
                            width: 120; height: 80; radius: 12; anchors.centerIn: parent
                            color: Qt.rgba(16, 185, 129, 0.12); border.color: "#10b981"
                            border.width: 1
                            Column {
                                anchors.centerIn: parent; spacing: 4
                                Text { text: "🏰 🛡️"; font.pixelSize: 20; anchors.horizontalCenter: parent }
                                Text { text: "THE KERNEL"; color: "white"; font { pixelSize: 11; bold: true } anchors.horizontalCenter: parent }
                                Text { text: "Direct HW Access"; color: "#6ee7b7"; font.pixelSize: 9; anchors.horizontalCenter: parent }
                            }
                        }
                        Text { text: "↩️ return (sret)"; color: "#6ee7b7"; font { family: "Consolas"; pixelSize: 10 } x: 15; y: 140 }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Text {
                        width: parent.width
                        text: "Inside Supervisor Mode, the kernel has full, unrestricted access to the entire machine. It safely manages tables, talks to the disk controller, and processes data. Once done, it runs 'sret' instruction to lower the privilege level back to U."
                        color: Qt.rgba(255, 255, 255, 0.7)
                        wrapMode: Text.WordWrap
                        font { family: "Segoe UI"; pixelSize: 12 }
                        lineHeight: 1.35
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

            Row {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Text { text: "🌟"; font.pixelSize: 22; anchors.verticalCenter: parent }

                Text {
                    width: parent.width - 50
                    anchors.verticalCenter: parent.verticalCenter
                    text: "CORE TAKEAWAY: Hardware (RISC-V) isolates memory and logic using Modes. Programs request kernel power using ecall (Trap), and the kernel safely returns control back to User Mode with sret."
                    color: "#ffffff"
                    wrapMode: Text.WordWrap
                    font { family: "Segoe UI"; bold: true; pixelSize: 12; letterSpacing: 0.2 }
                }
            }
        }
    }
}