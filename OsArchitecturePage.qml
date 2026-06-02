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
                    text: "LESSON 4: OS ARCHITECTURE (MONOLITHIC VS. MICROKERNEL)"
                    color: "#ffffff"
                    font { family: "Segoe UI"; bold: true; pixelSize: 20; letterSpacing: 0.5 }
                }
                Text {
                    text: "💡 GOAL: Understand how OS services are structured for efficiency and security, and see why xv6 uses a Monolithic design."
                    color: Qt.rgba(255, 255, 255, 0.6)
                    font { family: "Segoe UI"; pixelSize: 13 }
                }
            }
        }

        // ==========================================
        // 2. TWO COLUMNS LAYOUT: المقارنة بين التصميمين
        // ==========================================
        Row {
            width: parent.width
            spacing: 20

            // ------------------------------------------
            // [SIDE A]: النواة الموحدة - تصميم xv6
            // ------------------------------------------
            Rectangle {
                width: (parent.width - 20) / 2
                height: 520
                color: Qt.rgba(255, 255, 255, 0.02)
                radius: 16
                border.color: Qt.rgba(139, 92, 246, 0.2)
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
                            Text { text: "A"; color: "white"; font.bold: true; anchors.centerIn: parent }
                        }
                        Column {
                            spacing: 2
                            Text { text: "MONOLITHIC KERNEL (xv6 DESIGN)"; color: "white"; font { bold: true; pixelSize: 14 } }
                            Text { text: "All core services run in Supervisor Mode"; color: Qt.rgba(255, 255, 255, 0.4); font.pixelSize: 11 }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    // مخطط النواة الموحدة المصلح بأبعاد صريحة وثابتة
                    Item {
                        width: parent.width
                        height: 220

                        Rectangle {
                            id: monoKernelBlock
                            width: parent.width - 20; height: 130; x: 10; y: 10
                            radius: 12
                            color: Qt.rgba(139, 92, 246, 0.08); border.color: "#8b5cf6"
                            border.width: 1.5

                            layer.enabled: true
                            layer.effect: Glow { radius: 8; samples: 13; color: Qt.rgba(139, 92, 246, 0.15); spread: 0.1 }

                            Text {
                                text: "THE KERNEL (SUPERVISOR MODE)"
                                color: "#c084fc"; font { bold: true; pixelSize: 10; letterSpacing: 0.5 }
                                anchors { top: parent.top; topMargin: 10; horizontalCenter: parent.horizontalCenter }
                            }

                            // شبكة الخدمات الداخلية الآمنة بدون تداخل الـ Layouts
                            Grid {
                                columns: 2
                                rows: 2
                                anchors { fill: parent; topMargin: 35; bottomMargin: 12; leftMargin: 15; rightMargin: 15 }
                                spacing: 10

                                Rectangle { width: (parent.width - 10) / 2; height: (parent.height - 45) / 2; radius: 6; color: Qt.rgba(0,0,0,0.3); border.color: Qt.rgba(255,255,255,0.05)
                                    Text { text: "Process\nScheduling"; color: "white"; font.pixelSize: 10; anchors.centerIn: parent; horizontalAlignment: Text.AlignHCenter } }
                                Rectangle { width: (parent.width - 10) / 2; height: (parent.height - 45) / 2; radius: 6; color: Qt.rgba(0,0,0,0.3); border.color: Qt.rgba(255,255,255,0.05)
                                    Text { text: "Memory\nManagement"; color: "white"; font.pixelSize: 10; anchors.centerIn: parent; horizontalAlignment: Text.AlignHCenter } }
                                Rectangle { width: (parent.width - 10) / 2; height: (parent.height - 45) / 2; radius: 6; color: Qt.rgba(0,0,0,0.3); border.color: Qt.rgba(255,255,255,0.05)
                                    Text { text: "File System\nDrivers"; color: "white"; font.pixelSize: 10; anchors.centerIn: parent; horizontalAlignment: Text.AlignHCenter } }
                                Rectangle { width: (parent.width - 10) / 2; height: (parent.height - 45) / 2; radius: 6; color: Qt.rgba(0,0,0,0.3); border.color: Qt.rgba(255,255,255,0.05)
                                    Text { text: "Network\nStack"; color: "white"; font.pixelSize: 10; anchors.centerIn: parent; horizontalAlignment: Text.AlignHCenter } }
                            }
                        }

                        Canvas {
                            width: parent.width; height: parent.height
                            onAvailableChanged: if(available) requestPaint()
                            onPaint: {
                                var ctx = getContext("2d"); ctx.reset();
                                ctx.strokeStyle = "#8b5cf6"; ctx.lineWidth = 2;
                                ctx.beginPath(); ctx.moveTo(width/2, 140); ctx.lineTo(width/2, 168); ctx.stroke();
                                ctx.fillStyle = "#8b5cf6"; ctx.beginPath(); ctx.moveTo(width/2 - 5, 168); ctx.lineTo(width/2, 175); ctx.lineTo(width/2 + 5, 168); ctx.fill();
                            }
                        }

                        Rectangle {
                            width: parent.width - 40; height: 35; x: 20; y: 175; radius: 6
                            color: Qt.rgba(255, 255, 255, 0.04); border.color: Qt.rgba(255, 255, 255, 0.2)
                            Text { text: "RAW HARDWARE (CPU, DISK, MEMORY)"; color: "white"; font { bold: true; pixelSize: 10 } anchors.centerIn: parent }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Text {
                        width: parent.width
                        text: "HIGH PERFORMANCE! In xv6, every critical component operates inside one massive binary block. Because they share the exact same space, they communicate via fast, direct C function calls. This eliminates communication overhead, making monolithic kernels incredibly fast, though a single bug inside any subsystem can panic and crash the entire system."
                        color: Qt.rgba(255, 255, 255, 0.7)
                        wrapMode: Text.WordWrap
                        font { family: "Segoe UI"; pixelSize: 12 }
                        lineHeight: 1.35
                    }
                }
            }

            // ------------------------------------------
            // [SIDE B]: النواة المصغرة - التصميم المعزول
            // ------------------------------------------
            Rectangle {
                width: (parent.width - 20) / 2
                height: 520
                color: Qt.rgba(255, 255, 255, 0.02)
                radius: 16
                border.color: Qt.rgba(16, 185, 129, 0.2)
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
                            Text { text: "B"; color: "white"; font.bold: true; anchors.centerIn: parent }
                        }
                        Column {
                            spacing: 2
                            Text { text: "MICROKERNEL DESIGN"; color: "white"; font { bold: true; pixelSize: 14 } }
                            Text { text: "Services are isolated into User Space applications"; color: Qt.rgba(255, 255, 255, 0.4); font.pixelSize: 11 }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    // مخطط النواة المصغرة المصلح وثابت الأبعاد
                    Item {
                        width: parent.width
                        height: 220

                        Row {
                            id: isolatedServicesRow
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: 10; spacing: 8

                            Rectangle { width: 62; height: 35; radius: 6; color: Qt.rgba(255,255,255,0.03); border.color: Qt.rgba(255,255,255,0.1)
                                Text { text: "VFS\n(File)"; color: "white"; font.pixelSize: 9; anchors.centerIn: parent; horizontalAlignment: Text.AlignHCenter } }
                            Rectangle { width: 62; height: 35; radius: 6; color: Qt.rgba(255,255,255,0.03); border.color: Qt.rgba(255,255,255,0.1)
                                Text { text: "Drivers\n(Disk)"; color: "white"; font.pixelSize: 9; anchors.centerIn: parent; horizontalAlignment: Text.AlignHCenter } }
                            Rectangle { width: 62; height: 35; radius: 6; color: Qt.rgba(255,255,255,0.03); border.color: Qt.rgba(255,255,255,0.1)
                                Text { text: "Network\nServer"; color: "white"; font.pixelSize: 9; anchors.centerIn: parent; horizontalAlignment: Text.AlignHCenter } }
                        }

                        Rectangle {
                            id: microKernelBlock
                            width: parent.width - 40; height: 60; x: 20; y: 90; radius: 10
                            color: Qt.rgba(16, 185, 129, 0.12); border.color: "#10b981"
                            border.width: 1.5
                            layer.enabled: true
                            layer.effect: Glow { radius: 8; samples: 13; color: "#10b981"; spread: 0.1 }

                            Column {
                                anchors.centerIn: parent; spacing: 2
                                Text { text: "🛡️ THE MICROKERNEL"; color: "white"; font { bold: true; pixelSize: 11 } }
                                Text { text: "IPC • Scheduling • Address Spaces"; color: "#6ee7b7"; font.pixelSize: 9 }
                            }
                        }

                        Canvas {
                            width: parent.width; height: parent.height
                            onAvailableChanged: if(available) requestPaint()
                            onPaint: {
                                var ctx = getContext("2d"); ctx.reset();
                                ctx.strokeStyle = "#10b981"; ctx.lineWidth = 1.5; ctx.setLineDash([2, 2]);

                                ctx.beginPath(); ctx.moveTo(width/2 - 70, 45); ctx.lineTo(width/2 - 70, 90); ctx.stroke();
                                ctx.beginPath(); ctx.moveTo(width/2, 45); ctx.lineTo(width/2, 90); ctx.stroke();
                                ctx.beginPath(); ctx.moveTo(width/2 + 70, 45); ctx.lineTo(width/2 + 70, 90); ctx.stroke();

                                ctx.setLineDash([]); ctx.lineWidth = 2;
                                ctx.beginPath(); ctx.moveTo(width/2, 150); ctx.lineTo(width/2, 168); ctx.stroke();
                                ctx.fillStyle = "#10b981"; ctx.beginPath(); ctx.moveTo(width/2 - 5, 168); ctx.lineTo(width/2, 175); ctx.lineTo(width/2 + 5, 168); ctx.fill();
                            }
                        }

                        Rectangle {
                            width: parent.width - 40; height: 35; x: 20; y: 175; radius: 6
                            color: Qt.rgba(255, 255, 255, 0.04); border.color: Qt.rgba(255, 255, 255, 0.2)
                            Text { text: "RAW HARDWARE (CPU, DISK, MEMORY)"; color: "white"; font { bold: true; pixelSize: 10 } anchors.centerIn: parent }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Text {
                        width: parent.width
                        text: "HIGH SECURITY! Microkernels trim down kernel logic to the absolute bare minimum. Services run externally inside unprivileged User Space. If the Network Server or File Driver crashes, the OS seamlessly restarts it without interrupting anything else! However, passing messages across spaces via IPC incurs a heavy performance penalty."
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
                    text: "CORE SUMMARY: Monolithic architectures (like xv6 and Linux) bundle all subsystems together inside the kernel for optimal speed. Microkernels prioritize stability and total isolation, trading away raw execution speed for robust fault tolerance."
                    color: "#ffffff"
                    wrapMode: Text.WordWrap
                    font { family: "Segoe UI"; bold: true; pixelSize: 12; letterSpacing: 0.2 }
                }
            }
        }
    }
}