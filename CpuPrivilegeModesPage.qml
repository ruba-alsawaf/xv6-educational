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

    property int activeStep: 0
    property int hoveredStep: -1
    property int hoveredRow: -1
    property real privDot: 0.0
    property int  simMode:      0
    property int  simLastInstr: -1
    property bool simOk:        true

    property var instrLabels: ["read a0", "load [uaddr]", "csrr sstatus", "csrw satp,t0", "ecall", "sret", "csrr mstatus", "mret"]
    property var instrIcons:  ["\u{1F4CB}", "\u{1F4DD}", "\u{1F50D}", "\u{1F5FA}", "⚡", "↩️", "\u{1F512}", "\u{1F519}"]
    property var instrModes:  [7, 7, 6, 2, 1, 2, 4, 4]
    property var instrOkText: [
        "✓  General-purpose register read — permitted at every privilege level.",
        "✓  Load from user memory — both U and S mode can access user-mapped pages.",
        "✓  sstatus is a Supervisor CSR — readable from S-mode and M-mode.",
        "✓  satp written — kernel switches page table. Effective immediately after sfence.vma.",
        "⚡  ecall fires trap: sepc←PC, scause←8, PC←stvec.  Switching to S-mode now.",
        "↩️  sret: PC←sepc, mode←sstatus.SPP (U).  Returning to User Mode.",
        "✓  mstatus is a Machine CSR — accessible only from M-mode.",
        "↩️  mret: PC←mepc, mode←mstatus.MPP (S).  Returning to Supervisor Mode."
    ]
    property var instrFaultText: [
        "",
        "",
        "✗  ILLEGAL INSTRUCTION — User mode cannot read Supervisor CSRs. Trap → process killed.",
        "✗  ILLEGAL INSTRUCTION — Only S-mode (kernel) may set the page-table register satp.",
        "✗  ecall from S/M goes to M-mode trap — not the standard kernel path in xv6.",
        "✗  ILLEGAL INSTRUCTION — sret is privileged; executing it in U-mode causes a fault.",
        "✗  ILLEGAL INSTRUCTION — Machine CSRs are inaccessible from S or U mode.",
        "✗  ILLEGAL INSTRUCTION — mret is a Machine-mode only instruction."
    ]

    property var stepColors:    ["#60a5fa", "#a78bfa", "#10b981", "#fbbf24", "#f43f5e"]
    property var stepR:         [96,  167, 16,  251, 244]
    property var stepG:         [165, 139, 185, 191, 63]
    property var stepB:         [250, 250, 129, 36,  94]
    property var stepIcons:     ["\u{1F3DB}️", "\u{1F464}", "\u{1F6E1}️", "⚡", "\u{1F50C}"]
    property var stepTitles:    ["3 MODES", "U-MODE", "S-MODE", "TRANSITIONS", "xv6 BOOT"]
    property var stepSubtitles: [
        "Machine · Supervisor · User",
        "Restricted user-space ring",
        "Full supervisor privileges",
        "ecall / sret / mret mechanics",
        "M → S → U privilege journey"
    ]
    property var stepTheories: [
        "RISC-V defines three hardware privilege levels, each enforced directly by the CPU silicon. Machine Mode (M-mode) is the highest: the CPU starts here after reset, only firmware/OpenSBI runs in M-mode, with unrestricted access to every CSR and physical memory address. Supervisor Mode (S-mode) is the kernel level: xv6 runs here, with access to supervisor CSRs (satp, sstatus, sepc, scause, stvec) and the ability to manage virtual memory. User Mode (U-mode) is the lowest: every user process runs here with no access to CSRs, no direct hardware I/O, and only the pages the kernel has explicitly mapped for it.",
        "When the CPU is in U-mode it enforces a strict instruction whitelist. General-purpose register instructions (add, load, store to user memory) are fine. However any attempt to read or write a CSR register, any privileged instruction (sret, mret, sfence.vma, wfi), or any memory access outside the user page table — all trigger an Illegal Instruction or Page Fault trap. The CPU saves PC to sepc, sets scause, and jumps to stvec. In xv6 that means the process is killed or handled as a syscall via ecall.",
        "Supervisor Mode gives the kernel full control over virtual memory and trap handling. S-mode can read/write all supervisor CSRs: write satp to switch page tables, write stvec to install a trap handler, read scause to learn why a trap fired, read sepc to know the faulting PC, modify sstatus to control interrupt enable bits and SPP. S-mode CANNOT access Machine CSRs (mstatus, mtvec, mepc, mscratch, medeleg, mideleg). In xv6, S-mode is where the entire kernel executes after the boot hand-off from start.c.",
        "Mode transitions are controlled by two instructions. ecall (any mode): atomically sepc←current PC, scause←8, sstatus.SPP←current mode, PC←stvec; CPU enters S-mode at the kernel trap handler. sret (S-mode only): atomically PC←sepc, CPU mode←sstatus.SPP (U), sstatus.SIE←sstatus.SPIE; back in U-mode at the instruction after ecall. mret (M-mode only): same idea for M→S during boot to drop from M-mode to S-mode and jump to main().",
        "xv6 uses all three modes during boot. (1) M-mode: CPU resets into M-mode; kernel/start.c sets mstatus.MPP=S, delegates exceptions via medeleg/mideleg, programs the CLINT timer, then executes mret to drop to S-mode at main(). (2) S-mode: kernel/main.c initialises all subsystems (kalloc, pagetable, traps, scheduler), creates PID 1 via userinit(). (3) U-mode: scheduler picks up PID 1; CPU drops to U-mode, executes /init which exec's sh. Every user program runs in U-mode and transitions to S-mode only via ecall."
    ]
    property var stepCodes: [
        "// kernel/riscv.h\n#define SSTATUS_SPP  (1L << 8)\n#define SSTATUS_SPIE (1L << 5)\n#define SSTATUS_SIE  (1L << 1)\n\n// scause trap codes\n#define SCAUSE_ECALL_U  8\n#define SCAUSE_STORE_PF 15\n#define SCAUSE_LOAD_PF  13\n#define SCAUSE_ILL_INST  2\n\n// mstatus (M-mode only)\n#define MSTATUS_MPP_MASK (3L << 11)\n#define MSTATUS_MPP_S    (1L << 11)\n#define MSTATUS_MPP_U    (0L << 11)",
        "// user/cat.c - legal U-mode ops\nint fd = open(\"README\", 0);  // ecall OK\nread(fd, buf, 512);           // ecall OK\n\n// Illegal in U-mode:\n// csrr a0, sstatus;  -> ILLEGAL INSTR TRAP\n// sret;             -> ILLEGAL INSTR TRAP\n// *(uint64*)0x80000000 = 1; -> PAGE FAULT\n\n// Fault path:\n// 1. MMU: no mapping -> page fault\n// 2. sepc <- faulting PC\n// 3. PC   <- stvec\n// 4. usertrap() -> p->killed = 1",
        "// kernel/trap.c\nvoid usertrap(void) {\n    uint64 cause  = r_scause();\n    uint64 epc    = r_sepc();\n\n    if(cause == 8) {  // ecall\n        p->trapframe->epc += 4;\n        intr_on();\n        syscall();\n    } else if(cause == 13 || cause == 15) {\n        setkilled(p); // page fault\n    }\n    usertrapret();\n}",
        "// ecall: U -> S (hardware, atomic)\n// sepc   <- PC\n// scause <- 8\n// SPP    <- U (saved in sstatus)\n// PC     <- stvec  (uservec)\n// mode   -> S\n\n// sret: S -> U (kernel, atomic)\n// PC   <- sepc\n// mode <- sstatus.SPP (U)\n// SIE  <- SPIE\n\n// mret: M -> S (boot only)\n// PC   <- mepc  (= main)\n// mode <- mstatus.MPP (S)",
        "// kernel/start.c\nvoid start() {\n    // MPP = Supervisor\n    unsigned long x = r_mstatus();\n    x &= ~MSTATUS_MPP_MASK;\n    x |= MSTATUS_MPP_S;\n    w_mstatus(x);\n\n    w_mepc((uint64)main); // jump target\n    w_satp(0);            // no paging yet\n    w_medeleg(0xffff);    // delegate traps\n    w_mideleg(0xffff);\n    w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);\n\n    mret(); // -> S-mode at main()\n}"
    ]
    property var stepSources: [
        "kernel/riscv.h",
        "user/cat.c + kernel/trap.c",
        "kernel/trap.c",
        "kernel/trap.c + trampoline.S",
        "kernel/start.c"
    ]

    property var csrNames:   ["sstatus", "sepc",    "scause",  "stvec",   "satp",    "stval",   "mstatus", "mtvec",   "mepc"]
    property var csrModes:   ["S/M",     "S/M",     "S/M",     "S/M",     "S/M",     "S/M",     "M",       "M",       "M"]
    property var csrColors:  ["#60a5fa", "#a78bfa", "#fbbf24", "#10b981", "#f43f5e", "#6b7280", "#f43f5e", "#f43f5e", "#f43f5e"]
    property var csrDescs:   [
        "Supervisor Status: SPP (prev mode), SIE (irq enable), SPIE (saved SIE)",
        "Supervisor Exception PC — address to return to after sret",
        "Trap cause code: 8=ecall/U, 13=load fault, 15=store fault, 2=illegal instr",
        "Supervisor Trap Vector — address of trap handler (uservec in trampoline.S)",
        "Supervisor Address Translation — PPN of root page table + ASID + MODE",
        "Trap Value — faulting virtual address on page fault, 0 on ecall",
        "Machine Status: MPP (prev mode), MIE, MPIE — M-mode control register",
        "Machine Trap Vector — machine-mode trap handler address",
        "Machine Exception PC — return address for mret"
    ]

    Timer {
        interval: 20
        running: true
        repeat: true
        onTriggered: scrollRoot.privDot = (scrollRoot.privDot + 0.007) % 1.0
    }

    Column {
        id: mainColumn
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        spacing: 25

        // ── HEADER ──────────────────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: 95
            color: Qt.rgba(255, 255, 255, 0.03)
            radius: 14
            border.color: Qt.rgba(96, 165, 250, 0.25)
            border.width: 1

            layer.enabled: true
            layer.effect: Glow {
                radius: 10; samples: 17
                color: Qt.rgba(96, 165, 250, 0.12); spread: 0.1
            }

            Row {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 16

                Rectangle {
                    width: 52; height: 52; radius: 12
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(96, 165, 250, 0.15)
                    border.color: Qt.rgba(96, 165, 250, 0.4)
                    border.width: 1
                    Column {
                        anchors.centerIn: parent
                        spacing: 1
                        Text {
                            text: "04"
                            color: "#60a5fa"
                            font.bold: true
                            font.pixelSize: 20
                            font.family: "Consolas"
                            anchors.horizontalCenter: parent
                        }
                        Text {
                            text: "LESSON"
                            color: Qt.rgba(96, 165, 250, 0.5)
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
                        text: "CPU PRIVILEGE MODES — U · S · M"
                        color: "#ffffff"
                        font.family: "Segoe UI"
                        font.bold: true
                        font.pixelSize: 20
                        font.letterSpacing: 0.5
                    }
                    Text {
                        text: "How RISC-V hardware enforces security through three privilege rings, and how xv6 transitions between them via ecall, sret, and mret."
                        color: Qt.rgba(255, 255, 255, 0.55)
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                    }
                }
            }
        }

        // ── ANIMATED CANVAS ─────────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: 230
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 14
            border.color: Qt.rgba(96, 165, 250, 0.15)
            border.width: 1

            Text {
                text: "LIVE ANIMATION — ecall (U→S) and sret (S→U) privilege transitions"
                color: Qt.rgba(96, 165, 250, 0.6)
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 0.8
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Canvas {
                id: privCanvas
                anchors.fill: parent
                property real dot: scrollRoot.privDot
                onDotChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    var w = width, h = height;
                    var cx = w * 0.36;
                    var t = dot;
                    var uY = 42, sY = 118, mY = 190;
                    var bW = 190, bH = 38;

                    // M-mode box
                    ctx.beginPath();
                    roundRect(ctx, cx - bW/2, mY - bH/2, bW, bH, 8);
                    ctx.strokeStyle = "rgba(244,63,94,0.35)";
                    ctx.lineWidth = 1.5;
                    ctx.stroke();
                    ctx.fillStyle = "rgba(244,63,94,0.06)";
                    ctx.fill();
                    ctx.fillStyle = "rgba(244,63,94,0.7)";
                    ctx.font = "bold 10px Consolas";
                    ctx.textAlign = "center";
                    ctx.fillText("M-MODE  (Machine / Firmware)", cx, mY + 4);

                    // S-mode box
                    var sActive = (t > 0.48 && t < 0.82);
                    var sPulse = sActive ? (0.55 + 0.4 * Math.sin((t - 0.48) / 0.34 * Math.PI * 4)) : 0.35;
                    ctx.beginPath();
                    roundRect(ctx, cx - bW/2, sY - bH/2, bW, bH, 8);
                    ctx.strokeStyle = "rgba(96,165,250," + sPulse + ")";
                    ctx.lineWidth = sActive ? 2 : 1.5;
                    ctx.stroke();
                    ctx.fillStyle = "rgba(96,165,250," + (sActive ? 0.12 : 0.05) + ")";
                    ctx.fill();
                    ctx.fillStyle = "rgba(96,165,250," + (sActive ? 1.0 : 0.7) + ")";
                    ctx.font = "bold 10px Consolas";
                    ctx.textAlign = "center";
                    ctx.fillText("S-MODE  (Supervisor / Kernel)", cx, sY + 4);

                    // U-mode box
                    var uActive = (t < 0.38 || t > 0.90);
                    var uPulse = uActive ? (0.55 + 0.4 * Math.sin(t * Math.PI * 6)) : 0.35;
                    ctx.beginPath();
                    roundRect(ctx, cx - bW/2, uY - bH/2, bW, bH, 8);
                    ctx.strokeStyle = "rgba(167,139,250," + uPulse + ")";
                    ctx.lineWidth = uActive ? 2 : 1.5;
                    ctx.stroke();
                    ctx.fillStyle = "rgba(167,139,250," + (uActive ? 0.12 : 0.05) + ")";
                    ctx.fill();
                    ctx.fillStyle = "rgba(167,139,250," + (uActive ? 1.0 : 0.7) + ")";
                    ctx.font = "bold 10px Consolas";
                    ctx.textAlign = "center";
                    ctx.fillText("U-MODE  (User Applications)", cx, uY + 4);

                    // connector lines U↔S and S↔M
                    ctx.strokeStyle = "rgba(255,255,255,0.10)";
                    ctx.lineWidth = 1.5;
                    ctx.beginPath();
                    ctx.moveTo(cx, uY + bH/2);
                    ctx.lineTo(cx, sY - bH/2);
                    ctx.stroke();
                    ctx.beginPath();
                    ctx.moveTo(cx, sY + bH/2);
                    ctx.lineTo(cx, mY - bH/2);
                    ctx.stroke();

                    // mret label on S↔M gap (always dim)
                    var midSM = sY + bH/2 + (mY - bH/2 - sY - bH/2) / 2;
                    ctx.fillStyle = "rgba(244,63,94,0.30)";
                    ctx.font = "8px Consolas";
                    ctx.textAlign = "center";
                    ctx.fillText("mret (boot)", cx + 28, midSM + 4);

                    // ── Animated dot: 5 phases covering all 3 modes ──────────
                    // 0.00-0.20  dot rests at U
                    // 0.20-0.34  ecall  U→S
                    // 0.34-0.54  dot rests at S
                    // 0.54-0.66  sret   S→U
                    // 0.66-0.75  dot at U briefly, then jumps to M (boot)
                    // 0.75-0.87  mret   M→S
                    // 0.87-0.95  dot at S (kernel running)
                    // 0.95-1.00  dot fades back to U
                    var dotY, dotR, dotG, dotB;
                    var ecallPhase  = (t >= 0.20 && t < 0.34);
                    var sretPhase   = (t >= 0.54 && t < 0.66);
                    var mretPhase   = (t >= 0.75 && t < 0.87);

                    if(t < 0.20 || (t >= 0.66 && t < 0.75) || t >= 0.95) {
                        dotY = uY; dotR = 167; dotG = 139; dotB = 250;
                    } else if(ecallPhase) {
                        var pe = (t - 0.20) / 0.14;
                        dotY = uY + pe * (sY - uY);
                        dotR = Math.round(167 + pe * (96 - 167));
                        dotG = Math.round(139 + pe * (165 - 139));
                        dotB = 250;
                    } else if(t >= 0.34 && t < 0.54) {
                        dotY = sY; dotR = 96; dotG = 165; dotB = 250;
                    } else if(sretPhase) {
                        var ps = (t - 0.54) / 0.12;
                        dotY = sY + ps * (uY - sY);
                        dotR = Math.round(96  + ps * (167 - 96));
                        dotG = Math.round(165 + ps * (139 - 165));
                        dotB = 250;
                    } else if(t >= 0.75 && t < 0.75) {
                        dotY = mY; dotR = 244; dotG = 63; dotB = 94;
                    } else if(mretPhase) {
                        var pm = (t - 0.75) / 0.12;
                        dotY = mY + pm * (sY - mY);
                        dotR = Math.round(244 + pm * (96 - 244));
                        dotG = Math.round(63  + pm * (165 - 63));
                        dotB = Math.round(94  + pm * (250 - 94));
                    } else if(t >= 0.87 && t < 0.95) {
                        dotY = sY; dotR = 96; dotG = 165; dotB = 250;
                    } else {
                        dotY = uY; dotR = 167; dotG = 139; dotB = 250;
                    }

                    // show dot at M when in mret phase or just before
                    if(t >= 0.66 && t < 0.75) {
                        // dot at M (boot start flash)
                        var mFlash = (t >= 0.71) ? 1.0 : Math.min(1, (t - 0.66) / 0.05);
                        ctx.beginPath();
                        ctx.arc(cx, mY, 11, 0, Math.PI * 2);
                        ctx.fillStyle = "rgba(244,63,94," + (mFlash * 0.2) + ")";
                        ctx.fill();
                        ctx.beginPath();
                        ctx.arc(cx, mY, 5, 0, Math.PI * 2);
                        ctx.fillStyle = "rgba(244,63,94," + mFlash + ")";
                        ctx.fill();
                        dotY = -999; // skip normal dot draw below
                    }

                    if(dotY > -100) {
                        ctx.beginPath();
                        ctx.arc(cx, dotY, 11, 0, Math.PI * 2);
                        ctx.fillStyle = "rgba(" + dotR + "," + dotG + "," + dotB + ",0.18)";
                        ctx.fill();
                        ctx.beginPath();
                        ctx.arc(cx, dotY, 5, 0, Math.PI * 2);
                        ctx.fillStyle = "rgba(" + dotR + "," + dotG + "," + dotB + ",1.0)";
                        ctx.fill();
                    }

                    // transition labels
                    var labelX = cx + 108;
                    if(ecallPhase) {
                        var la = Math.min(1, (t - 0.20) / 0.05);
                        ctx.fillStyle = "rgba(251,191,36," + la + ")";
                        ctx.font = "bold 11px Consolas";
                        ctx.textAlign = "left";
                        ctx.fillText("ecall", labelX, 60);
                        ctx.fillStyle = "rgba(255,255,255," + (la * 0.65) + ")";
                        ctx.font = "9px Consolas";
                        ctx.fillText("sepc   ← PC", labelX, 75);
                        ctx.fillText("scause ← 8", labelX, 88);
                        ctx.fillText("PC     ← stvec", labelX, 101);
                        ctx.fillText("mode   → S", labelX, 114);
                    } else if(sretPhase) {
                        var la2 = Math.min(1, (t - 0.54) / 0.05);
                        ctx.fillStyle = "rgba(96,165,250," + la2 + ")";
                        ctx.font = "bold 11px Consolas";
                        ctx.textAlign = "left";
                        ctx.fillText("sret", labelX, 60);
                        ctx.fillStyle = "rgba(255,255,255," + (la2 * 0.65) + ")";
                        ctx.font = "9px Consolas";
                        ctx.fillText("PC   ← sepc", labelX, 75);
                        ctx.fillText("mode ← SPP (U)", labelX, 88);
                        ctx.fillText("SIE  ← SPIE", labelX, 101);
                    } else if(t >= 0.66 && t < 0.75) {
                        var la3 = Math.min(1, (t - 0.66) / 0.05);
                        ctx.fillStyle = "rgba(244,63,94," + la3 + ")";
                        ctx.font = "bold 11px Consolas";
                        ctx.textAlign = "left";
                        ctx.fillText("BOOT", labelX, 165);
                        ctx.fillStyle = "rgba(255,255,255," + (la3 * 0.65) + ")";
                        ctx.font = "9px Consolas";
                        ctx.fillText("start.c → M-mode", labelX, 180);
                    } else if(mretPhase) {
                        var la4 = Math.min(1, (t - 0.75) / 0.05);
                        ctx.fillStyle = "rgba(244,63,94," + la4 + ")";
                        ctx.font = "bold 11px Consolas";
                        ctx.textAlign = "left";
                        ctx.fillText("mret", labelX, 165);
                        ctx.fillStyle = "rgba(255,255,255," + (la4 * 0.65) + ")";
                        ctx.font = "9px Consolas";
                        ctx.fillText("PC   ← mepc (main)", labelX, 180);
                        ctx.fillText("mode ← MPP (S)", labelX, 193);
                    }

                    // right labels
                    var rx = cx + bW / 2 + 12;
                    ctx.font = "9px Consolas";
                    ctx.textAlign = "left";
                    ctx.fillStyle = "rgba(167,139,250,0.5)";
                    ctx.fillText("ring 3 · no CSRs · no hw", rx, uY + 4);
                    ctx.fillStyle = "rgba(96,165,250,0.5)";
                    ctx.fillText("ring 0 · S-CSRs · vm mgmt", rx, sY + 4);
                    ctx.fillStyle = "rgba(244,63,94,0.5)";
                    ctx.fillText("ring -1 · all CSRs · bare metal", rx, mY + 4);
                }

                function roundRect(ctx, x, y, w, h, r) {
                    ctx.beginPath();
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

        // ── STEP SELECTOR ───────────────────────────────────────────────
        Row {
            width: parent.width
            spacing: 8

            Repeater {
                model: scrollRoot.stepTitles.length
                delegate: Rectangle {
                    width: (parent.width - 32) / scrollRoot.stepTitles.length
                    height: 70
                    radius: 10
                    color: scrollRoot.activeStep === index
                           ? Qt.rgba(scrollRoot.stepR[index]/255, scrollRoot.stepG[index]/255, scrollRoot.stepB[index]/255, 0.18)
                           : (scrollRoot.hoveredStep === index
                              ? Qt.rgba(scrollRoot.stepR[index]/255, scrollRoot.stepG[index]/255, scrollRoot.stepB[index]/255, 0.08)
                              : Qt.rgba(255, 255, 255, 0.03))
                    border.color: scrollRoot.activeStep === index
                                  ? scrollRoot.stepColors[index]
                                  : Qt.rgba(255, 255, 255, 0.08)
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

        // ── DETAIL PANEL ────────────────────────────────────────────────
        Rectangle {
            id: detailPanel
            width: parent.width
            height: detailRow.implicitHeight + 36
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 14
            border.color: Qt.rgba(scrollRoot.stepR[scrollRoot.activeStep]/255,
                                  scrollRoot.stepG[scrollRoot.activeStep]/255,
                                  scrollRoot.stepB[scrollRoot.activeStep]/255, 0.28)
            border.width: 1

            // No displayedStep — bind directly to scrollRoot.activeStep everywhere

            Row {
                id: detailRow
                anchors.top: parent.top
                anchors.topMargin: 18
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.right: parent.right
                anchors.rightMargin: 18
                spacing: 16

                Column {
                    width: (parent.width - 16) * 0.42
                    spacing: 12

                    Row {
                        spacing: 10
                        Text { text: scrollRoot.stepIcons[scrollRoot.activeStep]; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
                        Column {
                            spacing: 3
                            Text {
                                text: scrollRoot.stepTitles[scrollRoot.activeStep]
                                color: scrollRoot.stepColors[scrollRoot.activeStep]
                                font.bold: true; font.pixelSize: 14; font.letterSpacing: 0.5
                            }
                            Text {
                                text: scrollRoot.stepSources[scrollRoot.activeStep]
                                color: Qt.rgba(255, 255, 255, 0.32)
                                font.pixelSize: 10; font.family: "Consolas"
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.06) }

                    Text {
                        width: parent.width
                        text: scrollRoot.stepTheories[scrollRoot.activeStep]
                        color: Qt.rgba(255, 255, 255, 0.78)
                        wrapMode: Text.WordWrap
                        font.family: "Segoe UI"; font.pixelSize: 12; lineHeight: 1.55
                    }
                }

                Rectangle {
                    width: (parent.width - 16) * 0.58
                    height: codeText.implicitHeight + 36
                    color: Qt.rgba(0, 0, 0, 0.28); radius: 10
                    border.color: Qt.rgba(255, 255, 255, 0.06); border.width: 1

                    Rectangle {
                        width: parent.width; height: 26
                        color: Qt.rgba(255, 255, 255, 0.04); radius: 10
                        Rectangle { width: parent.width; height: 13; anchors.bottom: parent.bottom; color: parent.color }
                        Row {
                            anchors.left: parent.left; anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter; spacing: 5
                            Repeater {
                                model: 3
                                delegate: Rectangle { width: 8; height: 8; radius: 4; color: ["#f43f5e","#fbbf24","#10b981"][index]; opacity: 0.7 }
                            }
                        }
                        Text {
                            text: scrollRoot.stepSources[scrollRoot.activeStep]
                            color: Qt.rgba(255, 255, 255, 0.28); font.pixelSize: 9; font.family: "Consolas"
                            anchors.centerIn: parent
                        }
                    }

                    Text {
                        id: codeText
                        anchors.top: parent.top; anchors.topMargin: 32
                        anchors.left: parent.left; anchors.leftMargin: 14
                        anchors.right: parent.right; anchors.rightMargin: 14
                        text: scrollRoot.stepCodes[scrollRoot.activeStep]
                        color: Qt.rgba(255, 255, 255, 0.82)
                        font.family: "Consolas"; font.pixelSize: 11
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere; lineHeight: 1.5
                    }
                }
            }
        }

        // ── PRIVILEGE SIMULATOR ─────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: simCol.implicitHeight + 32
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 14
            border.color: Qt.rgba(96, 165, 250, 0.2)
            border.width: 1

            Column {
                id: simCol
                anchors.top: parent.top; anchors.topMargin: 18
                anchors.left: parent.left; anchors.leftMargin: 18
                anchors.right: parent.right; anchors.rightMargin: 18
                spacing: 14

                Row {
                    spacing: 10
                    Text { text: "\u{1F9EA}"; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
                    Column {
                        spacing: 2
                        Text {
                            text: "PRIVILEGE SIMULATOR — pick a CPU mode, then try executing instructions"
                            color: "#60a5fa"; font.bold: true; font.pixelSize: 13; font.letterSpacing: 0.3
                        }
                        Text {
                            text: "The coloured dots on each card show which modes (U/S/M) allow that instruction"
                            color: Qt.rgba(255, 255, 255, 0.38); font.pixelSize: 11
                        }
                    }
                }

                // Mode selector
                Row {
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: 3
                        delegate: Rectangle {
                            property var mColors: ["#a78bfa", "#60a5fa", "#f43f5e"]
                            property var mRv: [167, 96,  244]
                            property var mGv: [139, 165, 63]
                            property var mBv: [250, 250, 94]
                            property var mLabels: ["U-MODE", "S-MODE", "M-MODE"]
                            property var mSubs:   ["User Applications\nRing 3 — Restricted", "Kernel / Supervisor\nRing 0 — Privileged", "Machine Firmware\nRing -1 — Full access"]
                            property var mIcons:  ["\u{1F464}", "\u{1F6E1}️", "\u{1F529}"]
                            property bool active: scrollRoot.simMode === index

                            width: (parent.width - 20) / 3
                            height: 80
                            radius: 10
                            color: active ? Qt.rgba(mRv[index]/255, mGv[index]/255, mBv[index]/255, 0.18) : Qt.rgba(255, 255, 255, 0.03)
                            border.color: active ? mColors[index] : Qt.rgba(mRv[index]/255, mGv[index]/255, mBv[index]/255, 0.3)
                            border.width: active ? 2 : 1

                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            Row {
                                anchors.centerIn: parent; spacing: 10
                                Text { text: mIcons[index]; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
                                Column {
                                    spacing: 3
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        text: mLabels[index]
                                        color: active ? mColors[index] : Qt.rgba(255,255,255,0.6)
                                        font.bold: true; font.pixelSize: 12; font.letterSpacing: 0.4
                                    }
                                    Text {
                                        text: mSubs[index]
                                        color: Qt.rgba(255,255,255,0.35)
                                        font.pixelSize: 9; lineHeight: 1.3
                                    }
                                }
                            }

                            Rectangle {
                                visible: active
                                width: 8; height: 8; radius: 4
                                anchors.top: parent.top; anchors.topMargin: 8
                                anchors.right: parent.right; anchors.rightMargin: 8
                                color: parent.mColors[index]
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite; running: active
                                    NumberAnimation { to: 0.3; duration: 500 }
                                    NumberAnimation { to: 1.0; duration: 500 }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { scrollRoot.simMode = index; scrollRoot.simLastInstr = -1 }
                            }
                        }
                    }
                }

                // Instruction grid
                Grid {
                    width: parent.width
                    columns: 4
                    spacing: 8

                    Repeater {
                        model: scrollRoot.instrLabels.length
                        delegate: Rectangle {
                            property bool allowed: (scrollRoot.instrModes[index] & (1 << scrollRoot.simMode)) !== 0
                            property bool isLast: scrollRoot.simLastInstr === index

                            width: (parent.width - 24) / 4
                            height: 64
                            radius: 9
                            color: isLast ? (allowed ? Qt.rgba(16/255,185/255,129/255,0.14) : Qt.rgba(244/255,63/255,94/255,0.12)) : Qt.rgba(255,255,255,0.03)
                            border.color: isLast ? (allowed ? "#10b981" : "#f43f5e") : Qt.rgba(255,255,255,0.08)
                            border.width: isLast ? 1.5 : 1

                            Behavior on color { ColorAnimation { duration: 180 } }
                            Behavior on border.color { ColorAnimation { duration: 180 } }

                            Column {
                                anchors.centerIn: parent; spacing: 4
                                Text {
                                    text: scrollRoot.instrIcons[index]
                                    font.pixelSize: 16; anchors.horizontalCenter: parent
                                }
                                Text {
                                    text: scrollRoot.instrLabels[index]
                                    color: isLast ? (allowed ? "#10b981" : "#f43f5e") : Qt.rgba(255,255,255,0.7)
                                    font.family: "Consolas"; font.pixelSize: 10; font.bold: true
                                    anchors.horizontalCenter: parent
                                }
                                Row {
                                    anchors.horizontalCenter: parent; spacing: 3
                                    Rectangle {
                                        width: 5; height: 5; radius: 2.5
                                        color: (scrollRoot.instrModes[index] & 1) !== 0 ? "#a78bfa" : Qt.rgba(255,255,255,0.12)
                                    }
                                    Rectangle {
                                        width: 5; height: 5; radius: 2.5
                                        color: (scrollRoot.instrModes[index] & 2) !== 0 ? "#60a5fa" : Qt.rgba(255,255,255,0.12)
                                    }
                                    Rectangle {
                                        width: 5; height: 5; radius: 2.5
                                        color: (scrollRoot.instrModes[index] & 4) !== 0 ? "#f43f5e" : Qt.rgba(255,255,255,0.12)
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var a = (scrollRoot.instrModes[index] & (1 << scrollRoot.simMode)) !== 0;
                                    scrollRoot.simOk = a;
                                    scrollRoot.simLastInstr = index;
                                    if(index === 4 && scrollRoot.simMode === 0 && a) scrollRoot.simMode = 1;
                                    else if(index === 5 && scrollRoot.simMode === 1 && a) scrollRoot.simMode = 0;
                                    else if(index === 7 && scrollRoot.simMode === 2 && a) scrollRoot.simMode = 1;
                                }
                            }
                        }
                    }
                }

                // Result banner
                Rectangle {
                    width: parent.width
                    height: scrollRoot.simLastInstr >= 0 ? simResult.implicitHeight + 20 : 0
                    radius: 9
                    visible: scrollRoot.simLastInstr >= 0
                    color: scrollRoot.simOk ? Qt.rgba(16/255,185/255,129/255,0.10) : Qt.rgba(244/255,63/255,94/255,0.10)
                    border.color: scrollRoot.simOk ? Qt.rgba(16/255,185/255,129/255,0.4) : Qt.rgba(244/255,63/255,94/255,0.4)
                    border.width: 1
                    clip: true

                    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Text {
                        id: simResult
                        visible: scrollRoot.simLastInstr >= 0
                        anchors.left: parent.left; anchors.leftMargin: 14
                        anchors.right: parent.right; anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: scrollRoot.simLastInstr >= 0
                              ? (scrollRoot.simOk ? scrollRoot.instrOkText[scrollRoot.simLastInstr] : scrollRoot.instrFaultText[scrollRoot.simLastInstr])
                              : ""
                        color: scrollRoot.simOk ? "#10b981" : "#f43f5e"
                        wrapMode: Text.WordWrap
                        font.family: "Segoe UI"; font.pixelSize: 12; font.bold: true
                        lineHeight: 1.4
                    }
                }
            }
        }

        // ── CSR REGISTER TABLE ──────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: csrCol.implicitHeight + 32
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 14
            border.color: Qt.rgba(255, 255, 255, 0.07)
            border.width: 1

            Column {
                id: csrCol
                anchors.top: parent.top; anchors.topMargin: 16
                anchors.left: parent.left; anchors.leftMargin: 16
                anchors.right: parent.right; anchors.rightMargin: 16
                spacing: 6

                Row {
                    spacing: 8
                    Text { text: "\u{1F4CB}"; font.pixelSize: 14 }
                    Text {
                        text: "KEY CSR REGISTERS — Control and Status Registers referenced in xv6"
                        color: Qt.rgba(96, 165, 250, 0.7)
                        font.bold: true; font.pixelSize: 11; font.letterSpacing: 0.5
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    width: parent.width; spacing: 0
                    Rectangle { width: 90; height: 24; color: Qt.rgba(96,165,250,0.13)
                        Text { text: "REGISTER"; color: "#60a5fa"; font.bold: true; font.pixelSize: 10; font.letterSpacing: 0.6; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter } }
                    Rectangle { width: 50; height: 24; color: Qt.rgba(96,165,250,0.09)
                        Text { text: "MODE"; color: "#60a5fa"; font.bold: true; font.pixelSize: 10; anchors.centerIn: parent } }
                    Rectangle { width: parent.width - 140; height: 24; color: Qt.rgba(96,165,250,0.07)
                        Text { text: "PURPOSE"; color: "#60a5fa"; font.bold: true; font.pixelSize: 10; font.letterSpacing: 0.5; anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter } }
                }

                Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.06) }

                Repeater {
                    model: scrollRoot.csrNames.length
                    delegate: Rectangle {
                        width: parent.width; height: 26; radius: 4
                        color: scrollRoot.hoveredRow === index ? Qt.rgba(96/255,165/255,250/255,0.08) : (index % 2 === 0 ? Qt.rgba(255,255,255,0.02) : Qt.rgba(255,255,255,0.035))
                        Behavior on color { ColorAnimation { duration: 120 } }
                        MouseArea { anchors.fill: parent; hoverEnabled: true; onEntered: scrollRoot.hoveredRow = index; onExited: scrollRoot.hoveredRow = -1 }
                        Row {
                            anchors.fill: parent; spacing: 0
                            Rectangle { width: 90; height: parent.height; color: "transparent"
                                Text { text: scrollRoot.csrNames[index]; color: scrollRoot.csrColors[index]; font.family: "Consolas"; font.pixelSize: 11; font.bold: true; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter } }
                            Rectangle { width: 50; height: parent.height; color: "transparent"
                                Text { text: scrollRoot.csrModes[index]; color: Qt.rgba(255,255,255,0.35); font.family: "Consolas"; font.pixelSize: 10; anchors.centerIn: parent } }
                            Rectangle { width: parent.width - 140; height: parent.height; color: "transparent"
                                Text { text: scrollRoot.csrDescs[index]; color: Qt.rgba(255,255,255,0.62); font.pixelSize: 11; elide: Text.ElideRight; width: parent.width - 10; anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter } }
                        }
                    }
                }
            }
        }

        // ── TAKEAWAY FOOTER ─────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 65
            color: Qt.rgba(96/255, 165/255, 250/255, 0.08); radius: 14
            border.color: Qt.rgba(96/255, 165/255, 250/255, 0.35); border.width: 1

            RowLayout {
                anchors.fill: parent; anchors.margins: 15; spacing: 15
                Text { text: "\u{1F31F}"; font.pixelSize: 22; Layout.alignment: Qt.AlignVCenter }
                Text {
                    Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter
                    text:                     "CORE SUMMARY: RISC-V enforces 3 hardware privilege rings — M (firmware), S (kernel), U (user). Transitions use ecall (U→S: sepc←PC, scause←8, PC←stvec), sret (S→U: PC←sepc, mode←SPP), and mret (M→S during boot). Any privilege violation triggers an immediate hardware trap."
                    color: "#ffffff"; wrapMode: Text.WordWrap
                    font.family: "Segoe UI"; font.bold: true; font.pixelSize: 12; font.letterSpacing: 0.2
                }
            }
        }

    }
}
