import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ScrollView {
    id: scrollRoot
    signal requestNavigate(string pageSource)
    anchors.fill: parent
    contentWidth: parent.width
    contentHeight: mainCol.implicitHeight + 40
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    property string currentUser: ""
    property var quizScores: []
    property var attendedList: []
    property string pwMsg: ""
    property bool pwSuccess: false

    // Quiz name → display label map
    readonly property var quizMeta: [
        { name: "sys_calls_quiz",   label: "Lesson 1 — System Calls" },
        { name: "proc_fork_quiz",   label: "Lesson 2 — Processes & Fork" },
        { name: "os_arch_quiz",     label: "Lesson 3 — OS Architecture" },
        { name: "priv_modes_quiz",  label: "Lesson 4 — Privilege Modes" },
        { name: "traps_quiz",       label: "Lesson 5 — Traps Overview" },
        { name: "mem_trans_quiz",   label: "Lesson 6 — Memory Translation" },
        { name: "kern_space_quiz",  label: "Lesson 7 — Kernel Space" },
        { name: "user_space_quiz",  label: "Lesson 8 — User Space" },
        { name: "ctx_switch_quiz",  label: "Lesson 9 — Context Switch" },
        { name: "round_robin_quiz", label: "Lesson 10 — Round-Robin" },
        { name: "locks_quiz",       label: "Lesson 11 — Locks" },
        { name: "pipes_quiz",       label: "Lesson 12 — Pipes & File Desc" },
        { name: "fs_overview_quiz", label: "Lesson 13 — FS Overview" },
        { name: "buf_cache_quiz",   label: "Lesson 14 — Buffer Cache" },
        { name: "logging_quiz",     label: "Lesson 15 — Logging" },
        { name: "inodes_quiz",      label: "Lesson 16 — Inodes & Paths" }
    ]

    readonly property var lessonMeta: [
        { src: "KernelGuardPage.qml",        label: "System Calls" },
        { src: "ProcessForkPage.qml",         label: "Processes & Fork" },
        { src: "OsArchitecturePage.qml",      label: "OS Architecture" },
        { src: "CpuPrivilegeModesPage.qml",   label: "Privilege Modes" },
        { src: "TrapsOverviewPage.qml",       label: "Traps Overview" },
        { src: "MemoryTranslationPage.qml",   label: "Memory Translation" },
        { src: "KernelSpacePage.qml",         label: "Kernel Space" },
        { src: "UserAddressSpacePage.qml",    label: "User Space" },
        { src: "ContextSwitchPage.qml",       label: "Context Switch" },
        { src: "RoundRobinPage.qml",          label: "Round-Robin" },
        { src: "LocksPage.qml",               label: "Locks" },
        { src: "PipesPage.qml",               label: "Pipes & File Desc" },
        { src: "FsOverviewPage.qml",          label: "FS Overview" },
        { src: "BufferCachePage.qml",         label: "Buffer Cache" },
        { src: "LoggingPage.qml",             label: "Logging" },
        { src: "InodesPage.qml",              label: "Inodes & Paths" }
    ]

    Component.onCompleted: loadData()

    function loadData() {
        currentUser = dbManager.getCurrentUser()
        attendedList = dbManager.getAttendedLessons(currentUser)
        var scores = []
        for (var i = 0; i < quizMeta.length; i++) {
            var sc = dbManager.getQuizScore(currentUser, quizMeta[i].name)
            scores.push({ label: quizMeta[i].label, score: sc })
        }
        quizScores = scores
    }

    function scoreStars(sc) {
        if (sc < 0) return "—"
        if (sc >= 5) return "★★★★★"
        if (sc >= 4) return "★★★★☆"
        if (sc >= 3) return "★★★☆☆"
        if (sc >= 2) return "★★☆☆☆"
        return "★☆☆☆☆"
    }

    function scoreColor(sc) {
        if (sc < 0) return Qt.rgba(255,255,255,0.25)
        if (sc >= 5) return "#10b981"
        if (sc >= 3) return "#fbbf24"
        return "#f43f5e"
    }

    Column {
        id: mainCol
        width: scrollRoot.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        spacing: 20

        // ── Header ───────────────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 80; radius: 14
            color: Qt.rgba(139,92,246,0.08)
            border.color: Qt.rgba(139,92,246,0.3); border.width: 1

            Row {
                anchors.fill: parent; anchors.margins: 16; spacing: 14
                Rectangle {
                    width: 50; height: 50; radius: 25; anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(139,92,246,0.25); border.color: "#a78bfa"; border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: scrollRoot.currentUser.substring(0,2).toUpperCase()
                        color: "#a78bfa"; font.pixelSize: 18; font.bold: true
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 4
                    Text { text: scrollRoot.currentUser; color: "#ffffff"; font.pixelSize: 18; font.bold: true; font.family: "Segoe UI" }
                    Text { text: "Student Profile"; color: Qt.rgba(255,255,255,0.4); font.pixelSize: 11; font.family: "Segoe UI" }
                }
            }
        }

        // ── Stats row ────────────────────────────────────────────────────
        Row {
            width: parent.width; spacing: 12
            property int attendedCount: scrollRoot.attendedList.length
            property int quizDoneCount: {
                var c = 0
                for (var i = 0; i < scrollRoot.quizScores.length; i++)
                    if (scrollRoot.quizScores[i].score >= 0) c++
                return c
            }
            property int perfectCount: {
                var c = 0
                for (var i = 0; i < scrollRoot.quizScores.length; i++)
                    if (scrollRoot.quizScores[i].score === 5) c++
                return c
            }

            Repeater {
                model: [
                    { label: "Lessons Attended", val: parent.attendedCount + " / 16", col: "#10b981" },
                    { label: "Quizzes Done",      val: parent.quizDoneCount + " / 16", col: "#fbbf24" },
                    { label: "Perfect Scores",    val: parent.perfectCount + "",       col: "#a78bfa" }
                ]
                delegate: Rectangle {
                    width: (parent.width - 24) / 3; height: 64; radius: 12
                    color: Qt.rgba(255,255,255,0.04); border.color: Qt.rgba(255,255,255,0.08); border.width: 1
                    Column {
                        anchors.centerIn: parent; spacing: 4
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.val; color: modelData.col; font.pixelSize: 20; font.bold: true }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.label; color: Qt.rgba(255,255,255,0.4); font.pixelSize: 10 }
                    }
                }
            }
        }

        // ── Two-column: Quiz scores + Attended lessons ────────────────────
        Row {
            width: parent.width; spacing: 16

            // Quiz scores
            Rectangle {
                width: (parent.width - 16) * 0.55; height: scoresCol.implicitHeight + 32; radius: 14
                color: Qt.rgba(255,255,255,0.02); border.color: Qt.rgba(251,191,36,0.2); border.width: 1

                Column {
                    id: scoresCol
                    anchors.top: parent.top; anchors.topMargin: 16
                    anchors.left: parent.left; anchors.leftMargin: 16
                    anchors.right: parent.right; anchors.rightMargin: 16
                    spacing: 6

                    Row { spacing: 8
                        Text { text: "📝"; font.pixelSize: 14 }
                        Text { text: "QUIZ SCORES"; color: "#fbbf24"; font.bold: true; font.pixelSize: 12; font.letterSpacing: 0.5; anchors.verticalCenter: parent.verticalCenter }
                    }
                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.06) }

                    Repeater {
                        model: scrollRoot.quizScores
                        delegate: Rectangle {
                            width: parent.width; height: 26; color: "transparent"
                            Text {
                                id: lblTxt
                                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label; color: Qt.rgba(255,255,255,0.65)
                                font.pixelSize: 11; font.family: "Segoe UI"
                                width: parent.width - 110; elide: Text.ElideRight
                            }
                            Text {
                                anchors.right: scoreTxt.left; anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                text: scrollRoot.scoreStars(modelData.score)
                                color: scrollRoot.scoreColor(modelData.score)
                                font.pixelSize: 10
                            }
                            Text {
                                id: scoreTxt
                                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                text: modelData.score >= 0 ? modelData.score + " / 5" : "—"
                                color: scrollRoot.scoreColor(modelData.score)
                                font.pixelSize: 11; font.bold: true; font.family: "Consolas"
                                width: 36; horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }

            // Attended lessons
            Rectangle {
                width: (parent.width - 16) * 0.45; height: attendCol.implicitHeight + 32; radius: 14
                color: Qt.rgba(255,255,255,0.02); border.color: Qt.rgba(16,185,129,0.2); border.width: 1

                Column {
                    id: attendCol
                    anchors.top: parent.top; anchors.topMargin: 16
                    anchors.left: parent.left; anchors.leftMargin: 16
                    anchors.right: parent.right; anchors.rightMargin: 16
                    spacing: 6

                    Row { spacing: 8
                        Text { text: "✅"; font.pixelSize: 14 }
                        Text { text: "ATTENDED LESSONS"; color: "#10b981"; font.bold: true; font.pixelSize: 12; font.letterSpacing: 0.5; anchors.verticalCenter: parent.verticalCenter }
                    }
                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.06) }

                    Repeater {
                        model: scrollRoot.lessonMeta
                        delegate: Row {
                            width: parent.width; height: 26; spacing: 8
                            property bool done: {
                                var src = scrollRoot.lessonMeta[index].src
                                var list = scrollRoot.attendedList
                                for (var i = 0; i < list.length; i++) if (list[i] === src) return true
                                return false
                            }
                            Text { text: done ? "✓" : "○"; color: done ? "#10b981" : Qt.rgba(255,255,255,0.2); font.pixelSize: 11; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                            Text {
                                text: scrollRoot.lessonMeta[index].label
                                color: done ? Qt.rgba(255,255,255,0.75) : Qt.rgba(255,255,255,0.3)
                                font.pixelSize: 11; font.family: "Segoe UI"; anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }

        // ── Change Password ───────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: pwCol.implicitHeight + 32; radius: 14
            color: Qt.rgba(255,255,255,0.02); border.color: Qt.rgba(255,255,255,0.08); border.width: 1

            Column {
                id: pwCol
                anchors.top: parent.top; anchors.topMargin: 16
                anchors.left: parent.left; anchors.leftMargin: 16
                anchors.right: parent.right; anchors.rightMargin: 16
                spacing: 10

                Row { spacing: 8
                    Text { text: "🔑"; font.pixelSize: 14 }
                    Text { text: "CHANGE PASSWORD"; color: Qt.rgba(255,255,255,0.6); font.bold: true; font.pixelSize: 12; font.letterSpacing: 0.5; anchors.verticalCenter: parent.verticalCenter }
                }
                Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.06) }

                Row {
                    width: parent.width; spacing: 12

                    Column {
                        width: (parent.width - 120) / 2; spacing: 6
                        Text { text: "Current password"; color: Qt.rgba(255,255,255,0.4); font.pixelSize: 10 }
                        Rectangle {
                            width: parent.width; height: 36; radius: 8
                            color: Qt.rgba(255,255,255,0.06); border.color: Qt.rgba(255,255,255,0.12); border.width: 1
                            TextInput {
                                id: oldPwInput; echoMode: TextInput.Password
                                anchors.fill: parent; anchors.margins: 10
                                color: "#ffffff"; font.pixelSize: 12; font.family: "Segoe UI"
                                Text { text: "••••••••"; color: Qt.rgba(255,255,255,0.25); font.pixelSize: 12; visible: !oldPwInput.text; anchors.verticalCenter: parent.verticalCenter }
                            }
                        }
                    }

                    Column {
                        width: (parent.width - 120) / 2; spacing: 6
                        Text { text: "New password"; color: Qt.rgba(255,255,255,0.4); font.pixelSize: 10 }
                        Rectangle {
                            width: parent.width; height: 36; radius: 8
                            color: Qt.rgba(255,255,255,0.06); border.color: Qt.rgba(255,255,255,0.12); border.width: 1
                            TextInput {
                                id: newPwInput; echoMode: TextInput.Password
                                anchors.fill: parent; anchors.margins: 10
                                color: "#ffffff"; font.pixelSize: 12; font.family: "Segoe UI"
                                Text { text: "••••••••"; color: Qt.rgba(255,255,255,0.25); font.pixelSize: 12; visible: !newPwInput.text; anchors.verticalCenter: parent.verticalCenter }
                            }
                        }
                    }

                    Column {
                        width: 96; spacing: 6; anchors.bottom: parent.bottom
                        Item { width: 1; height: 18 }
                        Rectangle {
                            width: 96; height: 36; radius: 8
                            color: saveMouse.containsMouse ? Qt.rgba(139,92,246,0.35) : Qt.rgba(139,92,246,0.2)
                            border.color: "#a78bfa"; border.width: 1
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Text { anchors.centerIn: parent; text: "Save"; color: "#a78bfa"; font.pixelSize: 12; font.bold: true }
                            MouseArea {
                                id: saveMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!oldPwInput.text || !newPwInput.text) {
                                        scrollRoot.pwMsg = "Fill both fields"; scrollRoot.pwSuccess = false; return
                                    }
                                    var ok = dbManager.changePassword(scrollRoot.currentUser, oldPwInput.text, newPwInput.text)
                                    if (ok) {
                                        scrollRoot.pwMsg = "Password changed successfully"
                                        scrollRoot.pwSuccess = true
                                        oldPwInput.text = ""; newPwInput.text = ""
                                    } else {
                                        scrollRoot.pwMsg = "Current password is incorrect"
                                        scrollRoot.pwSuccess = false
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: scrollRoot.pwMsg !== ""
                    text: scrollRoot.pwMsg
                    color: scrollRoot.pwSuccess ? "#10b981" : "#f43f5e"
                    font.pixelSize: 11; font.family: "Segoe UI"
                }
            }
        }

        Item { width: 1; height: 20 }
    }
}
