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
                    text: "LESSON 3: COMMUNICATING WITH THE WORLD (FILE DESCRIPTORS & PIPES)"
                    color: "#ffffff"
                    font { family: "Segoe UI"; bold: true; pixelSize: 20; letterSpacing: 0.5 }
                }
                Text {
                    text: "💡 GOAL: Learn how the OS abstracts hardware streams using unified indexing pointers, and how kernel memory buffers bind isolated tasks dynamically."
                    color: Qt.rgba(255, 255, 255, 0.6)
                    font { family: "Segoe UI"; pixelSize: 13 }
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
            // [STEP 1]: البطاقة الأولى - الأرقام السحرية ومصفوفة الكيرنل
            // ------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 490
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
                            Text { text: "STEP 1: MAGIC NUMBERS"; color: "white"; font { bold: true; pixelSize: 14 } }
                            Text { text: "File Descriptors (fd)"; color: Qt.rgba(255, 255, 255, 0.4); font.pixelSize: 11 }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Item {
                        width: parent.width
                        height: 150

                        Rectangle {
                            width: parent.width - 10; height: 135; radius: 10; anchors.centerIn: parent
                            color: Qt.rgba(255, 255, 255, 0.03); border.color: Qt.rgba(255, 255, 255, 0.1)

                            Column {
                                anchors.fill: parent; anchors.margins: 12; spacing: 8

                                Row {
                                    width: parent.width
                                    Text { text: "fd"; width: 40; color: "#a78bfa"; font { bold: true; family: "Consolas" } }
                                    Text { text: "Standard Stream / Core Purpose"; color: "#a78bfa"; font.bold: true }
                                }
                                Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.1) }

                                Row { width: parent.width; Text { text: "0"; width: 40; color: "white"; font.family: "Consolas" } Text { text: "Standard Input (Keyboard ⌨️ Input Vector)"; color: "#e2e8f0"; font.pixelSize: 11 } }
                                Row { width: parent.width; Text { text: "1"; width: 40; color: "white"; font.family: "Consolas" } Text { text: "Standard Output (Screen 🖥️ Console Output)"; color: "#e2e8f0"; font.pixelSize: 11 } }
                                Row { width: parent.width; Text { text: "2"; width: 40; color: "white"; font.family: "Consolas" } Text { text: "Standard Error (Console 🚨 Diagnostics Stream)"; color: "#e2e8f0"; font.pixelSize: 11 } }
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Text {
                        width: parent.width
                        text: "In xv6, everything is abstracted into a file structure index. When a task claims access to raw hardware or blocks, the kernel populates an entry inside the process's internal 'ofile' tracking array mapped within struct proc. By default, every process initialized inherits three static hardware channels pointing securely to standard system streams."
                        color: Qt.rgba(255, 255, 255, 0.7)
                        wrapMode: Text.WordWrap
                        font { family: "Segoe UI"; pixelSize: 12 }
                        lineHeight: 1.35
                    }
                }
            }

            // ------------------------------------------
            // [STEP 2]: البطاقة الثانية - استدعاءات الـ I/O والتحقق الدفاعي
            // ------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 490
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
                            Text { text: "2"; color: "white"; font.bold: true; anchors.centerIn: parent }
                        }
                        ColumnLayout {
                            spacing: 2
                            Text { text: "STEP 2: SYSTEM CALLS FOR I/O"; color: "white"; font { bold: true; pixelSize: 14 } }
                            Text { text: "Moving data inside the code"; color: Qt.rgba(255, 255, 255, 0.4); font.pixelSize: 11 }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Item {
                        width: parent.width
                        height: 150

                        Rectangle {
                            id: procBox
                            width: 80; height: 60; radius: 8; x: 10; y: 45
                            color: Qt.rgba(255, 255, 255, 0.04); border.color: Qt.rgba(255, 255, 255, 0.2)
                            Column { anchors.centerIn: parent; spacing: 4
                                Text { text: "⚙️"; font.pixelSize: 14; anchors.horizontalCenter: parent }
                                Text { text: "Process"; color: "white"; font { pixelSize: 11; bold: true } anchors.horizontalCenter: parent } }
                        }

                        Rectangle {
                            id: screenBox
                            width: 80; height: 40; radius: 6; x: 210; y: 15
                            color: Qt.rgba(139, 92, 246, 0.1); border.color: "#8b5cf6"
                            Text { text: "fd 1 (Screen)"; color: "white"; font.pixelSize: 10; anchors.centerIn: parent }
                        }

                        Rectangle {
                            id: fileBox
                            width: 80; height: 40; radius: 6; x: 210; y: 95
                            color: Qt.rgba(16, 185, 129, 0.1); border.color: "#10b981"
                            Text { text: "data.txt (fd 3)"; color: "white"; font.pixelSize: 10; anchors.centerIn: parent }
                        }

                        Text { text: "write(1, \"hello\", 5)"; color: "#c084fc"; font { family: "Consolas"; pixelSize: 9 } x: 95; y: 15 }
                        Text { text: "open(\"data.txt\", ...)"; color: "#6ee7b7"; font { family: "Consolas"; pixelSize: 9 } x: 95; y: 95 }

                        Canvas {
                            width: parent.width; height: parent.height
                            onAvailableChanged: if(available) requestPaint()
                            onPaint: {
                                var ctx = getContext("2d"); ctx.reset();
                                ctx.strokeStyle = "#8b5cf6"; ctx.lineWidth = 1.5;
                                ctx.beginPath(); ctx.moveTo(90, 35); ctx.lineTo(200, 35); ctx.stroke();
                                ctx.fillStyle = "#8b5cf6"; ctx.beginPath(); ctx.moveTo(200, 31); ctx.lineTo(207, 35); ctx.lineTo(200, 39); ctx.fill();

                                ctx.strokeStyle = "#10b981"; ctx.fillStyle = "#10b981";
                                ctx.beginPath(); ctx.moveTo(200, 115); ctx.lineTo(90, 115); ctx.stroke();
                                ctx.beginPath(); ctx.moveTo(97, 111); ctx.lineTo(90, 115); ctx.lineTo(97, 119); ctx.fill();
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Text {
                        width: parent.width
                        text: "System boundaries use protective verifications. System calls like open() return a new unallocated tracking integer token. When software passes raw user memory buffer addresses into read() or write(), the kernel spins down defensive filters like argaddr() to wrap and parse variables securely, isolating Ring 0 operations."
                        color: Qt.rgba(255, 255, 255, 0.7)
                        wrapMode: Text.WordWrap
                        font { family: "Segoe UI"; pixelSize: 12 }
                        lineHeight: 1.35
                    }
                }
            }

            // ------------------------------------------
            // [STEP 3]: البطاقة الثالثة - الأنابيب ومزامنة النواة
            // ------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 490
                color: Qt.rgba(255, 255, 255, 0.02)
                radius: 16
                border.color: Qt.rgba(139, 92, 246, 0.3)
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    RowLayout {
                        width: parent.width
                        spacing: 12
                        Rectangle {
                            width: 28; height: 28; radius: 14; color: "#8b5cf6"
                            Text { text: "3"; color: "white"; font.bold: true; anchors.centerIn: parent }
                        }
                        ColumnLayout {
                            spacing: 2
                            Text { text: "STEP 3: PIPES - THE SECRET TUNNEL"; color: "white"; font { bold: true; pixelSize: 14 } }
                            Text { text: "Process collaboration"; color: Qt.rgba(255, 255, 255, 0.4); font.pixelSize: 11 }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Item {
                        width: parent.width
                        height: 150

                        Rectangle {
                            id: appLeft
                            width: 65; height: 40; radius: 6; x: 5; y: 55
                            color: Qt.rgba(255, 255, 255, 0.04); border.color: Qt.rgba(255, 255, 255, 0.2)
                            Text { text: "App A\n(e.g., ls)"; color: "white"; font.pixelSize: 10; horizontalAlignment: Text.AlignHCenter; anchors.centerIn: parent }
                        }

                        Rectangle {
                            id: pipeTunnel
                            width: 100; height: 30; radius: 4; x: 95; y: 60
                            color: Qt.rgba(139, 92, 246, 0.15); border.color: "#8b5cf6"
                            layer.enabled: true
                            layer.effect: Glow { radius: 8; samples: 13; color: "#8b5cf6"; spread: 0.15 }
                            Text { text: "🔑 KERNEL PIPE"; color: "white"; font { pixelSize: 9; bold: true } anchors.centerIn: parent }
                        }

                        Rectangle {
                            id: appRight
                            width: 65; height: 40; radius: 6; x: 220; y: 55
                            color: Qt.rgba(255, 255, 255, 0.04); border.color: Qt.rgba(255, 255, 255, 0.2)
                            Text { text: "App B\n(e.g., wc)"; color: "white"; font.pixelSize: 10; horizontalAlignment: Text.AlignHCenter; anchors.centerIn: parent }
                        }

                        Text { text: "write"; color: "#a78bfa"; font.pixelSize: 9; x: 72; y: 40 }
                        Text { text: "reads"; color: "#a78bfa"; font.pixelSize: 9; x: 198; y: 40 }

                        Canvas {
                            width: parent.width; height: parent.height
                            onAvailableChanged: if(available) requestPaint()
                            onPaint: {
                                var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = "#8b5cf6"; ctx.lineWidth = 1.5;
                                ctx.beginPath(); ctx.moveTo(70, 75); ctx.lineTo(95, 75); ctx.stroke();
                                ctx.beginPath(); ctx.moveTo(195, 75); ctx.lineTo(220, 75); ctx.stroke();
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Text {
                        width: parent.width
                        text: "A Pipe is a secure circular ring buffer mapped inside kernel memory sectors. The pipe() initialization returns paired read/write tracks. To handle safe asynchronous stream processing, xv6 enforces strict internal sleep and wakeup locks, forcing fast producers to block and pause smoothly if the data queue reaches maximum saturation."
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

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Text { text: "🌟"; font.pixelSize: 22; Layout.alignment: Qt.AlignVCenter }

                Text {
                    Layout.fillWidth: true
                    text: "CORE TAKEAWAY: The OS abstracts all complex I/O devices into simple, identical File Descriptor numbers (0, 1, 2). Pipes connect these isolated numbers together, allowing processes to collaborate smoothly without touching physical block devices overhead."
                    color: "#ffffff"
                    wrapMode: Text.WordWrap
                    font { family: "Segoe UI"; bold: true; pixelSize: 12; letterSpacing: 0.2 }
                }
            }
        }
    }
}