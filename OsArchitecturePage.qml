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

    // ── Navigation signal — emit to open a live dashboard page ──────
    signal requestNavigate(string pageSource)

    // ── Active step & hover ──────────────────────────────────────────
    property int activeStep: 0
    property int hoveredStep: -1
    property int hoveredRow: -1
    property int hoveredCard: -1

    // ── Layer animation progress (0.0 → 1.0 loop) ───────────────────
    property real layerDot: 0.0

    // ── Step data (5 steps) ──────────────────────────────────────────
    property var stepColors:    ["#fbbf24", "#a78bfa", "#10b981", "#60a5fa", "#f43f5e"]
    property var stepR:         [251, 167, 16,  96,  244]
    property var stepG:         [191, 139, 185, 165, 63]
    property var stepB:         [36,  250, 129, 250, 94]
    property var stepIcons:     ["🏗️", "⚡", "🛡️", "📂", "🔗"]
    property var stepTitles:    ["OS LAYERS", "MONOLITHIC", "MICROKERNEL", "xv6 SOURCE", "INTERACTION"]
    property var stepSubtitles: [
        "The 5-layer stack model",
        "Everything in kernel space",
        "Services in user space",
        "Kernel directory layout",
        "How layers talk to each other"
    ]
    property var stepTheories: [
        "A modern OS is organised as a vertical stack of five layers, each only permitted to communicate with its immediate neighbours. From top to bottom: (1) User Applications run in restricted U-mode with no hardware access. (2) The System Call Interface (ecall/sret boundary) is the single controlled gateway between user and kernel. (3) The Kernel manages processes, memory, file systems, and devices — all in Supervisor Mode. (4) The Hardware Abstraction Layer (HAL) wraps raw device differences behind a uniform driver API. (5) Raw Hardware: the RISC-V CPU, DRAM, UART, virtio-disk, and PLIC interrupt controller.",
        "In a Monolithic kernel (xv6, Linux, FreeBSD), ALL subsystems — process scheduler, virtual memory, file system, device drivers — are compiled into ONE large binary that runs entirely in Supervisor Mode. Subsystems communicate via direct C function calls: `sched()` calls `proc.c` which calls `vm.c` which calls `fs.c` directly. No context switches, no message copying. This makes monolithic kernels extremely fast. The downside: a single NULL pointer anywhere in the kernel triggers a panic that kills the entire system.",
        "A Microkernel (MINIX3, L4, QNX, early macOS XNU) keeps only the absolute minimum in kernel space: IPC message passing, basic CPU scheduling, and address space management. All other services — file system server, device drivers, network stack — run as UNPRIVILEGED user-space processes. If the disk driver crashes, the OS simply restarts that one process. The system survives. The cost: every cross-service call requires two full kernel boundary crossings (IPC send + receive), making microkernels significantly slower than monolithic designs for I/O-heavy workloads.",
        "xv6's entire kernel lives in the `kernel/` directory and compiles to a single ~150 KB ELF binary. The key source files are: `main.c` (boot + initialization), `proc.c` (fork/exit/wait/scheduler), `vm.c` (page tables, uvmcopy, mappages), `kalloc.c` (physical memory free-list), `trap.c` + `trampoline.S` (syscall entry/return), `syscall.c` (dispatch table), `fs.c` (inodes, directories, paths), `bio.c` (block buffer cache), `virtio_disk.c` (disk driver), `uart.c` (console), `pipe.c` (anonymous pipes), `spinlock.c` + `sleeplock.c` (kernel synchronization).",
        "A system call traverses the full layer stack. Outbound: user C code → `usys.S` stub loads syscall# into a7 → `ecall` fires hardware trap → CPU jumps to `stvec` → `uservec` in `trampoline.S` saves 32 registers into trapframe → `usertrap()` in `trap.c` identifies cause → `syscall()` reads a7 → dispatches to handler (e.g. `sys_write`) → handler calls into `fs.c` / `bio.c` / `virtio_disk.c`. Return path: handler stores result in `trapframe→a0` → `usertrapret()` restores registers → `sret` restores U-mode and jumps to `sepc`. Total depth: ~12 function calls, ~4 kernel-user boundary crossings."
    ]
    property var stepCodes: [
        "// The 5-layer OS model — simplified view\n//\n// ┌─────────────────────────────────────────┐ ← U-MODE\n// │  USER APPLICATIONS                      │\n// │  sh, cat, echo, forktest, ls ...        │\n// ├─────────────────────────────────────────┤ ← ecall / sret\n// │  SYSTEM CALL INTERFACE                  │\n// │  (the only legal gateway)               │\n// ├────────────────────────────────────────┐│\n// │  KERNEL (Supervisor Mode)              ││ ← S-MODE\n// │  ┌──────────┬──────────┬─────────────┐ ││\n// │  │ Process  │ Memory   │ File System │ ││\n// │  │ proc.c   │ vm.c     │ fs.c/bio.c  │ ││\n// │  └──────────┴──────────┴─────────────┘ ││\n// │   Device Drivers: uart.c, virtio_disk.c ││\n// ├────────────────────────────────────────┘│\n// │  HARDWARE ABSTRACTION LAYER (HAL)        │\n// ├─────────────────────────────────────────┤\n// │  RAW HARDWARE (CPU, DRAM, DISK, UART)   │ ← M-MODE\n// └─────────────────────────────────────────┘",
        "// kernel/main.c — monolithic boot\n// All subsystems init in ONE function:\nvoid main() {\n    kinit();          // physical page allocator\n    kvminit();        // kernel page table\n    kvminithart();    // enable paging (satp)\n    procinit();       // process table\n    trapinit();       // trap vectors (stvec)\n    trapinithart();   // per-core trap init\n    plicinit();       // interrupt controller\n    plicinithart();   // per-core PLIC\n    binit();          // block buffer cache\n    iinit();          // inode table\n    fileinit();       // file table\n    virtio_disk_init(); // disk driver\n    userinit();       // PID 1 (/init)\n    scheduler();      // run forever\n}\n// Everything in ONE address space → direct calls",
        "// Microkernel architecture (MINIX3 style)\n//\n// KERNEL (minimal):\n//   → IPC send/receive\n//   → CPU scheduling\n//   → Address space management\n//\n// USER-SPACE SERVERS (unprivileged):\n//   process manager  (fork/exec/exit)\n//   VFS server       (open/read/write/close)\n//   disk driver      (block I/O via IPC)\n//   network server   (TCP/IP via IPC)\n//   tty server       (console input)\n//\n// System call path in microkernel:\n//   app → IPC to VFS server\n//   VFS server → IPC to disk driver\n//   disk driver → IPC to kernel HAL\n//   ← response propagates back\n// Result: 4 context switches per read()\n// vs. xv6 monolithic: 1 context switch",
        "// kernel/ — full xv6 kernel directory\n// All compiled into: kernel/kernel (ELF)\n\nmain.c         // boot, subsystem init\nproc.h/proc.c  // PCB, fork, exit, scheduler\nvm.c           // page tables, uvmcopy\nkalloc.c       // physical page free-list\ntrap.c         // usertrap() / kerneltrap()\ntrampoline.S   // uservec, userret (asm)\nsyscall.h/c    // dispatch table [NSYSCALL]\nfs.h/fs.c      // inode, dirent, log layer\nbio.c          // block buffer cache (30 bufs)\nvirtio_disk.c  // VirtIO block device driver\nuart.c         // RISC-V UART (console I/O)\npipe.c         // anonymous pipe (512-byte buf)\nspinlock.c     // test-and-set spin lock\nsleeplock.c    // blocking sleep lock\nfile.h/file.c  // file descriptor table\nriscv.h        // CSR macros, sv39 defs\ndefs.h         // forward declarations\n// Total: ~8,000 lines of C + 300 lines ASM",
        "// kernel/trap.c — full syscall path\nvoid usertrap(void) {\n    // Called from trampoline.S after ecall\n    // We are now in Supervisor Mode\n    struct proc *p = myproc();\n\n    // Identify trap cause\n    if(r_scause() == 8) {\n        // Environment call from U-mode\n        if(killed(p)) exit(-1);\n        p->trapframe->epc += 4; // skip ecall\n        intr_on();              // re-enable irqs\n        syscall();              // dispatch a7\n    } else if((which_dev = devintr()) != 0) {\n        // Timer / device interrupt\n    } else {\n        // Illegal instruction / page fault\n        setkilled(p);\n    }\n\n    usertrapret(); // restore regs, sret\n}\n// kernel/syscall.c dispatches a7 →\n// sys_read → fs.c → bio.c → virtio_disk.c"
    ]
    property var stepSources: [
        "OS Architecture — layer model",
        "kernel/main.c",
        "MINIX3 / L4 microkernel design",
        "kernel/ directory — xv6 source tree",
        "kernel/trap.c + kernel/syscall.c"
    ]

    // ── Comparison table ─────────────────────────────────────────────
    property var cmpFeatures: ["Subsystem location", "Inter-subsystem calls", "Performance (I/O)", "Crash impact", "xv6 verdict", "Real examples"]
    property var cmpMono:     ["Kernel space (S-mode)", "Direct C function call", "⚡ Fast — no IPC", "One bug → full panic", "✓ Monolithic", "Linux, xv6, FreeBSD, BSD"]
    property var cmpMicro:    ["User space (U-mode srv)", "IPC message passing", "🐢 Slower — 4× ctxsw", "Server crash → restart only", "— Microkernel", "MINIX3, L4, QNX, Plan9"]

    // ── Live demo reference cards ────────────────────────────────────
    property var liveNames:  ["CPU SCHEDULING", "MEMORY MANAGEMENT", "FILE SYSTEM"]
    property var liveIcons:  ["⚙️", "💾", "📁"]
    property var liveDescs:  [
        "Watch the real-time process scheduler — see running, sleeping and zombie processes with their PIDs and states.",
        "Explore live page tables, free frame counts and memory allocation as the OS manages virtual address spaces.",
        "Browse inodes, directory entries and block allocations in the live xv6 file system — data as it really sits on disk."
    ]
    property var livePages:  ["CpuSchedulingPage.qml", "MemoryManagementPage.qml", "FileSystemLessonPage.qml"]
    property var liveColors: ["#a78bfa", "#10b981", "#fbbf24"]
    property var liveR:      [167, 16,  251]
    property var liveG:      [139, 185, 191]
    property var liveB:      [250, 129, 36]

    // ── Animation timer ──────────────────────────────────────────────
    Timer {
        interval: 20
        running: true
        repeat: true
        onTriggered: scrollRoot.layerDot = (scrollRoot.layerDot + 0.007) % 1.0
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
            border.color: Qt.rgba(251, 191, 36, 0.25)
            border.width: 1

            layer.enabled: true
            layer.effect: Glow {
                radius: 10; samples: 17
                color: Qt.rgba(251, 191, 36, 0.12); spread: 0.1
            }

            Row {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 16

                Rectangle {
                    width: 52; height: 52; radius: 12
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(251, 191, 36, 0.15)
                    border.color: Qt.rgba(251, 191, 36, 0.4)
                    border.width: 1
                    Column {
                        anchors.centerIn: parent; spacing: 1
                        Text {
                            text: "03"
                            color: "#fbbf24"
                            font.bold: true
                            font.pixelSize: 20
                            font.family: "Consolas"
                            anchors.horizontalCenter: parent
                        }
                        Text {
                            text: "LESSON"
                            color: Qt.rgba(251, 191, 36, 0.5)
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
                        text: "OS ARCHITECTURE — MONOLITHIC vs. MICROKERNEL"
                        color: "#ffffff"
                        font.family: "Segoe UI"
                        font.bold: true
                        font.pixelSize: 20
                        font.letterSpacing: 0.5
                    }
                    Text {
                        text: "Understand the 5-layer OS model, why xv6 uses a Monolithic design, and how each layer interacts through system calls."
                        color: Qt.rgba(255, 255, 255, 0.55)
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                    }
                }
            }
        }

        // ══════════════════════════════════════════════════════════════
        // 2. ANIMATED OS LAYER STACK CANVAS
        // ══════════════════════════════════════════════════════════════
        Rectangle {
            width: parent.width
            height: 258
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 14
            border.color: Qt.rgba(251, 191, 36, 0.15)
            border.width: 1

            Text {
                text: "LIVE ANIMATION — syscall request travels through the OS layer stack"
                color: Qt.rgba(251, 191, 36, 0.6)
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 0.8
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Canvas {
                id: layerCanvas
                anchors.fill: parent
                property real dot: scrollRoot.layerDot

                onDotChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    var w = width, h = height;
                    var t = dot;

                    // ── 5 layer definitions ─────────────────────────────────
                    // [yCenter, halfH, r, g, b, label, sublabel]
                    var L = [
                        {yc:50,  hh:18, r:139, g:92,  b:246, lbl:"USER APPLICATIONS",        sub:"sh, cat, echo, forktest"},
                        {yc:88,  hh:13, r:251, g:191, b:36,  lbl:"SYSTEM CALL INTERFACE",    sub:"ecall / sret  (U→S boundary)"},
                        {yc:143, hh:38, r:244, g:63,  b:94,  lbl:"KERNEL  (Supervisor Mode)", sub:"proc · vm · fs · trap · bio"},
                        {yc:200, hh:13, r:96,  g:165, b:250, lbl:"HAL  (Hardware Abstraction)",sub:"virtio · uart · plic"},
                        {yc:232, hh:13, r:107, g:114, b:128, lbl:"RAW HARDWARE",              sub:"RISC-V CPU · DRAM · Disk"}
                    ];

                    // Active layer cycles with time
                    var activeL = Math.floor(t * 5) % 5;
                    var subT    = (t * 5) % 1.0;
                    var pulse   = 0.5 + 0.5 * Math.sin(subT * Math.PI * 2);

                    // ── Draw layers ─────────────────────────────────────────
                    for(var i = 0; i < 5; i++) {
                        var l = L[i];
                        var isActive = (i === activeL);
                        var alpha = isActive ? (0.35 + 0.35 * pulse) : 0.08;
                        var borderA = isActive ? (0.7 + 0.25 * pulse) : 0.22;

                        var lx = 14, lw = w - 28;
                        ctx.beginPath();
                        roundRect(ctx, lx, l.yc - l.hh, lw, l.hh * 2, 7);
                        ctx.fillStyle = "rgba(" + l.r + "," + l.g + "," + l.b + "," + alpha + ")";
                        ctx.fill();
                        ctx.strokeStyle = "rgba(" + l.r + "," + l.g + "," + l.b + "," + borderA + ")";
                        ctx.lineWidth = isActive ? 1.8 : 1;
                        ctx.stroke();

                        // Layer label
                        ctx.fillStyle = "rgba(" + l.r + "," + l.g + "," + l.b + "," + (isActive ? 1.0 : 0.65) + ")";
                        ctx.font = "bold 10px Consolas";
                        ctx.textAlign = "left";
                        ctx.fillText(l.lbl, lx + 14, l.yc + 4);

                        ctx.fillStyle = "rgba(255,255,255," + (isActive ? 0.45 : 0.22) + ")";
                        ctx.font = "9px Consolas";
                        var lblW = l.lbl.length * 6.4;
                        ctx.fillText(l.sub, lx + 14 + lblW + 12, l.yc + 4);
                    }

                    // ── Connecting arrows between layers ────────────────────
                    var arrowX = w * 0.78;
                    var arrowPairs = [[50+18, 88-13], [88+13, 143-38], [143+38, 200-13], [200+13, 232-13]];
                    for(var j = 0; j < arrowPairs.length; j++) {
                        var y1 = arrowPairs[j][0] + 2, y2 = arrowPairs[j][1] - 2;
                        var lyr = L[j];
                        ctx.strokeStyle = "rgba(" + lyr.r + "," + lyr.g + "," + lyr.b + ",0.3)";
                        ctx.lineWidth = 1.5;
                        ctx.beginPath(); ctx.moveTo(arrowX, y1); ctx.lineTo(arrowX, y2); ctx.stroke();
                        ctx.fillStyle = "rgba(" + lyr.r + "," + lyr.g + "," + lyr.b + ",0.3)";
                        ctx.beginPath(); ctx.moveTo(arrowX - 4, y2 - 5); ctx.lineTo(arrowX, y2); ctx.lineTo(arrowX + 4, y2 - 5); ctx.fill();
                    }

                    // ── Animated request dot ────────────────────────────────
                    // Travels down 0→0.5, back up 0.5→1.0
                    var goingDown = t < 0.5;
                    var halfT = goingDown ? (t * 2) : ((t - 0.5) * 2);
                    var topY = L[0].yc, botY = L[4].yc;
                    var dotY = goingDown ? (topY + halfT * (botY - topY)) : (botY - halfT * (botY - topY));

                    // Color by current layer
                    var dotLayer = 0;
                    for(var k = 0; k < 5; k++) {
                        if(dotY >= L[k].yc - L[k].hh) dotLayer = k;
                    }
                    var dl = L[dotLayer];
                    var dotX = w / 2;

                    // Trail
                    ctx.beginPath();
                    ctx.moveTo(dotX, goingDown ? topY : botY);
                    ctx.lineTo(dotX, dotY);
                    ctx.strokeStyle = "rgba(" + dl.r + "," + dl.g + "," + dl.b + ",0.25)";
                    ctx.lineWidth = 2;
                    ctx.stroke();

                    // Glow ring
                    ctx.beginPath();
                    ctx.arc(dotX, dotY, 9, 0, Math.PI * 2);
                    ctx.fillStyle = "rgba(" + dl.r + "," + dl.g + "," + dl.b + ",0.18)";
                    ctx.fill();

                    // Dot core
                    ctx.beginPath();
                    ctx.arc(dotX, dotY, 5, 0, Math.PI * 2);
                    ctx.fillStyle = "rgba(" + dl.r + "," + dl.g + "," + dl.b + ",1.0)";
                    ctx.fill();
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
        // 3. STEP SELECTOR — 5 clickable concepts
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
                            color: Qt.rgba(255, 255, 255, 0.28)
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

                // ── Left: theory ──────────────────────────────────────
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

                // ── Right: code block ─────────────────────────────────
                Rectangle {
                    width: (parent.width - 16) * 0.58
                    height: codeText.implicitHeight + 36
                    color: Qt.rgba(0, 0, 0, 0.28)
                    radius: 10
                    border.color: Qt.rgba(255, 255, 255, 0.06)
                    border.width: 1

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
        // 5. COMPARISON TABLE — Monolithic vs. Microkernel
        // ══════════════════════════════════════════════════════════════
        Rectangle {
            width: parent.width
            height: cmpCol.implicitHeight + 32
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 14
            border.color: Qt.rgba(255, 255, 255, 0.07)
            border.width: 1

            Column {
                id: cmpCol
                anchors.top: parent.top
                anchors.topMargin: 16
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                spacing: 6

                Row {
                    spacing: 8
                    Text { text: "⚖️"; font.pixelSize: 14 }
                    Text {
                        text: "DESIGN COMPARISON — Monolithic (xv6) vs. Microkernel"
                        color: Qt.rgba(251, 191, 36, 0.7)
                        font.bold: true
                        font.pixelSize: 11
                        font.letterSpacing: 0.5
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Header row
                Row {
                    width: parent.width
                    spacing: 0
                    Rectangle {
                        width: parent.width * 0.28; height: 24
                        color: Qt.rgba(251, 191, 36, 0.12)
                        Text { text: "FEATURE"; color: "#fbbf24"; font.bold: true; font.pixelSize: 10; font.letterSpacing: 0.6; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
                    }
                    Rectangle {
                        width: parent.width * 0.36; height: 24
                        color: Qt.rgba(139, 92, 246, 0.12)
                        Text { text: "MONOLITHIC  (xv6 ✓)"; color: "#a78bfa"; font.bold: true; font.pixelSize: 10; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
                    }
                    Rectangle {
                        width: parent.width * 0.36; height: 24
                        color: Qt.rgba(16, 185, 129, 0.10)
                        Text { text: "MICROKERNEL"; color: "#10b981"; font.bold: true; font.pixelSize: 10; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.06) }

                Repeater {
                    model: scrollRoot.cmpFeatures.length
                    delegate: Rectangle {
                        width: parent.width; height: 28; radius: 4
                        color: scrollRoot.hoveredRow === index ? Qt.rgba(251, 191, 36, 0.07) : (index % 2 === 0 ? Qt.rgba(255,255,255,0.02) : Qt.rgba(255,255,255,0.035))
                        Behavior on color { ColorAnimation { duration: 120 } }

                        MouseArea {
                            anchors.fill: parent; hoverEnabled: true
                            onEntered: scrollRoot.hoveredRow = index
                            onExited: scrollRoot.hoveredRow = -1
                        }

                        Row {
                            anchors.fill: parent; spacing: 0
                            Rectangle {
                                width: parent.width * 0.28; height: parent.height; color: "transparent"
                                Text {
                                    text: scrollRoot.cmpFeatures[index]
                                    color: "#fbbf24"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 11
                                    font.bold: true
                                    elide: Text.ElideRight
                                    width: parent.width - 10
                                    anchors.left: parent.left
                                    anchors.leftMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            Rectangle {
                                width: parent.width * 0.36; height: parent.height; color: "transparent"
                                Text {
                                    text: scrollRoot.cmpMono[index]
                                    color: Qt.rgba(167, 139, 250, 0.85)
                                    font.family: "Consolas"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    width: parent.width - 10
                                    anchors.left: parent.left
                                    anchors.leftMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            Rectangle {
                                width: parent.width * 0.36; height: parent.height; color: "transparent"
                                Text {
                                    text: scrollRoot.cmpMicro[index]
                                    color: Qt.rgba(16, 185, 129, 0.85)
                                    font.family: "Consolas"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    width: parent.width - 10
                                    anchors.left: parent.left
                                    anchors.leftMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }
        }

        // ══════════════════════════════════════════════════════════════
        // 6. LIVE DEMO REFERENCE CARDS
        // ══════════════════════════════════════════════════════════════
        Rectangle {
            width: parent.width
            height: liveSection.implicitHeight + 32
            color: Qt.rgba(255, 255, 255, 0.015)
            radius: 14
            border.color: Qt.rgba(255, 255, 255, 0.07)
            border.width: 1

            Column {
                id: liveSection
                anchors.top: parent.top
                anchors.topMargin: 16
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                spacing: 12

                Row {
                    spacing: 8
                    Rectangle {
                        width: 8; height: 8; radius: 4
                        color: "#f43f5e"
                        anchors.verticalCenter: parent.verticalCenter
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.3; duration: 600 }
                            NumberAnimation { to: 1.0; duration: 600 }
                        }
                    }
                    Text {
                        text: "SEE THESE CONCEPTS LIVE — open a real-time dashboard to watch the OS in action"
                        color: Qt.rgba(255, 255, 255, 0.6)
                        font.bold: true
                        font.pixelSize: 11
                        font.letterSpacing: 0.4
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    width: parent.width
                    spacing: 12

                    Repeater {
                        model: scrollRoot.liveNames.length
                        delegate: Rectangle {
                            width: (parent.width - 24) / 3
                            height: liveCardCol.implicitHeight + 28
                            radius: 12
                            color: scrollRoot.hoveredCard === index ? Qt.rgba(scrollRoot.liveR[index], scrollRoot.liveG[index], scrollRoot.liveB[index], 0.12) : Qt.rgba(255, 255, 255, 0.03)
                            border.color: scrollRoot.hoveredCard === index ? scrollRoot.liveColors[index] : Qt.rgba(scrollRoot.liveR[index], scrollRoot.liveG[index], scrollRoot.liveB[index], 0.25)
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            Column {
                                id: liveCardCol
                                anchors.top: parent.top
                                anchors.topMargin: 14
                                anchors.left: parent.left
                                anchors.leftMargin: 14
                                anchors.right: parent.right
                                anchors.rightMargin: 14
                                spacing: 8

                                Row {
                                    spacing: 8
                                    Text {
                                        text: scrollRoot.liveIcons[index]
                                        font.pixelSize: 20
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Column {
                                        spacing: 2
                                        Text {
                                            text: scrollRoot.liveNames[index]
                                            color: scrollRoot.liveColors[index]
                                            font.bold: true
                                            font.pixelSize: 11
                                            font.letterSpacing: 0.4
                                        }
                                        Text {
                                            text: "Live Dashboard"
                                            color: Qt.rgba(255, 255, 255, 0.3)
                                            font.pixelSize: 9
                                        }
                                    }
                                }

                                Text {
                                    width: parent.width
                                    text: scrollRoot.liveDescs[index]
                                    color: Qt.rgba(255, 255, 255, 0.6)
                                    wrapMode: Text.WordWrap
                                    font.pixelSize: 11
                                    font.family: "Segoe UI"
                                    lineHeight: 1.4
                                }

                                Rectangle {
                                    width: parent.width; height: 28; radius: 7
                                    color: Qt.rgba(scrollRoot.liveR[index], scrollRoot.liveG[index], scrollRoot.liveB[index], 0.15)
                                    border.color: scrollRoot.liveColors[index]
                                    border.width: 1

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        Text {
                                            text: "See it Live"
                                            color: scrollRoot.liveColors[index]
                                            font.bold: true
                                            font.pixelSize: 11
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Text {
                                            text: "→"
                                            color: scrollRoot.liveColors[index]
                                            font.pixelSize: 13
                                            font.bold: true
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: scrollRoot.requestNavigate(scrollRoot.livePages[index])
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: scrollRoot.hoveredCard = index
                                onExited: scrollRoot.hoveredCard = -1
                                onClicked: scrollRoot.requestNavigate(scrollRoot.livePages[index])
                            }
                        }
                    }
                }
            }
        }

        // ══════════════════════════════════════════════════════════════
        // 7. TAKEAWAY FOOTER
        // ══════════════════════════════════════════════════════════════
        Rectangle {
            width: parent.width; height: 65
            color: Qt.rgba(251, 191, 36, 0.08); radius: 14
            border.color: Qt.rgba(251, 191, 36, 0.35); border.width: 1

            RowLayout {
                anchors.fill: parent; anchors.margins: 15; spacing: 15
                Text { text: "🌟"; font.pixelSize: 22; Layout.alignment: Qt.AlignVCenter }
                Text {
                    Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter
                    text: "CORE SUMMARY: xv6 uses a Monolithic design — all subsystems (proc, vm, fs, drivers) compile into ONE kernel binary in Supervisor Mode, communicating via direct C calls. The 5-layer model (User → Syscall Interface → Kernel → HAL → Hardware) ensures strict separation of privilege, with ecall/sret as the only crossing point."
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