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

    property int  activeTL:    0
    property int  selectedVA:  0
    property int  hoveredRow:  -1
    property real memDot:      0.0

    // ── Timeline data (5 steps) ───────────────────────────────────────
    property var tlColors:  ["#3b82f6","#8b5cf6","#06b6d4","#10b981","#f97316"]
    property var tlR: [59,  139, 6,   16,  249]
    property var tlG: [130, 92,  182, 185, 115]
    property var tlB: [246, 246, 212, 129, 22]
    property var tlTitles: ["Sv39 ADDRESS FORMAT","THREE-LEVEL WALK","PTE STRUCTURE","satp REGISTER & TLB","xv6 VM FUNCTIONS"]
    property var tlSubs: [
        "39-bit VA splits into VPN[2]+VPN[1]+VPN[0]+offset",
        "satp.PPN → L2 → L1 → L0 → Physical Page",
        "64-bit entry: PPN (53:10) + V/R/W/X/U/G/A/D flags",
        "MODE=Sv39, PPN of root table, sfence.vma after write",
        "walk(), mappages(), walkaddr(), kvmmap()"
    ]
    property var tlSources: ["kernel/riscv.h","kernel/vm.c","kernel/riscv.h","kernel/riscv.h + vm.c","kernel/vm.c"]
    property var tlOpenH:   [310, 350, 330, 330, 360]
    property var tlTheories: [
        "RISC-V Sv39 uses 39-bit virtual addresses and 56-bit physical addresses. A 39-bit VA is divided into four fields: VPN[2] (bits 38:30, 9 bits), VPN[1] (bits 29:21, 9 bits), VPN[0] (bits 20:12, 9 bits), and page offset (bits 11:0, 12 bits). Each 9-bit VPN is used as an index into a 512-entry page table (each entry is 8 bytes, so one table = 512 × 8 = 4096 bytes = exactly one page). The 12-bit offset means every page is 4096 bytes (PGSIZE). The 56-bit physical address is: PPN[2:0] (44 bits, stored in PTE bits 53:10) concatenated with the 12-bit offset. xv6 sets MAXVA = 2^38 (not 2^39) to avoid sign-extension issues in some hardware implementations.",
        "Translation starts at the root L2 table whose base = satp.PPN × 4096. Step 1: index L2 with VPN[2] → read PTE → extract PPN → L1 base = PPN × 4096. Step 2: index L1 with VPN[1] → read PTE → L0 base = PPN × 4096. Step 3: index L0 with VPN[0] → read PTE → if V=1 and R|W|X set (leaf PTE), final PA = PTE.PPN × 4096 + VA offset. At any step, if V=0 → page fault. If V=1 and R=W=X=0 → non-leaf, descend further. The hardware MMU performs this walk automatically on every memory access; walk() in vm.c replicates it in software for page table management.",
        "Each PTE is a 64-bit unsigned integer. Bits 53:10 store the PPN (Physical Page Number). Bits 9:0 are flags: V (bit 0) = valid — entry is in use; R (bit 1) = readable; W (bit 2) = writable; X (bit 3) = executable; U (bit 4) = user-accessible (kernel pages have U=0); G (bit 5) = global (shared across all ASIDs); A (bit 6) = accessed (set by hardware on read); D (bit 7) = dirty (set by hardware on write). A PTE with V=1 but R=W=X=0 is a non-leaf pointer to the next level. A PTE with V=1 and any R/W/X set is a leaf. xv6 uses PA2PTE() to pack a physical address into a PTE and PTE2PA() to unpack it.",
        "The satp (Supervisor Address Translation and Protection) CSR activates and controls virtual memory. Fields: MODE (bits 63:60) = 8 for Sv39 (0 = no translation); ASID (bits 59:44) = Address Space ID for TLB disambiguation (xv6 always uses ASID=0); PPN (bits 43:0) = physical page number of the root L2 page table. Writing satp instantly switches address spaces. The TLB caches recent VA→PA translations; after writing satp or modifying any PTE, execute sfence.vma (or sfence.vma rs1, rs2 for targeted flushes) to invalidate stale TLB entries. In xv6, every context switch calls w_satp(MAKE_SATP(p->pagetable)) + sfence_vma().",
        "xv6 provides a clean VM API built on five core functions. walk(pt, va, alloc): software walk returning the L0 PTE pointer; if alloc=1, creates missing levels with kalloc(). mappages(pt, va, size, pa, perm): calls walk() for each page and writes PA2PTE(pa)|perm|PTE_V. kvmmap(kpgtbl, va, pa, size, perm): wrapper for kernel page table setup. walkaddr(pt, va): walk + validity check + PTE_U check — used by copyin/copyout to safely copy between kernel and user space. uvmcreate(): allocates a new empty page table. uvmfree(pt, size): unmaps + frees all user pages then the table itself. These six functions handle all of xv6's virtual memory lifecycle."
    ]
    property var tlCodes: [
        "// kernel/riscv.h — Sv39 address layout\n#define PGSIZE   4096        // 2^12\n#define PGSHIFT  12          // offset bits\n#define PXMASK   0x1FF       // 9-bit mask\n\n// Extract VPN[level] from virtual address\n#define PX(level, va) \\\n    (((va) >> (PGSHIFT + 9*(level))) & PXMASK)\n// PX(2, va) = bits [38:30]  VPN[2]\n// PX(1, va) = bits [29:21]  VPN[1]\n// PX(0, va) = bits [20:12]  VPN[0]\n\n#define MAXVA (1L << (9+9+9+12-1))  // 2^38\n\n// Physical address <-> PTE conversion\n#define PA2PTE(pa)  ((((uint64)pa) >> 12) << 10)\n#define PTE2PA(pte) (((pte) >> 10) << 12)\n#define PTE_FLAGS(pte) ((pte) & 0x3FF)",
        "// kernel/vm.c — software page table walk\npte_t *walk(pagetable_t pt, uint64 va, int alloc) {\n    for(int level = 2; level > 0; level--) {\n        pte_t *pte = &pt[PX(level, va)];\n        if(*pte & PTE_V) {\n            // non-leaf: follow PPN to next table\n            pt = (pagetable_t)PTE2PA(*pte);\n        } else {\n            // missing: allocate new page\n            if(!alloc) return 0;\n            pt = (pde_t*)kalloc();\n            memset(pt, 0, PGSIZE);\n            *pte = PA2PTE(pt) | PTE_V;\n        }\n    }\n    // Return pointer to the L0 PTE\n    return &pt[PX(0, va)];\n}",
        "// kernel/riscv.h — PTE bit flags\n// bit 63..54  reserved\n// bit 53..10  PPN (physical page number)\n// bit  9..8   RSW (reserved for supervisor)\n// bit  7      D — dirty (hw sets on write)\n// bit  6      A — accessed (hw sets on read)\n// bit  5      G — global (shared ASID)\n// bit  4      U — user-accessible\n// bit  3      X — executable\n// bit  2      W — writable\n// bit  1      R — readable\n// bit  0      V — valid\n\n#define PTE_V (1L << 0)\n#define PTE_R (1L << 1)\n#define PTE_W (1L << 2)\n#define PTE_X (1L << 3)\n#define PTE_U (1L << 4)\n#define PTE_G (1L << 5)\n// Non-leaf: V=1, R=W=X=0\n// Leaf:     V=1, at least one of R/W/X set",
        "// kernel/riscv.h\n#define SATP_SV39 (8L << 60)  // MODE = Sv39\n#define MAKE_SATP(pt) \\\n    (SATP_SV39 | (((uint64)(pt)) >> 12))\n\n// kernel/vm.c — activate kernel page table\nvoid kvminithart() {\n    sfence_vma();                    // flush TLB\n    w_satp(MAKE_SATP(kernel_pagetable));\n    sfence_vma();                    // flush again\n}\n\n// kernel/proc.c — switch per-process table\nvoid scheduler(void) {\n    // ...inside scheduling loop...\n    w_satp(MAKE_SATP(p->pagetable));\n    sfence_vma();  // MUST flush after every switch\n    swtch(&c->context, &p->context);\n    // After return: back to kernel page table\n    kvminithart();\n}",
        "// kernel/vm.c — core VM operations\n\n// Map [va, va+size) -> [pa, pa+size)\nint mappages(pagetable_t pt, uint64 va,\n             uint64 size, uint64 pa, int perm) {\n    for(uint64 a=PGROUNDDOWN(va);\n            a < va+size; a+=PGSIZE, pa+=PGSIZE) {\n        pte_t *pte = walk(pt, a, 1);\n        if(!pte) return -1;\n        if(*pte & PTE_V) panic(\"remap\");\n        *pte = PA2PTE(pa) | perm | PTE_V;\n    }\n    return 0;\n}\n\n// Translate user VA -> PA (safe, checks PTE_U)\nuint64 walkaddr(pagetable_t pt, uint64 va) {\n    pte_t *pte = walk(pt, va, 0);\n    if(!pte || !(*pte & PTE_V)) return 0;\n    if(!(*pte & PTE_U)) return 0; // kernel-only!\n    return PTE2PA(*pte);\n}"
    ]

    // ── VA Decoder data ───────────────────────────────────────────────
    property var vaNames:  ["kernel text", "user code", "trapframe VA", "trampoline VA"]
    property var vaHex:    ["0x80001000", "0x00001000", "0x3FFFFE000", "0x3FFFFF000"]
    property var vaVPN2:   ["0x200", "0x000", "0x1FF", "0x1FF"]
    property var vaVPN1:   ["0x000", "0x000", "0x1FF", "0x1FF"]
    property var vaVPN0:   ["0x001", "0x001", "0x1FE", "0x1FF"]
    property var vaOff:    ["0x000", "0x000", "0x000", "0x000"]
    property var vaDescs:  [
        "Kernel code — VA=PA (identity mapped in xv6 kernel address space)",
        "User process code page 1 — mapped to an arbitrary physical page by exec()",
        "Trapframe page just below trampoline — saved during every trap",
        "Trampoline at top of every address space — same VA in user + kernel tables"
    ]

    // ── PTE flags data ────────────────────────────────────────────────
    property bool pteV: true;  property bool pteR: true
    property bool pteW: false; property bool pteX: false
    property bool pteU: false; property bool pteG: false

    Timer {
        interval: 20; running: true; repeat: true
        onTriggered: scrollRoot.memDot = (scrollRoot.memDot + 0.006) % 1.0
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
            border.color: Qt.rgba(59,130,246,0.25); border.width: 1
            layer.enabled: true
            layer.effect: Glow { radius:10; samples:17; color:Qt.rgba(59,130,246,0.12); spread:0.1 }
            Row {
                anchors.fill: parent; anchors.margins: 15; spacing: 16
                Rectangle {
                    width: 52; height: 52; radius: 12
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(59,130,246,0.15); border.color: Qt.rgba(59,130,246,0.4); border.width: 1
                    Column {
                        anchors.centerIn: parent; spacing: 1
                        Text { text:"06"; color:"#3b82f6"; font.bold:true; font.pixelSize:20; font.family:"Consolas"; anchors.horizontalCenter:parent }
                        Text { text:"LESSON"; color:Qt.rgba(59,130,246,0.5); font.pixelSize:7; font.letterSpacing:1; anchors.horizontalCenter:parent }
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 6
                    Text {
                        text: "MEMORY TRANSLATION — Sv39 Three-Level Page Tables"
                        color: "#ffffff"; font.family:"Segoe UI"; font.bold:true; font.pixelSize:20; font.letterSpacing:0.5
                    }
                    Text {
                        text: "How xv6 translates 39-bit virtual addresses to 56-bit physical addresses through three levels of page tables, PTEs, and the satp register."
                        color: Qt.rgba(255,255,255,0.55); font.family:"Segoe UI"; font.pixelSize:12
                    }
                }
            }
        }

        // ── CANVAS — 3-level walk animation ─────────────────────────────
        Rectangle {
            width: parent.width; height: 190
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(59,130,246,0.15); border.width: 1

            Text {
                text: "LIVE — VA walks through L2 → L1 → L0 to produce a Physical Address"
                color: Qt.rgba(59,130,246,0.55); font.pixelSize:10; font.bold:true; font.letterSpacing:0.8
                anchors.top:parent.top; anchors.topMargin:9; anchors.horizontalCenter:parent.horizontalCenter
            }

            Canvas {
                id: memCanvas
                anchors.fill: parent
                property real dot: scrollRoot.memDot
                onDotChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d"); ctx.reset();
                    var w = width, h = height;
                    var t = dot;

                    var bW = w*0.14, bH = 40, bY = h*0.50;
                    var cxs = [w*0.08, w*0.27, w*0.50, w*0.73, w*0.92];
                    var bLabels = ["VA\n39 bits","L2 Table\nVPN[2]","L1 Table\nVPN[1]","L0 Table\nVPN[0]","Physical\nPage"];
                    var bR=[167,59,6,16,16]; var bG=[139,130,182,185,185]; var bB=[250,246,212,129,129];

                    // phases
                    var phaseAt  = [t<0.12||t>=0.94, t>=0.24&&t<0.38, t>=0.50&&t<0.62, t>=0.72&&t<0.84, t>=0.84&&t<0.94];
                    // arrows + labels
                    var arrowLbls = [["VPN[2]","PX(2,va)"],["PTE.PPN","×PGSIZE"],["PTE.PPN","×PGSIZE"],["PTE.PPN","+offset"]];
                    ctx.lineWidth = 1.5;
                    for(var i=0;i<4;i++) {
                        var ax=cxs[i]+bW/2+3, bx2=cxs[i+1]-bW/2-3, ay=bY;
                        ctx.strokeStyle="rgba(255,255,255,0.12)"; ctx.beginPath(); ctx.moveTo(ax,ay); ctx.lineTo(bx2,ay); ctx.stroke();
                        ctx.fillStyle="rgba(255,255,255,0.12)"; ctx.beginPath(); ctx.moveTo(bx2-7,ay-4); ctx.lineTo(bx2,ay); ctx.lineTo(bx2-7,ay+4); ctx.fill();
                        var mx=(ax+bx2)/2;
                        ctx.fillStyle="rgba(255,255,255,0.30)"; ctx.font="8px Consolas"; ctx.textAlign="center";
                        ctx.fillText(arrowLbls[i][0], mx, bY-bH/2-13);
                        ctx.fillStyle="rgba(255,255,255,0.18)";
                        ctx.fillText(arrowLbls[i][1], mx, bY-bH/2-3);
                    }
                    // boxes
                    for(var bi=0;bi<5;bi++) {
                        var pulse = phaseAt[bi] ? (0.55+0.38*Math.sin(t*Math.PI*10)) : 0.28;
                        ctx.beginPath(); roundRect(ctx,cxs[bi]-bW/2,bY-bH/2,bW,bH,7);
                        ctx.strokeStyle="rgba("+bR[bi]+","+bG[bi]+","+bB[bi]+","+pulse+")";
                        ctx.lineWidth = phaseAt[bi]?2:1.2; ctx.stroke();
                        ctx.fillStyle="rgba("+bR[bi]+","+bG[bi]+","+bB[bi]+","+(phaseAt[bi]?0.14:0.05)+")"; ctx.fill();
                        var lines=bLabels[bi].split("\n");
                        ctx.fillStyle="rgba("+bR[bi]+","+bG[bi]+","+bB[bi]+","+(phaseAt[bi]?1.0:0.6)+")";
                        ctx.font="bold 9px Consolas"; ctx.textAlign="center";
                        ctx.fillText(lines[0],cxs[bi],bY-4);
                        ctx.fillStyle="rgba(255,255,255,0.32)"; ctx.font="8px Consolas";
                        ctx.fillText(lines[1]||"",cxs[bi],bY+9);
                    }
                    // dot
                    var dotX, dotY2, dR, dG, dB;
                    if(t<0.12||t>=0.94){dotX=cxs[0];dotY2=bY;dR=167;dG=139;dB=250;}
                    else if(t<0.24){var p=((t-0.12)/0.12);dotX=cxs[0]+p*(cxs[1]-cxs[0]);dotY2=bY;dR=167;dG=139;dB=250;}
                    else if(t<0.38){dotX=cxs[1];dotY2=bY;dR=59;dG=130;dB=246;}
                    else if(t<0.50){var p2=(t-0.38)/0.12;dotX=cxs[1]+p2*(cxs[2]-cxs[1]);dotY2=bY;dR=59;dG=130;dB=246;}
                    else if(t<0.62){dotX=cxs[2];dotY2=bY;dR=6;dG=182;dB=212;}
                    else if(t<0.72){var p3=(t-0.62)/0.10;dotX=cxs[2]+p3*(cxs[3]-cxs[2]);dotY2=bY;dR=6;dG=182;dB=212;}
                    else if(t<0.84){dotX=cxs[3];dotY2=bY;dR=16;dG=185;dB=129;}
                    else{var p4=(t-0.84)/0.10;dotX=cxs[3]+p4*(cxs[4]-cxs[3]);dotY2=bY;dR=16;dG=185;dB=129;}
                    ctx.beginPath(); ctx.arc(dotX,dotY2,10,0,Math.PI*2);
                    ctx.fillStyle="rgba("+dR+","+dG+","+dB+",0.18)"; ctx.fill();
                    ctx.beginPath(); ctx.arc(dotX,dotY2,5,0,Math.PI*2);
                    ctx.fillStyle="rgba("+dR+","+dG+","+dB+",1.0)"; ctx.fill();
                }
                function roundRect(ctx,x,y,w2,h2,r) {
                    ctx.beginPath();
                    ctx.moveTo(x+r,y); ctx.lineTo(x+w2-r,y); ctx.quadraticCurveTo(x+w2,y,x+w2,y+r);
                    ctx.lineTo(x+w2,y+h2-r); ctx.quadraticCurveTo(x+w2,y+h2,x+w2-r,y+h2);
                    ctx.lineTo(x+r,y+h2); ctx.quadraticCurveTo(x,y+h2,x,y+h2-r);
                    ctx.lineTo(x,y+r); ctx.quadraticCurveTo(x,y,x+r,y); ctx.closePath();
                }
            }
        }

        // ── VA BIT DECODER ───────────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: decoderCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(59,130,246,0.2); border.width: 1

            Column {
                id: decoderCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 14

                Row {
                    spacing: 10
                    Text { text:"🔬"; font.pixelSize:18; anchors.verticalCenter:parent.verticalCenter }
                    Column {
                        spacing: 2
                        Text { text:"VA BIT DECODER — select an address and watch how 39 bits split into 4 fields"; color:"#3b82f6"; font.bold:true; font.pixelSize:13; font.letterSpacing:0.3 }
                        Text { text:"Every memory access in Sv39 goes through this exact decomposition in hardware"; color:Qt.rgba(255,255,255,0.35); font.pixelSize:11 }
                    }
                }

                // Preset selector
                Row {
                    spacing: 8
                    Repeater {
                        model: 4
                        delegate: Rectangle {
                            property bool active: scrollRoot.selectedVA === index
                            width: (decoderCol.width - 24) / 4; height: 46; radius: 9
                            color: active ? Qt.rgba(59,130,246,0.18) : Qt.rgba(255,255,255,0.03)
                            border.color: active ? "#3b82f6" : Qt.rgba(255,255,255,0.1)
                            border.width: active ? 1.5 : 1
                            Behavior on color { ColorAnimation { duration:130 } }
                            Behavior on border.color { ColorAnimation { duration:130 } }
                            Column {
                                anchors.centerIn: parent; spacing: 3
                                Text { text:scrollRoot.vaHex[index]; color:active?"#3b82f6":Qt.rgba(255,255,255,0.65); font.family:"Consolas"; font.bold:true; font.pixelSize:11; anchors.horizontalCenter:parent }
                                Text { text:scrollRoot.vaNames[index]; color:Qt.rgba(255,255,255,0.32); font.pixelSize:9; anchors.horizontalCenter:parent }
                            }
                            MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:scrollRoot.selectedVA=index }
                        }
                    }
                }

                // Bit field visual
                Row {
                    width: parent.width; spacing: 0

                    Rectangle {
                        width: parent.width * 9 / 39; height: 54; radius: 0
                        color: Qt.rgba(167/255, 139/255, 250/255, 0.16)
                        border.color: "#a78bfa"; border.width: 1
                        Column { anchors.centerIn:parent; spacing:3
                            Text { text:"VPN[2]"; color:"#a78bfa"; font.bold:true; font.pixelSize:10; font.letterSpacing:0.3; anchors.horizontalCenter:parent }
                            Text { text:"bits 38:30 · 9b"; color:Qt.rgba(255,255,255,0.35); font.pixelSize:8; anchors.horizontalCenter:parent }
                            Text { text:scrollRoot.vaVPN2[scrollRoot.selectedVA]; color:"#a78bfa"; font.family:"Consolas"; font.bold:true; font.pixelSize:13; anchors.horizontalCenter:parent }
                        }
                    }
                    Rectangle {
                        width: parent.width * 9 / 39; height: 54; radius: 0
                        color: Qt.rgba(59/255,130/255,246/255,0.16)
                        border.color: "#3b82f6"; border.width: 1
                        Column { anchors.centerIn:parent; spacing:3
                            Text { text:"VPN[1]"; color:"#3b82f6"; font.bold:true; font.pixelSize:10; font.letterSpacing:0.3; anchors.horizontalCenter:parent }
                            Text { text:"bits 29:21 · 9b"; color:Qt.rgba(255,255,255,0.35); font.pixelSize:8; anchors.horizontalCenter:parent }
                            Text { text:scrollRoot.vaVPN1[scrollRoot.selectedVA]; color:"#3b82f6"; font.family:"Consolas"; font.bold:true; font.pixelSize:13; anchors.horizontalCenter:parent }
                        }
                    }
                    Rectangle {
                        width: parent.width * 9 / 39; height: 54; radius: 0
                        color: Qt.rgba(6/255,182/255,212/255,0.16)
                        border.color: "#06b6d4"; border.width: 1
                        Column { anchors.centerIn:parent; spacing:3
                            Text { text:"VPN[0]"; color:"#06b6d4"; font.bold:true; font.pixelSize:10; font.letterSpacing:0.3; anchors.horizontalCenter:parent }
                            Text { text:"bits 20:12 · 9b"; color:Qt.rgba(255,255,255,0.35); font.pixelSize:8; anchors.horizontalCenter:parent }
                            Text { text:scrollRoot.vaVPN0[scrollRoot.selectedVA]; color:"#06b6d4"; font.family:"Consolas"; font.bold:true; font.pixelSize:13; anchors.horizontalCenter:parent }
                        }
                    }
                    Rectangle {
                        width: parent.width * 12 / 39; height: 54
                        color: Qt.rgba(16/255,185/255,129/255,0.16)
                        border.color: "#10b981"; border.width: 1
                        Column { anchors.centerIn:parent; spacing:3
                            Text { text:"OFFSET"; color:"#10b981"; font.bold:true; font.pixelSize:10; font.letterSpacing:0.3; anchors.horizontalCenter:parent }
                            Text { text:"bits 11:0 · 12b"; color:Qt.rgba(255,255,255,0.35); font.pixelSize:8; anchors.horizontalCenter:parent }
                            Text { text:scrollRoot.vaOff[scrollRoot.selectedVA]; color:"#10b981"; font.family:"Consolas"; font.bold:true; font.pixelSize:13; anchors.horizontalCenter:parent }
                        }
                    }
                }

                Text {
                    width: parent.width
                    text: scrollRoot.vaDescs[scrollRoot.selectedVA]
                    color: Qt.rgba(255,255,255,0.5); font.pixelSize:11; font.family:"Segoe UI"; wrapMode:Text.WordWrap
                }
            }
        }

        // ── VERTICAL TIMELINE ────────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: tlOuter.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.015); radius: 14
            border.color: Qt.rgba(255,255,255,0.07); border.width: 1

            // Vertical guide line
            Rectangle {
                x: 46; y: 28; width: 2
                height: parent.height - 52
                color: Qt.rgba(255,255,255,0.07)
            }

            Column {
                id: tlOuter
                anchors.top:parent.top; anchors.topMargin:16
                anchors.left:parent.left; anchors.leftMargin:16
                anchors.right:parent.right; anchors.rightMargin:16
                spacing: 4

                Text { text:"DEEP DIVE — five topics, click any node to expand"; color:Qt.rgba(59,130,246,0.6); font.bold:true; font.pixelSize:11; font.letterSpacing:0.4; leftPadding:52 }

                Repeater {
                    model: 5
                    delegate: Row {
                        width: parent.width; spacing: 0
                        property bool isOpen: scrollRoot.activeTL === index

                        // Left: circle node
                        Item {
                            width: 64
                            height: Math.max(56, rightBox.height)

                            Rectangle {
                                width: 30; height: 30; radius: 15
                                anchors.top: parent.top; anchors.topMargin: 13
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: isOpen ? scrollRoot.tlColors[index] : Qt.rgba(scrollRoot.tlR[index]/255, scrollRoot.tlG[index]/255, scrollRoot.tlB[index]/255, 0.15)
                                border.color: scrollRoot.tlColors[index]; border.width: isOpen ? 0 : 1.5
                                Behavior on color { ColorAnimation { duration:160 } }
                                Text {
                                    anchors.centerIn: parent
                                    text: (index+1).toString()
                                    color: isOpen ? "#ffffff" : scrollRoot.tlColors[index]
                                    font.bold:true; font.pixelSize:12; font.family:"Consolas"
                                }
                            }
                        }

                        // Right: expandable content
                        Rectangle {
                            id: rightBox
                            width: parent.width - 64
                            height: isOpen ? tlBodyRow.implicitHeight + 74 : 52
                            clip: true; radius: 10
                            color: isOpen ? Qt.rgba(scrollRoot.tlR[index]/255, scrollRoot.tlG[index]/255, scrollRoot.tlB[index]/255, 0.07) : Qt.rgba(255,255,255,0.02)
                            border.color: isOpen ? scrollRoot.tlColors[index] : Qt.rgba(scrollRoot.tlR[index]/255, scrollRoot.tlG[index]/255, scrollRoot.tlB[index]/255, 0.18)
                            border.width: isOpen ? 1.5 : 1

                            Behavior on height { NumberAnimation { duration:270; easing.type:Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration:160 } }

                            // Header (always visible)
                            Row {
                                anchors.left:parent.left; anchors.leftMargin:14
                                anchors.right:chevTL.left; anchors.rightMargin:8
                                anchors.top:parent.top; height:52; spacing:10
                                Column {
                                    anchors.verticalCenter:parent.verticalCenter; spacing:3
                                    Text { text:scrollRoot.tlTitles[index]; color:isOpen?scrollRoot.tlColors[index]:"#ffffff"; font.bold:true; font.pixelSize:12; font.letterSpacing:0.3; Behavior on color{ColorAnimation{duration:160}} }
                                    Text { text:scrollRoot.tlSubs[index]; color:Qt.rgba(255,255,255,0.32); font.pixelSize:9 }
                                }
                            }
                            Text {
                                id: chevTL
                                text: isOpen ? "▲" : "▼"
                                color: Qt.rgba(255,255,255,0.3); font.pixelSize:10
                                anchors.right:parent.right; anchors.rightMargin:14
                                anchors.top:parent.top; anchors.topMargin:21
                            }

                            // Body
                            Row {
                                id: tlBodyRow
                                anchors.top:parent.top; anchors.topMargin:58
                                anchors.left:parent.left; anchors.leftMargin:14
                                anchors.right:parent.right; anchors.rightMargin:14
                                spacing: 12

                                Column {
                                    width: (parent.width-12)*0.42; spacing:10
                                    Text { text:scrollRoot.tlSources[index]; color:scrollRoot.tlColors[index]; font.family:"Consolas"; font.pixelSize:10; font.bold:true }
                                    Rectangle { width:parent.width; height:1; color:Qt.rgba(255,255,255,0.06) }
                                    Text {
                                        width:parent.width
                                        text:scrollRoot.tlTheories[index]
                                        color:Qt.rgba(255,255,255,0.78); wrapMode:Text.WordWrap
                                        font.family:"Segoe UI"; font.pixelSize:11; lineHeight:1.55
                                    }
                                }

                                Rectangle {
                                    width:(parent.width-12)*0.58
                                    height:tlBodyCode.implicitHeight+32
                                    color:Qt.rgba(0,0,0,0.28); radius:9
                                    border.color:Qt.rgba(255,255,255,0.06); border.width:1
                                    Rectangle {
                                        width:parent.width; height:22; color:Qt.rgba(255,255,255,0.04); radius:9
                                        Rectangle{width:parent.width;height:11;anchors.bottom:parent.bottom;color:parent.color}
                                        Row { anchors.left:parent.left;anchors.leftMargin:8;anchors.verticalCenter:parent.verticalCenter;spacing:4
                                            Repeater{model:3;delegate:Rectangle{width:7;height:7;radius:3.5;color:["#f43f5e","#fbbf24","#10b981"][index];opacity:0.7}}
                                        }
                                        Text{text:scrollRoot.tlSources[index];color:Qt.rgba(255,255,255,0.22);font.pixelSize:9;font.family:"Consolas";anchors.centerIn:parent}
                                    }
                                    Text {
                                        id: tlBodyCode
                                        anchors.top:parent.top;anchors.topMargin:28
                                        anchors.left:parent.left;anchors.leftMargin:10
                                        anchors.right:parent.right;anchors.rightMargin:10
                                        text:scrollRoot.tlCodes[index]
                                        color:Qt.rgba(255,255,255,0.82);font.family:"Consolas";font.pixelSize:10
                                        wrapMode:Text.WrapAtWordBoundaryOrAnywhere;lineHeight:1.5
                                    }
                                }
                            }

                            MouseArea {
                                anchors.left:parent.left; anchors.right:parent.right
                                anchors.top:parent.top; height:52
                                cursorShape:Qt.PointingHandCursor
                                onClicked: scrollRoot.activeTL = isOpen ? -1 : index
                            }
                        }
                    }
                }
            }
        }

        // ── PTE FLAGS EXPLORER ───────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: pteCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(59,130,246,0.2); border.width: 1

            Column {
                id: pteCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 14

                Row { spacing:10
                    Text{text:"🔐";font.pixelSize:18;anchors.verticalCenter:parent.verticalCenter}
                    Column {
                        spacing:2
                        Text{text:"PTE FLAGS EXPLORER — toggle bits to see what access is granted";color:"#3b82f6";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3}
                        Text{text:"Every PTE in every page table has these 8 flags in bits [9:0]";color:Qt.rgba(255,255,255,0.35);font.pixelSize:11}
                    }
                }

                // Flag buttons
                Row {
                    width: parent.width; spacing: 8
                    Repeater {
                        model: ["V","R","W","X","U","G"]
                        delegate: Rectangle {
                            property bool flagOn: {
                                if(index===0) return scrollRoot.pteV;
                                if(index===1) return scrollRoot.pteR;
                                if(index===2) return scrollRoot.pteW;
                                if(index===3) return scrollRoot.pteX;
                                if(index===4) return scrollRoot.pteU;
                                return scrollRoot.pteG;
                            }
                            property var flagColors: ["#10b981","#3b82f6","#f97316","#f43f5e","#a78bfa","#6b7280"]
                            property var flagDescs: ["Valid — entry in use","Read — readable","Write — writable","Execute — runnable","User — U-mode access","Global — all ASIDs"]
                            width: (parent.width - 40) / 6; height: 64; radius: 9
                            color: flagOn ? Qt.rgba(0,0,0,0.0) : Qt.rgba(255,255,255,0.03)
                            border.color: flagOn ? flagColors[index] : Qt.rgba(255,255,255,0.1)
                            border.width: flagOn ? 1.5 : 1
                            Behavior on color{ColorAnimation{duration:130}}
                            Behavior on border.color{ColorAnimation{duration:130}}
                            Column {
                                anchors.centerIn:parent; spacing:5
                                Rectangle {
                                    width:26;height:26;radius:5
                                    anchors.horizontalCenter:parent
                                    color:flagOn ? Qt.rgba(0,0,0,0) : Qt.rgba(255,255,255,0.04)
                                    border.color:flagOn?flagColors[index]:Qt.rgba(255,255,255,0.15)
                                    Text{anchors.centerIn:parent;text:modelData;color:flagOn?flagColors[index]:Qt.rgba(255,255,255,0.4);font.bold:true;font.pixelSize:13;font.family:"Consolas"}
                                }
                                Text{text:flagDescs[index];color:Qt.rgba(255,255,255,0.32);font.pixelSize:8;anchors.horizontalCenter:parent;horizontalAlignment:Text.AlignHCenter;width:parent.parent.width-4;wrapMode:Text.WordWrap}
                            }
                            MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:{
                                if(index===0) scrollRoot.pteV=!scrollRoot.pteV;
                                else if(index===1) scrollRoot.pteR=!scrollRoot.pteR;
                                else if(index===2) scrollRoot.pteW=!scrollRoot.pteW;
                                else if(index===3) scrollRoot.pteX=!scrollRoot.pteX;
                                else if(index===4) scrollRoot.pteU=!scrollRoot.pteU;
                                else scrollRoot.pteG=!scrollRoot.pteG;
                            }}
                        }
                    }
                }

                // Result
                Rectangle {
                    width:parent.width; height:pteResult.implicitHeight+20
                    color: !scrollRoot.pteV ? Qt.rgba(244/255,63/255,94/255,0.08) : Qt.rgba(59/255,130/255,246/255,0.07)
                    radius:9
                    border.color: !scrollRoot.pteV ? Qt.rgba(244/255,63/255,94/255,0.3) : Qt.rgba(59/255,130/255,246/255,0.3)
                    border.width:1
                    Behavior on color{ColorAnimation{duration:180}}
                    Text {
                        id: pteResult
                        anchors.left:parent.left;anchors.leftMargin:14
                        anchors.right:parent.right;anchors.rightMargin:14
                        anchors.verticalCenter:parent.verticalCenter
                        color: !scrollRoot.pteV ? "#f43f5e" : Qt.rgba(255,255,255,0.75)
                        font.family:"Segoe UI"; font.pixelSize:12; font.bold:true; wrapMode:Text.WordWrap; lineHeight:1.4
                        text: {
                            if(!scrollRoot.pteV) return "✗  V=0 — INVALID PTE. Hardware will generate a page fault on any access to this page.";
                            var leaf = scrollRoot.pteR || scrollRoot.pteW || scrollRoot.pteX;
                            if(!leaf) return "→  Non-leaf PTE: V=1, R=W=X=0 — PPN points to the NEXT level page table (not a physical page yet).";
                            var perms = [];
                            if(scrollRoot.pteR) perms.push("read");
                            if(scrollRoot.pteW) perms.push("write");
                            if(scrollRoot.pteX) perms.push("execute");
                            var who = scrollRoot.pteU ? "U-mode + S-mode" : "S-mode only (kernel page)";
                            return "✓  Leaf PTE — maps to a physical page. Permissions: [" + perms.join(", ") + "]. Accessible by: " + who + (scrollRoot.pteG ? ". Global: shared across all ASIDs in TLB." : ".");
                        }
                    }
                }
            }
        }

        // ── FOOTER ──────────────────────────────────────────────────────

        // ── Sv39 VIRTUAL ADDRESS DECODER ────────────────────────────────
        Rectangle {
            id: sv39Sim
            width:parent.width; height:sv39Col.implicitHeight+32
            color:Qt.rgba(255,255,255,0.015); radius:14
            border.color:Qt.rgba(6,182,212,0.2); border.width:1

            property int vpn2: 0
            property int vpn1: 0
            property int vpn0: 1
            property int pgOff: 0
            property var vpn2Opts: [0,1,2,255]
            property var vpn1Opts: [0,1,7,255]
            property var vpn0Opts: [1,2,5,255]
            property var offOpts:  [0,4,4095,2048]

            property string physAddr: {
                var pte2 = vpn2*512+vpn1
                var pte1 = vpn1*512+vpn0
                var pte0 = vpn0*8+1
                var ppn  = pte0
                var pa   = ppn*4096 + pgOff
                return "0x"+pa.toString(16).toUpperCase().padStart(12,'0')
            }
            property string vaHex: {
                var v=(vpn2*(1<<18)+vpn1*(1<<9)+vpn0)*(1<<12)+pgOff
                return "0x"+v.toString(16).toUpperCase().padStart(12,'0')
            }

            Column {
                id:sv39Col
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing:14

                Row { spacing:10
                    Text { text:"🗺"; font.pixelSize:18; anchors.verticalCenter:parent.verticalCenter }
                    Column { spacing:2
                        Text { text:"Sv39 ADDRESS DECODER — pick VPN segments and page offset"; color:"#06b6d4"; font.bold:true; font.pixelSize:13 }
                        Text { text:"39-bit VA → 3 levels of page table (VPN[2]:VPN[1]:VPN[0] each 9 bits) + 12-bit offset"; color:Qt.rgba(255,255,255,0.32); font.pixelSize:11 }
                    }
                }

                // Bit-field visualisation
                Row { spacing:2; height:40; width:parent.width
                    Rectangle { width:parent.width*9/39; height:40; radius:6; color:Qt.rgba(139/255,92/255,246/255,0.25); border.color:"#8b5cf6"; border.width:1
                        Column { anchors.centerIn:parent; spacing:2
                            Text { text:"VPN[2]"; color:"#a78bfa"; font.pixelSize:9; font.bold:true; anchors.horizontalCenter:parent }
                            Text { text:sv39Sim.vpn2+" (bits 38–30)"; color:Qt.rgba(255,255,255,0.6); font.pixelSize:9; font.family:"Consolas"; anchors.horizontalCenter:parent }
                        }
                    }
                    Rectangle { width:parent.width*9/39; height:40; radius:6; color:Qt.rgba(6/255,182/255,212/255,0.2); border.color:"#06b6d4"; border.width:1
                        Column { anchors.centerIn:parent; spacing:2
                            Text { text:"VPN[1]"; color:"#06b6d4"; font.pixelSize:9; font.bold:true; anchors.horizontalCenter:parent }
                            Text { text:sv39Sim.vpn1+" (bits 29–21)"; color:Qt.rgba(255,255,255,0.6); font.pixelSize:9; font.family:"Consolas"; anchors.horizontalCenter:parent }
                        }
                    }
                    Rectangle { width:parent.width*9/39; height:40; radius:6; color:Qt.rgba(16/255,185/255,129/255,0.2); border.color:"#10b981"; border.width:1
                        Column { anchors.centerIn:parent; spacing:2
                            Text { text:"VPN[0]"; color:"#10b981"; font.pixelSize:9; font.bold:true; anchors.horizontalCenter:parent }
                            Text { text:sv39Sim.vpn0+" (bits 20–12)"; color:Qt.rgba(255,255,255,0.6); font.pixelSize:9; font.family:"Consolas"; anchors.horizontalCenter:parent }
                        }
                    }
                    Rectangle { width:parent.width*12/39; height:40; radius:6; color:Qt.rgba(251/255,191/255,36/255,0.2); border.color:"#fbbf24"; border.width:1
                        Column { anchors.centerIn:parent; spacing:2
                            Text { text:"Page Offset"; color:"#fbbf24"; font.pixelSize:9; font.bold:true; anchors.horizontalCenter:parent }
                            Text { text:sv39Sim.pgOff+" (bits 11–0)"; color:Qt.rgba(255,255,255,0.6); font.pixelSize:9; font.family:"Consolas"; anchors.horizontalCenter:parent }
                        }
                    }
                }

                // Selectors
                Row { spacing:12; width:parent.width
                    Repeater {
                        model:[
                            {label:"VPN[2]", opts:[0,1,2,255], prop:"vpn2", color:"#a78bfa"},
                            {label:"VPN[1]", opts:[0,1,7,255], prop:"vpn1", color:"#06b6d4"},
                            {label:"VPN[0]", opts:[1,2,5,255], prop:"vpn0", color:"#10b981"},
                            {label:"Offset", opts:[0,4,4095,2048], prop:"pgOff", color:"#fbbf24"}
                        ]
                        delegate: Column { spacing:6; width:(parent.width-36)/4
                            Text { text:modelData.label; color:modelData.color; font.pixelSize:10; font.bold:true }
                            Row { spacing:4
                                Repeater { model:modelData.opts
                                    delegate: Rectangle {
                                        property bool active: {
                                            switch(modelData.prop){
                                                case "vpn2": return sv39Sim.vpn2===modelData
                                                case "vpn1": return sv39Sim.vpn1===modelData
                                                case "vpn0": return sv39Sim.vpn0===modelData
                                                default:     return sv39Sim.pgOff===modelData
                                            }
                                        }
                                        width:34; height:28; radius:7
                                        color:active?Qt.rgba(6/255,182/255,212/255,0.2):Qt.rgba(255,255,255,0.04)
                                        border.color:active?modelData.color:Qt.rgba(255,255,255,0.1); border.width:active?1.5:1
                                        Text { anchors.centerIn:parent; text:""+modelData; color:active?modelData.color:Qt.rgba(255,255,255,0.5); font.pixelSize:9; font.family:"Consolas" }
                                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor
                                            onClicked: {
                                                switch(modelData.prop){
                                                    case "vpn2": sv39Sim.vpn2=modelData; break
                                                    case "vpn1": sv39Sim.vpn1=modelData; break
                                                    case "vpn0": sv39Sim.vpn0=modelData; break
                                                    default:     sv39Sim.pgOff=modelData
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Walk result
                Row { spacing:12; width:parent.width
                    Rectangle { width:(parent.width-12)/2; height:walkRes.implicitHeight+20; radius:10; color:Qt.rgba(0,0,0,0.2); border.color:Qt.rgba(6,182,212,0.2); border.width:1
                        Column { id:walkRes; anchors.top:parent.top; anchors.topMargin:14; anchors.left:parent.left; anchors.leftMargin:14; anchors.right:parent.right; anchors.rightMargin:14; spacing:6
                            Text { text:"PAGE TABLE WALK"; color:"#06b6d4"; font.bold:true; font.pixelSize:11 }
                            Text { text:"1. satp → root PT (PPN of L2 table)"; color:Qt.rgba(255,255,255,0.5); font.pixelSize:10 }
                            Text { text:"2. PT[VPN[2]="+sv39Sim.vpn2+"] → L1 PTE → PPN"; color:"#a78bfa"; font.pixelSize:10; font.family:"Consolas" }
                            Text { text:"3. PT[VPN[1]="+sv39Sim.vpn1+"] → L0 PTE → PPN"; color:"#06b6d4"; font.pixelSize:10; font.family:"Consolas" }
                            Text { text:"4. PT[VPN[0]="+sv39Sim.vpn0+"] → physical page"; color:"#10b981"; font.pixelSize:10; font.family:"Consolas" }
                            Text { text:"5. PA = PPN<<12 | offset("+sv39Sim.pgOff+")"; color:"#fbbf24"; font.pixelSize:10; font.family:"Consolas" }
                        }
                    }
                    Rectangle { width:(parent.width-12)/2; height:addrCol.implicitHeight+28; radius:10; color:Qt.rgba(0,0,0,0.2); border.color:Qt.rgba(16,185,129,0.3); border.width:1
                        Column { id:addrCol; anchors.top:parent.top; anchors.topMargin:14; anchors.left:parent.left; anchors.leftMargin:14; anchors.right:parent.right; anchors.rightMargin:14; spacing:8
                            Text { text:"Virtual Address"; color:Qt.rgba(255,255,255,0.3); font.pixelSize:10; anchors.horizontalCenter:parent }
                            Text { text:sv39Sim.vaHex; color:"#a78bfa"; font.pixelSize:16; font.bold:true; font.family:"Consolas"; anchors.horizontalCenter:parent }
                            Text { text:"↓  3-level walk  ↓"; color:Qt.rgba(255,255,255,0.2); font.pixelSize:10; anchors.horizontalCenter:parent }
                            Text { text:"Physical Address"; color:Qt.rgba(255,255,255,0.3); font.pixelSize:10; anchors.horizontalCenter:parent }
                            Text { text:sv39Sim.physAddr; color:"#10b981"; font.pixelSize:16; font.bold:true; font.family:"Consolas"; anchors.horizontalCenter:parent }
                        }
                    }
                }
            }
        }

        Rectangle {
            width:parent.width; height:65
            color:Qt.rgba(59/255,130/255,246/255,0.08); radius:14
            border.color:Qt.rgba(59/255,130/255,246/255,0.35); border.width:1
            RowLayout {
                anchors.fill:parent; anchors.margins:15; spacing:15
                Text{text:"🌟";font.pixelSize:22;Layout.alignment:Qt.AlignVCenter}
                Text {
                    Layout.fillWidth:true; Layout.alignment:Qt.AlignVCenter
                    text:"CORE SUMMARY: Sv39 splits a 39-bit VA into VPN[2]:VPN[1]:VPN[0]:offset. Three hardware table walks (each 512 entries, 4 KB) convert VPN fields to PTEs. Each 64-bit PTE stores PPN (bits 53:10) + flags (V/R/W/X/U/G). satp holds the root table PPN; sfence.vma flushes the TLB after any change. walk() does this in software; the MMU does it automatically on every memory access."
                    color:"#ffffff"; wrapMode:Text.WordWrap; font.family:"Segoe UI"; font.bold:true; font.pixelSize:12; font.letterSpacing:0.2
                }
            }
        }

    }
}
