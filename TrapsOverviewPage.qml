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
                    text: "LESSON 6: TRAPS & SYSTEM CALLS OVERVIEW"
                    color: "#ffffff"
                    font { family: "Segoe UI"; bold: true; pixelSize: 20; letterSpacing: 0.5 }
                }
                Text {
                    text: "💡 GOAL: Understand the 3 distinct pathways that force the CPU to switch context from User Code to Kernel Space."
                    color: Qt.rgba(255, 255, 255, 0.6)
                    font { family: "Segoe UI"; pixelSize: 13 }
                }
            }
        }

        // ==========================================
        // 2. THREE COLUMNS LAYOUT: الكروت الثلاثة لأنواع الـ Traps
        // ==========================================
        Row {
            width: parent.width
            spacing: 15

            // ------------------------------------------
            // [TYPE 1]: الكرت الأول - استدعاءات النظام (System Calls)
            // ------------------------------------------
            Rectangle {
                width: (parent.width - 30) / 3
                height: 480
                color: Qt.rgba(255, 255, 255, 0.02)
                radius: 16
                border.color: Qt.rgba(139, 92, 246, 0.25)
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
                            Text { text: "1"; color: "white"; font.bold: true; anchors.centerIn: parent }
                        }
                        Column {
                            spacing: 2
                            Text { text: "SYSTEM CALLS"; color: "white"; font { bold: true; pixelSize: 14 } }
                            Text { text: "Intentional Requests from App"; color: Qt.rgba(255, 255, 255, 0.4); font.pixelSize: 11 }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    // المخطط البصري الداخلي
                    Item {
                        width: parent.width
                        height: 180

                        Column {
                            anchors.centerIn: parent
                            spacing: 10

                            Rectangle {
                                width: 130; height: 35; radius: 8; color: Qt.rgba(139, 92, 246, 0.1); border.color: "#8b5cf6"
                                Text { text: "🚀 ecall instruction"; color: "white"; font { family: "Consolas"; pixelSize: 11 } anchors.centerIn: parent }
                            }

                            Text {
                                text: "💻 Examples:\n• write() to console\n• open() file descriptor\n• fork() new process"
                                color: Qt.rgba(255, 255, 255, 0.6)
                                font { family: "Segoe UI"; pixelSize: 11 }
                                lineHeight: 1.4
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Text {
                        width: parent.width
                        text: "An intentional synchronous event triggered by user code when it wants to request an explicit service from the operating system kernel. The application deliberately invokes the 'ecall' instruction to drop into the guarded subsystem."
                        color: Qt.rgba(255, 255, 255, 0.7)
                        wrapMode: Text.WordWrap
                        font { family: "Segoe UI"; pixelSize: 12 }
                        lineHeight: 1.35
                    }
                }
            }

            // ------------------------------------------
            // [TYPE 2]: الكرت الثاني - الأخطاء الاستثنائية (Exceptions)
            // ------------------------------------------
            Rectangle {
                width: (parent.width - 30) / 3
                height: 480
                color: Qt.rgba(255, 255, 255, 0.02)
                radius: 16
                border.color: Qt.rgba(239, 68, 68, 0.25)
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Row {
                        width: parent.width
                        spacing: 12
                        Rectangle {
                            width: 28; height: 28; radius: 14; color: "#ef4444"
                            Text { text: "2"; color: "white"; font.bold: true; anchors.centerIn: parent }
                        }
                        Column {
                            spacing: 2
                            Text { text: "EXCEPTIONS"; color: "white"; font { bold: true; pixelSize: 14 } }
                            Text { text: "Unintentional Errors by App"; color: Qt.rgba(255, 255, 255, 0.4); font.pixelSize: 11 }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    // المخطط البصري الداخلي
                    Item {
                        width: parent.width
                        height: 180

                        Column {
                            anchors.centerIn: parent
                            spacing: 10

                            Rectangle {
                                width: 130; height: 35; radius: 8; color: Qt.rgba(239, 68, 68, 0.1); border.color: "#ef4444"
                                Text { text: "⚠️ Illegal Action"; color: "#fca5a5"; font { bold: true; pixelSize: 11 } anchors.centerIn: parent }
                            }

                            Text {
                                text: "💥 Examples:\n• Division by Zero\n• Page Faults (Bad Memory)\n• Invalid CPU Instruction"
                                color: Qt.rgba(255, 255, 255, 0.6)
                                font { family: "Segoe UI"; pixelSize: 11 }
                                lineHeight: 1.4
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Text {
                        width: parent.width
                        text: "An unintentional synchronous event generated automatically by the hardware when an application executes an illegal instruction. Examples include division by zero or invalid address reference. The kernel intercepts this to terminate or swap memory."
                        color: Qt.rgba(255, 255, 255, 0.7)
                        wrapMode: Text.WordWrap
                        font { family: "Segoe UI"; pixelSize: 12 }
                        lineHeight: 1.35
                    }
                }
            }

            // ------------------------------------------
            // [TYPE 3]: الكرت الثالث - المقاطعات الخارجية (Interrupts)
            // ------------------------------------------
            Rectangle {
                width: (parent.width - 30) / 3
                height: 480
                color: Qt.rgba(255, 255, 255, 0.02)
                radius: 16
                border.color: Qt.rgba(16, 185, 129, 0.25)
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
                            Text { text: "HARDWARE INTERRUPTS"; color: "white"; font { bold: true; pixelSize: 14 } }
                            Text { text: "Asynchronous Hardware Signals"; color: Qt.rgba(255, 255, 255, 0.4); font.pixelSize: 11 }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    // المخطط البصري الداخلي
                    Item {
                        width: parent.width
                        height: 180

                        Column {
                            anchors.centerIn: parent
                            spacing: 10

                            Rectangle {
                                width: 130; height: 35; radius: 8; color: Qt.rgba(16, 185, 129, 0.1); border.color: "#10b981"
                                Text { text: "🔌 External Device Signal"; color: "#a7f3d0"; font { bold: true; pixelSize: 11 } anchors.centerIn: parent }
                            }

                            Text {
                                text: "⚡ Examples:\n• Keyboard Keypress\n• Timer ticks (Scheduling)\n• Network packet arrival"
                                color: Qt.rgba(255, 255, 255, 0.6)
                                font { family: "Segoe UI"; pixelSize: 11 }
                                lineHeight: 1.4
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Text {
                        width: parent.width
                        text: "An asynchronous signal raised outside the pipeline by a hardware peripheral device to indicate that it requires attention from the CPU. This happens entirely independent of whichever application is currently running at that moment."
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
                    text: "CORE SUMMARY: Whether it is an intentional System Call, a critical Exception error, or an external Hardware Interrupt signal, the RISC-V processor reacts exactly the same way: it drops everything, switches privilege to Supervisor Mode, and jumps to stvec handle."
                    color: "#ffffff"
                    wrapMode: Text.WordWrap
                    font { family: "Segoe UI"; bold: true; pixelSize: 12; letterSpacing: 0.2 }
                }
            }
        }
    }
}