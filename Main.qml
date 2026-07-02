import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "NavigationLogic.js" as Logic

Window {
    id: root
    width: 1400
    height: 900
    visible: true
    title: qsTr("xv6 OS Explorer")

    // ========== 1. الخلفية المشتركة (شاشة الدخول والبرنامج) ==========
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
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.3) }
            GradientStop { position: 0.5; color: Qt.rgba(0, 0, 0, 0) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.3) }
        }
    }

    // ========== 2. حاوية لوحة التحكم (تظهر فقط بعد تسجيل الدخول) ==========
    Item {
        id: mainDashboard
        anchors.fill: parent
        visible: false // مخفية حتى يتم تسجيل الدخول بنجاح

        // --- Main Layout Row ---
        Row {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // ========== SIDEBAR (CLEAR GLASS) ==========
            Rectangle {
                id: sidebar
                width: 280
                height: parent.height > 0 ? parent.height : 860
                radius: 20
                color: Qt.rgba(255, 255, 255, 0.08)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20

                    // Name of the system AREA
                    Column {
                        Layout.fillWidth: true
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
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8
                        clip: true
                        model: ListModel {
                            ListElement { name: "CPU SCHEDULING"; iconPath: "/icons/CPUSchedulingLogo.svg"; pageSource: "CpuSchedulingPage.qml" }
                            ListElement { name: "MEMORY MANAGEMENT"; iconPath: "/icons/MemoryManagmentLogo.svg"; pageSource: "MemoryManagementPage.qml" }
                            ListElement { name: "FILE SYSTEM"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "FileSystem.qml" }
                            ListElement { name: "SYSTEM CALLS"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "KernelGuardPage.qml" }
                            ListElement { name: "PROCESSES & FORK"; iconPath: "/icons/CPUSchedulingLogo.svg"; pageSource: "ProcessForkPage.qml" }
                            ListElement { name: "OS ARCHITECTURE"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "OsArchitecturePage.qml" }
                            ListElement { name: "PRIVILEGE MODES"; iconPath: "/icons/CPUSchedulingLogo.svg"; pageSource: "CpuPrivilegeModesPage.qml" }
                            ListElement { name: "TRAPS OVERVIEW"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "TrapsOverviewPage.qml" }
                            ListElement { name: "MEMORY TRANSLATION"; iconPath: "/icons/MemoryManagmentLogo.svg"; pageSource: "MemoryTranslationPage.qml" }
                            ListElement { name: "KERNEL ADDRESS SPACE"; iconPath: "/icons/MemoryManagmentLogo.svg"; pageSource: "KernelSpacePage.qml" }
                            ListElement { name: "USER SPACE"; iconPath: "/icons/MemoryManagmentLogo.svg"; pageSource: "UserAddressSpacePage.qml" }
                            ListElement { name: "CONTEXT SWITCH"; iconPath: "/icons/MemoryManagmentLogo.svg"; pageSource: "ContextSwitchPage.qml" }
                            ListElement { name: "LOCKS"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "LocksPage.qml" }
                            ListElement { name: "PIPES & FILE DESC"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "PipesPage.qml" }
                            ListElement { name: "FS OVERVIEW"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "FsOverviewPage.qml" }
                            ListElement { name: "BUFFER CACHE"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "BufferCachePage.qml" }
                            ListElement { name: "LOGGING"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "LoggingPage.qml" }
                            ListElement { name: "INODES & PATHS"; iconPath: "/icons/FileSystemLogo.svg"; pageSource: "InodesPage.qml" }
                        }

                        delegate: Rectangle {
                            id: delegateItem
                            width: ListView.view.width
                            height: 45
                            radius: 10
                            property bool isSelected: navList.currentIndex === index
                            color: isSelected ? Qt.rgba(75, 42, 192, 0.15) : (mouseArea.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : "transparent")

                            layer.enabled: isSelected
                            layer.effect: Glow {
                                radius: 6; samples: 13; color: "#4b2ac0"; spread: 0.2
                            }

                            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutQuad } }

                            Row {
                                anchors.left: parent.left; anchors.leftMargin: 15; anchors.verticalCenter: parent.verticalCenter
                                spacing: 12

                                Image {
                                    id: navIcon
                                    source: iconPath; width: 20; height: 20
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    layer.enabled: true
                                    layer.effect: ColorOverlay {
                                        color: isSelected || mouseArea.containsMouse ? "#ffffff" : Qt.rgba(255, 255, 255, 0.5)
                                    }
                                }

                                Text {
                                    id: navText
                                    text: name; font.pixelSize: 13; font.family: "Segoe UI"; font.weight: Font.Bold
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
                                    pageLoader.source = model.pageSource;
                                }
                            }
                        }
                    }

                    // Logout Button
                    Rectangle {
                        id: logoutButton
                        Layout.fillWidth: true
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

            // ========== 3. RIGHT SIDE (Content Area + Chatbot Panel) ==========
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

                    // ── Wire requestNavigate signal from any lesson page ──
                    Connections {
                        target: pageLoader.item
                        ignoreUnknownSignals: true
                        function onRequestNavigate(pageSource) {
                            pageLoader.source = pageSource;
                            for(var i = 0; i < navList.model.count; i++) {
                                if(navList.model.get(i).pageSource === pageSource) {
                                    navList.currentIndex = i;
                                    break;
                                }
                            }
                        }
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

        // ========== 4. زر الشات بوت العائم (موقعه الحر والمستقل تماماً في أقصى اليسار تحت الـ Sidebar) ==========
        Rectangle {
            id: aiChatButton
            width: 60
            height: 60
            radius: width / 2

            // تم فك الارتباط والتداخل؛ الزر يطفو بحرية الآن أسفل السايدبار بمسافة قريبة جداً من الحافة
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.bottomMargin: 10  // ملاصق تقريباً للحافة السفلية ليعطي مظهراً فخماً وعصرياً
            anchors.leftMargin: 35    // محاذاة عمودية هندسية كاملة مع الـ Sidebar

            color: aiMouseAreaBot.containsMouse ? Qt.rgba(255, 255, 255, 0.1) : Qt.rgba(255, 255, 255, 0.05)
            border.color: aiMouseAreaBot.containsMouse ? "#8b5cf6" : Qt.rgba(255, 255, 255, 0.3)
            border.width: 1

            layer.enabled: true
            layer.effect: Glow {
                radius: 12; samples: 15; color: "#4b2ac0"; spread: 0.2
            }

            scale: aiMouseAreaBot.containsMouse ? 1.08 : 1.0
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

            // سنترة اللوجو المطلقة بدون كتل تفاعلية أو نصوص زائدة
            Image {
                id: aiIcon
                anchors.centerIn: parent
                width: 28; height: 28
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

    // ========== 5. شاشة تسجيل الدخول حارسة النظام ==========
    LoginPage {
        id: loginScreen
        z: 100
        onLoginSuccess: {
            loginScreen.visible = false
            mainDashboard.visible = true
        }
    }
}
