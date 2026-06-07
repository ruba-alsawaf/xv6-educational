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

    // ========== 1. الخلفية المشتركة (تبقى في الخارج لتعطي جمالية لشاشة الدخول والبرنامج) ==========
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

    // ========== 2. حاوية لوحة التحكم (مخفية في البداية) ==========
    Item {
        id: mainDashboard
        anchors.fill: parent
        visible: false // مخفية حتى يتم تسجيل الدخول بنجاح

        // --- Main Layout Row --- (تم نقله إلى داخل الـ Item)
        Row {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // ========== SIDEBAR (CLEAR GLASS) ==========
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
                            font {
                                family: "Segoe UI"
                                pixelSize: 28
                                weight: Font.Black
                                letterSpacing: 2
                            }
                            color: "#ffffff"
                        }
                        Text {
                            text: "OS EXPLORER"
                            font {
                                family: "Segoe UI"
                                pixelSize: 10
                                weight: Font.Medium
                            }
                            color: Qt.rgba(255, 255, 255, 0.6)
                        }
                        Rectangle {
                            width: 40
                            height: 2
                            radius: 1
                            color: Qt.rgba(255, 255, 255, 0.6)
                        }
                    }

                    // Navigation List with Purple Glassy Selection
                    ListView {
                        id: navList
                        width: parent.width
                        height: 550
                        spacing: 8
                        model: ListModel {
                            ListElement { name: "CPU SCHEDULING"; iconPath: "/icons/CPUSchedulingLogo.svg"; pageSource: "CpuSchedulingPage.qml" }
                            ListElement { name: "MEMORY MANAGEMENT"; iconPath: "/icons/MemoryManagmentLogo.svg"; pageSource: "MemoryManagementPage.qml" }
                            ListElement { name: "FILE SYSTEM"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "FileSystem.qml" }
                            ListElement { name: "SYSTEM CALLS"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "KernelGuardPage.qml" }
                            ListElement { name: "PROCESSES & FORK"; iconPath: "/icons/CPUSchedulingLogo.svg"; pageSource: "ProcessForkPage.qml" }
                            ListElement { name: "FILE SYSTEM"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "FileSystemLessonPage.qml" }
                            ListElement { name: "OS ARCHITECTURE"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "OsArchitecturePage.qml" }
                            ListElement { name: "PRIVILEGE MODES"; iconPath: "/icons/CPUSchedulingLogo.svg"; pageSource: "CpuPrivilegeModesPage.qml" }
                            ListElement { name: "TRAPS OVERVIEW"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "TrapsOverviewPage.qml" }
                            ListElement { name: "Memory Translation"; iconPath: "/icons/MemoryManagmentLogo.svg"; pageSource: "MemoryTranslationPage.qml" }
                            ListElement { name: "KERNEL ADDRESS SPACE"; iconPath: "/icons/MemoryManagmentLogo.svg"; pageSource: "KernelSpacePage.qml" }
                            ListElement { name: "LESSON 9: USER SPACE"; iconPath: "/icons/MemoryManagmentLogo.svg"; pageSource: "UserAddressSpacePage.qml" }
                            ListElement { name: "LESSON 10: CONTEXT SWITCH"; iconPath: "/icons/MemoryManagmentLogo.svg"; pageSource: "ContextSwitchPage.qml" }
                            ListElement {
                                name: "CPU QUIZ"
                                iconPath: "/icons/CPUSchedulingLogo.svg"
                                pageSource: "CpuQuizPage.qml"
                            }
                        }

                        delegate: Rectangle {
                                                    width: ListView.view.width
                                                    height: 45
                                                    radius: 10
                                                    property bool isSelected: navList.currentIndex === index
                                                    color: isSelected ? Qt.rgba(75, 42, 192, 0.15) : (mouseArea.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : "transparent")

                                                    Row {
                                                        anchors.left: parent.left; anchors.leftMargin: 15; anchors.verticalCenter: parent.verticalCenter
                                                        spacing: 12
                                                        Image { source: iconPath; width: 20; height: 20 }
                                                        Text { text: name; font.pixelSize: 13; font.family: "Segoe UI"; color: "white" }
                                                    }
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

                                            // Logout Button (مضاف هنا في نهاية الـ Column)
                                            Rectangle {
                                                width: parent.width
                                                height: 40
                                                radius: 10
                                                color: mouseAreaLogout.containsMouse ? Qt.rgba(255, 92, 92, 0.3) : Qt.rgba(255, 255, 255, 0.05)

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "Logout"
                                                    color: "white"
                                                    font.pixelSize: 13
                                                    font.weight: Font.Bold
                                                    font.family: "Segoe UI"
                                                }
                                                MouseArea {
                                                    id: mouseAreaLogout
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        dbManager.logout();
                                                        mainDashboard.visible = false;
                                                        loginScreen.visible = true;
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // ========== MAIN CONTENT ==========
                                    Loader {
                                        id: pageLoader
                                        width: parent.width - sidebar.width - parent.spacing
                                        height: parent.height
                                        source: "CpuSchedulingPage.qml"
                                    }
                                }
                            }

                            // ========== 3. شاشة تسجيل الدخول ==========
                            LoginPage {
                                id: loginScreen
                                z: 100
                                onLoginSuccess: {
                                    loginScreen.visible = false
                                    mainDashboard.visible = true
                                }
                            }
                        }