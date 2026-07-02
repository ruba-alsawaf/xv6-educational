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

    // ── Active step & hover ──────────────────────────────────────────
    property int activeStep: 0
    property int hoveredStep: -1
    property int hoveredRow: -1

    // ── Fork canvas animation progress (0.0 → 1.0 loop) ─────────────
    property real forkDot: 0.0

    // ── Step data (5 steps) ──────────────────────────────────────────
    property var stepColors:    ["#a78bfa", "#fbbf24", "#f43f5e", "#10b981", "#60a5fa"]
    property var stepR:         [167, 251, 244, 16,  96]
    property var stepG:         [139, 191,  63, 185, 165]
    property var stepB:         [250,  36,  94, 129, 250]
    property var stepIcons:     ["💻", "📋", "⚡", "🔱", "🔄"]
    property var stepTitles:    ["PROCESS", "FORK CALL", "KERNEL DUP", "RETURN VAL", "EXEC/WAIT"]
    property var stepSubtitles: [
        "A living program in memory",
        "fork() fires the ecall trap",
        "OS duplicates the PCB",
        "Parent ≠ Child return value",
        "What comes after fork()"
    ]
    property var stepTheories: [
        "A Process is a program in execution — it is NOT just the binary file on disk. When you run 'sh', the OS creates a living Process Control Block (PCB) with a unique PID, private virtual memory (code, stack, heap), a register snapshot (trapframe), and open file descriptors. In xv6 the OS tracks every process in the global proc[] array in kernel/proc.c with room for NPROC=64 concurrent processes.",
        "fork() is System Call #1 (SYS_fork). The user process executes 'ecall' which fires an atomic trap into the kernel — privilege switches from U-mode to S-mode, PC jumps to the trap handler (uservec), and the kernel's sys_fork() is called. It allocates a fresh proc slot from the free list using allocproc(), and begins duplicating the caller's state. The calling parent does NOT pause — both will be scheduled after the clone is made.",
        "The kernel performs a full deep copy of the parent's virtual address space using uvmcopy(). Every mapped page in user memory is physically copied byte-for-byte into new page table entries. The child's trapframe is then set to be identical to the parent's — except trapframe→a0 is set to 0 (this will be the child's fork() return value). Finally the child's state is set to RUNNABLE and it joins the scheduler queue.",
        "After fork() completes, BOTH the parent AND the child resume running from the exact same next instruction — the line right after fork(). How do they know who they are? fork() returns DIFFERENT values to each: it returns 0 to the child (child knows it is child), it returns the child's PID to the parent (parent knows who the child is), and it returns -1 on failure (no free proc slots). A single if(pid==0) check is all that separates their execution paths.",
        "fork() alone only clones the process — the child runs the same code as the parent. To run a completely different program, exec() is called immediately after fork() in the child. exec() replaces the process's entire memory image by loading a new binary from disk. The parent meanwhile calls wait() which blocks until the child exits, then reaps the zombie process entry and collects the exit status code. The fork→exec→wait sequence is the foundation of every Unix shell."
    ]
    property var stepCodes: [
        "// kernel/proc.h — Process Control Block\nstruct proc {\n    uint64        sz;        // Memory size in bytes\n    pagetable_t   pagetable; // User-mode page table\n    struct trapframe *trapframe; // Saved registers\n    struct context    context;   // Kernel context switch\n    int           pid;       // Process ID (unique)\n    enum procstate state;    // UNUSED/EMBRYO/SLEEPING\n    //             RUNNABLE/RUNNING/ZOMBIE\n    struct proc  *parent;    // Pointer to parent proc\n    int           killed;    // Set to 1 on kill signal\n    struct file  *ofile[NOFILE]; // Open file table\n    struct inode *cwd;       // Current working directory\n    char          name[16];  // Process name (debug)\n};",
        "// kernel/sysproc.c — syscall dispatch\nuint64 sys_fork(void) {\n    return fork();\n}\n\n// kernel/proc.c — fork() entry\nint fork(void) {\n    struct proc *np;           // new (child) process\n    struct proc *p = myproc(); // current (parent)\n\n    // Step 1: get a free proc slot + init kernel stack\n    if((np = allocproc()) == 0)\n        return -1; // no free slots — NPROC limit hit\n\n    // Step 2: copy user memory pages\n    if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {\n        freeproc(np);\n        return -1;\n    }\n    np->sz = p->sz; // child same size as parent",
        "    // Step 3: copy the saved register state\n    *(np->trapframe) = *(p->trapframe);\n\n    // KEY: child's fork() return value = 0\n    np->trapframe->a0 = 0;\n\n    // Step 4: duplicate open file descriptors\n    for(int i = 0; i < NOFILE; i++)\n        if(p->ofile[i])\n            np->ofile[i] = filedup(p->ofile[i]);\n    np->cwd = idup(p->cwd);\n\n    // Step 5: set name, parent pointer, new PID\n    safestrcpy(np->name, p->name, sizeof(p->name));\n    int pid = np->pid;\n    np->parent = p;\n\n    // Step 6: mark runnable → enters scheduler\n    np->state = RUNNABLE;\n\n    return pid; // parent gets child's PID",
        "// user/forktest.c — canonical fork() pattern\nint pid = fork();\n\nif(pid < 0) {\n    // Error: no free proc slots (NPROC reached)\n    fprintf(2, \"fork failed\\n\");\n    exit(1);\n}\n\nif(pid == 0) {\n    // ── CHILD branch ──────────────────────────\n    // fork() placed 0 in trapframe->a0 for us\n    printf(\"child: my pid=%d\\n\", getpid());\n    exit(0); // child exits; becomes ZOMBIE\n}\n\n// ── PARENT branch ─────────────────────────────\n// fork() returned child's real PID here\nprintf(\"parent: child pid=%d\\n\", pid);\nwait(0); // reap zombie, free proc slot",
        "// The fork + exec + wait pattern:\n// This is exactly what xv6's sh.c does\n// for every command the user types.\n\nint pid = fork();      // 1. Clone self\n\nif(pid == 0) {\n    // 2. Child: replace image with target program\n    char *argv[] = { \"ls\", \"-l\", 0 };\n    exec(\"/ls\", argv); // loads new binary\n    // exec() only returns on failure:\n    fprintf(2, \"exec failed\\n\");\n    exit(1);\n}\n\n// 3. Parent: wait for child to finish\nint wstatus;\nwait(&wstatus); // blocks until child exits\n// Child is now ZOMBIE → reaped → slot freed\nprintf(\"done, exit code %d\\n\", wstatus);"
    ]
    property var stepSources: [
        "kernel/proc.h",
        "kernel/proc.c + kernel/sysproc.c",
        "kernel/proc.c: fork() continued",
        "user/forktest.c",
        "user/sh.c — runcmd()"
    ]

    // ── Process state table ──────────────────────────────────────────
    property var stateNames:  ["UNUSED",    "EMBRYO",                    "SLEEPING",               "RUNNABLE",                 "RUNNING",              "ZOMBIE"]
    property var stateColors: ["#6b7280",   "#fbbf24",                   "#60a5fa",                "#a78bfa",                  "#10b981",              "#f43f5e"]
    property var stateDescs:  [
        "Free proc slot in proc[] pool — available for allocproc()",
        "Being initialized by allocproc() — kernel stack set up",
        "Blocked waiting for I/O, pipe, sleep(), or child exit",
        "Ready to run — in scheduler queue, waiting for CPU",
        "Currently executing on a CPU core — in kernel or user",
        "Called exit() but parent has not yet called wait() to reap"
    ]

    // ── Animation timer ──────────────────────────────────────────────
    Timer {
        interval: 20
        running: true
        repeat: true
        onTriggered: scrollRoot.forkDot = (scrollRoot.forkDot + 0.008) % 1.0
    }

    // ─────────────────────────────────────────────────────────────────
    Column {
        id: mainColumn
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        spacing: 25

        // ══════════════════════════════════════════════════════════════
        // 1. HEADER
        // ══════════════════════════════════════════════════════════════
        Rectangle {
            width: parent.width
            height: 95
            color: Qt.rgba(255, 255, 255, 0.03)
            radius: 14
            border.color: Qt.rgba(16, 185, 129, 0.25)
            border.width: 1

            layer.enabled: true
            layer.effect: Glow {
                radius: 10; samples: 17
                color: Qt.rgba(16, 185, 129, 0.12); spread: 0.1
            }

            Row {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 16

                // Lesson number badge
                Rectangle {
                    width: 52; height: 52; radius: 12
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(16, 185, 129, 0.15)
                    border.color: Qt.rgba(16, 185, 129, 0.4)
                    border.width: 1
                    Column {
                        anchors.centerIn: parent; spacing: 1
                        Text {
                            text: "02"
                            color: "#10b981"
                            font.bold: true
                            font.pixelSize: 20
                            font.family: "Consolas"
                            anchors.horizontalCenter: parent
                        }
                        Text {
                            text: "LESSON"
                            color: Qt.rgba(16, 185, 129, 0.5)
                            font.pixelSize: 7
                            font.letterSpacing: 1
                            anchors.horizontalCenter: parent
                        }
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6
                    Text {
                        text: "PROCESSES & FORK — HOW PROGRAMS ARE BORN"
                        color: "#ffffff"
                        font.family: "Segoe UI"
                        font.bold: true
                        font.pixelSize: 20
                        font.letterSpacing: 0.5
                    }
                    Text {
                        text: "Understand the Process Control Block (PCB), how fork() clones a process, and the parent/child lifecycle in xv6."
                        color: Qt.rgba(255, 255, 255, 0.55)
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                    }
                }
            }
        }

        // ══════════════════════════════════════════════════════════════
        // 2. LIVE FORK ANIMATION CANVAS
        // ══════════════════════════════════════════════════════════════
        Rectangle {
            width: parent.width
            height: 215
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 14
            border.color: Qt.rgba(16, 185, 129, 0.18)
            border.width: 1

            Text {
                text: "LIVE ANIMATION — fork() splits one process into two"
                color: Qt.rgba(16, 185, 129, 0.6)
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 0.8
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Canvas {
                id: forkCanvas
                anchors.fill: parent
                property real dot: scrollRoot.forkDot

                onDotChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    var w = width, h = height;
                    var cx = w / 2;
                    var t = dot;

                    // ── Faint grid ──────────────────────────────────────────
                    ctx.strokeStyle = "rgba(255,255,255,0.025)";
                    ctx.lineWidth = 1;
                    for(var gx = 0; gx < w; gx += 60) {
                        ctx.beginPath(); ctx.moveTo(gx, 0); ctx.lineTo(gx, h); ctx.stroke();
                    }

                    // ── Parent process box (always visible, pulsing border) ─
                    var pulse = 0.55 + 0.35 * Math.sin(t * Math.PI * 8);
                    ctx.lineWidth = 2;
                    ctx.beginPath();
                    roundRect(ctx, cx - 56, 28, 112, 48, 9);
                    ctx.strokeStyle = "rgba(139,92,246," + pulse + ")";
                    ctx.stroke();
                    ctx.fillStyle = "rgba(139,92,246,0.07)";
                    ctx.fill();
                    ctx.fillStyle = "#a78bfa";
                    ctx.font = "bold 11px Consolas";
                    ctx.textAlign = "center";
                    ctx.fillText("PARENT PROCESS", cx, 48);
                    ctx.fillStyle = "rgba(255,255,255,0.4)";
                    ctx.font = "9px Consolas";
                    ctx.fillText("sh  |  PID: 10", cx, 62);

                    // ── Vertical line grows down (phase 0 → 0.38) ──────────
                    var lineGrow = Math.min(1.0, t / 0.38);
                    ctx.strokeStyle = "rgba(139,92,246,0.6)";
                    ctx.lineWidth = 2;
                    ctx.beginPath();
                    ctx.moveTo(cx, 76);
                    ctx.lineTo(cx, 76 + lineGrow * 36);
                    ctx.stroke();

                    // fork() label appears on line
                    if(lineGrow > 0.25) {
                        var la = Math.min(1.0, (lineGrow - 0.25) / 0.25);
                        ctx.fillStyle = "rgba(251,191,36," + la + ")";
                        ctx.font = "bold 10px Consolas";
                        ctx.textAlign = "left";
                        ctx.fillText("fork()", cx + 6, 97);
                    }

                    // ── Split branches (phase 0.38 → 0.65) ─────────────────
                    var splitGrow = Math.max(0.0, Math.min(1.0, (t - 0.38) / 0.27));
                    if(splitGrow > 0) {
                        var lx = cx - 105 * splitGrow;
                        var rx = cx + 105 * splitGrow;
                        var sy = 112 + 28 * splitGrow;

                        ctx.lineWidth = 2;
                        ctx.strokeStyle = "rgba(139,92,246," + (0.3 + 0.5 * splitGrow) + ")";
                        ctx.beginPath();
                        ctx.moveTo(cx, 112);
                        ctx.bezierCurveTo(cx, 124, lx + 40, 122, lx, sy);
                        ctx.stroke();

                        ctx.strokeStyle = "rgba(16,185,129," + (0.3 + 0.6 * splitGrow) + ")";
                        ctx.beginPath();
                        ctx.moveTo(cx, 112);
                        ctx.bezierCurveTo(cx, 124, rx - 40, 122, rx, sy);
                        ctx.stroke();
                    }

                    // ── Child boxes fade in (phase 0.65 → 0.88) ────────────
                    var boxAlpha = Math.max(0.0, Math.min(1.0, (t - 0.65) / 0.23));
                    if(boxAlpha > 0) {
                        var ba = boxAlpha;

                        // Parent result box (left)
                        ctx.beginPath();
                        roundRect(ctx, cx - 152, 143, 94, 38, 8);
                        ctx.strokeStyle = "rgba(139,92,246," + ba + ")";
                        ctx.lineWidth = 1.5;
                        ctx.stroke();
                        ctx.fillStyle = "rgba(139,92,246," + (0.1 * ba) + ")";
                        ctx.fill();
                        ctx.fillStyle = "rgba(167,139,250," + ba + ")";
                        ctx.font = "bold 10px Consolas";
                        ctx.textAlign = "center";
                        ctx.fillText("PARENT", cx - 105, 159);
                        ctx.fillStyle = "rgba(255,255,255," + (0.5 * ba) + ")";
                        ctx.font = "9px Consolas";
                        ctx.fillText("returns child PID", cx - 105, 173);

                        // Child result box (right)
                        ctx.beginPath();
                        roundRect(ctx, cx + 58, 143, 94, 38, 8);
                        ctx.strokeStyle = "rgba(16,185,129," + ba + ")";
                        ctx.lineWidth = 1.5;
                        ctx.stroke();
                        ctx.fillStyle = "rgba(16,185,129," + (0.1 * ba) + ")";
                        ctx.fill();
                        ctx.fillStyle = "rgba(16,185,129," + ba + ")";
                        ctx.font = "bold 10px Consolas";
                        ctx.textAlign = "center";
                        ctx.fillText("CHILD", cx + 105, 159);
                        ctx.fillStyle = "rgba(255,255,255," + (0.5 * ba) + ")";
                        ctx.font = "9px Consolas";
                        ctx.fillText("returns 0", cx + 105, 173);
                    }
                }

                function roundRect(ctx, x, y, w, h, r) {
                    ctx.moveTo(x + r, y);
                    ctx.lineTo(x + w - r, y);
                    ctx.quadraticCurveTo(x + w, y, x + w, y + r);
                    ctx.lineTo(x + w, y + h - r);
                    ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
                    ctx.lineTo(x + r, y + h);
                    ctx.quadraticCurveTo(x, y + h, x, y + h - r);
                    ctx.lineTo(x, y + r);
                    ctx.quadraticCurveTo(x, y, x + r, y);
                    ctx.closePath();
                }
            }
        }

        // ══════════════════════════════════════════════════════════════
        // 3. STEP SELECTOR — 5 clickable phases
        // ══════════════════════════════════════════════════════════════
        Row {
            width: parent.width
            spacing: 8

            Repeater {
                model: scrollRoot.stepTitles.length
                delegate: Rectangle {
                    width: (parent.width - 32) / scrollRoot.stepTitles.length
                    height: 70
                    radius: 10
                    color: scrollRoot.activeStep === index ? Qt.rgba(scrollRoot.stepR[index], scrollRoot.stepG[index], scrollRoot.stepB[index], 0.18) : (scrollRoot.hoveredStep === index ? Qt.rgba(scrollRoot.stepR[index], scrollRoot.stepG[index], scrollRoot.stepB[index], 0.08) : Qt.rgba(255, 255, 255, 0.03))
                    border.color: scrollRoot.activeStep === index ? scrollRoot.stepColors[index] : Qt.rgba(255, 255, 255, 0.08)
                    border.width: scrollRoot.activeStep === index ? 1.5 : 1

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 5
                        Text {
                            text: scrollRoot.stepIcons[index]
                            font.pixelSize: 18
                            anchors.horizontalCenter: parent
                        }
                        Text {
                            text: scrollRoot.stepTitles[index]
                            color: scrollRoot.activeStep === index ? scrollRoot.stepColors[index] : Qt.rgba(255, 255, 255, 0.5)
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 0.4
                            anchors.horizontalCenter: parent
                        }
                        Text {
                            text: scrollRoot.stepSubtitles[index]
                            color: Qt.rgba(255, 255, 255, 0.3)
                            font.pixelSize: 8
                            anchors.horizontalCenter: parent
                            width: parent.parent.width - 8
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: scrollRoot.hoveredStep = index
                        onExited: scrollRoot.hoveredStep = -1
                        onClicked: scrollRoot.activeStep = index
                    }
                }
            }
        }

        // ══════════════════════════════════════════════════════════════
        // 4. DETAIL PANEL — theory + code for selected step
        // ══════════════════════════════════════════════════════════════
        Rectangle {
            id: detailPanel
            width: parent.width
            height: detailRow.implicitHeight + 36
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 14
            border.color: Qt.rgba(scrollRoot.stepR[scrollRoot.activeStep], scrollRoot.stepG[scrollRoot.activeStep], scrollRoot.stepB[scrollRoot.activeStep], 0.28)
            border.width: 1

            property int displayedStep: 0

            Behavior on opacity { NumberAnimation { duration: 180 } }

            SequentialAnimation {
                id: stepTransition
                running: false
                NumberAnimation { target: detailPanel; property: "opacity"; to: 0; duration: 110 }
                ScriptAction { script: detailPanel.displayedStep = scrollRoot.activeStep }
                NumberAnimation { target: detailPanel; property: "opacity"; to: 1; duration: 180 }
            }

            Connections {
                target: scrollRoot
                function onActiveStepChanged() { stepTransition.restart() }
            }

            Row {
                id: detailRow
                anchors.top: parent.top
                anchors.topMargin: 18
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.right: parent.right
                anchors.rightMargin: 18
                spacing: 16

                // ── Left: theory ─────────────────────────────────────
                Column {
                    width: (parent.width - 16) * 0.42
                    spacing: 12

                    Row {
                        spacing: 10
                        Text {
                            text: scrollRoot.stepIcons[detailPanel.displayedStep]
                            font.pixelSize: 22
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Column {
                            spacing: 3
                            Text {
                                text: scrollRoot.stepTitles[detailPanel.displayedStep]
                                color: scrollRoot.stepColors[detailPanel.displayedStep]
                                font.bold: true
                                font.pixelSize: 14
                                font.letterSpacing: 0.5
                            }
                            Text {
                                text: scrollRoot.stepSources[detailPanel.displayedStep]
                                color: Qt.rgba(255, 255, 255, 0.32)
                                font.pixelSize: 10
                                font.family: "Consolas"
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.06) }

                    Text {
                        width: parent.width
                        text: scrollRoot.stepTheories[detailPanel.displayedStep]
                        color: Qt.rgba(255, 255, 255, 0.78)
                        wrapMode: Text.WordWrap
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        lineHeight: 1.55
                    }
                }

                // ── Right: code block ────────────────────────────────
                Rectangle {
                    width: (parent.width - 16) * 0.58
                    height: codeText.implicitHeight + 36
                    color: Qt.rgba(0, 0, 0, 0.28)
                    radius: 10
                    border.color: Qt.rgba(255, 255, 255, 0.06)
                    border.width: 1

                    // Title bar
                    Rectangle {
                        id: codeBar
                        width: parent.width; height: 26
                        color: Qt.rgba(255, 255, 255, 0.04)
                        radius: 10
                        Rectangle {
                            width: parent.width; height: 13
                            anchors.bottom: parent.bottom
                            color: parent.color
                        }
                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 5
                            Repeater {
                                model: 3
                                delegate: Rectangle {
                                    width: 8; height: 8; radius: 4
                                    color: ["#f43f5e", "#fbbf24", "#10b981"][index]
                                    opacity: 0.7
                                }
                            }
                        }
                        Text {
                            text: scrollRoot.stepSources[detailPanel.displayedStep]
                            color: Qt.rgba(255, 255, 255, 0.28)
                            font.pixelSize: 9
                            font.family: "Consolas"
                            anchors.centerIn: parent
                        }
                    }

                    Text {
                        id: codeText
                        anchors.top: parent.top
                        anchors.topMargin: 32
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        text: scrollRoot.stepCodes[detailPanel.displayedStep]
                        color: Qt.rgba(255, 255, 255, 0.82)
                        font.family: "Consolas"
                        font.pixelSize: 11
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        lineHeight: 1.5
                    }
                }
            }
        }

        // ══════════════════════════════════════════════════════════════
        // 5. PROCESS STATE TABLE
        // ══════════════════════════════════════════════════════════════
        Rectangle {
            width: parent.width
            height: stateCol.implicitHeight + 32
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 14
            border.color: Qt.rgba(139, 92, 246, 0.15)
            border.width: 1

            Column {
                id: stateCol
                anchors.top: parent.top
                anchors.topMargin: 16
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                spacing: 6

                // Section label
                Row {
                    spacing: 8
                    Text { text: "⚙️"; font.pixelSize: 14 }
                    Text {
                        text: "PROCESS STATES — enum procstate in kernel/proc.h"
                        color: Qt.rgba(167, 139, 250, 0.7)
                        font.bold: true
                        font.pixelSize: 11
                        font.letterSpacing: 0.5
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Table header
                Row {
                    width: parent.width
                    spacing: 0
                    Rectangle {
                        width: 100; height: 24
                        color: Qt.rgba(139, 92, 246, 0.14)
                        Text { text: "STATE"; color: "#a78bfa"; font.bold: true; font.pixelSize: 10; font.letterSpacing: 0.8; anchors.centerIn: parent }
                    }
                    Rectangle {
                        width: 50; height: 24
                        color: Qt.rgba(139, 92, 246, 0.10)
                        Text { text: "VAL"; color: "#a78bfa"; font.bold: true; font.pixelSize: 10; anchors.centerIn: parent }
                    }
                    Rectangle {
                        width: parent.width - 150; height: 24
                        color: Qt.rgba(139, 92, 246, 0.08)
                        Text {
                            text: "DESCRIPTION"
                            color: "#a78bfa"
                            font.bold: true
                            font.pixelSize: 10
                            font.letterSpacing: 0.5
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.06) }

                Repeater {
                    model: scrollRoot.stateNames.length
                    delegate: Rectangle {
                        width: parent.width; height: 28; radius: 4
                        color: scrollRoot.hoveredRow === index ? Qt.rgba(139, 92, 246, 0.10) : (index % 2 === 0 ? Qt.rgba(255,255,255,0.02) : Qt.rgba(255,255,255,0.035))
                        Behavior on color { ColorAnimation { duration: 120 } }

                        MouseArea {
                            anchors.fill: parent; hoverEnabled: true
                            onEntered: scrollRoot.hoveredRow = index
                            onExited: scrollRoot.hoveredRow = -1
                        }

                        Row {
                            anchors.fill: parent; spacing: 0
                            Rectangle {
                                width: 100; height: parent.height; color: "transparent"
                                Text {
                                    text: scrollRoot.stateNames[index]
                                    color: scrollRoot.stateColors[index]
                                    font.family: "Consolas"
                                    font.pixelSize: 11
                                    font.bold: true
                                    anchors.centerIn: parent
                                }
                            }
                            Rectangle {
                                width: 50; height: parent.height; color: "transparent"
                                Text {
                                    text: index.toString()
                                    color: Qt.rgba(255, 255, 255, 0.3)
                                    font.family: "Consolas"
                                    font.pixelSize: 11
                                    anchors.centerIn: parent
                                }
                            }
                            Rectangle {
                                width: parent.width - 150; height: parent.height; color: "transparent"
                                Text {
                                    text: scrollRoot.stateDescs[index]
                                    color: Qt.rgba(255, 255, 255, 0.62)
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    width: parent.width - 10
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }
        }

        // ══════════════════════════════════════════════════════════════
        // 6. TAKEAWAY FOOTER
        // ══════════════════════════════════════════════════════════════
        Rectangle {
            width: parent.width; height: 65
            color: Qt.rgba(16, 185, 129, 0.08); radius: 14
            border.color: Qt.rgba(16, 185, 129, 0.35); border.width: 1

            RowLayout {
                anchors.fill: parent; anchors.margins: 15; spacing: 15
                Text { text: "🌟"; font.pixelSize: 22; Layout.alignment: Qt.AlignVCenter }
                Text {
                    Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter
                    text: "CORE SUMMARY: A Process is a PCB struct (pid, pagetable, trapframe, state). fork() deep-copies the parent's address space, sets child's trapframe→a0=0, marks it RUNNABLE. Both resume at the same instruction but fork() returns 0 to child and child-PID to parent. exec() then replaces the child's image; wait() reaps the zombie."
                    color: "#ffffff"; wrapMode: Text.WordWrap
                    font.family: "Segoe UI"
                    font.bold: true
                    font.pixelSize: 12
                    font.letterSpacing: 0.2
                }
            }
        }

    } // end mainColumn
}
