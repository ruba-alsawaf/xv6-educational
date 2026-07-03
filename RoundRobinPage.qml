import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

ScrollView {
    id: scrollRoot
    anchors.fill: parent
    contentWidth: parent.width
    contentHeight: mainColumn.implicitHeight + 40
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    signal requestNavigate(string pageSource)

    // ── Simulator state ──────────────────────────────────────────────────
    property int  quantum:             2
    property bool simRunning:          false
    property int  timeElapsed:         0
    property int  currentQuantumUsed:  0
    property int  ganttBlockStart:     0
    property bool allDone:             false

    property var procNames:      ["P1", "P2", "P3", "P4"]
    property var procBursts:     [6, 4, 8, 3]
    property var procRemaining:  [6, 4, 8, 3]
    property var procColors:     ["#ec4899", "#06b6d4", "#fbbf24", "#10b981"]
    property var procR:          [236,   6, 251,  16]
    property var procG:          [ 72, 182, 191, 185]
    property var procB:          [153, 212,  36, 129]
    property var procWait:       [0, 0, 0, 0]
    property var procDone:       [false, false, false, false]
    property var procTurnaround: [0, 0, 0, 0]
    property var readyQueue:     [0, 1, 2, 3]
    property var gantt:          []

    function resetSimulation() {
        simRunning = false; timeElapsed = 0; currentQuantumUsed = 0
        ganttBlockStart = 0; allDone = false
        procRemaining   = [procBursts[0], procBursts[1], procBursts[2], procBursts[3]]
        procWait        = [0, 0, 0, 0]
        procDone        = [false, false, false, false]
        procTurnaround  = [0, 0, 0, 0]
        readyQueue      = [0, 1, 2, 3]
        gantt           = []
    }

    function stepSimulation() {
        if (allDone) return
        var rq = readyQueue.slice()
        if (rq.length === 0) { allDone = true; simRunning = false; return }
        var rem = procRemaining.slice(), wait = procWait.slice()
        var done = procDone.slice(), ta = procTurnaround.slice()
        var g = gantt.slice(), curr = rq[0]
        if (currentQuantumUsed === 0) ganttBlockStart = timeElapsed
        rem[curr] -= 1; timeElapsed += 1; currentQuantumUsed += 1
        for (var i = 1; i < rq.length; i++) wait[rq[i]] += 1
        if (rem[curr] === 0) {
            done[curr] = true; ta[curr] = timeElapsed
            g.push({ proc: curr, start: ganttBlockStart, end: timeElapsed })
            rq.shift(); currentQuantumUsed = 0
        } else if (currentQuantumUsed >= quantum) {
            g.push({ proc: curr, start: ganttBlockStart, end: timeElapsed })
            rq.shift(); rq.push(curr); currentQuantumUsed = 0
        }
        procRemaining = rem; procWait = wait; procDone = done
        procTurnaround = ta; readyQueue = rq; gantt = g
        if (rq.length === 0) { allDone = true; simRunning = false }
    }

    Timer { interval:550; running:scrollRoot.simRunning; repeat:true; onTriggered:scrollRoot.stepSimulation() }

    // ────────────────────────────────────────────────────────────────────
    Column {
        id: mainColumn
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top; anchors.topMargin: 20
        spacing: 24

        // ── HEADER ──────────────────────────────────────────────────────
        Rectangle {
            width:parent.width; height:95
            color:Qt.rgba(255,255,255,0.03); radius:14
            border.color:Qt.rgba(139,92,246,0.25); border.width:1
            layer.enabled:true
            layer.effect: Glow { radius:10; samples:17; color:Qt.rgba(139,92,246,0.12); spread:0.1 }
            Row {
                anchors.fill:parent; anchors.margins:15; spacing:16
                Rectangle {
                    width:52; height:52; radius:12; anchors.verticalCenter:parent.verticalCenter
                    color:Qt.rgba(139,92,246,0.15); border.color:Qt.rgba(139,92,246,0.4); border.width:1
                    Column { anchors.centerIn:parent; spacing:1
                        Text { text:"RR"; color:"#8b5cf6"; font.bold:true; font.pixelSize:16; font.family:"Consolas"; anchors.horizontalCenter:parent }
                        Text { text:"SCHED"; color:Qt.rgba(139,92,246,0.5); font.pixelSize:7; font.letterSpacing:1; anchors.horizontalCenter:parent }
                    }
                }
                Column { anchors.verticalCenter:parent.verticalCenter; spacing:5; width:parent.width-80
                    Text { text:"ROUND-ROBIN SCHEDULING — How xv6 Shares the CPU"; color:"#ffffff"; font.family:"Segoe UI"; font.bold:true; font.pixelSize:20 }
                    Text { width:parent.width; text:"Every process gets an equal time slice (quantum). When it expires the process is preempted and moves to the back of the ready queue — fair, simple, no starvation."; color:Qt.rgba(255,255,255,0.52); font.family:"Segoe UI"; font.pixelSize:12; wrapMode:Text.WordWrap }
                }
            }
        }

        // ── CONCEPT OVERVIEW — 5 cards in a grid of 2 rows ───────────────
        Rectangle {
            width:parent.width; height:conceptGrid.implicitHeight+32
            color:Qt.rgba(255,255,255,0.02); radius:14
            border.color:Qt.rgba(139,92,246,0.15); border.width:1

            // Use a Grid so cards wrap and text has room
            Grid {
                id:conceptGrid
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                columns: 5
                spacing: 10
                property real cardW: (width - spacing*4) / 5

                Repeater {
                    model:[
                        {title:"Time Quantum",   icon:"⏱",  desc:"Fixed time slice each process receives on the CPU. In xv6 one quantum ≈ 1 timer tick (~1ms on QEMU). When expired, timer fires an interrupt.", color:"#8b5cf6"},
                        {title:"Ready Queue",    icon:"📋", desc:"All RUNNABLE processes waiting for the CPU. Head process runs next. After preemption the process joins the tail. No starvation possible.", color:"#ec4899"},
                        {title:"Preemption",     icon:"✂️",  desc:"Timer interrupt → usertrap() → yield(). Running process is stopped, state set to RUNNABLE, CPU given to next process in queue.", color:"#fbbf24"},
                        {title:"Fairness",       icon:"⚖️",  desc:"Every process gets equal CPU time over the long run. No process monopolises the CPU. Simple to reason about and verify correctness.", color:"#10b981"},
                        {title:"Context Switch", icon:"🔄", desc:"swtch() saves callee-saved regs + ra + sp of current process into proc.context. Loads next process's saved context. Pure RISC-V assembly.", color:"#06b6d4"}
                    ]
                    delegate: Rectangle {
                        width:conceptGrid.cardW; height:cardContent.implicitHeight+28; radius:12
                        color:Qt.rgba(255,255,255,0.03); border.color:Qt.rgba(255,255,255,0.08); border.width:1
                        Column {
                            id:cardContent
                            anchors.top:parent.top; anchors.topMargin:14
                            anchors.left:parent.left; anchors.leftMargin:12
                            anchors.right:parent.right; anchors.rightMargin:12
                            spacing:7
                            Text { text:modelData.icon; font.pixelSize:20 }
                            Text { text:modelData.title; color:modelData.color; font.bold:true; font.pixelSize:12 }
                            Text {
                                width: parent.width           // ← critical for wrapping
                                text: modelData.desc
                                color: Qt.rgba(255,255,255,0.6)
                                font.pixelSize:10; wrapMode:Text.WordWrap; lineHeight:1.5
                            }
                        }
                    }
                }
            }
        }

        // ── ROUND-ROBIN SIMULATOR ────────────────────────────────────────
        Rectangle {
            width:parent.width; height:rrCol.implicitHeight+32
            color:Qt.rgba(255,255,255,0.025); radius:14
            border.color:Qt.rgba(139,92,246,0.3); border.width:1

            Column {
                id:rrCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing:14

                Row { spacing:10
                    Text { text:"⚙️"; font.pixelSize:18; anchors.verticalCenter:parent.verticalCenter }
                    Column { spacing:2
                        Text { text:"INTERACTIVE SIMULATOR — Run Round-Robin step by step"; color:"#8b5cf6"; font.bold:true; font.pixelSize:13 }
                        Text { text:"4 processes, different burst times. Choose quantum, step or auto-run, watch the Gantt chart build."; color:Qt.rgba(255,255,255,0.35); font.pixelSize:11 }
                    }
                }

                // Quantum + controls
                RowLayout {
                    width:parent.width; height:42
                    spacing: 8

                    Text { text:"Quantum:"; color:Qt.rgba(255,255,255,0.45); font.pixelSize:12; Layout.alignment:Qt.AlignVCenter }
                    Repeater {
                        model:[1,2,3,4]
                        delegate: Rectangle {
                            property bool active: scrollRoot.quantum === modelData
                            Layout.preferredWidth:36; Layout.preferredHeight:36
                            radius:9
                            color:active?Qt.rgba(139,92,246,0.3):Qt.rgba(255,255,255,0.05)
                            border.color:active?"#8b5cf6":Qt.rgba(255,255,255,0.1); border.width:active?1.5:1
                            Behavior on color { ColorAnimation { duration:100 } }
                            Text { anchors.centerIn:parent; text:modelData; color:active?"#c4b5fd":Qt.rgba(255,255,255,0.35); font.bold:true; font.pixelSize:13 }
                            MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor
                                onClicked:{ scrollRoot.quantum=modelData; scrollRoot.resetSimulation() }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        Layout.preferredWidth:92; Layout.preferredHeight:36; radius:9
                        color:scrollRoot.allDone?Qt.rgba(255,255,255,0.03):scrollRoot.simRunning?Qt.rgba(239,68,68,0.2):Qt.rgba(139,92,246,0.2)
                        border.color:scrollRoot.allDone?"#374151":scrollRoot.simRunning?"#ef4444":"#8b5cf6"; border.width:1
                        Text { anchors.centerIn:parent; text:scrollRoot.allDone?"✓ DONE":scrollRoot.simRunning?"■ PAUSE":"▶ START"; color:scrollRoot.allDone?"#4b5563":scrollRoot.simRunning?"#ef4444":"#a78bfa"; font.bold:true; font.pixelSize:12 }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; enabled:!scrollRoot.allDone; onClicked:scrollRoot.simRunning=!scrollRoot.simRunning }
                    }
                    Rectangle {
                        Layout.preferredWidth:72; Layout.preferredHeight:36; radius:9
                        color:Qt.rgba(255,255,255,0.05); border.color:Qt.rgba(255,255,255,0.15); border.width:1
                        Text { anchors.centerIn:parent; text:"▷ STEP"; color:Qt.rgba(255,255,255,0.55); font.bold:true; font.pixelSize:12 }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:{ scrollRoot.simRunning=false; scrollRoot.stepSimulation() } }
                    }
                    Rectangle {
                        Layout.preferredWidth:72; Layout.preferredHeight:36; radius:9
                        color:Qt.rgba(255,255,255,0.05); border.color:Qt.rgba(255,255,255,0.15); border.width:1
                        Text { anchors.centerIn:parent; text:"↺ RESET"; color:Qt.rgba(255,255,255,0.4); font.bold:true; font.pixelSize:12 }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:scrollRoot.resetSimulation() }
                    }
                }

                // Process table
                Rectangle {
                    width:parent.width; height:ptCol.implicitHeight+28
                    color:Qt.rgba(0,0,0,0.2); radius:10; border.color:Qt.rgba(255,255,255,0.06); border.width:1
                    Column {
                        id:ptCol
                        anchors.top:parent.top; anchors.topMargin:14
                        anchors.left:parent.left; anchors.leftMargin:14
                        anchors.right:parent.right; anchors.rightMargin:14
                        spacing:6
                        property real cw: width / 6

                        RowLayout { width:parent.width; height:20
                            Repeater {
                                model:["PROCESS","BURST","REMAINING","STATUS","WAIT","TURNAROUND"]
                                delegate: Text { Layout.preferredWidth:ptCol.cw; text:modelData; color:Qt.rgba(255,255,255,0.28); font.pixelSize:9; font.bold:true; font.letterSpacing:0.5 }
                            }
                        }
                        Rectangle { width:parent.width; height:1; color:Qt.rgba(255,255,255,0.06) }

                        Repeater {
                            model:4
                            delegate: Rectangle {
                                property bool isCurrent: !scrollRoot.procDone[index] && scrollRoot.readyQueue.length>0 && scrollRoot.readyQueue[0]===index
                                width:parent.width; height:38; radius:8
                                color:isCurrent?Qt.rgba(scrollRoot.procR[index]/255,scrollRoot.procG[index]/255,scrollRoot.procB[index]/255,0.16):Qt.rgba(255,255,255,0.02)
                                border.color:isCurrent?scrollRoot.procColors[index]:Qt.rgba(255,255,255,0.04); border.width:isCurrent?1.5:1
                                Behavior on color { ColorAnimation { duration:220 } }

                                RowLayout {
                                    anchors.fill:parent; anchors.leftMargin:4; anchors.rightMargin:4

                                    Row { Layout.preferredWidth:ptCol.cw; spacing:8; Layout.alignment:Qt.AlignVCenter
                                        Rectangle { width:10; height:10; radius:5; color:scrollRoot.procColors[index]; anchors.verticalCenter:parent.verticalCenter
                                            layer.enabled:true; layer.effect:Glow{radius:4;samples:7;color:scrollRoot.procColors[index];spread:0.4} }
                                        Text { text:scrollRoot.procNames[index]; color:"#ffffff"; font.bold:true; font.pixelSize:13 }
                                    }
                                    Text { Layout.preferredWidth:ptCol.cw; text:scrollRoot.procBursts[index]; color:Qt.rgba(255,255,255,0.55); font.pixelSize:12; font.family:"Consolas"; Layout.alignment:Qt.AlignVCenter }
                                    Item { Layout.preferredWidth:ptCol.cw; Layout.fillHeight:true
                                        Row { anchors.verticalCenter:parent.verticalCenter; spacing:6
                                            Rectangle { width:54; height:8; radius:4; color:Qt.rgba(255,255,255,0.08)
                                                Rectangle { width:scrollRoot.procDone[index]?0:54*scrollRoot.procRemaining[index]/scrollRoot.procBursts[index]; height:8; radius:4; color:scrollRoot.procColors[index]; Behavior on width{NumberAnimation{duration:280}} }
                                            }
                                            Text { text:scrollRoot.procRemaining[index]; color:scrollRoot.procColors[index]; font.pixelSize:11; font.family:"Consolas" }
                                        }
                                    }
                                    Text { Layout.preferredWidth:ptCol.cw; text:scrollRoot.procDone[index]?"✓ DONE":isCurrent?"● RUNNING":"○ WAITING"; color:scrollRoot.procDone[index]?"#10b981":isCurrent?scrollRoot.procColors[index]:Qt.rgba(255,255,255,0.3); font.pixelSize:11; font.bold:true; Layout.alignment:Qt.AlignVCenter }
                                    Text { Layout.preferredWidth:ptCol.cw; text:scrollRoot.procWait[index]+" t"; color:Qt.rgba(255,255,255,0.5); font.pixelSize:12; font.family:"Consolas"; Layout.alignment:Qt.AlignVCenter }
                                    Text { Layout.preferredWidth:ptCol.cw; text:scrollRoot.procDone[index]?scrollRoot.procTurnaround[index]+" t":"—"; color:scrollRoot.procDone[index]?"#a78bfa":Qt.rgba(255,255,255,0.2); font.pixelSize:12; font.family:"Consolas"; Layout.alignment:Qt.AlignVCenter }
                                }
                            }
                        }
                    }
                }

                // Time + ready queue
                RowLayout { width:parent.width; spacing:12; height:68

                    Rectangle { Layout.preferredWidth:108; Layout.fillHeight:true; radius:10; color:Qt.rgba(0,0,0,0.25); border.color:Qt.rgba(139,92,246,0.35); border.width:1
                        Column { anchors.centerIn:parent; spacing:3
                            Text { text:"TIME"; color:Qt.rgba(139,92,246,0.55); font.pixelSize:9; font.bold:true; font.letterSpacing:1; anchors.horizontalCenter:parent }
                            Text { text:scrollRoot.timeElapsed; color:"#a78bfa"; font.bold:true; font.pixelSize:30; font.family:"Consolas"; anchors.horizontalCenter:parent }
                        }
                    }
                    Rectangle { Layout.preferredWidth:120; Layout.fillHeight:true; radius:10; color:Qt.rgba(0,0,0,0.22); border.color:Qt.rgba(139,92,246,0.2); border.width:1
                        Column { anchors.centerIn:parent; spacing:3
                            Text { text:"QUANTUM LEFT"; color:Qt.rgba(139,92,246,0.45); font.pixelSize:8; font.bold:true; font.letterSpacing:0.5; anchors.horizontalCenter:parent }
                            Text { text:scrollRoot.readyQueue.length>0?(scrollRoot.quantum-scrollRoot.currentQuantumUsed):"—"; color:"#8b5cf6"; font.bold:true; font.pixelSize:30; font.family:"Consolas"; anchors.horizontalCenter:parent }
                        }
                    }
                    Rectangle { Layout.fillWidth:true; Layout.fillHeight:true; radius:10; color:Qt.rgba(0,0,0,0.18); border.color:Qt.rgba(255,255,255,0.06); border.width:1
                        Row { anchors.fill:parent; anchors.margins:12; spacing:10
                            Text { text:"READY QUEUE:"; color:Qt.rgba(255,255,255,0.28); font.pixelSize:11; font.bold:true; anchors.verticalCenter:parent.verticalCenter }
                            Row { spacing:6; anchors.verticalCenter:parent.verticalCenter
                                Repeater {
                                    model:scrollRoot.readyQueue
                                    delegate: Rectangle {
                                        width:46; height:42; radius:9
                                        color:Qt.rgba(scrollRoot.procR[modelData]/255,scrollRoot.procG[modelData]/255,scrollRoot.procB[modelData]/255,index===0?0.28:0.1)
                                        border.color:scrollRoot.procColors[modelData]; border.width:index===0?2:1
                                        Column { anchors.centerIn:parent; spacing:2
                                            Text { text:scrollRoot.procNames[modelData]; color:"#ffffff"; font.bold:true; font.pixelSize:13; anchors.horizontalCenter:parent }
                                            Text { text:index===0?"RUN":"wait"; color:Qt.rgba(255,255,255,0.35); font.pixelSize:8; anchors.horizontalCenter:parent }
                                        }
                                    }
                                }
                                Text { visible:scrollRoot.allDone; text:"ALL DONE ✓"; color:"#10b981"; font.bold:true; font.pixelSize:13; anchors.verticalCenter:parent.verticalCenter }
                            }
                        }
                    }
                }

                // Gantt chart
                Column { width:parent.width; spacing:6
                    Text { text:"GANTT CHART — execution timeline"; color:Qt.rgba(255,255,255,0.28); font.pixelSize:9; font.bold:true; font.letterSpacing:1 }
                    Rectangle { width:parent.width; height:62; radius:10; color:Qt.rgba(0,0,0,0.2); border.color:Qt.rgba(255,255,255,0.06); border.width:1; clip:true
                        Row {
                            anchors.top:parent.top; anchors.topMargin:8
                            anchors.left:parent.left; anchors.leftMargin:10
                            spacing:2; height:50
                            Repeater {
                                model:scrollRoot.gantt
                                delegate: Column { spacing:2; height:50
                                    Rectangle {
                                        width:Math.max(28,(modelData.end-modelData.start)*22); height:32; radius:7
                                        color:Qt.rgba(scrollRoot.procR[modelData.proc]/255,scrollRoot.procG[modelData.proc]/255,scrollRoot.procB[modelData.proc]/255,0.35)
                                        border.color:scrollRoot.procColors[modelData.proc]; border.width:1
                                        Text { anchors.centerIn:parent; text:scrollRoot.procNames[modelData.proc]; color:"#ffffff"; font.bold:true; font.pixelSize:11 }
                                    }
                                    Text { text:modelData.start; color:Qt.rgba(255,255,255,0.28); font.pixelSize:8; font.family:"Consolas" }
                                }
                            }
                            Text { visible:scrollRoot.gantt.length>0; text:scrollRoot.gantt.length>0?scrollRoot.gantt[scrollRoot.gantt.length-1].end:""; color:Qt.rgba(255,255,255,0.28); font.pixelSize:8; font.family:"Consolas"; anchors.bottom:parent.bottom }
                        }
                        Text { visible:scrollRoot.gantt.length===0; anchors.centerIn:parent; text:"Gantt chart appears here as simulation runs"; color:Qt.rgba(255,255,255,0.18); font.pixelSize:11; font.italic:true }
                    }
                }
            }
        }

        // ── xv6 SCHEDULER CODE + THEORY ─────────────────────────────────
        Rectangle {
            width:parent.width; height:codeSection.implicitHeight+32
            color:Qt.rgba(255,255,255,0.015); radius:14
            border.color:Qt.rgba(255,255,255,0.07); border.width:1

            Column {
                id:codeSection
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing:14

                Row { spacing:10
                    Text { text:"📄"; font.pixelSize:18; anchors.verticalCenter:parent.verticalCenter }
                    Column { spacing:2
                        Text { text:"xv6 SCHEDULER — kernel/proc.c + kernel/trap.c"; color:"#8b5cf6"; font.bold:true; font.pixelSize:13 }
                        Text { text:"The actual C code that implements Round-Robin in xv6 RISC-V"; color:Qt.rgba(255,255,255,0.32); font.pixelSize:11 }
                    }
                }

                // Theory left + Code right — using RowLayout to avoid overlap
                RowLayout {
                    width:parent.width; spacing:14

                    // Theory cards
                    Column {
                        Layout.preferredWidth: parent.width * 0.38
                        Layout.fillHeight: false
                        spacing:8
                        Repeater {
                            model:[
                                {title:"scheduler() — infinite loop",  desc:"Runs forever on each CPU core. Iterates proc[NPROC] linearly. First RUNNABLE found gets CPU via swtch(). After process yields, loop picks the next one.", color:"#8b5cf6"},
                                {title:"swtch() — context switch",      desc:"Saves callee-saved regs (s0–s11) + ra + sp of caller into *old. Loads same fields from *new. Written in pure RISC-V assembly in swtch.S.", color:"#ec4899"},
                                {title:"yield() — timer preemption",    desc:"Timer interrupt → usertrap() sees cause=TIMER → calls yield(). Sets p->state=RUNNABLE and calls sched() → swtch() back to scheduler. This is the quantum.", color:"#fbbf24"},
                                {title:"Why Round-Robin?",              desc:"proc[] is a fixed array. scheduler() scans it linearly every time. Since all processes get equal time (1 timer tick), the result is Round-Robin. No priority, no weights.", color:"#10b981"}
                            ]
                            delegate: Rectangle {
                                width: parent.width
                                height: theoryCard.implicitHeight+20; radius:9
                                color:Qt.rgba(255,255,255,0.03); border.color:Qt.rgba(255,255,255,0.07); border.width:1
                                Rectangle { width:3; height:parent.height-8; anchors.left:parent.left; anchors.verticalCenter:parent.verticalCenter; color:modelData.color; radius:2 }
                                Column {
                                    id:theoryCard
                                    anchors.top:parent.top; anchors.topMargin:10
                                    anchors.left:parent.left; anchors.leftMargin:12
                                    anchors.right:parent.right; anchors.rightMargin:10
                                    spacing:4
                                    Text { text:modelData.title; color:modelData.color; font.bold:true; font.pixelSize:11 }
                                    Text {
                                        width: parent.width          // ← forces wrapping
                                        text: modelData.desc
                                        color:Qt.rgba(255,255,255,0.62); font.pixelSize:10
                                        wrapMode:Text.WordWrap; lineHeight:1.5
                                    }
                                }
                            }
                        }
                    }

                    // Code panel
                    Rectangle {
                        Layout.fillWidth: true
                        height: schedCode.implicitHeight + 52
                        color:Qt.rgba(0,0,0,0.3); radius:10; border.color:Qt.rgba(255,255,255,0.06); border.width:1

                        // Title bar
                        Rectangle { width:parent.width; height:26; color:Qt.rgba(255,255,255,0.04); radius:10
                            Rectangle { width:parent.width; height:13; anchors.bottom:parent.bottom; color:parent.color }
                            Row { anchors.left:parent.left; anchors.leftMargin:10; anchors.verticalCenter:parent.verticalCenter; spacing:4
                                Repeater { model:3; delegate:Rectangle{width:8;height:8;radius:4;color:["#f43f5e","#fbbf24","#10b981"][index];opacity:0.7} }
                            }
                            Text { text:"kernel/proc.c"; color:Qt.rgba(255,255,255,0.16); font.pixelSize:9; font.family:"Consolas"; anchors.centerIn:parent }
                        }

                        Text {
                            id:schedCode
                            anchors.top:parent.top; anchors.topMargin:32
                            anchors.left:parent.left; anchors.leftMargin:14
                            anchors.right:parent.right; anchors.rightMargin:14
                            text:"void scheduler(void)\n{\n    struct proc *p;\n    struct cpu  *c = mycpu();\n    c->proc = 0;\n\n    for(;;) {\n        intr_on();   // enable interrupts (avoid deadlock)\n\n        // Linear scan → implicit Round-Robin\n        for(p = proc; p < &proc[NPROC]; p++) {\n            acquire(&p->lock);\n            if(p->state == RUNNABLE) {\n                p->state = RUNNING;\n                c->proc  = p;\n                swtch(&c->context, &p->context);\n                // process ran; returned via sched()\n                c->proc  = 0;\n            }\n            release(&p->lock);\n        }\n    }\n}\n\n// Timer interrupt → yield() preempts running process\nvoid yield(void)\n{\n    struct proc *p = myproc();\n    acquire(&p->lock);\n    p->state = RUNNABLE;  // preempted, back to ready queue\n    sched();              // swtch() back to scheduler()\n    release(&p->lock);\n}"
                            color:Qt.rgba(255,255,255,0.82); font.family:"Consolas"; font.pixelSize:10
                            lineHeight:1.55; wrapMode:Text.WrapAtWordBoundaryOrAnywhere
                        }
                    }
                }
            }
        }

        // ── FOOTER ──────────────────────────────────────────────────────
        Rectangle {
            width:parent.width; height:68
            color:Qt.rgba(139/255,92/255,246/255,0.08); radius:14
            border.color:Qt.rgba(139/255,92/255,246/255,0.35); border.width:1
            RowLayout { anchors.fill:parent; anchors.margins:15; spacing:15
                Text { text:"🌟"; font.pixelSize:22; Layout.alignment:Qt.AlignVCenter }
                Text { Layout.fillWidth:true; Layout.alignment:Qt.AlignVCenter
                    text:"CORE SUMMARY: Round-Robin = equal time slices. scheduler() scans proc[] linearly → RUNNABLE → swtch(). Timer interrupt → yield() → p->state=RUNNABLE → back of queue. Context saved in proc.context (s0–s11, ra, sp). Turnaround = completion − arrival. Wait = turnaround − burst. Smaller quantum = more fairness but more context-switch overhead."
                    color:"#ffffff"; wrapMode:Text.WordWrap; font.family:"Segoe UI"; font.bold:true; font.pixelSize:11
                }
            }
        }
    }
}
