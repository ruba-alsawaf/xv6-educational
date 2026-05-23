import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    visible: true
    width: 1800
    height: 1000
    color: "#0d1117"
    anchors.fill: parent

    component DashboardCard : Rectangle {
        property string title
        property string value
        property string subtitle1
        property string subtitle2
        property real percent: 0
        property color valueColor: "#58a6ff"

        radius: 14
        color: "#161b22"
        border.color: "#30363d"

        Layout.fillWidth: true
        Layout.preferredHeight: 170

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            Text {
                text: parent.parent.title
                color: "#8b949e"
                font.bold: true
                font.pixelSize: 13
            }

            Text {
                text: parent.parent.value
                color: parent.parent.valueColor
                font.pixelSize: 28
                font.bold: true
            }

            Text {
                text: parent.parent.subtitle1
                color: "#c9d1d9"
                visible: text !== ""
            }

            Text {
                text: parent.parent.subtitle2
                color: "#c9d1d9"
                visible: text !== ""
            }

            ProgressBar {
                visible: percent > 0
                value: percent / 100

                Layout.fillWidth: true

                background: Rectangle {
                    color: "#0d1117"
                    radius: 5
                }

                contentItem: Item {
                    Rectangle {
                        width: parent.width * parent.parent.value
                        height: parent.height
                        radius: 5
                        color: "#238636"
                    }
                }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16

            Text {
                text: "FILE SYSTEM CORE ENGINE"
                color: "#c9d1d9"
                font.pixelSize: 28
                font.bold: true
            }

            GridLayout {
                columns: 4
                columnSpacing: 12
                rowSpacing: 12
                Layout.fillWidth: true

                DashboardCard {
                    title: "BUFFER CACHE"
                    value: backend.totalBuffers
                    subtitle1: "Busy: " + backend.busyBuffers
                    subtitle2: "Free: " + backend.freeBuffers
                    percent: backend.usagePercent
                }

                DashboardCard {
                    title: "HIT RATE"
                    value: backend.hitRate
                }

                DashboardCard {
                    title: "INODES"
                    value: backend.activeInodes
                    subtitle1: "Used: " + backend.usedInodes
                    subtitle2: "Free: " + backend.freeInodes
                }

                DashboardCard {
                    title: "LOG STATUS"
                    value: backend.logStatus
                    subtitle1: "Outstanding: " + backend.outstanding
                    subtitle2: "Committing: " + backend.committing
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 14
                color: "#161b22"
                border.color: "#30363d"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    Text {
                        text: "BUFFER CACHE VISUALIZER"
                        color: "#8b949e"
                        font.bold: true
                    }

                    GridView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        reuseItems: true
                        cacheBuffer: 1000
                        cellWidth: 90
                        cellHeight: 70

                        model: backend.bufferModel

                        delegate: Rectangle {
                            width: 74
                            height: 52
                            radius: 8

                            color:
                                modelData.ref > 0 ? "#238636" :
                                modelData.valid ? "#1f6feb" :
                                "#161b22"

                            border.color: "#30363d"

                            Text {
                                anchors.centerIn: parent
                                text: "Buf " + modelData.id
                                color: "white"
                                font.bold: true
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 260
                radius: 14
                color: "#161b22"
                border.color: "#30363d"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    Text {
                        text: "FILE SYSTEM EVENT TIMELINE"
                        color: "#8b949e"
                        font.bold: true
                    }

                    RowLayout {
                        spacing: 8

                        Text {
                            text: "PID:"
                            color: "white"
                        }

                        TextField {
                            id: pidInput
                            placeholderText: "Filter by PID"

                            background: Rectangle {
                                radius: 6
                                color: "#0d1117"
                                border.color: "#30363d"
                            }

                            color: "#c9d1d9"
                        }

                        Button {
                            text: "Refresh"

                            onClicked: {
                                backend.refreshTimeline(pidInput.text)
                            }

                            background: Rectangle {
                                radius: 6
                                color: "#238636"
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.bold: true
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        reuseItems: true
                        cacheBuffer: 2000

                        spacing: 10

                        model: backend.timelineModel

                        delegate: Rectangle {

                            width: ListView.view.width
                            height: 80
                            radius: 10

                            color: "#0d1117"
                            border.color: "#21262d"

                            Row {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 12

                                Text {
                                    text: "PID " + modelData.pid
                                    color: "#8b949e"
                                    width: 70
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Flickable {

                                    width: parent.width - 100
                                    height: 50

                                    contentWidth: timelineRow.width
                                    clip: true

                                    Row {

                                        id: timelineRow

                                        spacing: 8

                                        Repeater {

                                            model: modelData.events

                                            delegate: Rectangle {

                                                width: 120
                                                height: 42
                                                radius: 8

                                                color: modelData.color

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.op
                                                    color: "white"
                                                    font.bold: true
                                                }

                                                MouseArea {
                                                    anchors.fill: parent

                                                    onClicked: {
                                                        backend.inspectEvent(modelData.id)
                                                    }

                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
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
        }

        Rectangle {
            Layout.preferredWidth: 360
            Layout.fillHeight: true

            radius: 14
            color: "#161b22"
            border.color: "#30363d"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Text {
                    text: "TECHNICAL INSPECTOR"
                    color: "#8b949e"
                    font.bold: true
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    TextArea {
                        text: backend.inspectorText
                        color: "#c9d1d9"
                        readOnly: true
                        wrapMode: Text.Wrap

                        background: Rectangle {
                            color: "#0d1117"
                            border.color: "#30363d"
                            radius: 8
                        }
                    }
                }
            }
        }
    }
}