import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: fileSystemPage
    Layout.fillWidth: true
    Layout.fillHeight: true

    // مكون كرت الداشبورد الاحترافي (Glassmorphism Style)
    component DashboardCard : Rectangle {
        property string title
        property string value
        property string subtitle1
        property string subtitle2
        property real percent: 0
        property color valueColor: "#58a6ff"

        radius: 16
        color: Qt.rgba(255, 255, 255, 0.04)
        border.color: Qt.rgba(255, 255, 255, 0.08)

        Layout.fillWidth: true
        Layout.preferredHeight: 140

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 4

            Text {
                text: parent.parent.title
                color: Qt.rgba(255, 255, 255, 0.5)
                font { family: "Segoe UI"; bold: true; pixelSize: 11; letterSpacing: 1 }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: parent.parent.parent.value
                    color: parent.parent.parent.valueColor
                    font { family: "Segoe UI"; pixelSize: 26; weight: Font.DemiBold }
                }

                Item { Layout.fillWidth: true }

                // دائرة النسبة أو الـ Progress الصغير إذا كانت القيمة موجودة
                Rectangle {
                    width: 35; height: 35; radius: 17.5
                    color: Qt.rgba(23, 42, 192, 0.2)
                    visible: parent.parent.parent.percent > 0
                    border.color: "#4b2ac0"
                    Text {
                        anchors.centerIn: parent
                        text: Math.round(parent.parent.parent.percent) + "%"
                        color: "#ffffff"
                        font.pixelSize: 10
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                Text {
                    text: parent.parent.parent.subtitle1
                    color: Qt.rgba(255, 255, 255, 0.7)
                    font { family: "Segoe UI"; pixelSize: 12 }
                    visible: text !== ""
                }
                Text {
                    text: parent.parent.parent.subtitle2
                    color: Qt.rgba(255, 255, 255, 0.4)
                    font { family: "Segoe UI"; pixelSize: 12 }
                    visible: text !== ""
                }
            }
        }
    }

    // --- Layout الأساسي للـ Content ---
    RowLayout {
        anchors.fill: parent
        spacing: 20

        // القسم الأيسر والأوسط (الداشبورد، المخططات، والجدول)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            // العنوان العلوي المتناسق مع الهوية البصرية الجديدة
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "FILE SYSTEM EXPLORER"
                    color: "#ffffff"
                    font { family: "Segoe UI"; pixelSize: 22; weight: Font.Black; letterSpacing: 1 }
                }
                Text {
                    text: "Unified View: Storage Engine + Namespace Engine"
                    color: Qt.rgba(255, 255, 255, 0.5)
                    font { family: "Segoe UI"; pixelSize: 12 }
                    Layout.alignment: Qt.AlignBottom
                    Layout.leftMargin: 10
                }
            }

            // 1. كروت الداشبورد العلوية (GridLayout)
            GridLayout {
                columns: 4
                columnSpacing: 15
                rowSpacing: 15
                Layout.fillWidth: true

                DashboardCard {
                    title: "1. BUFFER CACHE"
                    value: backend.totalBuffers
                    subtitle1: "● " + backend.busyBuffers + " Busy"
                    subtitle2: "● " + backend.freeBuffers + " Free"
                    percent: backend.usagePercent
                    valueColor: "#ffffff"
                }

                DashboardCard {
                    title: "2. HIT RATE"
                    value: backend.hitRate
                    subtitle1: "Overall Hit Rate"
                    valueColor: "#58a6ff"
                    percent: parseFloat(backend.hitRate)
                }

                DashboardCard {
                    title: "3. INODES"
                    value: backend.activeInodes
                    subtitle1: "● " + backend.usedInodes + " Locked"
                    subtitle2: "● " + backend.freeInodes + " Free"
                    valueColor: "#ffffff"
                }

                DashboardCard {
                    title: "4. LOG STATUS"
                    value: backend.logStatus
                    subtitle1: "Outstanding: " + backend.outstanding
                    subtitle2: "Committing: " + backend.committing
                    valueColor: "#3fb950"
                }
            }

            // 2. القسم الأوسط: Visualizer + Tree + FD Table
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15

                // Buffer Visualizer Block
                Rectangle {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    Layout.preferredWidth: 1.2
                    color: Qt.rgba(255, 255, 255, 0.03); radius: 14; border.color: Qt.rgba(255, 255, 255, 0.06)

                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 14; spacing: 10
                        Text { text: "2. BUFFER CACHE VISUALIZER"; color: Qt.rgba(255, 255, 255, 0.6); font { family: "Segoe UI"; bold: true; pixelSize: 12 } }

                        GridView {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            model: backend.bufferModel
                            cellWidth: 70; cellHeight: 60
                            clip: true
                            delegate: Rectangle {
                                width: 62; height: 52; radius: 8
                                // تغيير الألوان لكي تطابق الـ Palette الاحترافي بالصورة
                                color: modelData.ref > 0 ? Qt.rgba(35, 134, 54, 0.2) : Qt.rgba(31, 111, 235, 0.15)
                                border.color: modelData.ref > 0 ? "#238636" : "#1f6feb"
                                border.width: 1

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Buf " + modelData.id; color: "#ffffff"; font.pixelSize: 11; font.bold: true }
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Ref: " + modelData.ref; color: Qt.rgba(255,255,255,0.6); font.pixelSize: 9 }
                                }
                            }
                        }
                    }
                }

                // Directory Tree Block
                Rectangle {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    Layout.preferredWidth: 1.0
                    color: Qt.rgba(255, 255, 255, 0.03); radius: 14; border.color: Qt.rgba(255, 255, 255, 0.06)

                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 14
                        Text { text: "3. DIRECTORY TREE"; color: Qt.rgba(255, 255, 255, 0.6); font { family: "Segoe UI"; bold: true; pixelSize: 12 } }
                        ListView {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            model: backend.directoryTreeModel
                            clip: true
                            delegate: Rectangle {
                                width: parent.width; height: 28; color: "transparent"
                                RowLayout {
                                    anchors.fill: parent; spacing: 8
                                    Text {
                                        text: modelData
                                        color: "#ffffff"
                                        font { family: "Consolas"; pixelSize: 13 }
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }

                // File Descriptor Table Block
                Rectangle {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    Layout.preferredWidth: 1.5
                    color: Qt.rgba(255, 255, 255, 0.03); radius: 14; border.color: Qt.rgba(255, 255, 255, 0.06)

                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 14; spacing: 8
                        Text { text: "4. FILE DESCRIPTOR TABLE (PID 15)"; color: Qt.rgba(255, 255, 255, 0.6); font { family: "Segoe UI"; bold: true; pixelSize: 12 } }

                        // Header Table
                        RowLayout {
                            Layout.fillWidth: true
                            Rectangle { Layout.fillWidth: true; height: 25; color: Qt.rgba(255,255,255,0.05); radius: 4
                                RowLayout { anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                                    Text { text: "PID"; color: Qt.rgba(255,255,255,0.5); font.pixelSize: 11; Layout.preferredWidth: 35 }
                                    Text { text: "FD"; color: Qt.rgba(255,255,255,0.5); font.pixelSize: 11; Layout.preferredWidth: 30 }
                                    Text { text: "TYPE"; color: Qt.rgba(255,255,255,0.5); font.pixelSize: 11; Layout.preferredWidth: 65 }
                                    Text { text: "TARGET"; color: Qt.rgba(255,255,255,0.5); font.pixelSize: 11; Layout.fillWidth: true }
                                }
                            }
                        }

                        ListView {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            model: backend.fdTableModel
                            clip: true
                            spacing: 4
                            delegate: Rectangle {
                                width: parent.width; height: 32; radius: 6
                                color: index % 2 === 0 ? Qt.rgba(255,255,255,0.02) : "transparent"
                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                                    Text { text: modelData.pid; color: "#ffffff"; font.pixelSize: 12; Layout.preferredWidth: 35 }
                                    Text { text: modelData.fd; color: "#ffffff"; font.pixelSize: 12; Layout.preferredWidth: 30 }
                                    Text { text: modelData.type; color: "#58a6ff"; font { family: "Consolas"; pixelSize: 11 } Layout.preferredWidth: 65 }
                                    Text { text: modelData.target; color: Qt.rgba(255,255,255,0.8); font.pixelSize: 12; Layout.fillWidth: true; elide: Text.ElideRight }
                                }
                            }
                        }
                    }
                }
            }

            // 3. المخطط الزمني السفلي الـ Gantt Chart
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 240
                radius: 16
                color: Qt.rgba(255, 255, 255, 0.03)
                border.color: Qt.rgba(255, 255, 255, 0.06)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "5. FILE SYSTEM EVENT TIMELINE (GANTT CHART)"
                            color: Qt.rgba(255, 255, 255, 0.6)
                            font { family: "Segoe UI"; bold: true; pixelSize: 12 }
                        }
                        Item { Layout.fillWidth: true }

                        // فلتر الـ PID بطريقة مودرن أكثر
                        TextField {
                            id: pidInput
                            placeholderText: "Filter by PID..."
                            font.pixelSize: 11
                            background: Rectangle {
                                implicitWidth: 120; implicitHeight: 28; radius: 6
                                color: Qt.rgba(0, 0, 0, 0.3); border.color: Qt.rgba(255,255,255,0.1)
                            }
                            color: "#ffffff"
                        }
                        Button {
                            text: "Refresh"
                            onClicked: backend.refreshTimeline(pidInput.text)
                            background: Rectangle { implicitWidth: 70; implicitHeight: 28; radius: 6; color: "#4b2ac0" }
                            contentItem: Text { text: parent.text; color: "white"; font.bold: true; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        }
                    }

                    ListView {
                        id: timelineView
                        Layout.fillWidth: true; Layout.fillHeight: true
                        spacing: 8
                        clip: true
                        model: backend.timelineModel

                        delegate: Rectangle {
                            width: timelineView.width; height: 50; radius: 8
                            color: Qt.rgba(255, 255, 255, 0.02)
                            border.color: Qt.rgba(255,255,255,0.04)

                            RowLayout {
                                anchors.fill: parent; anchors.margins: 6; spacing: 10

                                Text {
                                    text: "PID " + modelData.pid
                                    color: Qt.rgba(255, 255, 255, 0.7)
                                    font { family: "Segoe UI"; bold: true; pixelSize: 12 }
                                    Layout.preferredWidth: 60
                                }

                                Flickable {
                                    Layout.fillWidth: true; Layout.fillHeight: true
                                    contentWidth: timelineRow.width; clip: true
                                    Row {
                                        id: timelineRow; spacing: 6; anchors.verticalCenter: parent.verticalCenter
                                        Repeater {
                                            model: modelData.events
                                            delegate: Rectangle {
                                                width: 110; height: 34; radius: 6
                                                // استخدام اللون القادم من الـ backend وإذا لم يتوفر نضع لون احترافي افتراضي
                                                color: modelData.color ? modelData.color : Qt.rgba(75, 42, 192, 0.4)
                                                border.color: Qt.rgba(255,255,255,0.15)

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.op
                                                    color: "white"
                                                    font { family: "Consolas"; bold: true; pixelSize: 11 }
                                                }
                                                MouseArea {
                                                    anchors.fill: parent; hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: backend.inspectEvent(modelData.id)
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

        // ========== القسم الأيمن (TECHNICAL INSPECTOR) ==========
        Rectangle {
            Layout.preferredWidth: 340
            Layout.fillHeight: true
            radius: 16
            color: Qt.rgba(255, 255, 255, 0.04)
            border.color: Qt.rgba(255, 255, 255, 0.08)

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 12

                Text {
                    text: "6. TECHNICAL INSPECTOR"
                    color: Qt.rgba(255, 255, 255, 0.6)
                    font { family: "Segoe UI"; bold: true; pixelSize: 12; letterSpacing: 0.5 }
                }

                ScrollView {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true
                    TextArea {
                        text: backend.inspectorText
                        color: "#ffffff"
                        readOnly: true; wrapMode: Text.Wrap
                        font { family: "Consolas"; pixelSize: 12 }
                        background: Rectangle {
                            color: Qt.rgba(0, 0, 0, 0.2)
                            radius: 8
                            border.color: Qt.rgba(255,255,255,0.05)
                        }
                        padding: 10
                    }
                }
            }
        }
    }
}