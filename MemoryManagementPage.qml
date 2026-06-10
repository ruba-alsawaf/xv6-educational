import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle {
    id: memoryManagementPage
    color: "transparent"
    anchors.fill: parent

    // 💡 مصفوفة استقبال البيانات الحية الهيكلية من الـ Backend في C++
    property variant memoryRawData: ({"totalPages": 32768, "freePages": 32768, "usedPages": 0, "fragmentation": 0, "gridStates": []})

    // ⚡ التايمر المركزي لجلب البيانات الحية كل ثانية ومنع تعليق أو بطء الواجهة
    Timer {
        id: liveMemTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            memoryManagementPage.memoryRawData = dbManager.getLiveMemoryMetrics()
        }
    }

    // Main Row containing the two distinct cards
    Row {
        id: mainLayoutRow
        anchors.fill: parent
        spacing: 25        // متناسق تماماً مع توزيع صفحة الـ CPU

        // === RECTANGLE 1: Memory & Usage (Left) ===
        Rectangle {
            id: memoryUsageCard
            width: (parent.width - parent.spacing) / 2
            height: parent.height
            color: Qt.rgba(255, 255, 255, 0.08)
            radius: 20

            // Title Bar
            Rectangle {
                id: memoryDashboardTitle
                width: parent.width
                height: 52
                radius: 20
                color: "transparent"

                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 20
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    Text {
                        text: "MEMORY USAGE"
                        font {
                            family: "Segoe UI"
                            pixelSize: 13
                            weight: Font.Bold
                            letterSpacing: 1
                        }
                        color: "#ffffff"
                    }
                }
            }

            // Centralized area for the 4 bars
            Item {
                anchors {
                    top: memoryDashboardTitle.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    margins: 20
                    topMargin: 15
                }

                Column {
                    id: barsColumn
                    anchors.fill: parent
                    spacing: 0

                    Repeater {
                        model: [
                            { "label": "Total pages",  "current": memoryManagementPage.memoryRawData.totalPages,  "max": 32768, "unit": " Pages" },
                            { "label": "Free pages",   "current": memoryManagementPage.memoryRawData.freePages,   "max": 32768, "unit": " Pages" },
                            { "label": "Pages in use", "current": memoryManagementPage.memoryRawData.usedPages,   "max": 32768, "unit": " Pages" },
                            { "label": "Fragmentation", "current": memoryManagementPage.memoryRawData.fragmentation, "max": 100,   "unit": "%" }
                        ]

                        delegate: Item {
                            width: barsColumn.width
                            height: barsColumn.height / 4

                            // Separator line
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Qt.rgba(255, 255, 255, 0.05)
                                anchors.bottom: parent.bottom
                                visible: index !== 3
                            }

                            Column {
                                width: parent.width
                                anchors.centerIn: parent
                                spacing: 14

                                // حساب النسبة المئوية للـ Bar انسيابياً بناءً على نوع العداد
                                property real calculatedPct: modelData.label === "Fragmentation" ? modelData.current / 100.0 : modelData.current / modelData.max

                                // Info Row
                                Item {
                                    width: parent.width
                                    height: 18
                                    Text {
                                        anchors.left: parent.left
                                        text: modelData.label
                                        color: "white"
                                        font {
                                            family: "Segoe UI"
                                            pixelSize: 14
                                            weight: Font.Bold
                                        }
                                    }
                                    Text {
                                        anchors.right: parent.right
                                        text: modelData.label === "Fragmentation" ? modelData.current + "%" : modelData.current + " / " + modelData.max + modelData.unit
                                        color: Qt.rgba(255, 255, 255, 0.6)
                                        font {
                                            family: "Segoe UI"
                                            pixelSize: 12
                                            weight: Font.Bold
                                        }
                                    }
                                }

                                // The Pill Bar
                                Rectangle {
                                    width: parent.width
                                    height: 32
                                    radius: 16
                                    color: Qt.rgba(0, 0, 0, 0.3)

                                    Rectangle {
                                        // الربط الانسيابي الذكي بحجم الشاشة والنسبة الفعلية الحية
                                        width: Math.max(height, parent.width * parent.calculatedPct)
                                        height: parent.height
                                        radius: 16
                                        color: "#8b5cf6"

                                        layer.enabled: true
                                        layer.effect: Glow {
                                            radius: 6
                                            samples: 13
                                            color: "#8b5cf6"
                                            spread: 0.1
                                        }

                                        // أنيميشن ناعم لتغير حجم البارات عند دخول البيانات الجديدة من الكيرنل
                                        Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutQuad } }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // === RECTANGLE 2: xv6 Virtual Memory Map (Right) ===
        Rectangle {
            id: secondaryCard
            width: (mainLayoutRow.width - mainLayoutRow.spacing) / 2
            height: parent.height
            color: Qt.rgba(255, 255, 255, 0.08)
            radius: 20
            clip: true // Keep the grid within the rounded corners

            // Title Bar
            Rectangle {
                id: secondaryTitle
                width: parent.width
                height: 52
                radius: 20
                color: "transparent"

                Row {
                    anchors.fill: parent
                    anchors.margins: 20
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    Text {
                        text: "PHYSICAL MEMORY MAP (128MB)"
                        font {
                            family: "Segoe UI"
                            pixelSize: 13
                            weight: Font.Bold
                            letterSpacing: 1
                        }
                        color: "#ffffff"
                    }
                }
            }

            // --- THE 256-BLOCK MEMORY GRID ---
            Item {
                anchors {
                    top: secondaryTitle.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    margins: 20
                    bottomMargin: 50 // Room for legend
                }

                Grid {
                    id: memoryGrid
                    anchors.centerIn: parent

                    // 16x16 grid (256 blocks total)
                    columns: 16
                    rows: 16
                    property int cellSpacing: 4

                    // الحساب التلقائي لحجم المربعات لتتناسب بدقة مع أبعاد الشاشات المختلفة للماك
                    property real availableWidth: parent.width - 10
                    property real availableHeight: parent.height - 10
                    property real cellSize: Math.floor(Math.min((availableWidth - (columns - 1) * cellSpacing) / columns, (availableHeight - (rows - 1) * cellSpacing) / rows))

                    spacing: cellSpacing

                    Repeater {
                        model: 256 // العدد الفعلي للمربعات

                        delegate: Rectangle {
                            id: cellRect
                            width: memoryGrid.cellSize
                            height: memoryGrid.cellSize
                            radius: 3

                            // رياضياّ في xv6: القاعدة تبدأ من 0x80000000. كل مربع يمثل 512KB (0x80000 bytes)
                            property string hexStart: "0x" + (0x80000000 + index * 0x80000).toString(16).toUpperCase()
                            property string hexEnd: "0x" + (0x80000000 + (index + 1) * 0x80000 - 1).toString(16).toUpperCase()

                            // 💡 قراءة الحالة الحية للكتلة مباشرة من الباك إيند (0: Free, 1: User, 2: Kernel)
                            property int pageState: (memoryManagementPage.memoryRawData.gridStates && memoryManagementPage.memoryRawData.gridStates.length > index)
                                                    ? memoryManagementPage.memoryRawData.gridStates[index] : 0

                            color: {
                                if (pageState === 1) return "#a855f7" // User (Purple)
                                if (pageState === 2) return "#6366f1" // Kernel (Indigo)
                                return Qt.rgba(255, 255, 255, 0.05)   // Free (Dark)
                            }

                            layer.enabled: pageState !== 0
                            layer.effect: Glow {
                                radius: 4
                                samples: 8
                                color: cellRect.pageState === 1 ? "#a855f7" : "#6366f1"
                                spread: 0.2
                            }

                            // وميض لوني ناعم وسلس عند تغير حالة المربعات لحظياً
                            Behavior on color { ColorAnimation { duration: 300 } }

                            // === HOVER TOOLTIP ===
                            MouseArea {
                                id: cellMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }

                            ToolTip {
                                visible: cellMouseArea.containsMouse
                                delay: 100 // تأخير بسيط لمنع الوميض المزعج أثناء حركة الماوس السريعة

                                background: Rectangle {
                                    color: Qt.rgba(10/255, 10/255, 20/255, 0.95)
                                    border.color: cellRect.color
                                    border.width: 1
                                    radius: 8
                                }

                                contentItem: Text {
                                    text: "<b>BLOCK " + index + "</b><br>" +
                                          "<font color='#aaaaaa'>Pages:</font> " + (index * 128) + " - " + ((index + 1) * 128 - 1) + "<br>" +
                                          "<font color='#aaaaaa'>Address:</font> " + cellRect.hexStart + " - " + cellRect.hexEnd
                                    color: "#ffffff"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 12
                                    textFormat: Text.RichText
                                }
                            }
                        }
                    }
                }
            }

            // LEGEND: Positioned at Bottom Left
            Row {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    margins: 20
                }
                spacing: 20

                Repeater {
                    model: [
                        { name: "Kernel", color: "#6366f1" },
                        { name: "User",   color: "#a855f7" },
                        { name: "Free",   color: Qt.rgba(255,255,255,0.15) }
                    ]
                    delegate: Row {
                        spacing: 8
                        Rectangle {
                            id: legendDot
                            width: 10; height: 10; radius: 2; color: modelData.color
                            anchors.verticalCenter: parent.verticalCenter
                            layer.enabled: modelData.name !== "Free"
                            layer.effect: Glow { radius: 4; samples: 8; color: legendDot.color; spread: 0.2 }
                        }
                        Text {
                            text: modelData.name; color: Qt.rgba(255,255,255,0.5)
                            font { family: "Segoe UI"; pixelSize: 11; weight: Font.Bold }
                        }
                    }
                }
            }
        }
    }
}
