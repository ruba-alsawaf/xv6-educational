import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle {
    id: cpuSchedulingPage
    color: "transparent"
    anchors.fill: parent

    property variant cpuModelData: []
    property variant timelineModelData: []
    property int currentCpuUsage: 0
    property variant processStatesData: ({"running": 0, "sleeping": 0, "zombie": 0, "total": 0})

    property variant hoveredBlockData: null

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuSchedulingPage.cpuModelData = dbManager.getLatestCpuMetrics()
            cpuSchedulingPage.timelineModelData = dbManager.getTimelineMetrics()
            cpuSchedulingPage.currentCpuUsage = dbManager.getAverageCpuUsage()
            cpuSchedulingPage.processStatesData = dbManager.getProcessStatesCount()
        }
    }

    Column {
        id: mainColumn
        anchors.fill: parent
        spacing: 25

        Row {
            width: parent.width
            height: (parent.height - parent.spacing) / 3
            spacing: 25

            Rectangle {
                id: cpusRect
                width: (parent.width - parent.spacing) / 2
                height: parent.height
                color: Qt.rgba(255, 255, 255, 0.08)
                radius: 20
                border.color: Qt.rgba(6/255,182/255,212/255,0.22); border.width: 1

                // ── cyan accent top strip ──
                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    height: 3; radius: 20
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0;  color: "transparent" }
                        GradientStop { position: 0.3;  color: "#06b6d4" }
                        GradientStop { position: 0.7;  color: "#06b6d4" }
                        GradientStop { position: 1.0;  color: "transparent" }
                    }
                }

                Rectangle {
                    id: systemDashboardTitle
                    width: parent.width; height: 52; radius: 20; color: "transparent"
                    Row {
                        anchors.fill: parent; anchors.margins: 20; spacing: 12
                        Text {
                            text: "PROCESSOR OVERVIEW"
                            font { family: "Segoe UI"; pixelSize: 13; weight: Font.Bold; letterSpacing: 1 }
                            color: "#06b6d4"
                        }
                    }
                }

                Row {
                    anchors { top: systemDashboardTitle.bottom; bottom: parent.bottom; left: parent.left; right: parent.right; margins: 20 }
                    spacing: 15
                    Repeater {
                        model: cpuSchedulingPage.cpuModelData
                        delegate: Rectangle {
                            id: cpuCard
                            width: (parent.width - 2 * 15) / 3; height: parent.height; radius: 12; color: Qt.rgba(0, 0, 0, 0.3)
                            Column {
                                anchors.centerIn: parent; spacing: 8
                                Text { text: modelData.name; font { family: "Segoe UI"; pixelSize: 14; weight: Font.Bold } color: "#ffffff" }
                                Row {
                                    spacing: 6
                                    Rectangle {
                                        id: stateDot
                                        width: 8; height: 8; radius: 4;
                                        color: modelData.state === "UNUSED" ? "#97969d" : "#10b981"
                                        anchors.verticalCenter: parent.verticalCenter
                                        layer.enabled: true
                                        layer.effect: Glow { radius: 4; samples: 9; color: stateDot.color; spread: 0.3 }
                                    }
                                    Text {
                                        text: modelData.state === "UNUSED" ? "IDLE" : "ACTIVE"
                                        font { family: "Segoe UI"; pixelSize: 12; weight: Font.Bold }
                                        color: modelData.state === "UNUSED" ? "#97969d" : "#34d399"
                                    }
                                }
                                Text { text: modelData.pid; font { family: "Segoe UI"; pixelSize: 10 } color: Qt.rgba(255, 255, 255, 0.4) }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: usageBoard
                width: (parent.width - parent.spacing) / 2; height: parent.height; color: Qt.rgba(255, 255, 255, 0.08); radius: 20
                border.color: Qt.rgba(6/255,182/255,212/255,0.22); border.width: 1
                // ── cyan accent top strip ──
                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    height: 3; radius: 20
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.3; color: "#06b6d4" }
                        GradientStop { position: 0.7; color: "#06b6d4" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                Row {
                    anchors { fill: parent; margins: 20 } spacing: 15

                    Rectangle {
                        id: rectWaterCard
                        width: (parent.width - parent.spacing) / 2; height: parent.height; radius: 12; color: Qt.rgba(0, 0, 0, 0.3)
                        property real percentage: cpuSchedulingPage.currentCpuUsage
                        property real _waveOffset: 0

                        Behavior on percentage { NumberAnimation { duration: 2000; easing.type: Easing.InOutSine } }
                        NumberAnimation on _waveOffset { from: 0; to: Math.PI * 2; duration: 2500; loops: Animation.Infinite; running: true }

                        Rectangle { id: cardMask; anchors.fill: parent; radius: 12; visible: false }
                        Item {
                            id: waterContainer; anchors.fill: parent; layer.enabled: true; layer.effect: OpacityMask { maskSource: cardMask }
                            Canvas {
                                id: canvas; anchors.fill: parent; anchors.margins: -2
                                Connections { target: rectWaterCard; function on_WaveOffsetChanged() { canvas.requestPaint() } function onPercentageChanged() { canvas.requestPaint() } }
                                onPaint: {
                                    var ctx = getContext("2d"); ctx.clearRect(0, 0, width, height)
                                    var cw = width; var ch = height; var p = Math.max(0.0, Math.min(100.0, rectWaterCard.percentage)) / 100.0
                                    var fillY = ch - (ch * p); var amplitude = (ch * 0.05) * Math.sin(p * Math.PI); var frequency = 0.025
                                    ctx.save()
                                    var bgGradient = ctx.createLinearGradient(0, fillY - amplitude, 0, ch)
                                    bgGradient.addColorStop(0, Qt.rgba(75 / 255, 42 / 255, 192 / 255, 0.3)); bgGradient.addColorStop(1, Qt.rgba(20 / 255, 10 / 255, 50 / 255, 0.4))
                                    var fgGradient = ctx.createLinearGradient(0, fillY - amplitude, 0, ch)
                                    fgGradient.addColorStop(0, Qt.rgba(110 / 255, 70 / 255, 230 / 255, 0.45)); fgGradient.addColorStop(1, Qt.rgba(40 / 255, 20 / 255, 100 / 255, 0.5))
                                    ctx.beginPath(); ctx.moveTo(0, fillY)
                                    for (var i = 0; i < cw; i += 5) { ctx.lineTo(i, fillY + Math.sin(i * frequency + rectWaterCard._waveOffset + 2) * amplitude) }
                                    ctx.lineTo(cw, fillY + Math.sin(cw * frequency + rectWaterCard._waveOffset + 2) * amplitude); ctx.lineTo(cw, ch); ctx.lineTo(0, ch); ctx.closePath(); ctx.fillStyle = bgGradient; ctx.fill()
                                    ctx.beginPath(); ctx.moveTo(0, fillY)
                                    for (var j = 0; j < cw; j += 5) { ctx.lineTo(j, fillY + Math.sin(j * frequency + rectWaterCard._waveOffset) * amplitude) }
                                    ctx.lineTo(cw, fillY + Math.sin(cw * frequency + rectWaterCard._waveOffset) * amplitude); ctx.lineTo(cw, ch); ctx.lineTo(0, ch); ctx.closePath(); ctx.fillStyle = fgGradient; ctx.fill()
                                    ctx.restore()
                                }
                            }
                        }
                        Text { anchors.centerIn: parent; text: "USAGE " + Math.round(rectWaterCard.percentage) + "%"; color: "white"; font { family: "Segoe UI"; pixelSize: 22; weight: Font.Bold } style: Text.Raised; styleColor: Qt.rgba(0, 0, 0, 0.3) }
                    }

                    Rectangle {
                        width: (parent.width - parent.spacing) / 2; height: parent.height; radius: 12; color: Qt.rgba(0, 0, 0, 0.3)
                        Column {
                            anchors.centerIn: parent; spacing: 8
                            Text { text: "PROCESS STATES"; color: "#a78bfa"; font { family: "Segoe UI"; pixelSize: 14; weight: Font.Bold } }
                            Repeater {
                                model: [
                                    { label: "RUNNING", count: cpuSchedulingPage.processStatesData.running.toString(), dotColor: "#10b981", textColor: "#34d399" },
                                    { label: "SLEEPING", count: cpuSchedulingPage.processStatesData.sleeping.toString(), dotColor: "#eab308", textColor: "#eab308" },
                                    { label: "ZOMBIE", count: cpuSchedulingPage.processStatesData.zombie.toString(), dotColor: "#ef4444", textColor: "#ef4444" }
                                ]
                                delegate: Row {
                                    spacing: 12
                                    Rectangle {
                                        width: 8; height: 8; radius: 4; color: modelData.dotColor; anchors.verticalCenter: parent.verticalCenter
                                        layer.enabled: true; layer.effect: Glow { radius: 4; samples: 9; color: modelData.dotColor; spread: 0.3 }
                                    }
                                    Text { text: modelData.label; color: modelData.textColor; font { family: "Segoe UI"; pixelSize: 12; weight: Font.Bold } }
                                    Text { text: modelData.count; color: Qt.rgba(255, 255, 255, 0.6); font { family: "Segoe UI"; pixelSize: 12; weight: Font.Bold } }
                                }
                            }
                            Text { text: "Total: " + cpuSchedulingPage.processStatesData.total + " processes"; font { family: "Segoe UI"; pixelSize: 10 } color: Qt.rgba(255, 255, 255, 0.4) }
                        }
                    }
                }
            }
        }

        // === BOTTOM ROW: Timeline ===
        Rectangle {
            id: schedulingRec
            width: parent.width; height: (parent.height - parent.spacing) * 2 / 3; color: Qt.rgba(255, 255, 255, 0.08); radius: 20
            border.color: Qt.rgba(139/255,92/255,246/255,0.22); border.width: 1
            // ── purple accent top strip ──
            Rectangle {
                anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                height: 3; radius: 20
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.3; color: "#8b5cf6" }
                    GradientStop { position: 0.7; color: "#8b5cf6" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            property real playheadProgress: 0.0
            property real playheadAlpha: 1.0

            SequentialAnimation {
                running: true; loops: Animation.Infinite
                NumberAnimation { target: schedulingRec; property: "playheadProgress"; from: 0.0; to: 1.0; duration: 10000; easing.type: Easing.Linear }
                NumberAnimation { target: schedulingRec; property: "playheadAlpha"; to: 0.0; duration: 250; easing.type: Easing.OutQuad }
                PropertyAction { target: schedulingRec; property: "playheadProgress"; value: 0.0 }
                NumberAnimation { target: schedulingRec; property: "playheadAlpha"; to: 1.0; duration: 250; easing.type: Easing.InQuad }
            }

            Rectangle {
                id: schedulingTitle; width: parent.width; height: 52; radius: 20; color: "transparent"
                Row {
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 20; verticalCenter: parent.verticalCenter }
                    spacing: 12
                    Text {
                        text: "PROCESS SCHEDULING TIMELINE"
                        font { family: "Segoe UI"; pixelSize: 13; weight: Font.Bold; letterSpacing: 1 }
                        color: "#8b5cf6"
                    }
                }
            }

            Item {
                id: graphArea
                anchors { top: schedulingTitle.bottom; bottom: parent.bottom; left: parent.left; right: parent.right; margins: 25; topMargin: 15 }

                property real labelWidth: 50
                property real innerSpacing: 15
                property real trackWidth: width - labelWidth - innerSpacing

                Column {
                    anchors.centerIn: parent; width: parent.width; spacing: 35
                    Repeater {
                        model: cpuSchedulingPage.timelineModelData
                        delegate: Row {
                            width: parent.width; height: 56; spacing: graphArea.innerSpacing
                            Text {
                                text: modelData.label; color: "white"
                                font { family: "Segoe UI"; pixelSize: 14; weight: Font.Bold }
                                width: graphArea.labelWidth; anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                id: trackBox
                                width: graphArea.trackWidth; height: parent.height; radius: 8; color: Qt.rgba(0, 0, 0, 0.3)

                                Item {
                                    width: trackBox.width * schedulingRec.playheadProgress
                                    height: trackBox.height
                                    layer.enabled: true
                                    layer.effect: Glow { radius: 15; samples: 20; color: "#8b5cf6"; spread: 0.15 }
                                    Row {
                                        width: trackBox.width; height: trackBox.height
                                        Repeater {
                                            model: modelData.blocks
                                            delegate: Rectangle {
                                                width: trackBox.width * (modelData.w / 10.0); height: trackBox.height
                                                color: modelData.c === "transparent" ? "transparent" : "#8b5cf6"
                                                radius: 8
                                            }
                                        }
                                    }
                                }

                                Item {
                                    width: trackBox.width * schedulingRec.playheadProgress
                                    height: trackBox.height
                                    clip: true

                                    Row {
                                        width: trackBox.width; height: trackBox.height
                                        Repeater {
                                            model: modelData.blocks
                                            delegate: Rectangle {
                                                id: blockItem
                                                width: trackBox.width * (modelData.w / 10.0); height: trackBox.height
                                                color: modelData.c === "transparent" ? "transparent" : "#8b5cf6"
                                                radius: 8

                                                property bool isProcess: modelData.t !== ""

                                                Text {
                                                    anchors.centerIn: parent; text: modelData.t; color: "white"
                                                    font { family: "Segoe UI"; pixelSize: 14; weight: Font.Bold }
                                                    visible: blockItem.isProcess
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    enabled: blockItem.isProcess
                                                    hoverEnabled: true
                                                    propagateComposedEvents: true

                                                    onEntered: {
                                                        blockItem.opacity = 0.8
                                                        cpuSchedulingPage.hoveredBlockData = modelData

                                                        var globalPos = blockItem.mapToItem(cpuSchedulingPage, width/2, height/2)
                                                        processTooltip.x = globalPos.x - (processTooltip.width / 2)
                                                        processTooltip.y = globalPos.y - 145
                                                        processTooltip.open()
                                                    }

                                                    onExited: {
                                                        blockItem.opacity = 1.0
                                                        cpuSchedulingPage.hoveredBlockData = null
                                                        processTooltip.hide()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: playhead
                                width: 2; height: parent.height; color: "#8b5cf6"
                                opacity: schedulingRec.playheadAlpha
                                x: 15 + graphArea.labelWidth + graphArea.innerSpacing + (graphArea.trackWidth * schedulingRec.playheadProgress)
                                y: 0
                                layer.enabled: true; layer.effect: Glow { radius: 8; samples: 13; color: "#8b5cf6"; spread: 0.3 }
                            }
                        }
                    }
                }
            }
        }
    }

    ToolTip {
        id: processTooltip
        delay: 0
        timeout: 5000
        padding: 15

        contentItem: Column {
            spacing: 12

            Row {
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 8; height: 8; radius: 4
                    color: "#34d399"
                    anchors.verticalCenter: parent.verticalCenter
                    layer.enabled: true
                    layer.effect: Glow { radius: 4; samples: 8; color: "#34d399"; spread: 0.3 }
                }

                Text {
                    text: cpuSchedulingPage.hoveredBlockData ? cpuSchedulingPage.hoveredBlockData.t : ""
                    font { family: "Segoe UI"; pixelSize: 13; weight: Font.Bold }
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "•"
                    font { family: "Segoe UI"; pixelSize: 12 }
                    color: Qt.rgba(255, 255, 255, 0.3)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: (cpuSchedulingPage.hoveredBlockData && cpuSchedulingPage.hoveredBlockData.proc_name) ? cpuSchedulingPage.hoveredBlockData.proc_name : "unknown"
                    font { family: "Segoe UI"; pixelSize: 13; weight: Font.Bold }
                    color: "#a78bfa"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width: parent.width; height: 1
                color: Qt.rgba(255, 255, 255, 0.1)
            }

            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter

                Column {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter
                    Text { text: "EIP (PC)"; font { family: "Segoe UI"; pixelSize: 10; weight: Font.Bold } color: Qt.rgba(255, 255, 255, 0.4) }
                    Text {
                        text: cpuSchedulingPage.hoveredBlockData ? cpuSchedulingPage.hoveredBlockData.eip : "0x0"
                        font { family: "Consolas"; pixelSize: 12; weight: Font.Bold }
                        color: "#f43f5e"
                    }
                }

                Rectangle { width: 1; height: 25; color: Qt.rgba(255, 255, 255, 0.1); anchors.verticalCenter: parent.verticalCenter }

                Column {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter
                    Text { text: "ESP (SP)"; font { family: "Segoe UI"; pixelSize: 10; weight: Font.Bold } color: Qt.rgba(255, 255, 255, 0.4) }
                    Text {
                        text: cpuSchedulingPage.hoveredBlockData ? cpuSchedulingPage.hoveredBlockData.esp : "0x0"
                        font { family: "Consolas"; pixelSize: 12; weight: Font.Bold }
                        color: "#38bdf8"
                    }
                }
            }
        }

        background: Rectangle {
            color: Qt.rgba(20 / 255, 15 / 255, 35 / 255, 0.85)
            border.color: Qt.rgba(139 / 255, 92 / 255, 246 / 255, 0.5)
            border.width: 1
            radius: 12
            layer.enabled: true
            layer.effect: Glow { radius: 10; samples: 15; color: Qt.rgba(139 / 255, 92 / 255, 246 / 255, 0.2); spread: 0.1 }
        }
    }
}
