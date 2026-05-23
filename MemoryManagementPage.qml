import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle {
    id: memoryManagementPage
    color: "transparent"
    anchors.fill: parent

    // Main Row containing the two distinct cards
    Row {
        id: mainLayoutRow
        anchors.fill: parent
        spacing: 25        // Aligned with CPU page spacing

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
                        model: [{
                                "label": "Total pages",
                                "total": 16.0,
                                "startPct": 0.77
                            }, {
                                "label": "Free pages",
                                "total": 4.0,
                                "startPct": 0.30
                            }, {
                                "label": "Pages in use",
                                "total": 12.0,
                                "startPct": 0.65
                            }, {
                                "label": "Fragmentation",
                                "total": 100,
                                "startPct": 0.15,
                                "unit": "%"
                            }]
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

                                property real currentPct: modelData.startPct

                                Timer {
                                    interval: 2000 + Math.random() * 2000
                                    running: true
                                    repeat: true
                                    onTriggered: parent.currentPct = 0.15 + Math.random() * 0.75
                                }

                                Behavior on currentPct {
                                    NumberAnimation {
                                        duration: 1500
                                        easing.type: Easing.InOutSine
                                    }
                                }

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
                                        text: modelData.unit
                                              === "%" ? Math.round(
                                                            parent.parent.currentPct * 100)
                                                        + "%" : (parent.parent.currentPct
                                                                 * modelData.total).toFixed(
                                                            1) + " GB / " + modelData.total.toFixed(
                                                            1) + " GB"
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
                                        width: Math.max(
                                                   height,
                                                   parent.parent.width * parent.parent.currentPct)
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

                    // Force a 16x16 grid (256 blocks total)
                    columns: 16
                    rows: 16
                    property int cellSpacing: 4

                    // Auto-calculate cell size to perfectly fit the available space
                    property real availableWidth: parent.width - 10
                    property real availableHeight: parent.height - 10
                    property real cellSize: Math.floor(Math.min((availableWidth - (columns - 1) * cellSpacing) / columns, (availableHeight - (rows - 1) * cellSpacing) / rows))

                    spacing: cellSpacing

                    Repeater {
                        model: 256 // Exact block count

                        delegate: Rectangle {
                            id: cellRect
                            width: memoryGrid.cellSize
                            height: memoryGrid.cellSize
                            radius: 3

                            // xv6 Address Math: Base is 0x80000000. Each block is 512KB (0x80000 bytes)
                            property string hexStart: "0x" + (0x80000000 + index * 0x80000).toString(16).toUpperCase()
                            property string hexEnd: "0x" + (0x80000000 + (index + 1) * 0x80000 - 1).toString(16).toUpperCase()

                            // State 0: Free, 1: User (Purple), 2: Kernel (Indigo)
                            // Dedicate the first 8 blocks (4MB) to the Kernel
                            property int pageState: index < 8 ? 2 : (Math.random() > 0.6 ? 1 : 0)

                            color: {
                                if (pageState === 1) return "#a855f7" // User
                                if (pageState === 2) return "#6366f1" // Kernel
                                return Qt.rgba(255, 255, 255, 0.05)   // Free
                            }

                            layer.enabled: pageState !== 0
                            layer.effect: Glow {
                                radius: 4
                                samples: 8
                                color: cellRect.pageState === 1 ? "#a855f7" : "#6366f1"
                                spread: 0.2
                            }

                            Timer {
                                interval: 1500 + Math.random() * 5000
                                running: pageState !== 2 // Kernel stays static
                                repeat: true
                                onTriggered: {
                                    if (Math.random() > 0.8) {
                                        parent.pageState = (Math.random() > 0.5 ? 1 : 0)
                                    }
                                }
                            }

                            Behavior on color { ColorAnimation { duration: 400 } }

                            // === HOVER TOOLTIP ===
                            MouseArea {
                                id: cellMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }

                            ToolTip {
                                visible: cellMouseArea.containsMouse
                                delay: 100 // Slight delay so it doesn't flash erratically while moving mouse

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
                        { name: "User", color: "#a855f7" },
                        { name: "Free", color: Qt.rgba(255,255,255,0.15) }
                    ]
                    delegate: Row {
                        spacing: 8
                        Rectangle {
                            width: 10; height: 10; radius: 2; color: modelData.color
                            anchors.verticalCenter: parent.verticalCenter
                            layer.enabled: modelData.name !== "Free"
                            layer.effect: Glow { radius: 4; samples: 8; color: modelData.color; spread: 0.2 }
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
