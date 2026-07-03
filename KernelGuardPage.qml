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

    // ── Active step ──────────────────────────────────────────────────
    property int activeStep: 0

    // ── Pipeline animation dot progress (0.0 → 1.0, looping) ────────
    property real pipelineDot: 0.0

    // ── Table hover ──────────────────────────────────────────────────
    property int hoveredRow: -1

    // ── Step data ────────────────────────────────────────────────────
    property var stepColors:    ["#a78bfa", "#fbbf24", "#f43f5e", "#10b981"]
    property var stepR:         [167, 251, 244, 16]
    property var stepG:         [139, 191, 63,  185]
    property var stepB:         [250, 36,  94,  129]
    property var stepIcons:     ["💻", "📋", "⚡", "🔧"]
    property var stepTitles:    ["USER SPACE", "LOAD VECTOR", "ECALL TRAP", "KERNEL EXEC"]
    property var stepSubtitles: [
        "Ring 3 — Restricted Environment",
        "Register a7 = Syscall Number",
        "Hardware → Supervisor Mode Switch",
        "Handler → Return to User Mode"
    ]
    property var stepTheories: [
        "The process executes in User Mode — the lowest CPU privilege level. It has no direct access to hardware, kernel memory, or OS data structures. When it needs an OS service such as writing to disk, reading a file, or cloning itself, it must request it through the System Call interface — the only controlled, legal gateway into the kernel.",
        "Before the trap fires, the C library wrapper (usys.S) loads the syscall number into register a7. In the RISC-V ABI, a7 is exclusively reserved for this purpose. Arguments are placed in a0–a5. This numeric convention is the compact 'language' that user code uses to address a specific kernel service by its unique ID number.",
        "The 'ecall' instruction fires an atomic hardware trap. In one uninterruptible step: PC is saved to sepc (return address), privilege level is saved to sstatus, scause is set to 8 (Environment Call from U-mode), and the CPU jumps to the address in stvec — the kernel's registered trap vector. The trampoline saves all 32 registers, then calls usertrap().",
        "The kernel reads a7 from the saved trapframe, validates the number against the syscall dispatch table, and calls the matching kernel function (e.g. sys_write). The return value is stored in trapframe→a0. When done, usertrapret() restores registers, calls sret — which atomically restores sstatus and jumps to sepc — returning safely to User Mode."
    ]
    property var stepCodes: [
        "// user/cat.c — a simple user-space program\nvoid cat(int fd) {\n    char buf[512];\n    int n;\n\n    // write() is a libc stub that\n    // eventually triggers 'ecall'\n    while((n = read(fd, buf, 512)) > 0)\n        write(1, buf, n);\n}",
        "// kernel/syscall.h — numeric ID table\n#define SYS_fork    1\n#define SYS_exit    2\n#define SYS_wait    3\n#define SYS_read    5\n#define SYS_write   16\n#define SYS_open    15\n#define SYS_close   21\n\n// user/usys.S stub (assembled):\n//   li   a7, 16     // SYS_write\n//   li   a0, 1      // fd = stdout\n//   ecall            // fire trap!",
        "// What 'ecall' triggers atomically (hw):\n//   sepc    ← PC        (return address)\n//   sstatus ← U-mode    (privilege saved)\n//   scause  ← 8         (env call cause)\n//   PC      ← stvec     (→ uservec)\n\n// kernel/trampoline.S: uservec\n//   saves all 32 user registers into\n//   proc->trapframe, then calls:\nusertrap();   // kernel/trap.c",
        "// kernel/syscall.c\nvoid syscall(void) {\n    struct proc *p = myproc();\n    int num = p->trapframe->a7;\n\n    if(num > 0 &&\n       num < NELEM(syscalls) &&\n       syscalls[num]) {\n        // dispatch to handler\n        p->trapframe->a0 =\n            syscalls[num]();\n    } else {\n        p->trapframe->a0 = -1; // error\n    }\n}"
    ]
    property var stepSources: [
        "user/cat.c",
        "kernel/syscall.h + user/usys.S",
        "RISC-V ISA Spec + kernel/trampoline.S",
        "kernel/syscall.c + kernel/trap.c"
    ]

    // ── Syscall reference table ──────────────────────────────────────
    property var tableNums:     ["1",   "5",      "16",      "15",     "7",      "21"]
    property var tableNames:    ["fork()", "read()", "write()", "open()", "exec()", "close()"]
    property var tableHandlers: ["sys_fork()", "sys_read()", "sys_write()", "sys_open()", "sys_exec()", "sys_close()"]
    property var tablePurposes: [
        "Clone process → new child with unique PID",
        "Read n bytes from file descriptor into buffer",
        "Write n bytes from buffer to file descriptor",
        "Open a file path → return a file descriptor",
        "Replace process image with a new program",
        "Release and free a file descriptor entry"
    ]

    // ── Pipeline animation timer ─────────────────────────────────────
    Timer {
        interval: 25
        running: true
        repeat: true
        onTriggered: scrollRoot.pipelineDot = (scrollRoot.pipelineDot + 0.011) % 1.0
    }

    // ─────────────────────────────────────────────────────────────────
    Column {
        id: mainColumn
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        spacing: 25

        // ═════════════════════════════════════════════════════════════
        // 1. HEADER
        // ═════════════════════════════════════════════════════════════
        Rectangle {
            width: parent.width
            height: 95
            color: Qt.rgba(255, 255, 255, 0.03)
            radius: 14
            border.color: Qt.rgba(139, 92, 246, 0.25)
            border.width: 1

            layer.enabled: true
            layer.effect: Glow {
                radius: 10; samples: 17
                color: Qt.rgba(139, 92, 246, 0.12); spread: 0.1
            }

            Row {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 16

                // Lesson number badge
                Rectangle {
                    width: 52; height: 52; radius: 12
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(139, 92, 246, 0.15)
                    border.color: Qt.rgba(139, 92, 246, 0.4)
                    border.width: 1
                    Column {
                        anchors.centerIn: parent; spacing: 1
                        Text {
                            text: "01"
                            color: "#a78bfa"
                            font { bold: true; pixelSize: 20; family: "Consolas" }
                            anchors.horizontalCenter: parent
                        }
                        Text {
                            text: "LESSON"
                            color: Qt.rgba(167, 139, 250, 0.5)
                            font { pixelSize: 7; letterSpacing: 1 }
                            anchors.horizontalCenter: parent
                        }
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6
                    Text {
                        text: "SYSTEM CALLS — THE KERNEL GATEWAY"
                        color: "#ffffff"
                        font { family: "Segoe UI"; bold: true; pixelSize: 20; letterSpacing: 0.5 }
                    }
                    Text {
                        text: "💡 GOAL: Trace the full syscall lifecycle — from a user library call, through the hardware ecall trap, into the kernel dispatcher, and safely back to User Mode."
                        color: Qt.rgba(255, 255, 255, 0.6)
                        font { family: "Segoe UI"; pixelSize: 13 }
                        wrapMode: Text.WordWrap
                        width: mainColumn.width - 100
                    }
                }
            }
        }

        // ═════════════════════════════════════════════════════════════
        // 2. ANIMATED PIPELINE DIAGRAM  (NEW)
        // ═════════════════════════════════════════════════════════════
        Rectangle {
            width: parent.width
            height: 130
            color: Qt.rgba(0, 0, 0, 0.25)
            radius: 14
            border.color: Qt.rgba(255, 255, 255, 0.06)
            border.width: 1

            Text {
                text: "SYSCALL LIFECYCLE PIPELINE"
                color: Qt.rgba(255, 255, 255, 0.2)
                font { pixelSize: 9; letterSpacing: 2; bold: true }
                anchors.top: parent.top
                anchors.topMargin: 9
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Canvas {
                id: pipelineCanvas
                anchors.fill: parent
                anchors.topMargin: 18

                property real dot:    scrollRoot.pipelineDot
                property int  active: scrollRoot.activeStep
                onDotChanged:    requestPaint()
                onActiveChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()

                    var w = width, h = height
                    var bw = 100, bh = 52
                    var gap = 36
                    var totalW = 4 * bw + 3 * gap
                    var sx = (w - totalW) / 2
                    var midY = h / 2 + 4

                    var boxes = [
                        { x: sx,              r:167, g:139, b:250, hex:"#a78bfa", label:"USER SPACE", sub:"Ring 3"     },
                        { x: sx+bw+gap,       r:251, g:191, b:36,  hex:"#fbbf24", label:"LOAD  a7",   sub:"Syscall ID" },
                        { x: sx+2*(bw+gap),   r:244, g:63,  b:94,  hex:"#f43f5e", label:"ecall TRAP", sub:"HW Switch"  },
                        { x: sx+3*(bw+gap),   r:16,  g:185, b:129, hex:"#10b981", label:"KERNEL EXEC",sub:"+ sret"     }
                    ]

                    // arrows + animated dots
                    for (var i = 0; i < 3; i++) {
                        var ax = boxes[i].x + bw
                        var bx2 = boxes[i+1].x
                        var segLen = bx2 - ax

                        // dashed line
                        ctx.strokeStyle = "rgba(255,255,255,0.10)"
                        ctx.lineWidth = 1.5
                        ctx.setLineDash([4, 4])
                        ctx.beginPath(); ctx.moveTo(ax+4, midY); ctx.lineTo(bx2-4, midY); ctx.stroke()
                        ctx.setLineDash([])

                        // arrowhead
                        ctx.fillStyle = "rgba(255,255,255,0.22)"
                        ctx.beginPath()
                        ctx.moveTo(bx2-10, midY-4); ctx.lineTo(bx2-2, midY); ctx.lineTo(bx2-10, midY+4)
                        ctx.fill()

                        // 2 staggered dots per segment
                        var cr = boxes[i].r, cg = boxes[i].g, cb2 = boxes[i].b
                        for (var d = 0; d < 2; d++) {
                            var p = (scrollRoot.pipelineDot + d * 0.5) % 1.0
                            var dx = ax + 4 + p * (segLen - 8)
                            // glow ring
                            ctx.fillStyle = "rgba("+cr+","+cg+","+cb2+",0.2)"
                            ctx.beginPath(); ctx.arc(dx, midY, 6, 0, Math.PI*2); ctx.fill()
                            // core
                            ctx.fillStyle = "rgba("+cr+","+cg+","+cb2+",0.9)"
                            ctx.beginPath(); ctx.arc(dx, midY, 3, 0, Math.PI*2); ctx.fill()
                        }
                    }

                    // draw boxes
                    for (var bi = 0; bi < 4; bi++) {
                        var box = boxes[bi]
                        var isActive = (bi === scrollRoot.activeStep)
                        var by = midY - bh/2
                        var r2 = box.r, g2 = box.g, b3 = box.b

                        ctx.fillStyle = isActive
                            ? "rgba("+r2+","+g2+","+b3+",0.20)"
                            : "rgba("+r2+","+g2+","+b3+",0.07)"
                        ctx.strokeStyle = isActive
                            ? box.hex
                            : "rgba("+r2+","+g2+","+b3+",0.38)"
                        ctx.lineWidth = isActive ? 2 : 1

                        // rounded rect
                        var rx2=box.x, ry=by, rw=bw, rh=bh, rad=9
                        ctx.beginPath()
                        ctx.moveTo(rx2+rad, ry)
                        ctx.lineTo(rx2+rw-rad, ry);     ctx.quadraticCurveTo(rx2+rw, ry,    rx2+rw, ry+rad)
                        ctx.lineTo(rx2+rw, ry+rh-rad);  ctx.quadraticCurveTo(rx2+rw, ry+rh, rx2+rw-rad, ry+rh)
                        ctx.lineTo(rx2+rad, ry+rh);     ctx.quadraticCurveTo(rx2, ry+rh,    rx2, ry+rh-rad)
                        ctx.lineTo(rx2, ry+rad);         ctx.quadraticCurveTo(rx2, ry,       rx2+rad, ry)
                        ctx.closePath(); ctx.fill(); ctx.stroke()

                        ctx.fillStyle = isActive ? box.hex : "rgba("+r2+","+g2+","+b3+",0.75)"
                        ctx.font = "bold 10px 'Segoe UI'"
                        ctx.textAlign = "center"
                        ctx.fillText(box.label, box.x+bw/2, by+22)

                        ctx.fillStyle = "rgba(255,255,255,0.38)"
                        ctx.font = "9px 'Segoe UI'"
                        ctx.fillText(box.sub, box.x+bw/2, by+38)

                        if (isActive) {
                            ctx.fillStyle = box.hex
                            ctx.beginPath(); ctx.arc(box.x+bw/2, by+bh+8, 3, 0, Math.PI*2); ctx.fill()
                        }
                    }
                }
            }
        }

        // ═════════════════════════════════════════════════════════════
        // 3. INTERACTIVE STEP SELECTOR
        // ═════════════════════════════════════════════════════════════
        Rectangle {
            width: parent.width
            height: 90
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 14
            border.color: Qt.rgba(255, 255, 255, 0.05)

            Row {
                anchors.centerIn: parent
                width: parent.width - 20
                height: 70
                spacing: 6

                Repeater {
                    model: 4
                    delegate: Row {
                        spacing: 6

                        Rectangle {
                            id: stepCard
                            width: (parent.parent.width - 3*26 - 6*6) / 4
                            height: 70
                            radius: 10
                            color: scrollRoot.activeStep===index ? Qt.rgba(scrollRoot.stepR[index]/255,scrollRoot.stepG[index]/255,scrollRoot.stepB[index]/255,0.13) : (hov.containsMouse ? Qt.rgba(scrollRoot.stepR[index]/255,scrollRoot.stepG[index]/255,scrollRoot.stepB[index]/255,0.07) : Qt.rgba(255,255,255,0.03))
                            border.color: scrollRoot.activeStep===index ? scrollRoot.stepColors[index] : (hov.containsMouse ? Qt.rgba(scrollRoot.stepR[index]/255,scrollRoot.stepG[index]/255,scrollRoot.stepB[index]/255,0.5) : Qt.rgba(255,255,255,0.1))
                            border.width: scrollRoot.activeStep === index ? 1.5 : 1

                            scale: hov.containsMouse ? 1.04 : 1.0
                            Behavior on scale       { NumberAnimation { duration: 120 } }
                            Behavior on color       { ColorAnimation  { duration: 200 } }
                            Behavior on border.color { ColorAnimation { duration: 200 } }

                            Column {
                                anchors.centerIn: parent; spacing: 3
                                Text {
                                    text: scrollRoot.stepIcons[index]; font.pixelSize: 18
                                    anchors.horizontalCenter: parent
                                }
                                Text {
                                    text: scrollRoot.stepTitles[index]
                                    color: scrollRoot.activeStep === index ? scrollRoot.stepColors[index] : "#e2e8f0"
                                    font { bold: true; pixelSize: 9 }
                                    anchors.horizontalCenter: parent
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                                Text {
                                    text: ["Ring 3","a7 = ID","HW Trap","Handler"][index]
                                    color: Qt.rgba(255,255,255,0.35); font.pixelSize: 8
                                    anchors.horizontalCenter: parent
                                }
                            }

                            MouseArea {
                                id: hov; anchors.fill: parent
                                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: scrollRoot.activeStep = index
                            }
                        }

                        Canvas {
                            visible: index < 3
                            width: 26; height: 70
                            onAvailableChanged: if (available) requestPaint()
                            onPaint: {
                                var c = getContext("2d"); c.reset()
                                c.strokeStyle = "#374151"; c.lineWidth = 1.5
                                c.beginPath(); c.moveTo(3,35); c.lineTo(20,35); c.stroke()
                                c.fillStyle = "#374151"
                                c.beginPath(); c.moveTo(14,31); c.lineTo(23,35); c.lineTo(14,39); c.fill()
                            }
                        }
                    }
                }
            }
        }

        // ═════════════════════════════════════════════════════════════
        // 4. DETAIL PANEL — theory + code (with fade transition)
        // ═════════════════════════════════════════════════════════════
        Rectangle {
            id: detailPanel
            width: parent.width
            height: 320
            color: Qt.rgba(0, 0, 0, 0.25)
            radius: 14
            border.color: scrollRoot.stepColors[scrollRoot.activeStep]
            border.width: 1
            Behavior on border.color { ColorAnimation { duration: 300 } }

            // displayedStep updates AFTER fade-out so content flips cleanly
            property int displayedStep: 0

            Connections {
                target: scrollRoot
                function onActiveStepChanged() { contentFadeOut.start() }
            }

            SequentialAnimation {
                id: contentFadeOut
                NumberAnimation { target: detailContent; property: "opacity"; to: 0; duration: 110 }
                ScriptAction    { script: { detailPanel.displayedStep = scrollRoot.activeStep; contentFadeIn.start() } }
            }
            NumberAnimation {
                id: contentFadeIn
                target: detailContent; property: "opacity"; to: 1; duration: 160
            }

            Item {
                id: detailContent
                anchors.fill: parent; anchors.margins: 22; opacity: 1.0

                // LEFT: Theory (40%)
                Column {
                    id: theoryCol
                    width: parent.width * 0.40; height: parent.height; spacing: 12

                    Row {
                        spacing: 12
                        Text { text: scrollRoot.stepIcons[detailPanel.displayedStep]; font.pixelSize: 26 }
                        Column {
                            spacing: 2
                            Text {
                                text: scrollRoot.stepTitles[detailPanel.displayedStep]
                                color: scrollRoot.stepColors[detailPanel.displayedStep]
                                font { bold: true; pixelSize: 16; family: "Segoe UI" }
                            }
                            Text {
                                text: scrollRoot.stepSubtitles[detailPanel.displayedStep]
                                color: Qt.rgba(255, 255, 255, 0.5)
                                font { pixelSize: 11; family: "Segoe UI" }
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.08) }

                    Text {
                        text: "THEORETICAL DEPTH"
                        color: scrollRoot.stepColors[detailPanel.displayedStep]
                        font { bold: true; pixelSize: 11; letterSpacing: 0.8 }
                    }

                    Text {
                        width: parent.width
                        text: scrollRoot.stepTheories[detailPanel.displayedStep]
                        color: Qt.rgba(255, 255, 255, 0.82)
                        wrapMode: Text.WordWrap
                        font { family: "Segoe UI"; pixelSize: 13 }
                        lineHeight: 1.55
                    }
                }

                // RIGHT: Code block
                Rectangle {
                    x: theoryCol.width + 22
                    width: parent.width - theoryCol.width - 22; height: parent.height
                    color: Qt.rgba(0, 0, 0, 0.55); radius: 10
                    border.color: Qt.rgba(255, 255, 255, 0.06); clip: true

                    Column {
                        anchors.fill: parent; anchors.margins: 16; spacing: 10

                        Row {
                            spacing: 6
                            Rectangle { width:10; height:10; radius:5; color:"#ef4444" }
                            Rectangle { width:10; height:10; radius:5; color:"#eab308" }
                            Rectangle { width:10; height:10; radius:5; color:"#10b981" }
                            Text {
                                text: "  " + scrollRoot.stepSources[detailPanel.displayedStep]
                                color: "#6b7280"; font { family: "Consolas"; pixelSize: 10 }
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.06) }

                        Flickable {
                            width: parent.width; height: parent.height - 40
                            contentWidth: codeText.implicitWidth; contentHeight: codeText.implicitHeight
                            clip: true
                            ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }

                            Text {
                                id: codeText
                                text: scrollRoot.stepCodes[detailPanel.displayedStep]
                                color: "#e2e8f0"; font { family: "Consolas"; pixelSize: 12 }
                                lineHeight: 1.7; wrapMode: Text.NoWrap
                            }
                        }
                    }
                }
            }
        }

        // ═════════════════════════════════════════════════════════════
        // 5. SYSCALL REFERENCE TABLE  (row hover highlight)
        // ═════════════════════════════════════════════════════════════
        Rectangle {
            width: parent.width
            height: tableInnerCol.implicitHeight + 32
            color: Qt.rgba(255, 255, 255, 0.02); radius: 14
            border.color: Qt.rgba(255, 255, 255, 0.06)

            Column {
                id: tableInnerCol
                anchors.top: parent.top
                anchors.topMargin: 16
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                spacing: 8

                Text {
                    text: "QUICK REFERENCE — COMMON xv6 SYSTEM CALLS"
                    color: "#c084fc"; font { bold: true; pixelSize: 11; letterSpacing: 0.8 }
                }

                Row {
                    width: parent.width; height: 24; spacing: 2
                    Rectangle { width:42;  height:24; color:Qt.rgba(139,92,246,0.15); radius:3; Text{text:"#"; color:"#a78bfa"; font.bold:true; font.pixelSize:9; anchors.centerIn:parent} }
                    Rectangle { width:110; height:24; color:Qt.rgba(139,92,246,0.15); radius:3; Text{text:"SYSCALL"; color:"#a78bfa"; font.bold:true; font.pixelSize:9; anchors.centerIn:parent} }
                    Rectangle { width:160; height:24; color:Qt.rgba(139,92,246,0.15); radius:3; Text{text:"KERNEL HANDLER"; color:"#a78bfa"; font.bold:true; font.pixelSize:9; anchors.centerIn:parent} }
                    Rectangle { width:parent.width-42-110-160-6; height:24; color:Qt.rgba(139,92,246,0.15); radius:3; Text{text:"PURPOSE"; color:"#a78bfa"; font.bold:true; font.pixelSize:9; anchors.left:parent.left; anchors.leftMargin:10; anchors.verticalCenter:parent.verticalCenter} }
                }

                Repeater {
                    model: scrollRoot.tableNums.length
                    delegate: Rectangle {
                        width: parent.width; height: 26; radius: 4
                        color: scrollRoot.hoveredRow === index
                               ? Qt.rgba(139,92,246,0.12)
                               : index%2===0 ? Qt.rgba(255,255,255,0.02) : Qt.rgba(255,255,255,0.04)
                        Behavior on color { ColorAnimation { duration: 120 } }

                        MouseArea {
                            anchors.fill: parent; hoverEnabled: true
                            onEntered: scrollRoot.hoveredRow = index
                            onExited:  scrollRoot.hoveredRow = -1
                        }

                        Row {
                            anchors.fill: parent; spacing: 2
                            Rectangle { width:42;  height:26; color:"transparent"; Text{text:scrollRoot.tableNums[index];    color:"#fbbf24"; font.family:"Consolas"; font.pixelSize:11; anchors.centerIn:parent} }
                            Rectangle { width:110; height:26; color:"transparent"; Text{text:scrollRoot.tableNames[index];   color:"#a78bfa"; font.family:"Consolas"; font.pixelSize:11; anchors.centerIn:parent} }
                            Rectangle { width:160; height:26; color:"transparent"; Text{text:scrollRoot.tableHandlers[index];color:"#6b7280"; font.family:"Consolas"; font.pixelSize:11; anchors.centerIn:parent} }
                            Rectangle { width:parent.width-42-110-160-6; height:26; color:"transparent"
                                Text{text:scrollRoot.tablePurposes[index]; color:Qt.rgba(255,255,255,0.62); font.pixelSize:11;
                                     anchors.left:parent.left; anchors.leftMargin:10; anchors.verticalCenter:parent.verticalCenter;
                                     elide:Text.ElideRight; width:parent.width-10} }
                        }
                    }
                }
            }
        }

        // ═════════════════════════════════════════════════════════════
        // 6. TAKEAWAY FOOTER
        // ═════════════════════════════════════════════════════════════

        // ── SCAUSE DECODER + SYSCALL EXPLORER ─────────────────────────────
        Rectangle {
            id: scauseSim
            width:parent.width; height:decoderCol.implicitHeight+32
            color:Qt.rgba(255,255,255,0.015); radius:14
            border.color:Qt.rgba(167,139,250,0.2); border.width:1

            property int scauseVal: 8
            property int syscallNum: 0
            property var causes: [
                {val:8,  label:"8 — Environment Call (U-mode)", desc:"User process executed 'ecall'. This is a System Call. Kernel reads a7 for syscall number, dispatches to handler.", color:"#a78bfa"},
                {val:9,  label:"9 — Environment Call (S-mode)", desc:"Supervisor mode executed 'ecall'. Used for machine-level operations. Rare in xv6.", color:"#a78bfa"},
                {val:12, label:"12 — Instruction Page Fault", desc:"CPU tried to fetch an instruction from an unmapped page. Likely null pointer or corrupted PC. Kernel kills the process.", color:"#f43f5e"},
                {val:13, label:"13 — Load Page Fault", desc:"Read from an unmapped or protected virtual address. sval register holds the faulting VA. Results in process termination.", color:"#f43f5e"},
                {val:15, label:"15 — Store Page Fault", desc:"Write to an unmapped or read-only virtual address. Copy-on-write systems handle this; xv6 does not — process is killed.", color:"#f43f5e"},
                {val:2,  label:"2 — Illegal Instruction", desc:"CPU decoded an invalid opcode, or tried a privileged instruction in U-mode (e.g. csrw from user code). Process killed.", color:"#fbbf24"},
                {val:0x80000001, label:"0x80000001 — Timer Interrupt", desc:"Timer interrupt fired. sstatus.SIE was set. This triggers yield() → Round-Robin preemption. scause high bit=1 means Interrupt.", color:"#10b981"},
                {val:0x80000009, label:"0x80000009 — External Interrupt", desc:"External device (UART, VIRTIO disk) raised an interrupt via PLIC. Kernel reads PLIC claim register to find which device.", color:"#06b6d4"}
            ]

            Column {
                id:decoderCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing:14

                Row { spacing:10
                    Text { text:"🔍"; font.pixelSize:18; anchors.verticalCenter:parent.verticalCenter }
                    Column { spacing:2
                        Text { text:"SCAUSE REGISTER DECODER — click any trap cause to decode it"; color:"#a78bfa"; font.bold:true; font.pixelSize:13 }
                        Text { text:"The scause register tells the kernel WHY the trap fired. Interrupt=1 in high bit, exception code in low bits."; color:Qt.rgba(255,255,255,0.32); font.pixelSize:11 }
                    }
                }

                // Cause pills
                Flow { width:parent.width; spacing:6
                    Repeater {
                        model: scauseSim.causes.length
                        delegate: Rectangle {
                            property var c: scauseSim.causes[index]
                            property bool active: scauseSim.scauseVal === c.val
                            height:30; width:causeText.implicitWidth+20; radius:8
                            color:active?Qt.rgba(167/255,139/255,250/255,0.2):Qt.rgba(255,255,255,0.04)
                            border.color:active?c.color:Qt.rgba(255,255,255,0.1); border.width:active?1.5:1
                            Behavior on color{ColorAnimation{duration:100}}
                            Text { id:causeText; anchors.centerIn:parent; text:c.label; color:active?c.color:Qt.rgba(255,255,255,0.4); font.pixelSize:10; font.bold:active; font.family:"Consolas" }
                            MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor
                                onClicked: scauseSim.scauseVal = c.val
                            }
                        }
                    }
                }

                // Decode result
                Rectangle {
                    width:parent.width; height:decodeResult.implicitHeight+24; radius:10
                    color:Qt.rgba(167/255,139/255,250/255,0.07); border.color:Qt.rgba(167/255,139/255,250/255,0.3); border.width:1
                    Column {
                        id:decodeResult
                        anchors.top:parent.top; anchors.topMargin:12
                        anchors.left:parent.left; anchors.leftMargin:16
                        anchors.right:parent.right; anchors.rightMargin:16
                        spacing:6
                        Row { spacing:12
                            Text { text:"scause ="; color:Qt.rgba(255,255,255,0.35); font.pixelSize:11; font.family:"Consolas"; anchors.verticalCenter:parent.verticalCenter }
                            Text {
                                text: {
                                    var v = scauseSim.scauseVal
                                    var found = null
                                    for(var i=0;i<scauseSim.causes.length;i++) if(scauseSim.causes[i].val===v){found=scauseSim.causes[i];break}
                                    return found ? found.label : v.toString()
                                }
                                color:"#a78bfa"; font.pixelSize:13; font.bold:true; font.family:"Consolas"; anchors.verticalCenter:parent.verticalCenter
                            }
                        }
                        Text {
                            width:parent.width
                            text: {
                                var v = scauseSim.scauseVal
                                for(var i=0;i<scauseSim.causes.length;i++) if(scauseSim.causes[i].val===v) return scauseSim.causes[i].desc
                                return "Unknown cause"
                            }
                            color:Qt.rgba(255,255,255,0.72); font.pixelSize:11; wrapMode:Text.WordWrap; lineHeight:1.55
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width; height: 65
            color: Qt.rgba(139, 92, 246, 0.08); radius: 14
            border.color: Qt.rgba(139, 92, 246, 0.35); border.width: 1

            RowLayout {
                anchors.fill: parent; anchors.margins: 15; spacing: 15
                Text { text: "🌟"; font.pixelSize: 22; Layout.alignment: Qt.AlignVCenter }
                Text {
                    Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter
                    text: "CORE SUMMARY: System Calls are the only legal bridge between User Space and the Kernel. Every I/O, process, or file operation passes through: ecall → uservec trap handler → syscall dispatcher → kernel function → sret back to User Mode."
                    color: "#ffffff"; wrapMode: Text.WordWrap
                    font { family: "Segoe UI"; bold: true; pixelSize: 12; letterSpacing: 0.2 }
                }
            }
        }


    } // end mainColumn
}
