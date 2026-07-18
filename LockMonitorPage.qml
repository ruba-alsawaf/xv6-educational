import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

ScrollView {
    id: root
    anchors.fill: parent
    contentWidth: parent.width
    contentHeight: mainCol.implicitHeight + 40
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    // ── Live data ─────────────────────────────────────────────────────────
    property var lockData: backend.lockMetricsModel

    // Force-tracked lookup — explicitly reference lockData so QML re-evaluates
    function getLock(name) {
        var list = root.lockData          // tracked dependency
        for (var i = 0; i < list.length; i++)
            if (list[i].name === name) return list[i]
        return null
    }

    function lockStatus(d) {
        if (!d) return "idle"
        if (d.contention > 0) return "contended"
        if (d.acq_count  > 0) return "active"
        return "idle"
    }
    function statusColor(s) {
        if (s === "contended") return "#f43f5e"
        if (s === "active")    return "#fbbf24"
        return "#10b981"
    }
    function statusLabel(s) {
        if (s === "contended") return "CONTENDED"
        if (s === "active")    return "ACTIVE"
        return "IDLE"
    }

    // ── Selected lock (reactive — updates when lockData changes) ──────────
    property string selectedLock: ""
    property var selectedData: {
        var _dep = root.lockData   // explicit tracking
        return root.selectedLock !== "" ? root.getLock(root.selectedLock) : null
    }

    // ── Stats (reactive) ──────────────────────────────────────────────────
    property int totalLocks:     root.lockData.length
    property int contendedCount: {
        var list = root.lockData; var c = 0
        for (var i = 0; i < list.length; i++) if (list[i].contention > 0) c++
        return c
    }
    property int activeCount: {
        var list = root.lockData; var c = 0
        for (var i = 0; i < list.length; i++) if (list[i].acq_count > 0) c++
        return c
    }
    property string hotLockName: {
        var list = root.lockData; var best = null
        for (var i = 0; i < list.length; i++)
            if (!best || list[i].acq_count > best.acq_count) best = list[i]
        return best ? best.name : "—"
    }

    // ── Categories ────────────────────────────────────────────────────────
    readonly property var categories: [
        {
            title: "Process Management", icon: "⚙", accent: "#06b6d4",
            bg: Qt.rgba(6/255,182/255,212/255,0.07),
            border: Qt.rgba(6/255,182/255,212/255,0.25),
            locks: [
                { name: "proc" }, { name: "wait_lock" }, { name: "nextpid" }
            ]
        },
        {
            title: "Memory Management", icon: "🧠", accent: "#a78bfa",
            bg: Qt.rgba(167/255,139/255,250/255,0.07),
            border: Qt.rgba(167/255,139/255,250/255,0.25),
            locks: [ { name: "kmem" } ]
        },
        {
            title: "File System & Storage", icon: "💾", accent: "#fbbf24",
            bg: Qt.rgba(251/255,191/255,36/255,0.06),
            border: Qt.rgba(251/255,191/255,36/255,0.22),
            locks: [
                { name: "bcache" }, { name: "log" }, { name: "ftable" },
                { name: "virtio_disk" }, { name: "sleep lock" }
            ]
        },
        {
            title: "I/O & Timing", icon: "⏱", accent: "#10b981",
            bg: Qt.rgba(16/255,185/255,129/255,0.06),
            border: Qt.rgba(16/255,185/255,129/255,0.22),
            locks: [
                { name: "cons" }, { name: "pr" }, { name: "uart" }, { name: "ticks" }
            ]
        }
    ]

    // ─────────────────────────────────────────────────────────────────────
    Column {
        id: mainCol
        width: root.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top; anchors.topMargin: 20
        spacing: 20

        // ── PAGE TITLE (simple — like other monitor pages) ────────────────
        Text {
            text: "Lock Monitor"
            color: "#ffffff"
            font.family: "Segoe UI"; font.pixelSize: 22; font.bold: true
        }

        // ── STATS ROW ─────────────────────────────────────────────────────
        Row {
            width: parent.width; spacing: 12
            Repeater {
                model: [
                    { label: "Total Locks",  val: root.totalLocks,     col: "#06b6d4" },
                    { label: "Contended",    val: root.contendedCount,  col: "#f43f5e" },
                    { label: "Active",       val: root.activeCount,     col: "#fbbf24" },
                    { label: "Hottest Lock", val: root.hotLockName,     col: "#a78bfa" }
                ]
                Rectangle {
                    width: (parent.width - 36) / 4; height: 60; radius: 10
                    color: Qt.rgba(255,255,255,0.03)
                    border.color: Qt.rgba(255,255,255,0.07); border.width: 1
                    Column { anchors.centerIn: parent; spacing: 3
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: ""+modelData.val; color: modelData.col; font.pixelSize: 18; font.bold: true; font.family: "Consolas" }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.label; color: Qt.rgba(255,255,255,0.35); font.pixelSize: 10 }
                    }
                }
            }
        }

        // ── DETAIL PANEL ──────────────────────────────────────────────────
        Rectangle {
            id: detailPanel
            width: parent.width
            height: root.selectedLock !== "" ? detailInner.implicitHeight + 28 : 0
            radius: 14; clip: true
            color: Qt.rgba(255,255,255,0.03)
            border.color: root.selectedLock !== ""
                ? root.statusColor(root.lockStatus(root.selectedData))
                : "transparent"
            border.width: 1
            Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            Column {
                id: detailInner
                anchors.top: parent.top; anchors.topMargin: 14
                anchors.left: parent.left; anchors.leftMargin: 20
                anchors.right: parent.right; anchors.rightMargin: 20
                spacing: 10

                Item {
                    width: parent.width; height: 24
                    Row {
                        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                        spacing: 10
                        Rectangle {
                            width: 8; height: 8; radius: 4; anchors.verticalCenter: parent.verticalCenter
                            color: root.statusColor(root.lockStatus(root.selectedData))
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { from:1; to:0.2; duration:600 }
                                NumberAnimation { from:0.2; to:1; duration:600 }
                            }
                        }
                        Text {
                            text: root.selectedLock.toUpperCase()
                            color: "#ffffff"; font.bold: true; font.pixelSize: 15; font.family: "Segoe UI"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Rectangle {
                            height: 18; width: stLbl.implicitWidth + 14; radius: 4
                            color: Qt.rgba(255,255,255,0.05)
                            border.color: root.statusColor(root.lockStatus(root.selectedData)); border.width: 1
                            anchors.verticalCenter: parent.verticalCenter
                            Text { id: stLbl; anchors.centerIn: parent; text: root.statusLabel(root.lockStatus(root.selectedData)); color: root.statusColor(root.lockStatus(root.selectedData)); font.pixelSize: 9; font.bold: true; font.letterSpacing: 1 }
                        }
                    }
                    MouseArea {
                        width: 22; height: 22; cursorShape: Qt.PointingHandCursor
                        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        onClicked: root.selectedLock = ""
                        Text { anchors.centerIn: parent; text: "✕"; color: Qt.rgba(255,255,255,0.3); font.pixelSize: 12 }
                    }
                }

                Grid {
                    width: parent.width; columns: 3; spacing: 10
                    Repeater {
                        model: root.selectedData ? [
                            { label: "Last PID",       val: root.selectedData.last_pid,       col: "#06b6d4" },
                            { label: "Process Name",   val: root.selectedData.proc_name || "—",  col: "#a78bfa" },
                            { label: "CPU ID",         val: root.selectedData.cpu_id,         col: "#fbbf24" },
                            { label: "Hold Time (ns)", val: root.selectedData.last_hold_time, col: "#10b981" },
                            { label: "Acq Count",      val: root.selectedData.acq_count,      col: "#06b6d4" },
                            { label: "Contention",     val: root.selectedData.contention,     col: "#f43f5e" }
                        ] : []
                        Rectangle {
                            width: (detailInner.width - 20) / 3; height: 50; radius: 8
                            color: Qt.rgba(255,255,255,0.03); border.color: Qt.rgba(255,255,255,0.06); border.width: 1
                            Column { anchors.centerIn: parent; spacing: 3
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: ""+modelData.val; color: modelData.col; font.pixelSize: 14; font.bold: true; font.family: "Consolas" }
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.label; color: Qt.rgba(255,255,255,0.3); font.pixelSize: 9 }
                            }
                        }
                    }
                }
            }
        }

        // ── CATEGORY CARDS ────────────────────────────────────────────────
        Grid {
            width: parent.width
            columns: 2; columnSpacing: 16; rowSpacing: 16

            Repeater {
                model: root.categories

                Rectangle {
                    // capture outer modelData before inner Repeater shadows it
                    property var catData: modelData

                    width: (parent.width - 16) / 2
                    height: catCol.implicitHeight + 32
                    radius: 14
                    color: catData.bg
                    border.color: catData.border; border.width: 1

                    Column {
                        id: catCol
                        anchors.top: parent.top; anchors.topMargin: 16
                        anchors.left: parent.left; anchors.leftMargin: 16
                        anchors.right: parent.right; anchors.rightMargin: 16
                        spacing: 12

                        Row { spacing: 8
                            Text { text: catData.icon; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: catData.title.toUpperCase(); color: catData.accent; font.bold: true; font.pixelSize: 12; font.letterSpacing: 0.8; anchors.verticalCenter: parent.verticalCenter }
                        }
                        Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.06) }

                        Flow {
                            width: parent.width; spacing: 8

                            Repeater {
                                model: catData.locks

                                Rectangle {
                                    id: chip
                                    // Explicit lockData reference → re-evaluates on every backend refresh
                                    property var liveData: {
                                        var _dep = root.lockData
                                        return root.getLock(modelData.name)
                                    }
                                    property string st: root.lockStatus(liveData)
                                    property bool isSelected: root.selectedLock === modelData.name
                                    property bool hov: false

                                    width:  chipInner.implicitWidth + 24
                                    height: 68; radius: 10

                                    color: isSelected
                                        ? Qt.rgba(parseInt(root.statusColor(st).slice(1,3),16)/255,
                                                  parseInt(root.statusColor(st).slice(3,5),16)/255,
                                                  parseInt(root.statusColor(st).slice(5,7),16)/255, 0.22)
                                        : (hov ? Qt.rgba(255,255,255,0.07) : Qt.rgba(255,255,255,0.04))
                                    border.color: isSelected
                                        ? root.statusColor(st)
                                        : (st === "contended" ? Qt.rgba(244/255,63/255,94/255,0.5)
                                           : st === "active"  ? Qt.rgba(251/255,191/255,36/255,0.35)
                                           :                    Qt.rgba(16/255,185/255,129/255,0.25))
                                    border.width: isSelected ? 1.5 : 1
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    layer.enabled: st === "contended"
                                    layer.effect: Glow { radius: 8; samples: 17; color: Qt.rgba(244/255,63/255,94/255,0.3) }

                                    Column {
                                        id: chipInner
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left; anchors.leftMargin: 12
                                        spacing: 5

                                        Row { spacing: 6
                                            Rectangle {
                                                width: 7; height: 7; radius: 3.5
                                                color: root.statusColor(chip.st)
                                                anchors.verticalCenter: parent.verticalCenter
                                                SequentialAnimation on opacity {
                                                    running: chip.st === "contended"
                                                    loops: Animation.Infinite
                                                    NumberAnimation { from:1; to:0.2; duration:500 }
                                                    NumberAnimation { from:0.2; to:1; duration:500 }
                                                }
                                            }
                                            Text { text: modelData.name; color: "#ffffff"; font.family: "Consolas"; font.pixelSize: 12; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                                        }
                                        Text { text: root.statusLabel(chip.st); color: root.statusColor(chip.st); font.pixelSize: 9; font.letterSpacing: 1 }
                                        Text {
                                            text: chip.liveData ? "acq: " + chip.liveData.acq_count : "no data"
                                            color: Qt.rgba(255,255,255,0.3); font.pixelSize: 9; font.family: "Consolas"
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                        onEntered: chip.hov = true
                                        onExited:  chip.hov = false
                                        onClicked: {
                                            root.selectedLock = (root.selectedLock === modelData.name) ? "" : modelData.name
                                        }
                                    }
                                }
                            }
                        }

                        // Category health line
                        Text {
                            property int catContended: {
                                var list = root.lockData   // tracked
                                var c = 0
                                for (var i = 0; i < catData.locks.length; i++) {
                                    var d = root.getLock(catData.locks[i].name)
                                    if (d && d.contention > 0) c++
                                }
                                return c
                            }
                            text: catContended > 0
                                ? "⚠  " + catContended + " lock(s) under contention"
                                : "✓  All locks healthy"
                            color: catContended > 0 ? "#f43f5e" : Qt.rgba(16/255,185/255,129/255,0.7)
                            font.pixelSize: 10; font.family: "Segoe UI"
                        }
                    }
                }
            }
        }

        Item { width: 1; height: 20 }
    }
}
