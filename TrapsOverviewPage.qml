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

    property int  openCard:    0
    property int  trapType:    0
    property int  hoveredRow:  -1
    property int  hoveredCard: -1
    property real trapDot:     0.0

    property var cardColors:  ["#a78bfa","#fbbf24","#f97316","#10b981","#60a5fa"]
    property var cardR: [167,251,249,16,96]
    property var cardG: [139,191,115,185,165]
    property var cardB: [250,36,22,129,250]
    property var cardTitles: ["WHAT IS A TRAP?","TRAP ENTRY — uservec","TRAP DISPATCH — usertrap","TRAP RETURN — usertrapret","THE TRAMPOLINE PAGE"]
    property var cardSubs: [
        "syscall · exception · interrupt — three causes, one path",
        "trampoline.S saves 32 registers, loads kernel stack + page table",
        "trap.c reads scause and dispatches to the right handler",
        "trap.c + trampoline.S restore state and sret back to user code",
        "The page mapped at the same VA in BOTH user and kernel tables"
    ]
    property var cardSources: ["kernel/trap.c","kernel/trampoline.S","kernel/trap.c","kernel/trap.c + trampoline.S","kernel/vm.c"]
    property var cardOpenH: [440,500,480,520,460]

    property var cardTheories: [
        "In xv6, 'trap' is the umbrella term for three events that force the CPU from U-mode to S-mode. (1) System Call (ecall, scause=8): user code voluntarily requests a kernel service — read, write, fork, exit. The kernel reads register a7 to identify which syscall. (2) Exception (scause=2/13/15): user code does something illegal — unmapped page access (page fault), illegal instruction, or arithmetic fault. xv6 kills the process. (3) Interrupt (scause MSB set): asynchronous hardware event — the RISC-V CLINT timer fires (scause=0x8000000000000005), or a UART/disk interrupt arrives. All three go through the identical hardware path: stvec → uservec → usertrap.",
        "When a trap fires, the CPU atomically: writes PC to sepc, writes cause to scause, sets sstatus.SPP=S, and jumps to stvec (pointing at uservec in the trampoline). We arrive in S-mode still on the user page table — no kernel memory accessible except the trampoline. We also cannot touch any general-purpose register (they hold user data to preserve). The solution uses sscratch: before returning to user space, usertrapret stored the trapframe VA in sscratch. uservec does 'csrrw a0, sscratch, a0' — atomically swapping the two — so a0 now holds the trapframe VA. We then save all 32 registers into the trapframe, load kernel_sp and kernel_satp from pre-filled trapframe fields, switch page tables (safe: trampoline VA is identical in both), and jump to usertrap().",
        "usertrap() runs in S-mode with the kernel page table active. It first re-aims stvec at kernelvec — if another trap fires while we are in the kernel, it must use the kernel's own handler, not uservec. It saves sepc into trapframe->epc (because yield() might run while we wait, overwriting sepc). Then it dispatches on scause: value 8 = ecall → add 4 to epc (advance past ecall instruction), enable interrupts, call syscall() which reads a7. MSB set = interrupt → check for timer (code 5) and call clockintr()+yield(). Anything else = exception → setkilled(p). Every path ends with usertrapret().",
        "usertrapret() bridges kernel back to user space. It turns off interrupts, re-aims stvec at uservec (ready for next trap), saves kernel_satp, kernel_sp, and usertrap address into the trapframe (so next uservec call can reload them), clears sstatus.SPP=U (sret will lower mode), sets sepc = trapframe->epc (the user PC to resume), stores trapframe VA into sscratch, then switches to user page table and calls userret() in the trampoline. userret: restores all 32 registers from trapframe (saving a0 for last since it holds the trapframe VA), then executes sret — PC = sepc, mode → U.",
        "The trampoline is one 4 KB page (kernel/trampoline.S) mapped at TRAMPOLINE = MAXVA - PGSIZE (highest possible user VA) in EVERY page table — kernel and each process. This solves a fundamental problem: when a trap fires the CPU uses the user page table. To switch to the kernel page table we write satp, but the very next instruction fetch must succeed — so that VA must map to the same physical code in the new table. Because the trampoline VA is identical in both tables, writing satp does not crash the instruction stream. The trampoline is mapped PTE_R|PTE_X but NOT PTE_U — user code can never execute it."
    ]
    property var cardCodes: [
        "// kernel/trap.c\nvoid usertrap(void) {\n    uint64 cause = r_scause();\n    if(cause == 8) {\n        // syscall: ecall from U-mode\n        p->trapframe->epc += 4;\n        intr_on();\n        syscall();  // dispatches on a7\n    } else if(cause & (1L << 63)) {\n        // interrupt\n        if((cause & 0xff) == 5) clockintr();\n        yield();\n    } else {\n        // exception: page fault, illegal instr\n        setkilled(p);\n    }\n    usertrapret();\n}",
        "# kernel/trampoline.S\nuservec:\n    # swap a0 <-> sscratch\n    # (sscratch = trapframe VA)\n    csrrw a0, sscratch, a0\n\n    # save all 32 user registers\n    sd ra,   40(a0)\n    sd sp,   48(a0)\n    # ... (all 32 regs)\n    sd t6,  280(a0)\n\n    # load kernel resources\n    ld sp, 8(a0)     # kernel stack\n    ld t0, 16(a0)    # usertrap address\n    ld t1, 0(a0)     # kernel satp\n\n    csrw satp, t1    # switch page table\n    sfence.vma zero, zero\n    jr t0            # -> usertrap()",
        "// kernel/trap.c\nvoid usertrap(void) {\n    // trap in kernel -> kernel handler\n    w_stvec((uint64)kernelvec);\n\n    p->trapframe->epc = r_sepc();\n    uint64 cause = r_scause();\n\n    if(cause == 8) {          // ecall\n        p->trapframe->epc += 4;\n        intr_on();\n        syscall();\n    } else if((cause&(1L<<63)) &&\n              (cause&0xff)==5) { // timer\n        clockintr();\n        yield();\n    } else {                  // exception\n        setkilled(p);\n    }\n    usertrapret();\n}",
        "// kernel/trap.c\nvoid usertrapret(void) {\n    intr_off();\n    // re-aim stvec at trampoline uservec\n    w_stvec(TRAMPOLINE+(uservec-trampoline));\n\n    // fill trapframe for next uservec\n    p->trapframe->kernel_satp = r_satp();\n    p->trapframe->kernel_sp   = p->kstack+PGSIZE;\n    p->trapframe->kernel_trap = (uint64)usertrap;\n\n    // set up sret: SPP=U, SPIE=1\n    unsigned long x = r_sstatus();\n    x &= ~SSTATUS_SPP;\n    x |=  SSTATUS_SPIE;\n    w_sstatus(x);\n    w_sepc(p->trapframe->epc);\n\n    // switch satp + jump to userret\n    uint64 satp = MAKE_SATP(p->pagetable);\n    ((void(*)(uint64,uint64))fn)(TRAPFRAME,satp);\n}",
        "// kernel/vm.c\n// Map trampoline in kernel page table:\nkvmmap(kpgtbl, TRAMPOLINE,\n       (uint64)trampoline, PGSIZE,\n       PTE_R | PTE_X);  // NOT PTE_U\n\n// Map in every process page table:\nmappages(pagetable, TRAMPOLINE, PGSIZE,\n         (uint64)trampoline,\n         PTE_R | PTE_X);  // NOT PTE_U\n\n// TRAMPOLINE = MAXVA - PGSIZE\n//            = 0x3FFFFF000 (Sv39)\n//\n// Same physical page, same virtual address,\n// in every address space.\n// PTE_U is intentionally absent:\n// user code cannot execute the trampoline."
    ]

    property var trapTypeNames:  ["SYSCALL (ecall)", "PAGE FAULT", "TIMER INTERRUPT"]
    property var trapTypeColors: ["#a78bfa","#f43f5e","#fbbf24"]
    property var trapTypeTR: [167,244,251]; property var trapTypeTG: [139,63,191]; property var trapTypeTB: [250,94,36]
    property var trapTypeIcons:  ["⚡","💥","⏱️"]
    property var trapTypeScause: ["8 (Environment call from U-mode)","13 (Load page fault) or 15 (Store page fault)","0x8000000000000005 (Supervisor timer interrupt)"]
    property var trapTypePath:   [
        "ecall → uservec → usertrap → syscall() → usertrapret → sret → user code",
        "exception → uservec → usertrap → setkilled() → exit(-1) → process dies",
        "interrupt → uservec → usertrap → clockintr() → yield() → scheduler → next process"
    ]
    property var trapTypeResult: [
        "Return value in a0. sepc advanced +4 (past ecall). sret returns to the very next instruction.",
        "In xv6 (simplified): the faulting process is killed. A real OS would handle demand paging here.",
        "Tick counter updated. If time slice exhausted, yield() switches context to next runnable process."
    ]

    property var causeVals:  ["2","8","9","12","13","15","0x8000...1","0x8000...5"]
    property var causeModes: ["U/S","U","S","U/S","U/S","U/S","S","S"]
    property var causeNames: ["Illegal Instruction","Env Call (U-mode)","Env Call (S-mode)","Instr Page Fault","Load Page Fault","Store/AMO Page Fault","Software Interrupt","Timer Interrupt"]
    property var causeColors:["#f43f5e","#a78bfa","#60a5fa","#fbbf24","#f97316","#f97316","#10b981","#10b981"]

    Timer {
        interval: 20; running: true; repeat: true
        onTriggered: scrollRoot.trapDot = (scrollRoot.trapDot + 0.006) % 1.0
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
            width: parent.width; height: 95
            color: Qt.rgba(255,255,255,0.03); radius: 14
            border.color: Qt.rgba(249,115,22,0.25); border.width: 1
            layer.enabled: true
            layer.effect: Glow { radius:10; samples:17; color:Qt.rgba(249,115,22,0.12); spread:0.1 }

            Row {
                anchors.fill: parent; anchors.margins: 15; spacing: 16
                Rectangle {
                    width: 52; height: 52; radius: 12
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(249,115,22,0.15); border.color: Qt.rgba(249,115,22,0.4); border.width: 1
                    Column {
                        anchors.centerIn: parent; spacing: 1
                        Text { text:"05"; color:"#f97316"; font.bold:true; font.pixelSize:20; font.family:"Consolas"; anchors.horizontalCenter:parent }
                        Text { text:"LESSON"; color:Qt.rgba(249,115,22,0.5); font.pixelSize:7; font.letterSpacing:1; anchors.horizontalCenter:parent }
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 6
                    Text {
                        text: "TRAPS OVERVIEW — The Path from User to Kernel and Back"
                        color: "#ffffff"; font.family:"Segoe UI"; font.bold:true; font.pixelSize:20; font.letterSpacing:0.5
                    }
                    Text {
                        text: "How syscalls, exceptions, and interrupts all funnel through the same uservec→usertrap→usertrapret pipeline in xv6."
                        color: Qt.rgba(255,255,255,0.55); font.family:"Segoe UI"; font.pixelSize:12
                    }
                }
            }
        }

        // ── CANVAS — trap flow animation ────────────────────────────────
        Rectangle {
            width: parent.width; height: 200
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(249,115,22,0.15); border.width: 1

            Text {
                text: "LIVE — complete trap path: ecall → uservec → usertrap → usertrapret → sret"
                color: Qt.rgba(249,115,22,0.55); font.pixelSize:10; font.bold:true; font.letterSpacing:0.8
                anchors.top: parent.top; anchors.topMargin:9; anchors.horizontalCenter:parent.horizontalCenter
            }

            Canvas {
                id: trapCanvas
                anchors.fill: parent
                property real dot: scrollRoot.trapDot
                onDotChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d"); ctx.reset();
                    var w = width, h = height;
                    var t = dot;

                    // ── Box layout ──────────────────────────────────────
                    var bW = w * 0.155, bH = 38, bY = h * 0.43;
                    var cx0 = w*0.09, cx1 = w*0.34, cx2 = w*0.59, cx3 = w*0.84;
                    var boxData = [
                        {cx:cx0, lbl:"USER\nPROCESS",  sub:"U-mode",         r:167,g:139,b:250},
                        {cx:cx1, lbl:"uservec",        sub:"trampoline.S",   r:251,g:191,b:36},
                        {cx:cx2, lbl:"usertrap",       sub:"trap.c",         r:249,g:115,b:22},
                        {cx:cx3, lbl:"usertrapret",    sub:"trap.c",         r:16, g:185,b:129}
                    ];

                    // ── Determine active box from animation phase ───────
                    var atBox   = [t < 0.12 || t >= 0.94,
                                   t >= 0.24 && t < 0.36,
                                   t >= 0.48 && t < 0.60,
                                   t >= 0.72 && t < 0.82];
                    var inTravel = (t >= 0.12 && t < 0.24) || (t >= 0.36 && t < 0.48) ||
                                   (t >= 0.60 && t < 0.72) || (t >= 0.82 && t < 0.94);

                    // ── Draw arrow lines between boxes ──────────────────
                    ctx.lineWidth = 1.5;
                    for(var i = 0; i < 3; i++) {
                        var ax = boxData[i].cx + bW/2 + 4;
                        var bx2 = boxData[i+1].cx - bW/2 - 4;
                        var ay = bY;
                        ctx.strokeStyle = "rgba(255,255,255,0.14)";
                        ctx.beginPath(); ctx.moveTo(ax, ay); ctx.lineTo(bx2, ay); ctx.stroke();
                        // arrowhead
                        ctx.beginPath(); ctx.moveTo(bx2, ay-5); ctx.lineTo(bx2+8, ay); ctx.lineTo(bx2, ay+5); ctx.fill();
                        ctx.fillStyle = "rgba(255,255,255,0.14)"; ctx.fill();
                    }

                    // ── Return arc at bottom ────────────────────────────
                    var arcY = h * 0.80;
                    ctx.strokeStyle = "rgba(255,255,255,0.10)";
                    ctx.lineWidth = 1.5;
                    ctx.setLineDash([4, 4]);
                    ctx.beginPath();
                    ctx.moveTo(cx3, bY + bH/2);
                    ctx.quadraticCurveTo(w * 0.465, arcY + 22, cx0, bY + bH/2);
                    ctx.stroke();
                    ctx.setLineDash([]);
                    // sret label on arc
                    ctx.fillStyle = "rgba(96,165,250,0.45)";
                    ctx.font = "bold 9px Consolas"; ctx.textAlign = "center";
                    ctx.fillText("sret", w * 0.465, arcY + 30);

                    // ── Draw boxes ──────────────────────────────────────
                    for(var bi = 0; bi < 4; bi++) {
                        var bd = boxData[bi];
                        var pulse = atBox[bi] ? (0.6 + 0.35 * Math.sin(t * Math.PI * 10)) : 0.3;
                        ctx.beginPath();
                        roundRect(ctx, bd.cx - bW/2, bY - bH/2, bW, bH, 7);
                        ctx.strokeStyle = "rgba("+bd.r+","+bd.g+","+bd.b+","+pulse+")";
                        ctx.lineWidth = atBox[bi] ? 2 : 1.2;
                        ctx.stroke();
                        ctx.fillStyle = "rgba("+bd.r+","+bd.g+","+bd.b+","+(atBox[bi] ? 0.13 : 0.05)+")";
                        ctx.fill();
                        ctx.fillStyle = "rgba("+bd.r+","+bd.g+","+bd.b+","+(atBox[bi] ? 1.0 : 0.65)+")";
                        ctx.font = "bold 10px Consolas"; ctx.textAlign = "center";
                        ctx.fillText(bd.lbl.split("\n")[0], bd.cx, bY - 4);
                        ctx.fillStyle = "rgba(255,255,255,0.35)";
                        ctx.font = "8px Consolas";
                        ctx.fillText(bd.lbl.split("\n")[1] || bd.sub, bd.cx, bY + 10);
                    }

                    // ── Animated dot ────────────────────────────────────
                    var dotX, dotY2, dotR, dotG, dotB2;
                    if(t < 0.12 || t >= 0.94) {
                        dotX=cx0; dotY2=bY; dotR=167; dotG=139; dotB2=250;
                    } else if(t < 0.24) {
                        var p01 = (t-0.12)/0.12;
                        dotX = cx0 + p01*(cx1-cx0); dotY2=bY;
                        dotR=167; dotG=139; dotB2=250;
                    } else if(t < 0.36) {
                        dotX=cx1; dotY2=bY; dotR=251; dotG=191; dotB2=36;
                    } else if(t < 0.48) {
                        var p12 = (t-0.36)/0.12;
                        dotX = cx1 + p12*(cx2-cx1); dotY2=bY;
                        dotR=251; dotG=Math.round(191+p12*(115-191)); dotB2=36;
                    } else if(t < 0.60) {
                        dotX=cx2; dotY2=bY; dotR=249; dotG=115; dotB2=22;
                    } else if(t < 0.72) {
                        var p23 = (t-0.60)/0.12;
                        dotX = cx2 + p23*(cx3-cx2); dotY2=bY;
                        dotR=249; dotG=Math.round(115+p23*(185-115)); dotB2=Math.round(22+p23*(129-22));
                    } else if(t < 0.82) {
                        dotX=cx3; dotY2=bY; dotR=16; dotG=185; dotB2=129;
                    } else {
                        // return arc via bezier
                        var pa = (t-0.82)/0.12;
                        var cpX = w*0.465, cpY = arcY+22;
                        dotX = (1-pa)*(1-pa)*cx3 + 2*(1-pa)*pa*cpX + pa*pa*cx0;
                        dotY2 = (1-pa)*(1-pa)*bY  + 2*(1-pa)*pa*cpY + pa*pa*bY;
                        dotR=16; dotG=185; dotB2=129;
                    }
                    ctx.beginPath();
                    ctx.arc(dotX, dotY2, 10, 0, Math.PI*2);
                    ctx.fillStyle = "rgba("+dotR+","+dotG+","+dotB2+",0.18)"; ctx.fill();
                    ctx.beginPath();
                    ctx.arc(dotX, dotY2, 5, 0, Math.PI*2);
                    ctx.fillStyle = "rgba("+dotR+","+dotG+","+dotB2+",1.0)"; ctx.fill();

                    // ── Labels above arrows ─────────────────────────────
                    var arrowLabels = [["ecall","scause←8"],["save regs","load kstack"],["dispatch","scause?"],["sret setup","restore regs"]];
                    var arrowMidX = [(cx0+cx1)/2, (cx1+cx2)/2, (cx2+cx3)/2];
                    ctx.font = "8px Consolas"; ctx.textAlign = "center";
                    for(var ai = 0; ai < 3; ai++) {
                        ctx.fillStyle = "rgba(255,255,255,0.28)";
                        ctx.fillText(arrowLabels[ai][0], arrowMidX[ai], bY - bH/2 - 14);
                        ctx.fillStyle = "rgba(255,255,255,0.18)";
                        ctx.fillText(arrowLabels[ai][1], arrowMidX[ai], bY - bH/2 - 4);
                    }
                }

                function roundRect(ctx, x, y, w2, h2, r) {
                    ctx.beginPath();
                    ctx.moveTo(x+r, y);
                    ctx.lineTo(x+w2-r, y);
                    ctx.quadraticCurveTo(x+w2, y, x+w2, y+r);
                    ctx.lineTo(x+w2, y+h2-r);
                    ctx.quadraticCurveTo(x+w2, y+h2, x+w2-r, y+h2);
                    ctx.lineTo(x+r, y+h2);
                    ctx.quadraticCurveTo(x, y+h2, x, y+h2-r);
                    ctx.lineTo(x, y+r);
                    ctx.quadraticCurveTo(x, y, x+r, y);
                    ctx.closePath();
                }
            }
        }

        // ── ACCORDION CARDS ─────────────────────────────────────────────
        Column {
            width: parent.width
            spacing: 7

            Repeater {
                model: 5
                delegate: Rectangle {
                    id: accordCard
                    property bool isOpen: scrollRoot.openCard === index
                    width: parent.width
                    height: isOpen ? cardBodyRow.implicitHeight + 84 : 56
                    clip: true
                    radius: 12
                    color: Qt.rgba(255,255,255,0.02)
                    border.color: isOpen ? scrollRoot.cardColors[index] : Qt.rgba(scrollRoot.cardR[index]/255, scrollRoot.cardG[index]/255, scrollRoot.cardB[index]/255, 0.22)
                    border.width: isOpen ? 1.5 : 1

                    Behavior on height { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 160 } }

                    // ── Header row ──────────────────────────────────────
                    Rectangle {
                        id: cardHeader
                        width: parent.width; height: 56
                        color: "transparent"

                        // Left accent bar
                        Rectangle {
                            width: 4; height: parent.height
                            anchors.left: parent.left
                            radius: 2
                            color: scrollRoot.cardColors[index]
                            opacity: accordCard.isOpen ? 1.0 : 0.5
                        }

                        Row {
                            anchors.left: parent.left; anchors.leftMargin: 16
                            anchors.right: chevron.left; anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 12

                            // Number badge
                            Rectangle {
                                width: 28; height: 28; radius: 8
                                color: Qt.rgba(scrollRoot.cardR[index]/255, scrollRoot.cardG[index]/255, scrollRoot.cardB[index]/255, 0.18)
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    anchors.centerIn: parent
                                    text: "0" + (index + 1)
                                    color: scrollRoot.cardColors[index]
                                    font.bold: true; font.pixelSize: 11; font.family: "Consolas"
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                Text {
                                    text: scrollRoot.cardTitles[index]
                                    color: accordCard.isOpen ? scrollRoot.cardColors[index] : "#ffffff"
                                    font.bold: true; font.pixelSize: 13; font.letterSpacing: 0.3
                                    Behavior on color { ColorAnimation { duration: 160 } }
                                }
                                Text {
                                    text: scrollRoot.cardSubs[index]
                                    color: Qt.rgba(255,255,255,0.35); font.pixelSize: 10
                                }
                            }
                        }

                        // Chevron icon
                        Text {
                            id: chevron
                            text: accordCard.isOpen ? "▲" : "▼"
                            color: Qt.rgba(255,255,255,0.35); font.pixelSize: 10
                            anchors.right: parent.right; anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onEntered: scrollRoot.hoveredCard = index
                            onExited: scrollRoot.hoveredCard = -1
                            onClicked: scrollRoot.openCard = accordCard.isOpen ? -1 : index
                        }
                    }

                    // ── Body ────────────────────────────────────────────
                    Row {
                        id: cardBodyRow
                        anchors.top: cardHeader.bottom; anchors.topMargin: 12
                        anchors.left: parent.left; anchors.leftMargin: 16
                        anchors.right: parent.right; anchors.rightMargin: 16
                        spacing: 14

                        Column {
                            width: (parent.width - 14) * 0.42
                            spacing: 10
                            Row {
                                spacing: 8
                                Text { text: scrollRoot.cardSources[index]; color: scrollRoot.cardColors[index]; font.family:"Consolas"; font.pixelSize:10; font.bold:true; anchors.verticalCenter:parent.verticalCenter }
                            }
                            Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.06) }
                            Text {
                                width: parent.width
                                text: scrollRoot.cardTheories[index]
                                color: Qt.rgba(255,255,255,0.78)
                                wrapMode: Text.WordWrap
                                font.family:"Segoe UI"; font.pixelSize:12; lineHeight:1.55
                            }
                        }

                        Rectangle {
                            width: (parent.width - 14) * 0.58
                            height: bodyCode.implicitHeight + 34
                            color: Qt.rgba(0,0,0,0.28); radius: 10
                            border.color: Qt.rgba(255,255,255,0.06); border.width: 1

                            Rectangle {
                                width: parent.width; height: 24
                                color: Qt.rgba(255,255,255,0.04); radius: 10
                                Rectangle { width:parent.width; height:12; anchors.bottom:parent.bottom; color:parent.color }
                                Row {
                                    anchors.left:parent.left; anchors.leftMargin:10
                                    anchors.verticalCenter:parent.verticalCenter; spacing:5
                                    Repeater { model:3; delegate: Rectangle { width:7;height:7;radius:3.5; color:["#f43f5e","#fbbf24","#10b981"][index]; opacity:0.7 } }
                                }
                                Text { text:scrollRoot.cardSources[index]; color:Qt.rgba(255,255,255,0.25); font.pixelSize:9; font.family:"Consolas"; anchors.centerIn:parent }
                            }
                            Text {
                                id: bodyCode
                                anchors.top:parent.top; anchors.topMargin:30
                                anchors.left:parent.left; anchors.leftMargin:12
                                anchors.right:parent.right; anchors.rightMargin:12
                                text: scrollRoot.cardCodes[index]
                                color: Qt.rgba(255,255,255,0.82)
                                font.family:"Consolas"; font.pixelSize:11
                                wrapMode:Text.WrapAtWordBoundaryOrAnywhere; lineHeight:1.5
                            }
                        }
                    }
                }
            }
        }

        // ── TRAP TYPE SIMULATOR ─────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: simInner.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(249,115,22,0.2); border.width: 1

            Column {
                id: simInner
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 14

                Row {
                    spacing: 10
                    Text { text:"🔬"; font.pixelSize:18; anchors.verticalCenter:parent.verticalCenter }
                    Column {
                        spacing: 2
                        Text { text:"TRAP TYPE EXPLORER — select a trap cause and trace its path"; color:"#f97316"; font.bold:true; font.pixelSize:13; font.letterSpacing:0.3 }
                        Text { text:"Each type sets a different scause, fires a different handler, and has a different resolution"; color:Qt.rgba(255,255,255,0.35); font.pixelSize:11 }
                    }
                }

                Row {
                    width: parent.width; spacing: 10
                    Repeater {
                        model: 3
                        delegate: Rectangle {
                            property bool active: scrollRoot.trapType === index
                            width: (parent.width - 20) / 3; height: 68; radius: 10
                            color: active ? Qt.rgba(scrollRoot.trapTypeTR[index]/255, scrollRoot.trapTypeTG[index]/255, scrollRoot.trapTypeTB[index]/255, 0.16) : Qt.rgba(255,255,255,0.03)
                            border.color: active ? scrollRoot.trapTypeColors[index] : Qt.rgba(scrollRoot.trapTypeTR[index]/255, scrollRoot.trapTypeTG[index]/255, scrollRoot.trapTypeTB[index]/255, 0.28)
                            border.width: active ? 2 : 1
                            Behavior on color { ColorAnimation { duration:150 } }
                            Behavior on border.color { ColorAnimation { duration:150 } }
                            Row {
                                anchors.centerIn: parent; spacing: 10
                                Text { text:scrollRoot.trapTypeIcons[index]; font.pixelSize:20; anchors.verticalCenter:parent.verticalCenter }
                                Column {
                                    anchors.verticalCenter:parent.verticalCenter; spacing:3
                                    Text { text:scrollRoot.trapTypeNames[index]; color:active ? scrollRoot.trapTypeColors[index] : Qt.rgba(255,255,255,0.65); font.bold:true; font.pixelSize:11; font.letterSpacing:0.3 }
                                    Text { text:"scause = " + scrollRoot.trapTypeScause[index]; color:Qt.rgba(255,255,255,0.3); font.family:"Consolas"; font.pixelSize:9 }
                                }
                            }
                            MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:scrollRoot.trapType = index }
                        }
                    }
                }

                Rectangle {
                    width: parent.width; height: trapResult.implicitHeight + 28
                    color: Qt.rgba(scrollRoot.trapTypeTR[scrollRoot.trapType]/255, scrollRoot.trapTypeTG[scrollRoot.trapType]/255, scrollRoot.trapTypeTB[scrollRoot.trapType]/255, 0.08)
                    radius: 10
                    border.color: Qt.rgba(scrollRoot.trapTypeTR[scrollRoot.trapType]/255, scrollRoot.trapTypeTG[scrollRoot.trapType]/255, scrollRoot.trapTypeTB[scrollRoot.trapType]/255, 0.3)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration:200 } }
                    Behavior on border.color { ColorAnimation { duration:200 } }

                    Column {
                        id: trapResult
                        anchors.left:parent.left; anchors.leftMargin:16
                        anchors.right:parent.right; anchors.rightMargin:16
                        anchors.verticalCenter:parent.verticalCenter
                        spacing: 8

                        Text {
                            text: "PATH:  " + scrollRoot.trapTypePath[scrollRoot.trapType]
                            color: scrollRoot.trapTypeColors[scrollRoot.trapType]
                            font.family:"Consolas"; font.pixelSize:11; font.bold:true; width:parent.width; wrapMode:Text.WordWrap
                        }
                        Text {
                            text: scrollRoot.trapTypeResult[scrollRoot.trapType]
                            color: Qt.rgba(255,255,255,0.72); font.family:"Segoe UI"; font.pixelSize:12; width:parent.width; wrapMode:Text.WordWrap; lineHeight:1.4
                        }
                    }
                }
            }
        }

        // ── scause QUICK-REF TABLE ──────────────────────────────────────
        Rectangle {
            width: parent.width
            height: causeTableCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(255,255,255,0.07); border.width: 1

            Column {
                id: causeTableCol
                anchors.top:parent.top; anchors.topMargin:16
                anchors.left:parent.left; anchors.leftMargin:16
                anchors.right:parent.right; anchors.rightMargin:16
                spacing: 5

                Row { spacing:8
                    Text { text:"📋"; font.pixelSize:14 }
                    Text { text:"scause QUICK REFERENCE — codes written by hardware on every trap"; color:Qt.rgba(249,115,22,0.7); font.bold:true; font.pixelSize:11; font.letterSpacing:0.4; anchors.verticalCenter:parent.verticalCenter }
                }
                Row {
                    width:parent.width; spacing:0
                    Rectangle { width:100;height:24;color:Qt.rgba(249,115,22,0.13); Text{text:"scause";color:"#f97316";font.bold:true;font.pixelSize:10;font.letterSpacing:0.5;anchors.left:parent.left;anchors.leftMargin:8;anchors.verticalCenter:parent.verticalCenter} }
                    Rectangle { width:50; height:24;color:Qt.rgba(249,115,22,0.09); Text{text:"MODE"; color:"#f97316";font.bold:true;font.pixelSize:10;anchors.centerIn:parent} }
                    Rectangle { width:parent.width-150;height:24;color:Qt.rgba(249,115,22,0.07); Text{text:"DESCRIPTION";color:"#f97316";font.bold:true;font.pixelSize:10;font.letterSpacing:0.4;anchors.left:parent.left;anchors.leftMargin:10;anchors.verticalCenter:parent.verticalCenter} }
                }
                Rectangle { width:parent.width;height:1;color:Qt.rgba(255,255,255,0.06) }
                Repeater {
                    model: scrollRoot.causeVals.length
                    delegate: Rectangle {
                        width:parent.width;height:26;radius:4
                        color: scrollRoot.hoveredRow===index ? Qt.rgba(249/255,115/255,22/255,0.08) : (index%2===0 ? Qt.rgba(255,255,255,0.02) : Qt.rgba(255,255,255,0.035))
                        Behavior on color { ColorAnimation { duration:120 } }
                        MouseArea { anchors.fill:parent;hoverEnabled:true;onEntered:scrollRoot.hoveredRow=index;onExited:scrollRoot.hoveredRow=-1 }
                        Row {
                            anchors.fill:parent; spacing:0
                            Rectangle { width:100;height:parent.height;color:"transparent"; Text{text:scrollRoot.causeVals[index];color:scrollRoot.causeColors[index];font.family:"Consolas";font.pixelSize:11;font.bold:true;anchors.left:parent.left;anchors.leftMargin:8;anchors.verticalCenter:parent.verticalCenter} }
                            Rectangle { width:50; height:parent.height;color:"transparent"; Text{text:scrollRoot.causeModes[index];color:Qt.rgba(255,255,255,0.35);font.family:"Consolas";font.pixelSize:10;anchors.centerIn:parent} }
                            Rectangle { width:parent.width-150;height:parent.height;color:"transparent"; Text{text:scrollRoot.causeNames[index];color:Qt.rgba(255,255,255,0.65);font.pixelSize:11;anchors.left:parent.left;anchors.leftMargin:10;anchors.verticalCenter:parent.verticalCenter} }
                        }
                    }
                }
            }
        }

        // ── TAKEAWAY FOOTER ─────────────────────────────────────────────

        // ── TRAP TYPE SELECTOR & HANDLER TRACE ─────────────────────────
        Rectangle {
            id: trapSim
            width:parent.width; height:trapSelCol.implicitHeight+32
            color:Qt.rgba(255,255,255,0.015); radius:14
            border.color:Qt.rgba(244,63,94,0.2); border.width:1

            property int selTrap: 0

            property var trapTypes: [
                {name:"Timer Interrupt",   icon:"⏱", scause:"0x8000_0001", color:"#10b981",
                 what:"RISC-V timer chip fires. sstatus.SIE=1 allows it. CPU vectored to stvec (trampoline).",
                 handler:"devintr() → clockintr() → yield()",
                 effect:"yield() sets p→state=RUNNABLE, calls sched() → Round-Robin preemption",
                 kernel:"kernel/trap.c: clockintr(); kernel/proc.c: yield()"},
                {name:"System Call (ecall)",icon:"💻", scause:"8",           color:"#a78bfa",
                 what:"User code executes 'ecall'. Fires synchronous trap. sepc saved, PC→stvec.",
                 handler:"usertrap() → syscall()",
                 effect:"Reads a7 (syscall #), dispatches to handler, stores result in trapframe→a0",
                 kernel:"kernel/trap.c: usertrap(); kernel/syscall.c: syscall()"},
                {name:"Page Fault",        icon:"❌", scause:"12/13/15",     color:"#f43f5e",
                 what:"Load/store/fetch on unmapped or protected VA. stval holds the faulting address.",
                 handler:"usertrap() → p→killed=1",
                 effect:"xv6 does not handle page faults — it kills the process immediately",
                 kernel:"kernel/trap.c: usertrap() default case"},
                {name:"Illegal Instruction",icon:"⛔", scause:"2",          color:"#fbbf24",
                 what:"CPU decoded an invalid opcode, or user code tried a privileged instruction.",
                 handler:"usertrap() → p→killed=1",
                 effect:"Process is terminated. sepc holds the address of the bad instruction.",
                 kernel:"kernel/trap.c: usertrap() default case"},
                {name:"UART/Disk Interrupt",icon:"💾", scause:"0x8000_0009",color:"#06b6d4",
                 what:"External device interrupt via PLIC. devintr() reads PLIC claim to find device.",
                 handler:"devintr() → uartintr() or virtio_disk_intr()",
                 effect:"Wakes up sleeping process waiting for I/O. PLIC claim written to complete.",
                 kernel:"kernel/trap.c: devintr(); kernel/uart.c; kernel/virtio_disk.c"}
            ]

            property var cur: trapTypes[selTrap]

            Column {
                id:trapSelCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing:14

                Row { spacing:10
                    Text { text:"⚡"; font.pixelSize:18; anchors.verticalCenter:parent.verticalCenter }
                    Column { spacing:2
                        Text { text:"TRAP TYPE EXPLORER — click any trap to trace its full path"; color:"#f43f5e"; font.bold:true; font.pixelSize:13 }
                        Text { text:"All traps enter the kernel the same way (stvec→uservec) but diverge based on scause"; color:Qt.rgba(255,255,255,0.32); font.pixelSize:11 }
                    }
                }

                // Trap type pills
                Row { spacing:8; width:parent.width
                    Repeater {
                        model: trapSim.trapTypes
                        delegate: Rectangle {
                            property bool active: trapSim.selTrap === index
                            height:42; width:trapPillCol.implicitWidth+20; radius:10
                            color:active?Qt.rgba(244/255,63/255,94/255,0.15):Qt.rgba(255,255,255,0.04)
                            border.color:active?modelData.color:Qt.rgba(255,255,255,0.1); border.width:active?1.5:1
                            Behavior on color{ColorAnimation{duration:120}}
                            Column { id:trapPillCol; anchors.centerIn:parent; spacing:2
                                Text { text:modelData.icon+" "+modelData.name; color:active?modelData.color:"#ffffff"; font.pixelSize:11; font.bold:true; anchors.horizontalCenter:parent }
                                Text { text:"scause="+modelData.scause; color:Qt.rgba(255,255,255,0.3); font.pixelSize:9; font.family:"Consolas"; anchors.horizontalCenter:parent }
                            }
                            MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:trapSim.selTrap=index }
                        }
                    }
                }

                // Detail cards
                Rectangle {
                    width:parent.width; height:trapDetail.implicitHeight+24; radius:10
                    color:Qt.rgba(0,0,0,0.2); border.color:parent.cur.color; border.width:1
                    Column {
                        id:trapDetail
                        anchors.top:parent.top; anchors.topMargin:14
                        anchors.left:parent.left; anchors.leftMargin:16
                        anchors.right:parent.right; anchors.rightMargin:16
                        spacing:10
                        Row { spacing:10
                            Rectangle{width:10;height:10;radius:5;color:trapSim.cur.color;anchors.verticalCenter:parent.verticalCenter}
                            Text { text:trapSim.cur.name; color:trapSim.cur.color; font.bold:true; font.pixelSize:14 }
                        }
                        Repeater {
                            model:[
                                {label:"WHAT HAPPENS", key:"what"},
                                {label:"HANDLER CHAIN", key:"handler"},
                                {label:"EFFECT",        key:"effect"},
                                {label:"SOURCE FILES",  key:"kernel"}
                            ]
                            delegate: Row { width:parent.width; spacing:12
                                Text { text:modelData.label; color:Qt.rgba(255,255,255,0.3); font.pixelSize:9; font.bold:true; font.letterSpacing:0.6; width:90; topPadding:2 }
                                Text {
                                    width:parent.width-102
                                    text: {
                                        var c = trapSim.cur
                                        return c[modelData.key]
                                    }
                                    color:Qt.rgba(255,255,255,0.75); font.pixelSize:11; wrapMode:Text.WordWrap; lineHeight:1.5; font.family:modelData.key==="kernel"?"Consolas":"Segoe UI"
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            width:parent.width; height:65
            color:Qt.rgba(249/255,115/255,22/255,0.08); radius:14
            border.color:Qt.rgba(249/255,115/255,22/255,0.35); border.width:1

            RowLayout {
                anchors.fill:parent; anchors.margins:15; spacing:15
                Text { text:"🌟"; font.pixelSize:22; Layout.alignment:Qt.AlignVCenter }
                Text {
                    Layout.fillWidth:true; Layout.alignment:Qt.AlignVCenter
                    text: "CORE SUMMARY: Every xv6 trap (syscall/exception/interrupt) follows one path — stvec→uservec (trampoline saves regs)→usertrap (dispatches on scause)→usertrapret (sets up sret)→userret (restores regs, sret back to U-mode). The trampoline page is the key: mapped at the same VA in both page tables so switching satp mid-stream never crashes."
                    color:"#ffffff"; wrapMode:Text.WordWrap; font.family:"Segoe UI"; font.bold:true; font.pixelSize:12; font.letterSpacing:0.2
                }
            }
        }

    }
}
