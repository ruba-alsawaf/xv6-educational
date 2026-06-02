import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "NavigationLogic.js" as Logic

Window {
    id: root
    width: 1400
    height: 900
    visible: true
    title: qsTr("xv6 OS Explorer")

    // Background Image Container with Blur
    Rectangle {
        anchors.fill: parent

        Image {
            id: backgroundImage
            source: "test.png"
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            smooth: true
            visible: false
        }

        FastBlur {
            anchors.fill: parent
            source: backgroundImage
            radius: 32
            transparentBorder: false
        }
    }

    // Dark overlay
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
    }

    // Subtle gradient overlay
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Diagonal
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.3) }
            GradientStop { position: 0.5; color: Qt.rgba(0, 0, 0, 0) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.3) }
        }
    }

    // --- Main Layout Row ---
    Row {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // ========== 1. SIDEBAR (CLEAR GLASS) ==========
        Rectangle {
            id: sidebar
            width: 280
            height: parent.height
            radius: 20
            color: Qt.rgba(255, 255, 255, 0.08)

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 30

                // Name of the system AREA
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "xv6"
                        font { family: "Segoe UI"; pixelSize: 28; weight: Font.Black; letterSpacing: 2 }
                        color: "#ffffff"
                    }
                    Text {
                        text: "OS EXPLORER"
                        font { family: "Segoe UI"; pixelSize: 10; weight: Font.Medium }
                        color: Qt.rgba(255, 255, 255, 0.6)
                    }
                    Rectangle {
                        width: 40; height: 2; radius: 1; color: Qt.rgba(255, 255, 255, 0.6)
                    }
                }

                // Navigation List
                ListView {
                    id: navList
                    width: parent.width
                    height: 380
                    spacing: 8
                    model: ListModel {
                        ListElement { name: "CPU SCHEDULING"; iconPath: "/icons/CPUSchedulingLogo.svg"; pageSource: "CpuSchedulingPage.qml" }
                        ListElement { name: "MEMORY MANAGEMENT"; iconPath: "/icons/MemoryManagmentLogo.svg"; pageSource: "MemoryManagementPage.qml" }
                        ListElement { name: "FILE SYSTEM"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "FileSystemLessonPage.qml" }
                        ListElement { name: "SYSTEM CALLS"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "KernelGuardPage.qml" }
                        ListElement { name: "PROCESSES & FORK"; iconPath: "/icons/CPUSchedulingLogo.svg"; pageSource: "ProcessForkPage.qml" }
                        ListElement { name: "OS ARCHITECTURE"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "OsArchitecturePage.qml" }
                        ListElement { name: "PRIVILEGE MODES"; iconPath: "/icons/CPUSchedulingLogo.svg"; pageSource: "CpuPrivilegeModesPage.qml" }
                        ListElement { name: "TRAPS OVERVIEW"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "TrapsOverviewPage.qml" }
                        ListElement { name: "Memory Translation"; iconPath: "/icons/MemoryManagmentLogo.svg"; pageSource: "MemoryTranslationPage.qml" }
                        ListElement { name: "KERNEL ADDRESS SPACE"; iconPath: "/icons/MemoryManagmentLogo.svg"; pageSource: "KernelSpacePage.qml" }
                        ListElement { name: "LESSON 9: USER SPACE"; iconPath: "/icons/MemoryManagmentLogo.svg"; pageSource: "UserAddressSpacePage.qml" }
                        ListElement { name: "LESSON 10: CONTEXT SWITCH"; iconPath: "/icons/MemoryManagmentLogo.svg"; pageSource: "ContextSwitchPage.qml" }
                    }

                    delegate: Rectangle {
                        id: delegateItem
                        width: parent.width
                        height: 45
                        radius: 10

                        property bool isSelected: navList.currentIndex === index

                        color: {
                            if (isSelected) return Qt.rgba(75, 42, 192, 0.15);
                            else if (mouseArea.containsMouse) return Qt.rgba(255, 255, 255, 0.08);
                            else return "transparent";
                        }

                        layer.enabled: isSelected
                        layer.effect: Glow {
                            radius: 6; samples: 13; color: "#4b2ac0"; spread: 0.2
                        }

                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutQuad } }

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 12

                            Image {
                                id: navIcon
                                source: iconPath
                                width: 20; height: 20
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                layer.enabled: true
                                layer.effect: ColorOverlay {
                                    color: isSelected || mouseArea.containsMouse ? "#ffffff" : Qt.rgba(255, 255, 255, 0.5)
                                }
                            }

                            Text {
                                id: navText
                                text: name
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: 13; font.family: "Segoe UI"; font.weight: Font.Bold
                                color: isSelected || mouseArea.containsMouse ? "#ffffff" : Qt.rgba(255, 255, 255, 0.6)
                                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutQuad } }
                            }
                        }

                        scale: mouseArea.containsMouse ? 1.02 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                navList.currentIndex = index;
                                pageLoader.source = Logic.handleTabChange(index);
                            }
                        }
                    }
                }
            }
        }

        // ========== 2. RIGHT SIDE (Content Area + Terminal) ==========
        Column {
            id: rightColumn
            width: parent.width - sidebar.width - parent.spacing
            height: parent.height
            spacing: 20


            Loader {
                id: pageLoader
                width: parent.width

                height: parent.height - aiPanel.height - (aiPanel.isOpen ? rightColumn.spacing : 0)
                source: "CpuSchedulingPage.qml"
                clip: true


                Behavior on height {
                    NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
                }
            }


            ChatbotPanel {
                id: aiPanel
                width: parent.width


                property bool isOpen: false


                height: isOpen ? 280 : 0
                visible: height > 0
                opacity: isOpen ? 1.0 : 0.0

                Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }
        }
    }


    Rectangle {
        id: aiChatButton
        width: 65
        height: 65
        radius: width / 2
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 35

        color: Qt.rgba(255, 255, 255, 0.1)
        border.color: Qt.rgba(255, 255, 255, 0.3)
        border.width: 1

        layer.enabled: true
        layer.effect: Glow {
            radius: 12; samples: 15; color: "#4b2ac0"; spread: 0.2
        }

        scale: aiMouseAreaBot.containsMouse ? 1.08 : 1.0
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

        Image {
            id: aiIcon
            anchors.centerIn: parent
            width: 32; height: 32
            source: "/icons/chat-bot.svg"
            fillMode: Image.PreserveAspectFit
            smooth: true
            layer.enabled: true
            layer.effect: ColorOverlay { color: "#ffffff" }
        }

        MouseArea {
            id: aiMouseAreaBot
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                aiPanel.isOpen = !aiPanel.isOpen
            }
        }
    }
}
