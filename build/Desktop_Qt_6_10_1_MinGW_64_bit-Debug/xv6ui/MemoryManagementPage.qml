import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle {
    id: memoryManagementPage
    color: "transparent"
    anchors.fill: parent

    Column {
        id: mainColumn
        anchors.fill: parent
        spacing: 25

        // === TOP ROW: Two rectangles side by side ===
        Row {
            width: parent.width
            height: parent.height
            spacing: 25

            // RECTANGLE 1: Memory & Usage (Left)
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
                    z: 2

                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 20
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Text {
                            text: "MEMORY USAGE"
                            font { family: "Segoe UI"; pixelSize: 13; weight: Font.Bold; letterSpacing: 1 }
                            color: "#ffffff"
                        }
                    }
                }

                // CONTAINER FOR BARS: Distributed evenly
                Item {
                    anchors {
                        top: memoryDashboardTitle.bottom
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        margins: 20
                    }

                    Column {
                        id: barsContainer
                        anchors.fill: parent
                        spacing: 0 // Spacing is now handled by the height of the delegates

                        Repeater {
                            model: [
                                { label: "Total pages", total: 16.0, startPct: 0.77, barColor: "#8b5cf6" },
                                { label: "Free pages", total: 4.0, startPct: 0.30, barColor: "#8b5cf6" },
                                { label: "Pages in use", total: 4.0, startPct: 0.30, barColor: "#8b5cf6" },
                                { label: "Fragmentation", total: 4.0, startPct: 0.30, barColor: "#8b5cf6" }
                            ]
                            delegate: Item {
                                width: barsContainer.width
                                height: barsContainer.height / 4 // Each bar takes exactly 1/4 of the space

                                Column {
                                    anchors.centerIn: parent // Center the bar content within its allocated 1/4th slice
                                    width: parent.width
                                    spacing: 12

                                    property real currentPct: modelData.startPct

                                    Timer {
                                        interval: 2000 + Math.random() * 2000
                                        running: true
                                        repeat: true
                                        onTriggered: {
                                            parent.currentPct = 0.15 + Math.random() * 0.80
                                        }
                                    }

                                    Behavior on currentPct {
                                        NumberAnimation { duration: 1500; easing.type: Easing.InOutSine }
                                    }

                                    Item {
                                        width: parent.width
                                        height: 18

                                        Text {
                                            anchors.left: parent.left
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: modelData.label
                                            color: "white"
                                            font { family: "Segoe UI"; pixelSize: 14; weight: Font.Bold }
                                        }

                                        Text {
                                            anchors.right: parent.right
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: (parent.parent.currentPct * modelData.total).toFixed(1) + " GB / " +
                                                  modelData.total.toFixed(1) + " GB (" +
                                                  Math.round(parent.parent.currentPct * 100) + "%)"
                                            color: Qt.rgba(255, 255, 255, 0.6)
                                            font { family: "Segoe UI"; pixelSize: 12; weight: Font.Bold }
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 24
                                        radius: 12
                                        color: Qt.rgba(0, 0, 0, 0.3)

                                        Rectangle {
                                            width: Math.max(height, parent.parent.width * parent.parent.currentPct)
                                            height: parent.height
                                            radius: 12
                                            color: modelData.barColor

                                            layer.enabled: true
                                            layer.effect: Glow {
                                                radius: 6; samples: 13; color: modelData.barColor; spread: 0.1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }

        // Placeholder for BOTTOM ROW
        Item {
            width: parent.width
            height: (parent.height - parent.spacing) * 1 / 3
        }
    }
}
