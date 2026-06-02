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
        // 1. HEADER: Comprehensive Lesson Title
        // ==========================================
        Rectangle {
            width: parent.width
            height: 95
            color: Qt.rgba(255, 255, 255, 0.03)
            radius: 14
            border.color: Qt.rgba(139, 92, 246, 0.25)
            border.width: 1

            layer.enabled: true
            layer.effect: Glow {
                radius: 10; samples: 17; color: Qt.rgba(139, 92, 246, 0.1); spread: 0.1
            }

            Column {
                anchors.fill: parent
                anchors.margins: 15
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    text: "LESSON 1: THE OS KERNEL AS A GUARD & SYSTEM CALL ARCHITECTURE"
                    color: "#ffffff"
                    font { family: "Segoe UI"; bold: true; pixelSize: 18; letterSpacing: 0.5 }
                }
                Text {
                    text: "💡 CORE CONCEPT: Master the defensive shielding mechanisms of the xv6 kernel, exploring why user apps are denied raw access, and how system calls bridge the privilege boundary."
                    color: Qt.rgba(255, 255, 255, 0.6)
                    font { family: "Segoe UI"; pixelSize: 12 }
                    wrapMode: Text.WordWrap
                    width: parent.width - 30
                }
            }
        }

        // ==========================================
        // 2. SECTION I: THE PRIVILEGE SPLIT VIEW (Horizontal Split)
        // ==========================================
        Rectangle {
            width: parent.width
            height: 250
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 16
            border.color: Qt.rgba(139, 92, 246, 0.15)
            border.width: 1

            Item {
                anchors.fill: parent
                anchors.margins: 20

                Text {
                    id: splitTitle
                    text: "I. HARDWARE PRIVILEGE SEGREGATION: USER SPACE VS KERNEL SPACE"
                    color: "#c084fc"
                    font { bold: true; pixelSize: 13; letterSpacing: 0.5 }
                }

                Row {
                    anchors.top: splitTitle.bottom
                    anchors.topMargin: 20
                    width: parent.width
                    spacing: 20

                    // النصف الأيسر: فضاء المستخدم غير الموثوق
                    Rectangle {
                        width: (parent.width - 160) / 2; height: 140; radius: 10
                        color: Qt.rgba(239, 68, 68, 0.04); border.color: Qt.rgba(239, 68, 68, 0.2)
                        Column { anchors.centerIn: parent; spacing: 6; width: parent.width - 20
                            Text { text: "❌ UNTRUSTED USER SPACE"; color: "#fca5a5"; font.bold: true; font.pixelSize: 12; anchors.horizontalCenter: parent }
                            Text { text: "Applications (sh, cat, user_apps)\n• Trapped inside User Mode (Ring 3)\n• Zero direct access to raw memory or disk controllers"; color: Qt.rgba(255,255,255,0.4); font.pixelSize: 10; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; width: parent.width } }
                    }

                    // المنتصف: الجدار الدفاعي المضيء
                    Rectangle {
                        id: boundaryShield
                        width: 120; height: 140; radius: 12
                        color: Qt.rgba(139, 92, 246, 0.15); border.color: "#8b5cf6"; border.width: 1.5
                        layer.enabled: true; layer.effect: Glow { radius: 8; samples: 13; color: "#8b5cf6"; spread: 0.15 }
                        Column { anchors.centerIn: parent; spacing: 8; width: parent.width - 10
                            Text { text: "🛡️ SHIELD"; color: "#c084fc"; font { bold: true; pixelSize: 10; letterSpacing: 1 } anchors.horizontalCenter: parent }
                            Text { text: "GATEWAY"; color: "white"; font { bold: true; pixelSize: 13 } anchors.horizontalCenter: parent }
                            Text { text: "Enforces Boundaries"; color: Qt.rgba(255,255,255,0.5); font.pixelSize: 9; anchors.horizontalCenter: parent } }
                    }

                    // النصف الأيمن: فضاء النواة المستقر فوق المكونات المادية
                    Rectangle {
                        width: (parent.width - 160) / 2; height: 140; radius: 10
                        color: Qt.rgba(16, 185, 129, 0.08); border.color: "#10b981"
                        Column { anchors.centerIn: parent; spacing: 6; width: parent.width - 20
                            Text { text: "🏰 PROTECTED KERNEL SPACE"; color: "#6ee7b7"; font.bold: true; font.pixelSize: 12; anchors.horizontalCenter: parent }
                            Text { text: "The xv6 Core Binary Subsystems\n• Runs in Supervisor Mode (Ring 0)\n• Complete hardware control (CPU, RAM, Disks)"; color: Qt.rgba(255,255,255,0.4); font.pixelSize: 10; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; width: parent.width } }
                    }
                }
            }
        }

        // ==========================================
        // 3. SECTION II: SYSTEM CALL TRAPPING PATH (Horizontal Flow)
        // ==========================================
        Rectangle {
            width: parent.width
            height: 175
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 16
            border.color: Qt.rgba(16, 185, 129, 0.2)
            border.width: 1

            Item {
                anchors.fill: parent
                anchors.margins: 18

                Text {
                    id: flowTitle
                    text: "II. SYSTEM CALL EXECUTION LIFECYCLE: THE TRAPPING PATHWAY"
                    color: "#10b981"
                    font { bold: true; pixelSize: 13; letterSpacing: 0.5 }
                }

                Row {
                    anchors.top: flowTitle.bottom
                    anchors.topMargin: 15
                    width: parent.width
                    spacing: 15

                    Rectangle { width: (parent.width - 45) / 4; height: 85; radius: 8; color: Qt.rgba(255,255,255,0.03); border.color: Qt.rgba(255,255,255,0.1)
                        Column { anchors.centerIn: parent; spacing: 4; width: parent.width - 10
                            Text { text: "1. API Invoke"; color: "white"; font.bold: true; font.pixelSize: 11; anchors.horizontalCenter: parent }
                            Text { text: "User App triggers write()\nwith explicit buffers."; color: Qt.rgba(255,255,255,0.5); font.pixelSize: 9; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; width: parent.width } } }

                    Rectangle { width: (parent.width - 45) / 4; height: 85; radius: 8; color: Qt.rgba(255,255,255,0.03); border.color: Qt.rgba(255,255,255,0.1)
                        Column { anchors.centerIn: parent; spacing: 4; width: parent.width - 10
                            Text { text: "2. Vector Load"; color: "white"; font.bold: true; font.pixelSize: 11; anchors.horizontalCenter: parent }
                            Text { text: "Puts system call number\ninto register (SYS_write)."; color: Qt.rgba(255,255,255,0.5); font.pixelSize: 9; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; width: parent.width } } }

                    Rectangle { width: (parent.width - 45) / 4; height: 85; radius: 8; color: Qt.rgba(139, 92, 246, 0.08); border.color: "#8b5cf6"
                        Column { anchors.centerIn: parent; spacing: 4; width: parent.width - 10
                            Text { text: "3. ecall Switch"; color: "white"; font.bold: true; font.pixelSize: 11; anchors.horizontalCenter: parent }
                            Text { text: "Executes hardware trap.\nFlips CPU mode to Supervisor."; color: "#c084fc"; font.pixelSize: 9; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; width: parent.width } } }

                    Rectangle { width: (parent.width - 45) / 4; height: 85; radius: 8; color: Qt.rgba(16, 185, 129, 0.08); border.color: "#10b981"
                        Column { anchors.centerIn: parent; spacing: 4; width: parent.width - 10
                            Text { text: "4. Kernel Execution"; color: "white"; font.bold: true; font.pixelSize: 11; anchors.horizontalCenter: parent }
                            Text { text: "sys_write() runs securely,\nstreaming data to console."; color: "#a7f3d0"; font.pixelSize: 9; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; width: parent.width } } }
                }
            }
        }

        // ==========================================
        // 4. SECTION III: EXPANDED DETAILED TAKEAWAYS (Info Cards)
        // ==========================================
        Rectangle {
            width: parent.width
            height: 250
            color: Qt.rgba(255, 255, 255, 0.01)
            radius: 12
            border.color: Qt.rgba(255, 255, 255, 0.05)

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Column {
                    width: parent.width
                    spacing: 3
                    Text { text: "📌 The Core Necessity of Kernel Guarding:"; color: "#c084fc"; font { bold: true; pixelSize: 12 } }
                    Text {
                        text: "Operating systems must employ defensive design. If user applications were allowed to directly write to disk blocks or read unisolated memory registries, a malicious or crashing application would instantly destroy data integrity or pull down the whole hardware machine. Isolation guarantees that user bugs remain confined inside their own process boundaries.";
                        color: Qt.rgba(255, 255, 255, 0.75); font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width
                    }
                }

                Column {
                    width: parent.width
                    spacing: 3
                    Text { text: "📌 Hardware Boundaries Enforcement:"; color: "#10b981"; font { bold: true; pixelSize: 12 } }
                    Text {
                        text: "The separation is not just a software trick; it is strictly controlled by the central processing unit hardware flags. User space processes execute inside unprivileged user rings. They cannot modify system configurations or jump arbitrarily to random kernel code lines. The hardware locks access down until a controlled transaction gate is invoked.";
                        color: Qt.rgba(255, 255, 255, 0.75); font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width
                    }
                }

                Column {
                    width: parent.width
                    spacing: 3
                    Text { text: "📌 The Controlled Gateway (System Call Traps):"; color: "#ef4444"; font { bold: true; pixelSize: 12 } }
                    Text {
                        text: "The 'ecall' assembly instruction acts as an intentional structural escape tunnel. It drops the unprivileged execution line instantly and hands total control over to a single, hardcoded entry coordinate defined by the kernel inside the supervisor trap vectors. The kernel acts as an elite security guard, inspects user arguments carefully, performs the hardware transaction, and lowers privileges back.";
                        color: Qt.rgba(255, 255, 255, 0.75); font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width
                    }
                }
            }
        }
    }
}