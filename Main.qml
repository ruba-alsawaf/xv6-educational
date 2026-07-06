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

    // ── Active page tracking ──────────────────────────────────────────────
    property string currentPage: "CpuSchedulingPage.qml"

    // ── Collapsible section state ─────────────────────────────────────────
    property bool xrayExpanded: true
    property bool lessonsExpanded: true

    // ── Attendance cache ──────────────────────────────────────────────────
    property var attendanceCache: ({})

    function refreshAttendance() {
        var user = dbManager.getCurrentUser()
        var lessons = [
            "KernelGuardPage.qml","ProcessForkPage.qml","OsArchitecturePage.qml",
            "CpuPrivilegeModesPage.qml","TrapsOverviewPage.qml","MemoryTranslationPage.qml",
            "KernelSpacePage.qml","UserAddressSpacePage.qml","ContextSwitchPage.qml",
            "RoundRobinPage.qml","LocksPage.qml","PipesPage.qml","FsOverviewPage.qml",
            "BufferCachePage.qml","LoggingPage.qml","InodesPage.qml"
        ]
        var cache = {}
        for (var i = 0; i < lessons.length; i++)
            cache[lessons[i]] = dbManager.isAttended(user, lessons[i])
        attendanceCache = cache
    }

    function doNavigate(src) {
        currentPage = src
        pageLoader.source = src
        refreshAttendance()
    }

    // ── Backgrounds ───────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        Image { id: backgroundImage; source: "test.png"; anchors.fill: parent; fillMode: Image.PreserveAspectCrop; smooth: true; visible: false }
        FastBlur { anchors.fill: parent; source: backgroundImage; radius: 32; transparentBorder: false }
    }
    Rectangle { anchors.fill: parent; color: Qt.rgba(0,0,0,0.5) }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.rgba(0,0,0,0.3) }
            GradientStop { position: 0.5; color: Qt.rgba(0,0,0,0) }
            GradientStop { position: 1.0; color: Qt.rgba(0,0,0,0.3) }
        }
    }

    // ── Main Dashboard ────────────────────────────────────────────────────
    Item {
        id: mainDashboard
        anchors.fill: parent
        visible: false

        Row {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // ══════════════════════════════════════════════════════════════
            // SIDEBAR
            // ══════════════════════════════════════════════════════════════
            Rectangle {
                id: sidebar
                width: 255
                height: parent.height
                radius: 20
                color: Qt.rgba(255,255,255,0.07)
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 0

                    // ── Logo ──────────────────────────────────────────────
                    Item {
                        Layout.fillWidth: true
                        height: 58
                        Column {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3
                            Text { text: "xv6"; font { family:"Segoe UI"; pixelSize:26; weight:Font.Black; letterSpacing:2 } color:"#ffffff" }
                            Text { text: "OS EXPLORER"; font { family:"Segoe UI"; pixelSize:9 } color:Qt.rgba(255,255,255,0.45) }
                            Rectangle { width:34; height:2; radius:1; color:Qt.rgba(255,255,255,0.45) }
                        }
                    }

                    // ── Scrollable nav (no visible scrollbar) ─────────────
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        clip: true

                        Column {
                            id: navColumn
                            width: sidebar.width - 28
                            spacing: 2

                            // ── XRAY MONITOR header ───────────────────────
                            SectionHeader {
                                width: parent.width
                                sectionTitle: "XRAY MONITOR"
                                accentColor: "#06b6d4"
                                expanded: root.xrayExpanded
                                onToggle: root.xrayExpanded = !root.xrayExpanded
                            }

                            // XRAY items (animated collapse)
                            Item {
                                width: parent.width
                                height: root.xrayExpanded ? xrayCol.implicitHeight : 0
                                clip: true
                                Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                                Column {
                                    id: xrayCol
                                    width: parent.width
                                    spacing: 2
                                    SidebarItem { width: parent.width; itemLabel: "CPU Scheduling"; iconSrc: "/icons/CPUSchedulingLogo.svg"; accentColor: "#06b6d4"; isSelected: root.currentPage === "CpuSchedulingPage.qml"; onNav: doNavigate("CpuSchedulingPage.qml") }
                                    SidebarItem { width: parent.width; itemLabel: "Memory Management"; iconSrc: "/icons/MemoryManagmentLogo.svg"; accentColor: "#06b6d4"; isSelected: root.currentPage === "MemoryManagementPage.qml"; onNav: doNavigate("MemoryManagementPage.qml") }
                                    SidebarItem { width: parent.width; itemLabel: "File System"; iconSrc: "/icons/FileSystemLogo.svg"; accentColor: "#06b6d4"; isSelected: root.currentPage === "FileSystem.qml"; onNav: doNavigate("FileSystem.qml") }
                                }
                            }

                            // ── LESSONS header ────────────────────────────
                            SectionHeader {
                                width: parent.width
                                topPadding: 10
                                sectionTitle: "LESSONS"
                                accentColor: "#a78bfa"
                                expanded: root.lessonsExpanded
                                onToggle: root.lessonsExpanded = !root.lessonsExpanded
                            }

                            // Lessons (animated collapse)
                            Item {
                                width: parent.width
                                height: root.lessonsExpanded ? lessonsCol.implicitHeight : 0
                                clip: true
                                Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                                Column {
                                    id: lessonsCol
                                    width: parent.width
                                    spacing: 2

                                    LessonGroup { width: parent.width; num: 1;  lessonName: "System Calls";       lessonSrc: "KernelGuardPage.qml";       quizSrc: "KernelGuardQuizPage.qml";       attended: root.attendanceCache["KernelGuardPage.qml"]===true;       currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                    LessonGroup { width: parent.width; num: 2;  lessonName: "Processes & Fork";   lessonSrc: "ProcessForkPage.qml";        quizSrc: "ProcessForkQuizPage.qml";       attended: root.attendanceCache["ProcessForkPage.qml"]===true;        currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                    LessonGroup { width: parent.width; num: 3;  lessonName: "OS Architecture";    lessonSrc: "OsArchitecturePage.qml";     quizSrc: "OsArchitectureQuizPage.qml";    attended: root.attendanceCache["OsArchitecturePage.qml"]===true;     currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                    LessonGroup { width: parent.width; num: 4;  lessonName: "Privilege Modes";    lessonSrc: "CpuPrivilegeModesPage.qml";  quizSrc: "CpuPrivilegeQuizPage.qml";      attended: root.attendanceCache["CpuPrivilegeModesPage.qml"]===true;  currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                    LessonGroup { width: parent.width; num: 5;  lessonName: "Traps Overview";     lessonSrc: "TrapsOverviewPage.qml";      quizSrc: "TrapsOverviewQuizPage.qml";     attended: root.attendanceCache["TrapsOverviewPage.qml"]===true;      currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                    LessonGroup { width: parent.width; num: 6;  lessonName: "Memory Translation"; lessonSrc: "MemoryTranslationPage.qml";  quizSrc: "MemoryTranslationQuizPage.qml"; attended: root.attendanceCache["MemoryTranslationPage.qml"]===true;  currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                    LessonGroup { width: parent.width; num: 7;  lessonName: "Kernel Space";       lessonSrc: "KernelSpacePage.qml";        quizSrc: "KernelSpaceQuizPage.qml";       attended: root.attendanceCache["KernelSpacePage.qml"]===true;        currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                    LessonGroup { width: parent.width; num: 8;  lessonName: "User Space";         lessonSrc: "UserAddressSpacePage.qml";   quizSrc: "UserSpaceQuizPage.qml";         attended: root.attendanceCache["UserAddressSpacePage.qml"]===true;   currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                    LessonGroup { width: parent.width; num: 9;  lessonName: "Context Switch";     lessonSrc: "ContextSwitchPage.qml";      quizSrc: "ContextSwitchQuizPage.qml";     attended: root.attendanceCache["ContextSwitchPage.qml"]===true;      currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                    LessonGroup { width: parent.width; num: 10; lessonName: "Round-Robin";        lessonSrc: "RoundRobinPage.qml";         quizSrc: "RoundRobinQuizPage.qml";        attended: root.attendanceCache["RoundRobinPage.qml"]===true;         currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                    LessonGroup { width: parent.width; num: 11; lessonName: "Locks";              lessonSrc: "LocksPage.qml";              quizSrc: "LocksQuizPage.qml";             attended: root.attendanceCache["LocksPage.qml"]===true;              currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                    LessonGroup { width: parent.width; num: 12; lessonName: "Pipes & File Desc";  lessonSrc: "PipesPage.qml";              quizSrc: "PipesQuizPage.qml";             attended: root.attendanceCache["PipesPage.qml"]===true;              currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                    LessonGroup { width: parent.width; num: 13; lessonName: "FS Overview";        lessonSrc: "FsOverviewPage.qml";         quizSrc: "FsOverviewQuizPage.qml";        attended: root.attendanceCache["FsOverviewPage.qml"]===true;         currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                    LessonGroup { width: parent.width; num: 14; lessonName: "Buffer Cache";       lessonSrc: "BufferCachePage.qml";        quizSrc: "BufferCacheQuizPage.qml";       attended: root.attendanceCache["BufferCachePage.qml"]===true;        currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                    LessonGroup { width: parent.width; num: 15; lessonName: "Logging";            lessonSrc: "LoggingPage.qml";            quizSrc: "LoggingQuizPage.qml";           attended: root.attendanceCache["LoggingPage.qml"]===true;            currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                    LessonGroup { width: parent.width; num: 16; lessonName: "Inodes & Paths";     lessonSrc: "InodesPage.qml";             quizSrc: "InodesQuizPage.qml";            attended: root.attendanceCache["InodesPage.qml"]===true;             currentPage: root.currentPage; onNav: function(s){ doNavigate(s) } }
                                }
                            }

                            Item { width: 1; height: 8 }
                        }
                    }

                    // ── Profile button ────────────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 6
                        height: 46; radius: 12
                        color: profileMouse.containsMouse ? Qt.rgba(139,92,246,0.22) : (root.currentPage === "ProfilePage.qml" ? Qt.rgba(139,92,246,0.18) : Qt.rgba(255,255,255,0.05))
                        border.color: root.currentPage === "ProfilePage.qml" ? "#a78bfa" : Qt.rgba(255,255,255,0.1)
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Row {
                            anchors.fill: parent; anchors.margins: 10; spacing: 10
                            Rectangle {
                                width: 28; height: 28; radius: 14; anchors.verticalCenter: parent.verticalCenter
                                color: Qt.rgba(139,92,246,0.3); border.color: "#a78bfa"; border.width: 1
                                Text { anchors.centerIn: parent; text: dbManager.getCurrentUser().substring(0,2).toUpperCase(); color: "#a78bfa"; font.pixelSize: 10; font.bold: true }
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                Text { text: dbManager.getCurrentUser(); color: "#ffffff"; font.pixelSize: 11; font.bold: true; font.family: "Segoe UI" }
                                Text { text: "Profile & Grades"; color: Qt.rgba(255,255,255,0.38); font.pixelSize: 9; font.family: "Segoe UI" }
                            }
                        }
                        MouseArea { id: profileMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: doNavigate("ProfilePage.qml") }
                    }

                    // ── Logout ────────────────────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 5
                        height: 34; radius: 10
                        color: logoutMouse.containsMouse ? Qt.rgba(255,92,92,0.22) : Qt.rgba(255,255,255,0.04)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Text { anchors.centerIn: parent; text: "Logout"; color: "white"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI" }
                        MouseArea { id: logoutMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: { dbManager.logout(); mainDashboard.visible = false; loginScreen.visible = true }
                        }
                    }
                }
            }

            // ── Content area ──────────────────────────────────────────────
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
                    Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
                    Connections {
                        target: pageLoader.item
                        ignoreUnknownSignals: true
                        function onRequestNavigate(pageSource) { doNavigate(pageSource) }
                        function onAttendanceChanged() { refreshAttendance() }
                    }
                }

                ChatbotPanel {
                    id: aiPanel; width: parent.width
                    property bool isOpen: false
                    height: isOpen ? 280 : 0; visible: height > 0; opacity: isOpen ? 1.0 : 0.0
                    Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 250 } }
                }
            }
        }

        // ── Chatbot button ────────────────────────────────────────────────
        Rectangle {
            width: 60; height: 60; radius: 30
            anchors.bottom: parent.bottom; anchors.left: parent.left
            anchors.bottomMargin: 10; anchors.leftMargin: 35
            color: aiBot.containsMouse ? Qt.rgba(255,255,255,0.1) : Qt.rgba(255,255,255,0.05)
            border.color: aiBot.containsMouse ? "#8b5cf6" : Qt.rgba(255,255,255,0.3); border.width: 1
            layer.enabled: true; layer.effect: Glow { radius: 12; samples: 15; color: "#4b2ac0"; spread: 0.2 }
            scale: aiBot.containsMouse ? 1.08 : 1.0
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
            Image { anchors.centerIn: parent; width: 28; height: 28; source: "/icons/chat-bot.svg"; fillMode: Image.PreserveAspectFit; smooth: true; layer.enabled: true; layer.effect: ColorOverlay { color: "#ffffff" } }
            MouseArea { id: aiBot; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: aiPanel.isOpen = !aiPanel.isOpen }
        }
    }

    // ── Login screen ──────────────────────────────────────────────────────
    LoginPage {
        id: loginScreen; z: 100
        onLoginSuccess: { loginScreen.visible = false; mainDashboard.visible = true; refreshAttendance() }
    }

    // ══════════════════════════════════════════════════════════════════════
    // INLINE COMPONENTS
    // ══════════════════════════════════════════════════════════════════════

    // ── Section header (collapsible) ──────────────────────────────────────
    component SectionHeader: Item {
        property string sectionTitle: ""
        property string accentColor: "#a78bfa"
        property bool expanded: true
        signal toggle()

        height: 30 + topPadding
        property int topPadding: 4

        Rectangle {
            anchors.bottom: parent.bottom; width: parent.width; height: 28; radius: 8
            color: shMouse.containsMouse ? Qt.rgba(255,255,255,0.06) : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }

            Row {
                anchors.left: parent.left; anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter; spacing: 6
                Text {
                    text: parent.parent.parent.expanded ? "▾" : "▸"
                    color: Qt.rgba(255,255,255,0.35); font.pixelSize: 8
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: parent.parent.parent.sectionTitle
                    color: parent.parent.parent.accentColor
                    font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.2; font.family: "Segoe UI"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            MouseArea { id: shMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.parent.toggle() }
        }
    }

    // ── Single nav item ───────────────────────────────────────────────────
    component SidebarItem: Rectangle {
        id: si
        property string itemLabel: ""
        property string iconSrc: ""
        property bool isSelected: false
        property string accentColor: "#a78bfa"
        signal nav()

        height: 38; radius: 10
        color: isSelected ? Qt.rgba(255,255,255,0.14) : (siM.containsMouse ? Qt.rgba(255,255,255,0.07) : "transparent")
        border.color: isSelected ? accentColor : "transparent"; border.width: 1
        Behavior on color { ColorAnimation { duration: 130 } }

        Row {
            anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 9
            Image { source: si.iconSrc; width: 16; height: 16; fillMode: Image.PreserveAspectFit; smooth: true; layer.enabled: true; layer.effect: ColorOverlay { color: si.isSelected ? si.accentColor : Qt.rgba(255,255,255,0.45) } }
            Text { text: si.itemLabel; font.pixelSize: 11; font.bold: true; font.family: "Segoe UI"; color: si.isSelected ? "#ffffff" : Qt.rgba(255,255,255,0.55) }
        }
        MouseArea { id: siM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: si.nav() }
    }

    // ── Lesson group (collapsible, with lesson name inside) ───────────────
    component LessonGroup: Item {
        id: lg
        property int num: 1
        property string lessonName: ""
        property string lessonSrc: ""
        property string quizSrc: ""
        property bool attended: false
        property string currentPage: ""
        signal nav(string src)

        property bool isActive: currentPage.endsWith(lessonSrc) || currentPage.endsWith(quizSrc)
        property bool expanded: false

        onIsActiveChanged: if (isActive && !expanded) expanded = true

        height: lgHeader.height + (expanded ? lgSubs.implicitHeight + 2 : 0)
        clip: true
        Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        // Header — shows "Lesson N"
        Rectangle {
            id: lgHeader
            width: parent.width; height: 36; radius: 10
            color: lg.isActive ? Qt.rgba(139,92,246,0.15) : (lgHM.containsMouse ? Qt.rgba(255,255,255,0.07) : "transparent")
            border.color: lg.isActive ? Qt.rgba(139,92,246,0.5) : "transparent"; border.width: 1
            Behavior on color { ColorAnimation { duration: 130 } }

            Row {
                anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; spacing: 7
                Rectangle {
                    width: 22; height: 16; radius: 4; anchors.verticalCenter: parent.verticalCenter
                    color: lg.isActive ? Qt.rgba(139,92,246,0.3) : Qt.rgba(255,255,255,0.08)
                    Text { anchors.centerIn: parent; text: lg.num; color: lg.isActive ? "#a78bfa" : Qt.rgba(255,255,255,0.4); font.pixelSize: 8; font.bold: true; font.family: "Consolas" }
                }
                Text { text: "Lesson " + lg.num; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"; color: lg.isActive ? "#ffffff" : Qt.rgba(255,255,255,0.6); anchors.verticalCenter: parent.verticalCenter }
            }

            Row {
                anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter; spacing: 5
                Rectangle {
                    width: 14; height: 14; radius: 3
                    color: lg.attended ? Qt.rgba(16,185,129,0.2) : "transparent"
                    border.color: lg.attended ? "#10b981" : Qt.rgba(255,255,255,0.18); border.width: 1
                    Text { anchors.centerIn: parent; text: "✓"; visible: lg.attended; color: "#10b981"; font.pixelSize: 8; font.bold: true }
                }
                Text { text: lg.expanded ? "▾" : "▸"; color: Qt.rgba(255,255,255,0.3); font.pixelSize: 8; anchors.verticalCenter: parent.verticalCenter }
            }

            MouseArea { id: lgHM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: {
                    lg.expanded = !lg.expanded
                    if (!lg.expanded && !lg.isActive) return
                    if (lg.expanded) lg.nav(lg.lessonSrc)
                }
            }
        }

        // Sub-items
        Column {
            id: lgSubs
            anchors.top: lgHeader.bottom; anchors.topMargin: 2
            anchors.left: parent.left; anchors.leftMargin: 16
            width: parent.width - 16
            spacing: 2

            // Lesson sub-item — shows actual lesson name
            Rectangle {
                width: parent.width; height: 30; radius: 8
                color: root.currentPage === lg.lessonSrc ? Qt.rgba(139,92,246,0.2) : (lesM.containsMouse ? Qt.rgba(255,255,255,0.07) : "transparent")
                Behavior on color { ColorAnimation { duration: 110 } }
                Row { anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter; spacing: 7
                    Text { text: "📖"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: lg.lessonName; font.pixelSize: 11; font.family: "Segoe UI"; color: root.currentPage === lg.lessonSrc ? "#ffffff" : Qt.rgba(255,255,255,0.55); anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea { id: lesM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: lg.nav(lg.lessonSrc) }
            }

            // Quiz sub-item — locked until attended
            Rectangle {
                width: parent.width; height: 30; radius: 8
                color: root.currentPage === lg.quizSrc ? Qt.rgba(251,191,36,0.15) : (qzM.containsMouse && lg.attended ? Qt.rgba(255,255,255,0.07) : "transparent")
                Behavior on color { ColorAnimation { duration: 110 } }
                Row { anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter; spacing: 7
                    Text { text: lg.attended ? "📝" : "🔒"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: "Quiz"
                        font.pixelSize: 11; font.family: "Segoe UI"
                        color: root.currentPage === lg.quizSrc ? "#fbbf24" : (lg.attended ? Qt.rgba(255,255,255,0.55) : Qt.rgba(255,255,255,0.22))
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea { id: qzM; anchors.fill: parent; hoverEnabled: true
                    cursorShape: lg.attended ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: if (lg.attended) lg.nav(lg.quizSrc)
                }
            }
        }
    }
}
