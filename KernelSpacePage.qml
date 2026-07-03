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

    // ── Animation dot ─────────────────────────────────────────────────
    property real kDot: 0.0
    property int  hoveredRegion: -1
    property int  selectedRegion: 3

    Timer {
        interval: 22; running: true; repeat: true
        onTriggered: scrollRoot.kDot = (scrollRoot.kDot + 0.005) % 1.0
    }

    // ── Kernel memory region data ─────────────────────────────────────
    // Each region: name, PA start, PA end, VA, color R,G,B, permission, description
    property var regionNames:  ["MMIO / UART0","VIRTIO DISK","PLIC","KERNEL TEXT","KERNEL DATA","FREE RAM","TRAMPOLINE"]
    property var regionPALow:  ["0x10000000","0x10001000","0x0C000000","0x80000000","~0x80008000","~0x80010000","dynamic"]
    property var regionPAHigh: ["0x10000FFF","0x10001FFF","0x0FFFFFFF","~0x80007FFF","~0x8000FFFF","~0x88000000","1 page"]
    property var regionVA:     ["= PA","= PA","= PA","= PA","= PA","= PA","0x3FFFFF000"]
    property var regionPerms:  ["R/W (kernel)","R/W (kernel)","R/W (kernel)","R/X (kernel)","R/W (kernel)","R/W (kernel)","R/X (both)"]
    property var regionR: [249,16,139,16,59,139,167]
    property var regionG: [115,185,92,185,130,92,139]
    property var regionB: [22,129,246,129,246,246,250]
    property var regionColors: ["#f97316","#10b981","#8b5cf6","#10b981","#3b82f6","#8b5cf6","#a78bfa"]
    property var regionHeights:[14,14,28,28,28,50,14]  // visual proportional heights in canvas
    property var regionDescs: [
        "Universal Asynchronous Receiver-Transmitter at 0x10000000. xv6 uses this for console I/O. Memory-mapped: writing to 0x10000000 sends a character. Identity-mapped so VA=PA. Mapped in kvminit() with mappages() + PTE_R|PTE_W (no PTE_X — MMIO should never be executed).",
        "VIRTIO disk controller at 0x10001000. xv6 block driver reads/writes this region to access disk sectors. Identity-mapped VA=PA, mapped R/W kernel-only. Interrupts from VIRTIO appear as trap cause scause=9 (external interrupt via PLIC).",
        "Platform-Level Interrupt Controller from 0x0C000000–0x0FFFFFFF. Arbitrates external device interrupts and routes them to appropriate harts. xv6 writes PLIC registers during plicinit() and plicinithart() to enable UART and VIRTIO interrupts at priority 1.",
        "Kernel executable code lives here — from _entry (the first instruction run after boot) through the end of text (.text section). Mapped R/X — readable and executable but NOT writable, preventing accidental overwrites. kernel.ld places _entry at 0x80000000, which is where QEMU puts the machine after firmware. PTE_R|PTE_X set, PTE_W cleared.",
        "Kernel global variables, BSS, and read-write data. Follows text in the ELF layout. Mapped R/W, not executable (PTE_X=0). kvminit() maps this separately from text using the etext symbol exported by kernel.ld so permissions differ: text is R/X, data is R/W.",
        "Physical memory from end of kernel data up to PHYSTOP (0x88000000 = 128 MB). Managed by kalloc()/kfree() as a linked list of 4 KB pages. Each free page stores a pointer to the next in the first word. Identity-mapped in the kernel page table so the kernel can access any physical page directly. Used for: process page tables, pipe buffers, file caches, user stack pages.",
        "One page (4 KB) of trampoline code mapped at the very top of EVERY address space — both kernel and user — at VA 0x3FFFFF000 (MAXVA−PGSIZE). Maps to the SAME physical page (trampoline.S) in all tables. This shared mapping means the trap handler code is reachable at the same VA whether executing in user mode or supervisor mode, allowing uservec to run safely right after the trap before the page table switch."
    ]

    // ── Accordion for detailed regions ────────────────────────────────
    property int openCard: 3

    // ── xv6 boot sequence steps ───────────────────────────────────────
    property int bootStep: 0
    property var bootTitles: ["QEMU loads kernel at 0x80000000","_entry sets up stack, calls start()","start() switches to S-mode via mret","main() → kvminit() builds kernel page table","kvminithart() writes satp, enables VM","userinit() creates first process"]
    property var bootCodes: [
        "# kernel.ld linker script\nOUTPUT_ARCH(riscv)\nENTRY(_entry)\nSECTIONS {\n  . = 0x80000000;     # QEMU kernel load addr\n  .text : { *(.text) }\n  .rodata : { ... }\n  .data : { ... }\n  .bss : { ... }\n}",
        "# kernel/entry.S\n_entry:\n    # stack0 is a per-CPU stack defined in start.c\n    la sp, stack0\n    li a0, 1024*4       # 4 KB per core\n    csrr a1, mhartid    # which core am I?\n    addi a1, a1, 1\n    mul a0, a0, a1\n    add sp, sp, a0      # sp = stack0 + (hart+1)*4096\n    call start          # jump to C",
        "// kernel/start.c\nvoid start() {\n    // Set M-mode Previous Privilege = S\n    unsigned long x = r_mstatus();\n    x &= ~MSTATUS_MPP_MASK;\n    x |= MSTATUS_MPP_S;\n    w_mstatus(x);\n    w_mepc((uint64)main);  // mret → main()\n    w_satp(0);             // disable VM for now\n    // delegate all interrupts/exceptions to S-mode\n    w_medeleg(0xffff); w_mideleg(0xffff);\n    // enable S-mode interrupts\n    w_sie(r_sie()|SIE_SEIE|SIE_STIE|SIE_SSIE);\n    w_pmpcfg0(0xf); w_pmpaddr0(0x3fffffffffffffull);\n    asm volatile(\"mret\");  // jump to main() in S-mode\n}",
        "// kernel/vm.c\nvoid kvminit() {\n    kernel_pagetable = kvmmake();\n}\npagetable_t kvmmake() {\n    pagetable_t kpgtbl = (pagetable_t)kalloc();\n    memset(kpgtbl, 0, PGSIZE);\n    // Map UART0 MMIO\n    kvmmap(kpgtbl,UART0,UART0,PGSIZE,PTE_R|PTE_W);\n    // Map VIRTIO, PLIC...\n    kvmmap(kpgtbl,VIRTIO0,VIRTIO0,PGSIZE,PTE_R|PTE_W);\n    kvmmap(kpgtbl,PLIC,PLIC,0x400000,PTE_R|PTE_W);\n    // Kernel text: R/X\n    kvmmap(kpgtbl,KERNBASE,KERNBASE,\n           (uint64)etext-KERNBASE, PTE_R|PTE_X);\n    // Kernel data: R/W\n    kvmmap(kpgtbl,(uint64)etext,(uint64)etext,\n           PHYSTOP-(uint64)etext, PTE_R|PTE_W);\n    // Trampoline: R/X in both user+kernel tables\n    kvmmap(kpgtbl,TRAMPOLINE,\n           (uint64)trampoline,PGSIZE,PTE_R|PTE_X);\n    return kpgtbl;\n}",
        "// kernel/vm.c\nvoid kvminithart() {\n    // Flush stale TLB entries before switching\n    sfence_vma();\n    // Write satp: MODE=Sv39 | root table PPN\n    w_satp(MAKE_SATP(kernel_pagetable));\n    // Flush again after enabling translation\n    sfence_vma();\n    // From this point on, ALL memory accesses\n    // go through the kernel page table!\n}",
        "// kernel/proc.c\nvoid userinit() {\n    struct proc *p = allocproc();\n    initproc = p;\n    // Create first user address space\n    uvmfirst(p->pagetable, initcode, sizeof(initcode));\n    p->sz = PGSIZE;\n    // Set up trapframe for first return to user\n    p->trapframe->epc = 0;   // user PC = 0\n    p->trapframe->sp  = PGSIZE; // user stack top\n    safestrcpy(p->name, \"initcode\", ...);\n    p->state = RUNNABLE;\n    // init process will exec /init when scheduled\n}"
    ]
    property var bootDescs: [
        "The QEMU virt machine places the kernel binary at physical address 0x80000000. The linker script (kernel.ld) sets ENTRY(_entry) and `. = 0x80000000` so the ELF entry point matches QEMU's load address. At reset, every RISC-V hart starts executing in M-mode at the reset vector, then firmware jumps to 0x80000000.",
        "_entry is pure assembly. It computes a unique per-hart stack pointer using mhartid, then calls start(). No C runtime initialization happens before this — no .data copying, no .bss zeroing. Those happen in main() later via a memset loop.",
        "start() is the first C function. It configures mstatus.MPP=S so mret will drop into S-mode, delegates all exceptions/interrupts to S-mode via medeleg/mideleg, sets up PMP to grant S-mode full access, then executes mret. This is the one and only time xv6 runs in M-mode during normal operation.",
        "kvminit() allocates one page for the root L2 page table and calls kvmmap() for each region: UART, VIRTIO, PLIC (MMIO), kernel text (R/X), kernel data+bss+free RAM (R/W), and trampoline (R/X). At this point satp is still 0 — VA=PA — so kalloc() works without translation.",
        "kvminithart() writes satp (MODE=8, PPN=kernel_pagetable>>12) and issues sfence.vma before and after. From this instruction forward, all loads/stores in S-mode go through the kernel page table. Since xv6 identity-maps the kernel, addresses don't change numerically, but the MMU now validates every access.",
        "userinit() prepares the very first process. It calls allocproc() (which sets up the kernel stack and trapframe page), then uvmfirst() to copy the tiny initcode binary into a freshly allocated user page at VA 0. The trapframe is set so that when the scheduler swtch()es into this process, usertrapret() will return to user VA=0 — the start of initcode."
    ]

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
            border.color: Qt.rgba(139,92,246,0.25); border.width: 1
            layer.enabled: true
            layer.effect: Glow { radius:10; samples:17; color:Qt.rgba(139,92,246,0.12); spread:0.1 }
            Row {
                anchors.fill: parent; anchors.margins: 15; spacing: 16
                Rectangle {
                    width: 52; height: 52; radius: 12
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(139,92,246,0.15); border.color: Qt.rgba(139,92,246,0.4); border.width: 1
                    Column {
                        anchors.centerIn: parent; spacing: 1
                        Text { text:"07"; color:"#8b5cf6"; font.bold:true; font.pixelSize:20; font.family:"Consolas"; anchors.horizontalCenter:parent }
                        Text { text:"LESSON"; color:Qt.rgba(139,92,246,0.5); font.pixelSize:7; font.letterSpacing:1; anchors.horizontalCenter:parent }
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 6
                    Text {
                        text: "KERNEL ADDRESS SPACE — How xv6 Maps Its Own Memory"
                        color: "#ffffff"; font.family:"Segoe UI"; font.bold:true; font.pixelSize:20; font.letterSpacing:0.5
                    }
                    Text {
                        text: "The kernel page table: identity-mapped MMIO + RAM, R/X text, R/W data, and the trampoline at MAXVA. Boot sequence from _entry to VM activation."
                        color: Qt.rgba(255,255,255,0.55); font.family:"Segoe UI"; font.pixelSize:12
                    }
                }
            }
        }

        // ── MEMORY MAP CANVAS + LEGEND ────────────────────────────────
        Rectangle {
            width: parent.width
            height: mapLegCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(139,92,246,0.15); border.width: 1

            Column {
                id: mapLegCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 14

                Text {
                    text:"KERNEL VIRTUAL ADDRESS SPACE  —  click any region for details"
                    color:Qt.rgba(139,92,246,0.7); font.bold:true; font.pixelSize:12; font.letterSpacing:0.5
                }

                Row {
                    width: parent.width; spacing: 14

                    // Address map (left column)
                    Column {
                        width: parent.width * 0.38; spacing: 2

                        Repeater {
                            model: 7
                            delegate: Rectangle {
                                property bool isHov: scrollRoot.hoveredRegion === index
                                property bool isSel: scrollRoot.selectedRegion === index
                                width: parent.width
                                height: Math.max(44, scrollRoot.regionHeights[index] * 7)
                                color: isSel ? Qt.rgba(scrollRoot.regionR[index]/255,scrollRoot.regionG[index]/255,scrollRoot.regionB[index]/255,0.18)
                                             : isHov ? Qt.rgba(scrollRoot.regionR[index]/255,scrollRoot.regionG[index]/255,scrollRoot.regionB[index]/255,0.09)
                                             : Qt.rgba(255,255,255,0.02)
                                border.color: isSel ? scrollRoot.regionColors[index]
                                            : Qt.rgba(scrollRoot.regionR[index]/255,scrollRoot.regionG[index]/255,scrollRoot.regionB[index]/255,0.3)
                                border.width: isSel ? 1.5 : 1
                                radius: 6
                                Behavior on color { ColorAnimation { duration:120 } }
                                Behavior on border.color { ColorAnimation { duration:120 } }

                                Rectangle {
                                    width: 4; height: parent.height - 6
                                    anchors.left:parent.left; anchors.leftMargin:0; anchors.verticalCenter:parent.verticalCenter
                                    color: scrollRoot.regionColors[index]; radius: 2
                                }
                                Column {
                                    anchors.left:parent.left; anchors.leftMargin:12
                                    anchors.right:parent.right; anchors.rightMargin:8
                                    anchors.verticalCenter:parent.verticalCenter; spacing:3
                                    Text { text:scrollRoot.regionNames[index]; color:scrollRoot.regionColors[index]; font.bold:true; font.pixelSize:10; font.letterSpacing:0.3 }
                                    Text { text:scrollRoot.regionPALow[index]; color:Qt.rgba(255,255,255,0.4); font.family:"Consolas"; font.pixelSize:9 }
                                    Text { text:scrollRoot.regionVA[index]; color:Qt.rgba(255,255,255,0.3); font.family:"Consolas"; font.pixelSize:8; visible: scrollRoot.regionVA[index] !== "= PA" }
                                }
                                MouseArea {
                                    anchors.fill:parent; hoverEnabled:true; cursorShape:Qt.PointingHandCursor
                                    onClicked: scrollRoot.selectedRegion = index
                                    onEntered: scrollRoot.hoveredRegion = index
                                    onExited:  scrollRoot.hoveredRegion = -1
                                }
                            }
                        }
                    }

                    // Detail panel (right column)
                    Rectangle {
                        width: parent.width * 0.62 - 14
                        height: detailCol.implicitHeight + 24
                        color: Qt.rgba(0,0,0,0.18); radius: 12
                        border.color: scrollRoot.selectedRegion >= 0 ? Qt.rgba(scrollRoot.regionR[scrollRoot.selectedRegion]/255,scrollRoot.regionG[scrollRoot.selectedRegion]/255,scrollRoot.regionB[scrollRoot.selectedRegion]/255,0.4) : Qt.rgba(255,255,255,0.06)
                        border.width: 1.5

                        Column {
                            id: detailCol
                            anchors.top:parent.top; anchors.topMargin:16
                            anchors.left:parent.left; anchors.leftMargin:16
                            anchors.right:parent.right; anchors.rightMargin:16
                            spacing: 10

                            // Title bar
                            Row { spacing:10
                                Rectangle {
                                    width:8; height:8; radius:4; anchors.verticalCenter:parent.verticalCenter
                                    color: scrollRoot.selectedRegion>=0 ? scrollRoot.regionColors[scrollRoot.selectedRegion] : "#888"
                                }
                                Text {
                                    text: scrollRoot.selectedRegion>=0 ? scrollRoot.regionNames[scrollRoot.selectedRegion] : "Select a region"
                                    color: scrollRoot.selectedRegion>=0 ? scrollRoot.regionColors[scrollRoot.selectedRegion] : Qt.rgba(255,255,255,0.4)
                                    font.bold:true; font.pixelSize:13; font.letterSpacing:0.4
                                }
                            }

                            // Metadata row
                            Row { spacing:16; visible: scrollRoot.selectedRegion >= 0
                                Column { spacing:3
                                    Text { text:"PA RANGE"; color:Qt.rgba(255,255,255,0.25); font.pixelSize:8; font.letterSpacing:0.8 }
                                    Text { text:scrollRoot.selectedRegion>=0 ? scrollRoot.regionPALow[scrollRoot.selectedRegion]+"  →  "+scrollRoot.regionPAHigh[scrollRoot.selectedRegion] : ""; color:Qt.rgba(255,255,255,0.6); font.family:"Consolas"; font.pixelSize:10 }
                                }
                                Column { spacing:3
                                    Text { text:"PERMS"; color:Qt.rgba(255,255,255,0.25); font.pixelSize:8; font.letterSpacing:0.8 }
                                    Text { text:scrollRoot.selectedRegion>=0 ? scrollRoot.regionPerms[scrollRoot.selectedRegion] : ""; color:Qt.rgba(255,255,255,0.6); font.family:"Consolas"; font.pixelSize:10 }
                                }
                            }

                            Rectangle { width:parent.width; height:1; color:Qt.rgba(255,255,255,0.06); visible:scrollRoot.selectedRegion>=0 }

                            Text {
                                width: parent.width
                                text: scrollRoot.selectedRegion>=0 ? scrollRoot.regionDescs[scrollRoot.selectedRegion] : "Click any region on the left to see what it is, why it exists, and how xv6 maps it."
                                color: scrollRoot.selectedRegion>=0 ? Qt.rgba(255,255,255,0.78) : Qt.rgba(255,255,255,0.28)
                                wrapMode: Text.WordWrap; font.family:"Segoe UI"; font.pixelSize:11; lineHeight:1.55
                            }
                        }
                    }
                }
            }
        }

        // ── BOOT SEQUENCE STEPPER ────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: bootCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(139,92,246,0.15); border.width: 1

            Column {
                id: bootCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 16

                Row { spacing:10
                    Text{text:"⚡";font.pixelSize:18;anchors.verticalCenter:parent.verticalCenter}
                    Column { spacing:2
                        Text{text:"BOOT SEQUENCE — step through xv6 startup to understand how the kernel comes alive";color:"#8b5cf6";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3}
                        Text{text:"From first instruction at 0x80000000 to the first user process being scheduled";color:Qt.rgba(255,255,255,0.35);font.pixelSize:11}
                    }
                }

                // Step indicator dots row
                Row {
                    spacing: 10
                    Repeater {
                        model: 6
                        delegate: Row {
                            spacing: 0
                            Rectangle {
                                width: 28; height: 28; radius: 14
                                color: scrollRoot.bootStep >= index ? "#8b5cf6" : Qt.rgba(139,92,246,0.1)
                                border.color: "#8b5cf6"; border.width: scrollRoot.bootStep >= index ? 0 : 1
                                Behavior on color { ColorAnimation { duration:180 } }
                                Text { anchors.centerIn:parent; text:(index+1).toString(); color: scrollRoot.bootStep>=index?"#fff":Qt.rgba(255,255,255,0.3); font.bold:true; font.pixelSize:11; font.family:"Consolas" }
                                MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked: scrollRoot.bootStep=index }
                            }
                            Rectangle {
                                visible: index<5; width:22; height:2
                                anchors.verticalCenter:parent.verticalCenter
                                color: scrollRoot.bootStep>index ? "#8b5cf6" : Qt.rgba(255,255,255,0.1)
                                Behavior on color { ColorAnimation { duration:180 } }
                            }
                        }
                    }
                }

                // Step title
                Text {
                    width: parent.width
                    text: scrollRoot.bootTitles[scrollRoot.bootStep]
                    color: "#a78bfa"; font.bold:true; font.pixelSize:14; font.letterSpacing:0.3
                }

                // Step content: theory + code side by side
                Row {
                    width: parent.width; spacing: 14

                    Text {
                        width: parent.width * 0.40
                        text: scrollRoot.bootDescs[scrollRoot.bootStep]
                        color: Qt.rgba(255,255,255,0.75); font.family:"Segoe UI"; font.pixelSize:11
                        wrapMode: Text.WordWrap; lineHeight: 1.55
                    }

                    Rectangle {
                        width: parent.width * 0.60 - 14
                        height: bootCodeText.implicitHeight + 32
                        color: Qt.rgba(0,0,0,0.3); radius: 10
                        border.color: Qt.rgba(255,255,255,0.06); border.width: 1

                        Rectangle {
                            width:parent.width; height:22; color:Qt.rgba(255,255,255,0.04); radius:10
                            Rectangle{width:parent.width;height:11;anchors.bottom:parent.bottom;color:parent.color}
                            Row { anchors.left:parent.left;anchors.leftMargin:8;anchors.verticalCenter:parent.verticalCenter;spacing:4
                                Repeater{model:3;delegate:Rectangle{width:7;height:7;radius:3.5;color:["#f43f5e","#fbbf24","#10b981"][index];opacity:0.7}}
                            }
                            Text{text:"kernel/"; color:Qt.rgba(255,255,255,0.18);font.pixelSize:9;font.family:"Consolas";anchors.centerIn:parent}
                        }
                        Text {
                            id: bootCodeText
                            anchors.top:parent.top; anchors.topMargin:28
                            anchors.left:parent.left; anchors.leftMargin:12
                            anchors.right:parent.right; anchors.rightMargin:12
                            text: scrollRoot.bootCodes[scrollRoot.bootStep]
                            color: Qt.rgba(255,255,255,0.82); font.family:"Consolas"; font.pixelSize:10
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere; lineHeight: 1.5
                        }
                    }
                }

                // Prev/Next
                Row {
                    spacing: 10
                    Rectangle {
                        width: 90; height: 34; radius: 9
                        color: scrollRoot.bootStep>0 ? Qt.rgba(139,92,246,0.15) : Qt.rgba(255,255,255,0.03)
                        border.color: scrollRoot.bootStep>0 ? "#8b5cf6" : Qt.rgba(255,255,255,0.1)
                        border.width: 1
                        Text { anchors.centerIn:parent; text:"← PREV"; color:scrollRoot.bootStep>0?"#8b5cf6":Qt.rgba(255,255,255,0.2); font.bold:true; font.pixelSize:11 }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked: if(scrollRoot.bootStep>0) scrollRoot.bootStep-- }
                    }
                    Rectangle {
                        width: 90; height: 34; radius: 9
                        color: scrollRoot.bootStep<5 ? Qt.rgba(139,92,246,0.15) : Qt.rgba(255,255,255,0.03)
                        border.color: scrollRoot.bootStep<5 ? "#8b5cf6" : Qt.rgba(255,255,255,0.1)
                        border.width: 1
                        Text { anchors.centerIn:parent; text:"NEXT →"; color:scrollRoot.bootStep<5?"#8b5cf6":Qt.rgba(255,255,255,0.2); font.bold:true; font.pixelSize:11 }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked: if(scrollRoot.bootStep<5) scrollRoot.bootStep++ }
                    }
                    Text { anchors.verticalCenter:parent.verticalCenter; text:"Step " + (scrollRoot.bootStep+1) + " of 6"; color:Qt.rgba(255,255,255,0.2); font.pixelSize:11 }
                }
            }
        }

        // ── KERNEL vs USER ADDRESS SPACE COMPARISON ──────────────────────
        Rectangle {
            width: parent.width
            height: cmpCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.015); radius: 14
            border.color: Qt.rgba(255,255,255,0.07); border.width: 1

            Column {
                id: cmpCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 14

                Row { spacing:10
                    Text{text:"⚖️";font.pixelSize:18;anchors.verticalCenter:parent.verticalCenter}
                    Column { spacing:2
                        Text{text:"KERNEL vs USER PAGE TABLE — what's shared, what differs";color:"#8b5cf6";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3}
                        Text{text:"Both tables share the trampoline mapping — that's the only deliberately shared page";color:Qt.rgba(255,255,255,0.35);font.pixelSize:11}
                    }
                }

                Row {
                    width: parent.width; spacing: 10

                    // Kernel side
                    Rectangle {
                        width: (parent.width-10)*0.5; height: cmpKernCol.implicitHeight+20
                        color: Qt.rgba(139/255,92/255,246/255,0.07); radius:10
                        border.color: Qt.rgba(139/255,92/255,246/255,0.3); border.width:1.5

                        Column {
                            id: cmpKernCol
                            anchors.top:parent.top;anchors.topMargin:14
                            anchors.left:parent.left;anchors.leftMargin:14
                            anchors.right:parent.right;anchors.rightMargin:14; spacing:8

                            Row { spacing:8
                                Rectangle{width:8;height:8;radius:4;color:"#8b5cf6";anchors.verticalCenter:parent.verticalCenter}
                                Text{text:"KERNEL PAGE TABLE";color:"#8b5cf6";font.bold:true;font.pixelSize:12;font.letterSpacing:0.4}
                            }
                            Repeater {
                                model: ["UART0 / VIRTIO / PLIC  →  identity-map R/W","Kernel text (0x80000000)  →  R/X","Kernel data / bss / RAM  →  R/W","Every process kernel stack  →  R/W (PTE_U=0)","Trampoline (MAXVA-1)  →  R/X (shared with user tables)","Direct mapped: VA = PA for all RAM regions"]
                                delegate: Row {
                                    spacing:8
                                    Text{text:"•";color:"#a78bfa";font.pixelSize:11}
                                    Text{text:modelData;color:Qt.rgba(255,255,255,0.65);font.family:"Segoe UI";font.pixelSize:11;wrapMode:Text.WordWrap;width:parent.parent.width-20}
                                }
                            }
                        }
                    }

                    // User side
                    Rectangle {
                        width: (parent.width-10)*0.5; height: cmpUserCol.implicitHeight+20
                        color: Qt.rgba(16/255,185/255,129/255,0.07); radius:10
                        border.color: Qt.rgba(16/255,185/255,129/255,0.3); border.width:1.5

                        Column {
                            id: cmpUserCol
                            anchors.top:parent.top;anchors.topMargin:14
                            anchors.left:parent.left;anchors.leftMargin:14
                            anchors.right:parent.right;anchors.rightMargin:14; spacing:8

                            Row { spacing:8
                                Rectangle{width:8;height:8;radius:4;color:"#10b981";anchors.verticalCenter:parent.verticalCenter}
                                Text{text:"USER PAGE TABLE (per process)";color:"#10b981";font.bold:true;font.pixelSize:12;font.letterSpacing:0.4}
                            }
                            Repeater {
                                model: ["Code page(s) at VA 0  →  R/X (PTE_U=1)","Data page(s) after text  →  R/W (PTE_U=1)","Guard page (unmapped)  →  catches stack overflow","User stack page  →  R/W (PTE_U=1)","Trapframe (MAXVA-2)  →  R/W, PTE_U=0 (kernel writes it)","Trampoline (MAXVA-1)  →  R/X, PTE_U=0 (shared with kernel)"]
                                delegate: Row {
                                    spacing:8
                                    Text{text:"•";color:"#34d399";font.pixelSize:11}
                                    Text{text:modelData;color:Qt.rgba(255,255,255,0.65);font.family:"Segoe UI";font.pixelSize:11;wrapMode:Text.WordWrap;width:parent.parent.width-20}
                                }
                            }
                        }
                    }
                }

                // Key insight box
                Rectangle {
                    width:parent.width; height:insightText.implicitHeight+20
                    color:Qt.rgba(251/255,191/255,36/255,0.07); radius:9
                    border.color:Qt.rgba(251/255,191/255,36/255,0.35); border.width:1
                    Text {
                        id: insightText
                        anchors.left:parent.left;anchors.leftMargin:14
                        anchors.right:parent.right;anchors.rightMargin:14
                        anchors.verticalCenter:parent.verticalCenter
                        text:"💡  KEY INSIGHT: The kernel page table has NO PTE_U bits set. This means a user-mode (U-mode) process cannot touch any kernel address even if it somehow learns the VA — the MMU will raise a page fault. The only page with PTE_U=0 that the user page table contains is the trampoline (MAXVA-1), which uservec needs to run at the start of every trap. The trapframe at MAXVA-2 also has PTE_U=0 since only the kernel writes it."
                        color:"#fbbf24"; wrapMode:Text.WordWrap; font.family:"Segoe UI"; font.pixelSize:12; lineHeight:1.5
                    }
                }
            }
        }

        // ── FOOTER ──────────────────────────────────────────────────────

        // ── KERNEL MEMORY MAP EXPLORER ───────────────────────────────────
        Rectangle {
            id: ksSim
            width:parent.width; height:ksMapCol.implicitHeight+32
            color:Qt.rgba(255,255,255,0.015); radius:14
            border.color:Qt.rgba(16,185,129,0.2); border.width:1

            property int selRegion: 0
            property var regions: [
                {name:"TRAMPOLINE",   addr:"0xFFFF_FFFF_F000",size:"4 KB",  color:"#ec4899",
                 desc:"Mapped at the very top of both kernel and user address spaces. Contains uservec (save regs) and userret (restore regs). Must be accessible from both spaces during trap handling without changing satp."},
                {name:"TRAPFRAME",    addr:"0xFFFF_FFFF_E000",size:"4 KB",  color:"#f97316",
                 desc:"Per-process page, mapped just below trampoline. Stores all 32 general-purpose registers + sepc/sstatus/satp during ecall/trap. The kernel reads it to handle the syscall."},
                {name:"KERNEL STACK", addr:"per-process",      size:"4 KB × N",color:"#fbbf24",
                 desc:"Each process has its own kernel stack. Used while the process runs kernel code (syscalls, trap handlers). Guard page below it catches stack overflow (PTE_V=0)."},
                {name:"KERNEL DATA",  addr:"0x8020_0000+",     size:"varies",  color:"#a78bfa",
                 desc:"Global kernel variables, per-process structs (proc[], file[], buf[]), run-time data. Compiled into the kernel binary, directly mapped (VA=PA)."},
                {name:"KERNEL TEXT",  addr:"0x8000_0000",      size:"~128 KB", color:"#06b6d4",
                 desc:"Kernel executable code. Starts at KERNBASE. Mapped read/execute only. Direct-mapped (VA==PA). Entry point: _entry in entry.S sets up the stack, then calls start()."},
                {name:"PHYS DEVICES", addr:"0x0000–0x7FFF_FFFF",size:"varies", color:"#10b981",
                 desc:"UART at 0x1000_0000, PLIC at 0x0C00_0000, CLINT at 0x0200_0000, virtio disk at 0x1000_1000. All direct-mapped into kernel VA so drivers can read/write registers with plain pointer dereference."}
            ]

            Column {
                id:ksMapCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing:14

                Row { spacing:10
                    Text { text:"🗂"; font.pixelSize:18; anchors.verticalCenter:parent.verticalCenter }
                    Column { spacing:2
                        Text { text:"KERNEL VIRTUAL MEMORY MAP — click a region to inspect it"; color:"#10b981"; font.bold:true; font.pixelSize:13 }
                        Text { text:"xv6 kernel virtual space: directly maps all physical RAM + device MMIO. Top pages are per-process (trampoline/trapframe)."; color:Qt.rgba(255,255,255,0.32); font.pixelSize:11 }
                    }
                }

                // Memory map visual (top-down, highest VA first)
                Column { spacing:3; width:parent.width
                    Repeater { model:ksSim.regions
                        delegate: Rectangle {
                            property bool active: ksSim.selRegion===index
                            width:parent.width; height:38; radius:8
                            color:active?Qt.rgba(16/255,185/255,129/255,0.1):Qt.rgba(255,255,255,0.025)
                            border.color:active?modelData.color:Qt.rgba(255,255,255,0.06); border.width:active?2:1
                            Behavior on border.width{NumberAnimation{duration:100}}
                            Row { anchors.fill:parent; anchors.leftMargin:12; anchors.rightMargin:12; spacing:12
                                Rectangle { width:10; height:26; radius:4; color:modelData.color; opacity:active?1.0:0.5; anchors.verticalCenter:parent.verticalCenter }
                                Column { anchors.verticalCenter:parent.verticalCenter; spacing:2
                                    Text { text:modelData.name; color:active?modelData.color:Qt.rgba(255,255,255,0.5); font.bold:true; font.pixelSize:11 }
                                    Text { text:modelData.addr+"  |  "+modelData.size; color:Qt.rgba(255,255,255,0.28); font.pixelSize:9; font.family:"Consolas" }
                                }
                            }
                            MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:ksSim.selRegion=index }
                        }
                    }
                }

                // Detail card
                Rectangle { width:parent.width; height:regionDetail.implicitHeight+24; radius:10
                    color:Qt.rgba(0,0,0,0.2); border.color:ksSim.regions[ksSim.selRegion].color; border.width:1
                    Column { id:regionDetail; anchors.top:parent.top; anchors.topMargin:14; anchors.left:parent.left; anchors.leftMargin:16; anchors.right:parent.right; anchors.rightMargin:16; spacing:8
                        Text { text:ksSim.regions[ksSim.selRegion].name; color:ksSim.regions[ksSim.selRegion].color; font.bold:true; font.pixelSize:14 }
                        Text { text:ksSim.regions[ksSim.selRegion].desc; color:Qt.rgba(255,255,255,0.7); font.pixelSize:11; wrapMode:Text.WordWrap; width:parent.width; lineHeight:1.6 }
                    }
                }
            }
        }

        Rectangle {
            width:parent.width; height:65
            color:Qt.rgba(139/255,92/255,246/255,0.08); radius:14
            border.color:Qt.rgba(139/255,92/255,246/255,0.35); border.width:1
            RowLayout {
                anchors.fill:parent; anchors.margins:15; spacing:15
                Text{text:"🌟";font.pixelSize:22;Layout.alignment:Qt.AlignVCenter}
                Text {
                    Layout.fillWidth:true; Layout.alignment:Qt.AlignVCenter
                    text:"CORE SUMMARY: xv6 uses a single kernel page table (kvmmake): identity-maps MMIO + all RAM, maps kernel text R/X and data R/W (separated by etext symbol), maps the trampoline R/X at MAXVA-1. Boot: _entry→start() (M→S via mret)→kvminit()→kvminithart() (enables Sv39). Every process has its own user page table but shares only the trampoline VA. PTE_U=0 on all kernel mappings: hardware enforces isolation."
                    color:"#ffffff"; wrapMode:Text.WordWrap; font.family:"Segoe UI"; font.bold:true; font.pixelSize:12; font.letterSpacing:0.2
                }
            }
        }

    }
}
