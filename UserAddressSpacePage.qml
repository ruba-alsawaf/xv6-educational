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

    // ── Selected layout region ─────────────────────────────────────────
    property int  selectedLayer: 5
    property int  hoveredLayer:  -1
    property real scanDot: 0.0
    property int  execStep: 0

    Timer {
        interval: 20; running: true; repeat: true
        onTriggered: scrollRoot.scanDot = (scrollRoot.scanDot + 0.004) % 1.0
    }

    // ── User address space layers (bottom → top VA, displayed top→bottom) ──
    // Index 0 = bottom (VA 0), index 7 = top (MAXVA)
    property var layerNames:  ["CODE (text)","DATA + BSS","HEAP (brk)","GUARD PAGE","USER STACK","TRAPFRAME","TRAMPOLINE"]
    property var layerVALow:  ["0x0000","after text","after data","below stack","MAXVA − 3p","MAXVA − 2p","MAXVA − 1p"]
    property var layerPerms:  ["R/X  PTE_U=1","R/W  PTE_U=1","R/W  PTE_U=1","UNMAPPED","R/W  PTE_U=1","R/W  PTE_U=0","R/X  PTE_U=0"]
    property var layerH:      [36,30,30,28,36,28,28]
    property var layerR: [16,59,249,80,139,251,167]
    property var layerG: [185,130,115,80,92,191,139]
    property var layerB: [129,246,22,80,246,36,250]
    property var layerColors: ["#10b981","#3b82f6","#f97316","#444","#8b5cf6","#fbbf24","#a78bfa"]
    property var layerDescs: [
        "The code segment starts at VA 0. exec() loads the ELF .text section here using uvmalloc() + loadseg(). Mapped R/X with PTE_U=1 so user code can be fetched and executed, but not written — this prevents self-modifying attacks. Each ELF program header (type PT_LOAD) is mapped individually; xv6 supports simple single-segment ELF binaries. The kernel uses walkaddr() to safely read user code (e.g. for ptrace-style inspection) by checking PTE_U=1 on each PTE.",
        "DATA and BSS follow the text segment. exec() maps these pages R/W with PTE_U=1. BSS (zero-initialized globals) pages are zeroed via memset before mapping. The ELF program header specifies both filesz (bytes to copy from file) and memsz (total size including BSS padding). xv6 copies filesz bytes from disk then zeroes the remaining memsz−filesz bytes in the last partial page.",
        "The heap grows upward from the end of BSS. sbrk(n) (system call) calls uvmalloc(p->pagetable, oldsz, oldsz+n) to allocate n more bytes. Each kalloc() call provides a 4 KB physical page; mappages() maps it. sbrk(-n) calls uvmdealloc() to unmap and kfree() physical pages. p->sz tracks the current top of heap. The heap uses R/W with PTE_U=1. malloc() in user space builds on top of sbrk().",
        "One unmapped page sits between the heap and the stack. It is intentionally left out of the page table — there is no PTE for this VA range. If the user stack overflows downward into this page, the MMU generates a page fault (scause=15, store page fault), which xv6 reports as a segmentation fault and kills the process. This is a simple but effective stack overflow detector using the hardware.",
        "One page (4 KB) of user stack, allocated by exec() via uvmalloc(). Starts with argc, argv[] pointers, and the argument strings pushed onto it by exec(). sp (stack pointer) in the trapframe is set to the top of this page. The stack grows downward as the user program pushes values. R/W with PTE_U=1. Note: xv6 gives each process only ONE page of stack — no automatic stack growth. If overflowed, the guard page triggers a fault.",
        "The trapframe page sits at MAXVA−2 pages (just below the trampoline). It holds the saved register state for the currently executing process: all 32 general-purpose registers (x0–x31), sepc, sstatus, sscratch, and pointers to the kernel stack, kernel page table, and the usertrap() function. Written by uservec (trampoline.S) at trap entry; read by usertrapret() at trap return. PTE_U=0: the user cannot read or write its own trapframe — only the kernel can.",
        "The trampoline page is mapped at MAXVA−1 page (0x3FFFFF000) in EVERY address space — both kernel and user — pointing to the SAME physical page of trampoline.S code. PTE_U=0 so user code cannot directly jump to or read it. Its purpose: when a trap occurs, the CPU switches to S-mode and jumps to stvec, which points into the trampoline. At that moment the page table has NOT yet been switched. The trampoline being present in both tables means execution continues without a fault while the page table swap happens."
    ]

    // ── exec() step data ────────────────────────────────────────────────
    property var execTitles: ["open ELF binary","parse ELF header","uvmcreate() — new page table","load each PT_LOAD segment","set up user stack","copy argv[] strings","commit: free old table, set new"]
    property var execDescs: [
        "exec() starts with namei() to look up the file by path in the filesystem, then begin_op() to open a read-only session. It reads the first 4 bytes to verify the ELF magic number (0x7F 'E' 'L' 'F'). If the magic is wrong, exec() returns an error and the process keeps its old address space — exec() only replaces the process image on success.",
        "The ELF header (struct elfhdr) gives the entry point address and the offset + count of program headers. exec() reads each program header (struct proghdr) in a loop. It only acts on headers of type PT_LOAD (loadable segments). All others (PT_NOTE, PT_GNU_STACK, etc.) are skipped. It validates that va+memsz does not overflow and that va is below MAXVA.",
        "uvmcreate() allocates a fresh root page table page via kalloc() + memset. This new table starts completely empty — no mappings at all. exec() uses this new table for all the segment mappings, keeping the old table alive until everything succeeds. If any step fails (out of memory, bad ELF), exec() calls uvmfree() on the new table and returns -1 without touching the process.",
        "For each PT_LOAD header: uvmalloc() expands sz to cover va+memsz, allocating physical pages. loadseg() walks the page table (via walkaddr) to find each physical page, then readi() copies filesz bytes from the inode into that physical memory. The remaining memsz-filesz bytes (BSS) are zeroed. Flags from the ELF ph.flags determine PTE_W|PTE_X|PTE_R.",
        "exec() calls uvmalloc() again for two more pages: the guard page (left unmapped, flags=0) and the user stack page (flags=PTE_W|PTE_R). The stack pointer is set to the TOP of the stack page (sp = stackbase + PGSIZE). Stack grows downward so sp decrements as arguments are pushed. The guard page VA is explicitly cleared with uvmclear() to ensure no PTE_V bit.",
        "exec() pushes argument strings (argv[]) onto the stack from right to left, recording each string's VA. Then it pushes the argv[] pointer array, then argc (as a register argument), and finally a fake return address (0xFFFFFFFFFFFFFFFF). The trapframe's a0 and a1 are set to argc and argv so the user main() sees them as function arguments when it starts.",
        "Only after all steps succeed does exec() atomically commit: proc_freepagetable() frees the old page table (uvmunmap + kfree for each mapped page), p->pagetable = pagetable2 installs the new table, p->sz = sz records the new size, p->trapframe->epc = elf.entry sets the program entry point, p->trapframe->sp = sp sets the stack pointer. end_op() closes the filesystem session. On the next usertrapret(), the process runs the new program from elf.entry."
    ]
    property var execCodes: [
        "// kernel/exec.c (simplified)\nint exec(char *path, char **argv) {\n    struct inode *ip;\n    if((ip = namei(path)) == 0)\n        return -1;\n    begin_op();\n    // Read and verify ELF magic\n    struct elfhdr elf;\n    if(readi(ip,0,(uint64)&elf,0,sizeof(elf)) != sizeof(elf))\n        goto bad;\n    if(elf.magic != ELF_MAGIC)\n        goto bad;  // not an ELF file",
        "// kernel/exec.c\n// Loop over ELF program headers\nfor(int i=0, off=elf.phoff;\n        i < elf.phnum;\n        i++, off+=sizeof(ph)) {\n    struct proghdr ph;\n    if(readi(ip,0,(uint64)&ph,off,sizeof(ph)) != sizeof(ph))\n        goto bad;\n    if(ph.type != ELF_PROG_LOAD)\n        continue;\n    if(ph.memsz < ph.filesz)\n        goto bad;\n    if(ph.vaddr + ph.memsz < ph.vaddr)\n        goto bad;  // overflow check",
        "// kernel/exec.c + vm.c\npagetable_t pagetable = uvmcreate();\nif(pagetable == 0)\n    goto bad;\n\n// kernel/vm.c\npagetable_t uvmcreate() {\n    pagetable_t pt;\n    pt = (pagetable_t)kalloc();\n    if(pt == 0) return 0;\n    memset(pt, 0, PGSIZE);  // all PTEs invalid\n    return pt;\n}",
        "// kernel/exec.c\nuint64 sz = 0;\nfor(/* each PT_LOAD */) {\n    // grow address space to cover segment\n    if((sz = uvmalloc(pagetable, sz,\n            ph.vaddr+ph.memsz, flags2perm(ph.flags))) == 0)\n        goto bad;\n    // copy filesz bytes from inode, zero BSS\n    if(loadseg(pagetable, ph.vaddr, ip,\n            ph.off, ph.filesz) < 0)\n        goto bad;\n}",
        "// kernel/exec.c — stack setup\nuint64 stackbase = sz;\n// Allocate: guard page + stack page\nsz = PGROUNDUP(sz);\nif((sz = uvmalloc(pagetable, sz, sz+2*PGSIZE,\n        PTE_W|PTE_R)) == 0)\n    goto bad;\n// Guard page: clear valid bit\nuvmclear(pagetable, sz-2*PGSIZE);\nuint64 sp = sz;\nuint64 stackbase2 = sp - PGSIZE;",
        "// kernel/exec.c — push argv\nfor(argc=0; argv[argc]; argc++) {\n    sp -= strlen(argv[argc]) + 1;\n    sp -= sp % 16;  // align\n    if(copyout(pagetable, sp, argv[argc],\n            strlen(argv[argc])+1) < 0)\n        goto bad;\n    ustack[argc] = sp;  // save VA of string\n}\nustack[argc] = 0;       // null terminator\n// push argv[] array + argc + fake ret addr\nsp -= (argc+1)*8;\ncopyout(pagetable, sp, (char*)ustack, (argc+1)*8);\np->trapframe->a1 = sp;  // argv pointer\np->trapframe->a0 = argc;",
        "// kernel/exec.c — atomic commit\noldpagetable = p->pagetable;\np->pagetable  = pagetable;    // new table live\np->sz         = sz;\np->trapframe->epc = elf.entry; // entry point\np->trapframe->sp  = sp;        // stack top\n// Free old address space\nproc_freepagetable(oldpagetable, oldsz);\nend_op();  // close filesystem transaction\nreturn argc;  // returned in a0 to user\nbad:\n    if(pagetable) uvmfree(pagetable, sz);\n    end_op(); return -1;"
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
            border.color: Qt.rgba(16,185,129,0.25); border.width: 1
            layer.enabled: true
            layer.effect: Glow { radius:10; samples:17; color:Qt.rgba(16,185,129,0.12); spread:0.1 }
            Row {
                anchors.fill: parent; anchors.margins: 15; spacing: 16
                Rectangle {
                    width: 52; height: 52; radius: 12
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(16,185,129,0.15); border.color: Qt.rgba(16,185,129,0.4); border.width: 1
                    Column {
                        anchors.centerIn: parent; spacing: 1
                        Text { text:"08"; color:"#10b981"; font.bold:true; font.pixelSize:20; font.family:"Consolas"; anchors.horizontalCenter:parent.horizontalCenter }
                        Text { text:"LESSON"; color:Qt.rgba(16,185,129,0.5); font.pixelSize:7; font.letterSpacing:1; anchors.horizontalCenter:parent.horizontalCenter }
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 6
                    Text {
                        text: "USER ADDRESS SPACE — What exec() Builds for Every Process"
                        color: "#ffffff"; font.family:"Segoe UI"; font.bold:true; font.pixelSize:20; font.letterSpacing:0.5
                    }
                    Text {
                        text: "Layout of a user process virtual address space: text, data, heap, guard page, stack, trapframe, and trampoline — how exec() builds it step by step."
                        color: Qt.rgba(255,255,255,0.55); font.family:"Segoe UI"; font.pixelSize:12
                    }
                }
            }
        }

        // ── ADDRESS SPACE LAYOUT — visual stack + detail panel ──────────
        Rectangle {
            width: parent.width
            height: layoutRow.implicitHeight + 40
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(16,185,129,0.15); border.width: 1

            Row {
                id: layoutRow
                anchors.top:parent.top; anchors.topMargin:20
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 18

                // Left: address stack (high VA at top)
                Column {
                    width: parent.width * 0.32; spacing: 0

                    Text {
                        text: "HIGH VA (MAXVA)"; color: Qt.rgba(255,255,255,0.2)
                        font.pixelSize:9; font.letterSpacing:0.5; font.bold:true
                        leftPadding: 8; bottomPadding: 6
                    }

                    // Reversed display: index 6 (TRAMPOLINE) at top → index 0 (CODE) at bottom
                    Repeater {
                        model: 7
                        delegate: Rectangle {
                            property int ri: 6 - index   // real region index (reversed)
                            property bool isSel: scrollRoot.selectedLayer === ri
                            property bool isHov: scrollRoot.hoveredLayer === ri
                            width: parent.width
                            height: Math.max(36, scrollRoot.layerH[ri] * 2)
                            color: isSel ? Qt.rgba(scrollRoot.layerR[ri]/255,scrollRoot.layerG[ri]/255,scrollRoot.layerB[ri]/255, ri===3?0.06:0.18)
                                         : isHov ? Qt.rgba(scrollRoot.layerR[ri]/255,scrollRoot.layerG[ri]/255,scrollRoot.layerB[ri]/255, ri===3?0.03:0.09)
                                         : Qt.rgba(255,255,255, ri===3?0.01:0.02)
                            border.color: isSel ? (ri===3?"#666":scrollRoot.layerColors[ri]) : Qt.rgba(scrollRoot.layerR[ri]/255,scrollRoot.layerG[ri]/255,scrollRoot.layerB[ri]/255,ri===3?0.1:0.28)
                            border.width: isSel ? 1.5 : 1
                            Behavior on color { ColorAnimation { duration:130 } }

                            Rectangle {
                                width:4; height:parent.height-4
                                anchors.left:parent.left; anchors.verticalCenter:parent.verticalCenter
                                color: ri===3 ? "#555" : scrollRoot.layerColors[ri]; radius:2
                            }

                            Column {
                                anchors.left:parent.left; anchors.leftMargin:12
                                anchors.right:parent.right; anchors.rightMargin:8
                                anchors.verticalCenter:parent.verticalCenter; spacing:2
                                Text { text:scrollRoot.layerNames[ri]; color:ri===3?"#666":scrollRoot.layerColors[ri]; font.bold:true; font.pixelSize:9; font.letterSpacing:0.3 }
                                Text { text:scrollRoot.layerVALow[ri]; color:Qt.rgba(255,255,255,0.3); font.family:"Consolas"; font.pixelSize:8 }
                                Text { text:scrollRoot.layerPerms[ri]; color:ri===3?"#444":Qt.rgba(255,255,255,0.22); font.family:"Consolas"; font.pixelSize:8; visible:isSel }
                            }
                            MouseArea {
                                anchors.fill:parent; hoverEnabled:true; cursorShape:Qt.PointingHandCursor
                                onClicked: scrollRoot.selectedLayer = ri
                                onEntered: scrollRoot.hoveredLayer = ri
                                onExited:  scrollRoot.hoveredLayer = -1
                            }
                        }
                    }

                    Text {
                        text: "LOW VA (0x0000)"; color: Qt.rgba(255,255,255,0.2)
                        font.pixelSize:9; font.letterSpacing:0.5; font.bold:true
                        leftPadding: 8; topPadding: 6
                    }
                }

                // Right: detail panel
                Rectangle {
                    width: parent.width * 0.68 - 18
                    height: Math.max(layoutRow.implicitHeight - 0, detailPanelCol.implicitHeight + 28)
                    color: Qt.rgba(0,0,0,0.18); radius: 12
                    border.color: scrollRoot.selectedLayer>=0 ? Qt.rgba(scrollRoot.layerR[scrollRoot.selectedLayer]/255,scrollRoot.layerG[scrollRoot.selectedLayer]/255,scrollRoot.layerB[scrollRoot.selectedLayer]/255,0.4) : Qt.rgba(255,255,255,0.06)
                    border.width: 1.5

                    Column {
                        id: detailPanelCol
                        anchors.top:parent.top; anchors.topMargin:16
                        anchors.left:parent.left; anchors.leftMargin:16
                        anchors.right:parent.right; anchors.rightMargin:16
                        spacing: 10

                        Row { spacing:10
                            Rectangle {
                                width:10; height:10; radius:5
                                anchors.verticalCenter:parent.verticalCenter
                                color: scrollRoot.selectedLayer>=0 ? scrollRoot.layerColors[scrollRoot.selectedLayer] : "#888"
                            }
                            Text {
                                text: scrollRoot.selectedLayer>=0 ? scrollRoot.layerNames[scrollRoot.selectedLayer] : "Select a region"
                                color: scrollRoot.selectedLayer>=0 ? scrollRoot.layerColors[scrollRoot.selectedLayer] : Qt.rgba(255,255,255,0.35)
                                font.bold:true; font.pixelSize:14; font.letterSpacing:0.4
                            }
                        }

                        Row { spacing:18; visible:scrollRoot.selectedLayer>=0
                            Column { spacing:3
                                Text { text:"VA START"; color:Qt.rgba(255,255,255,0.22); font.pixelSize:8; font.letterSpacing:0.8 }
                                Text { text:scrollRoot.selectedLayer>=0?scrollRoot.layerVALow[scrollRoot.selectedLayer]:""; color:Qt.rgba(255,255,255,0.6); font.family:"Consolas"; font.pixelSize:10 }
                            }
                            Column { spacing:3
                                Text { text:"PERMISSIONS"; color:Qt.rgba(255,255,255,0.22); font.pixelSize:8; font.letterSpacing:0.8 }
                                Text { text:scrollRoot.selectedLayer>=0?scrollRoot.layerPerms[scrollRoot.selectedLayer]:""; color:Qt.rgba(255,255,255,0.6); font.family:"Consolas"; font.pixelSize:10 }
                            }
                        }

                        Rectangle { width:parent.width; height:1; color:Qt.rgba(255,255,255,0.05); visible:scrollRoot.selectedLayer>=0 }

                        Text {
                            width: parent.width
                            text: scrollRoot.selectedLayer>=0 ? scrollRoot.layerDescs[scrollRoot.selectedLayer] : "Click any segment in the address space diagram on the left."
                            color: scrollRoot.selectedLayer>=0 ? Qt.rgba(255,255,255,0.78) : Qt.rgba(255,255,255,0.28)
                            wrapMode: Text.WordWrap; font.family:"Segoe UI"; font.pixelSize:11; lineHeight:1.55
                        }
                    }
                }
            }
        }

        // ── exec() STEP-BY-STEP ──────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: execCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.015); radius: 14
            border.color: Qt.rgba(255,255,255,0.07); border.width: 1

            Column {
                id: execCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 16

                Row { spacing:10
                    Text{text:"🔧";font.pixelSize:18;anchors.verticalCenter:parent.verticalCenter}
                    Column { spacing:2
                        Text{text:"exec() INTERNALS — step through how a new user image is built";color:"#10b981";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3}
                        Text{text:"exec() is the system call that replaces a process's address space with a new program";color:Qt.rgba(255,255,255,0.35);font.pixelSize:11}
                    }
                }

                // Step progress bar
                Row {
                    spacing: 6
                    Repeater {
                        model: 7
                        delegate: Row {
                            spacing: 0
                            Rectangle {
                                width: 26; height: 26; radius: 13
                                color: scrollRoot.execStep >= index ? "#10b981" : Qt.rgba(16,185,129,0.1)
                                border.color: "#10b981"; border.width: scrollRoot.execStep>=index?0:1
                                Behavior on color { ColorAnimation { duration:180 } }
                                Text { anchors.centerIn:parent; text:(index+1).toString(); color:scrollRoot.execStep>=index?"#fff":Qt.rgba(255,255,255,0.3); font.bold:true; font.pixelSize:10; font.family:"Consolas" }
                                MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked: scrollRoot.execStep=index }
                            }
                            Rectangle { visible:index<6; width:16; height:2; anchors.verticalCenter:parent.verticalCenter; color:scrollRoot.execStep>index?"#10b981":Qt.rgba(255,255,255,0.1); Behavior on color{ColorAnimation{duration:180}} }
                        }
                    }
                }

                Text {
                    text: scrollRoot.execTitles[scrollRoot.execStep]
                    color: "#34d399"; font.bold:true; font.pixelSize:14; font.letterSpacing:0.3
                }

                Row {
                    width: parent.width; spacing: 14

                    Text {
                        width: parent.width * 0.38
                        text: scrollRoot.execDescs[scrollRoot.execStep]
                        color: Qt.rgba(255,255,255,0.75); font.family:"Segoe UI"; font.pixelSize:11
                        wrapMode: Text.WordWrap; lineHeight: 1.55
                    }

                    Rectangle {
                        width: parent.width * 0.62 - 14
                        height: execCodeText.implicitHeight + 32
                        color: Qt.rgba(0,0,0,0.3); radius: 10
                        border.color: Qt.rgba(255,255,255,0.06); border.width: 1

                        Rectangle {
                            width:parent.width; height:22; color:Qt.rgba(255,255,255,0.04); radius:10
                            Rectangle{width:parent.width;height:11;anchors.bottom:parent.bottom;color:parent.color}
                            Row { anchors.left:parent.left;anchors.leftMargin:8;anchors.verticalCenter:parent.verticalCenter;spacing:4
                                Repeater{model:3;delegate:Rectangle{width:7;height:7;radius:3.5;color:["#f43f5e","#fbbf24","#10b981"][index];opacity:0.7}}
                            }
                            Text{text:"kernel/exec.c";color:Qt.rgba(255,255,255,0.18);font.pixelSize:9;font.family:"Consolas";anchors.centerIn:parent}
                        }
                        Text {
                            id: execCodeText
                            anchors.top:parent.top; anchors.topMargin:28
                            anchors.left:parent.left; anchors.leftMargin:12
                            anchors.right:parent.right; anchors.rightMargin:12
                            text: scrollRoot.execCodes[scrollRoot.execStep]
                            color: Qt.rgba(255,255,255,0.82); font.family:"Consolas"; font.pixelSize:10
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere; lineHeight: 1.5
                        }
                    }
                }

                Row {
                    spacing: 10
                    Rectangle {
                        width:90;height:34;radius:9
                        color:scrollRoot.execStep>0?Qt.rgba(16,185,129,0.15):Qt.rgba(255,255,255,0.03)
                        border.color:scrollRoot.execStep>0?"#10b981":Qt.rgba(255,255,255,0.1); border.width:1
                        Text{anchors.centerIn:parent;text:"← PREV";color:scrollRoot.execStep>0?"#10b981":Qt.rgba(255,255,255,0.2);font.bold:true;font.pixelSize:11}
                        MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:if(scrollRoot.execStep>0)scrollRoot.execStep--}
                    }
                    Rectangle {
                        width:90;height:34;radius:9
                        color:scrollRoot.execStep<6?Qt.rgba(16,185,129,0.15):Qt.rgba(255,255,255,0.03)
                        border.color:scrollRoot.execStep<6?"#10b981":Qt.rgba(255,255,255,0.1); border.width:1
                        Text{anchors.centerIn:parent;text:"NEXT →";color:scrollRoot.execStep<6?"#10b981":Qt.rgba(255,255,255,0.2);font.bold:true;font.pixelSize:11}
                        MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:if(scrollRoot.execStep<6)scrollRoot.execStep++}
                    }
                    Text{anchors.verticalCenter:parent.verticalCenter;text:"Step "+(scrollRoot.execStep+1)+" of 7";color:Qt.rgba(255,255,255,0.2);font.pixelSize:11}
                }
            }
        }

        // ── sbrk / heap growth quick-ref ─────────────────────────────────
        Rectangle {
            width: parent.width
            height: sbrkCol.implicitHeight + 32
            color: Qt.rgba(249/255,115/255,22/255,0.05); radius: 14
            border.color: Qt.rgba(249/255,115/255,22/255,0.2); border.width: 1

            Column {
                id: sbrkCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 12

                Row { spacing:10
                    Text{text:"📈";font.pixelSize:18;anchors.verticalCenter:parent.verticalCenter}
                    Column { spacing:2
                        Text{text:"HEAP GROWTH — sbrk() and how the kernel allocates user pages on demand";color:"#f97316";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3}
                        Text{text:"sbrk(n) grows the heap by n bytes; sbrk(-n) shrinks it";color:Qt.rgba(255,255,255,0.35);font.pixelSize:11}
                    }
                }

                Row {
                    width: parent.width; spacing: 14

                    Column { width:(parent.width-14)*0.5; spacing:10
                        Repeater {
                            model: [
                                ["sbrk(n)","sys_sbrk → growproc(n) → uvmalloc(pt, oldsz, oldsz+n, PTE_W|PTE_R)"],
                                ["sbrk(-n)","growproc(-n) → uvmdealloc(pt, oldsz, oldsz-n) + kfree each page"],
                                ["p->sz","Tracks top of heap; updated atomically; visible in /proc (procfs not in xv6 but concept applies)"],
                                ["OOM","kalloc() returns 0 → uvmalloc returns 0 → growproc returns -1 → sbrk returns -1 (errno = ENOMEM in libc)"]
                            ]
                            delegate: Row {
                                spacing:10; width:parent.width
                                Rectangle { width:82;height:30;radius:6;color:Qt.rgba(249/255,115/255,22/255,0.12);border.color:"#f97316";border.width:1
                                    Text{anchors.centerIn:parent;text:modelData[0];color:"#f97316";font.family:"Consolas";font.bold:true;font.pixelSize:10}
                                }
                                Text{width:parent.width-92;text:modelData[1];color:Qt.rgba(255,255,255,0.65);font.family:"Segoe UI";font.pixelSize:11;wrapMode:Text.WordWrap}
                            }
                        }
                    }

                    Rectangle {
                        width:(parent.width-14)*0.5
                        height:heapCode.implicitHeight+32
                        color:Qt.rgba(0,0,0,0.28);radius:10
                        border.color:Qt.rgba(255,255,255,0.06);border.width:1

                        Rectangle{width:parent.width;height:22;color:Qt.rgba(255,255,255,0.04);radius:10
                            Rectangle{width:parent.width;height:11;anchors.bottom:parent.bottom;color:parent.color}
                            Row{anchors.left:parent.left;anchors.leftMargin:8;anchors.verticalCenter:parent.verticalCenter;spacing:4
                                Repeater{model:3;delegate:Rectangle{width:7;height:7;radius:3.5;color:["#f43f5e","#fbbf24","#10b981"][index];opacity:0.7}}}
                            Text{text:"kernel/sysproc.c + vm.c";color:Qt.rgba(255,255,255,0.18);font.pixelSize:9;font.family:"Consolas";anchors.centerIn:parent}
                        }
                        Text {
                            id: heapCode
                            anchors.top:parent.top;anchors.topMargin:28
                            anchors.left:parent.left;anchors.leftMargin:12
                            anchors.right:parent.right;anchors.rightMargin:12
                            text:"// kernel/sysproc.c\nuint64 sys_sbrk(void) {\n    int n;\n    argint(0, &n);\n    uint64 addr = myproc()->sz;\n    if(growproc(n) < 0)\n        return -1;\n    return addr; // old brk = start of new region\n}\n// kernel/proc.c\nint growproc(int n) {\n    uint sz = p->sz;\n    if(n > 0){\n        sz = uvmalloc(p->pagetable, sz, sz+n,\n                      PTE_W|PTE_R);\n        if(sz == 0) return -1;\n    } else {\n        sz = uvmdealloc(p->pagetable, sz, sz+n);\n    }\n    p->sz = sz;\n    return 0;\n}"
                            color:Qt.rgba(255,255,255,0.82);font.family:"Consolas";font.pixelSize:10
                            wrapMode:Text.WrapAtWordBoundaryOrAnywhere;lineHeight:1.5
                        }
                    }
                }
            }
        }

        // ── FOOTER ──────────────────────────────────────────────────────

        // ── USER ADDRESS SPACE EXPLORER ─────────────────────────────────
        Rectangle {
            id: uasSim
            width:parent.width; height:uasCol.implicitHeight+32
            color:Qt.rgba(255,255,255,0.015); radius:14
            border.color:Qt.rgba(236,72,153,0.2); border.width:1

            property int stackFrames: 1
            property int maxFrames: 5
            property int selSeg: 0
            property var segments: [
                {name:"TRAMPOLINE",  va:"MAXVA-1 page", color:"#ec4899", pct:0.04,
                 desc:"Kernel page mapped into user space (read-only). Contains uservec/userret. Lets the CPU switch address spaces without changing PC mid-trap."},
                {name:"TRAPFRAME",   va:"MAXVA-2 pages",color:"#f97316", pct:0.04,
                 desc:"Per-process struct p→trapframe. Kernel writes registers here on trap entry; restores on return. User code cannot write here (not mapped U-accessible)."},
                {name:"STACK",       va:"grows down ↓", color:"#fbbf24", pct:0.12,
                 desc:"User call stack. Each function call pushes a frame (return addr, saved regs, locals). sp register points to current top. Guard page (PTE_V=0) below catches overflow — causes page fault."},
                {name:"HEAP",        va:"grows up ↑",   color:"#a78bfa", pct:0.18,
                 desc:"Dynamic memory (malloc/sbrk). Grows upward via sbrk() syscall. xv6 allocates one page at a time. p→sz tracks the current top of heap."},
                {name:"DATA/BSS",    va:"above text",   color:"#10b981", pct:0.1,
                 desc:"Initialized globals (DATA) and zero-initialized globals (BSS). Loaded from the ELF binary by exec(). BSS pages are zeroed by the kernel."},
                {name:"TEXT",        va:"0x0 (base)",   color:"#06b6d4", pct:0.12,
                 desc:"Executable code. Loaded by exec() from the ELF. Read+execute only (PTE_R|PTE_X). The entry point (main) is in this segment."}
            ]

            Column {
                id:uasCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing:14

                Row { spacing:10
                    Text { text:"📐"; font.pixelSize:18; anchors.verticalCenter:parent.verticalCenter }
                    Column { spacing:2
                        Text { text:"USER ADDRESS SPACE — click segments, simulate stack growth"; color:"#ec4899"; font.bold:true; font.pixelSize:13 }
                        Text { text:"xv6 Sv39: 39-bit VA. User space top=MAXVA (0x40_0000_0000). Each process gets an isolated VA space."; color:Qt.rgba(255,255,255,0.32); font.pixelSize:11 }
                    }
                }

                Row { spacing:16; width:parent.width

                    // Visual map
                    Column { spacing:3; width:120
                        Text { text:"HIGH (MAXVA)"; color:Qt.rgba(255,255,255,0.2); font.pixelSize:8; horizontalAlignment:Text.AlignRight; width:parent.width }
                        Repeater { model:uasSim.segments
                            delegate: Rectangle {
                                property bool active: uasSim.selSeg===index
                                width:120; height:Math.max(28, modelData.pct*220)+(index===2?uasSim.stackFrames*10:0); radius:6
                                color:active?Qt.rgba(255,255,255,0.07):Qt.rgba(255,255,255,0.025)
                                border.color:active?modelData.color:Qt.rgba(255,255,255,0.06); border.width:active?2:1
                                Text { anchors.centerIn:parent; text:modelData.name+(index===2?"  ["+uasSim.stackFrames+"f]":""); color:active?modelData.color:Qt.rgba(255,255,255,0.4); font.pixelSize:9; font.bold:true; horizontalAlignment:Text.AlignHCenter; width:parent.width-8; wrapMode:Text.WordWrap }
                                MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:uasSim.selSeg=index }
                            }
                        }
                        Text { text:"LOW (0x0)"; color:Qt.rgba(255,255,255,0.2); font.pixelSize:8; width:parent.width }
                    }

                    // Detail + stack sim
                    Column { spacing:12; width:parent.width-136

                        // Segment detail
                        Rectangle { width:parent.width; height:segDetail.implicitHeight+20; radius:10; color:Qt.rgba(0,0,0,0.2); border.color:uasSim.segments[uasSim.selSeg].color; border.width:1
                            Column { id:segDetail; anchors.top:parent.top; anchors.topMargin:12; anchors.left:parent.left; anchors.leftMargin:14; anchors.right:parent.right; anchors.rightMargin:14; spacing:6
                                Row { spacing:10
                                    Text { text:uasSim.segments[uasSim.selSeg].name; color:uasSim.segments[uasSim.selSeg].color; font.bold:true; font.pixelSize:13 }
                                    Text { text:uasSim.segments[uasSim.selSeg].va; color:Qt.rgba(255,255,255,0.3); font.pixelSize:10; font.family:"Consolas"; anchors.verticalCenter:parent.verticalCenter }
                                }
                                Text { text:uasSim.segments[uasSim.selSeg].desc; color:Qt.rgba(255,255,255,0.65); font.pixelSize:11; wrapMode:Text.WordWrap; width:parent.width; lineHeight:1.6 }
                            }
                        }

                        // Stack simulator
                        Column { spacing:8; width:parent.width
                            Text { text:"STACK FRAME SIMULATOR"; color:Qt.rgba(255,255,255,0.2); font.pixelSize:9; font.letterSpacing:1 }
                            Row { spacing:8
                                Rectangle { height:32; width:pushBtn.implicitWidth+18; radius:9; color:uasSim.stackFrames<uasSim.maxFrames?Qt.rgba(251/255,191/255,36/255,0.15):Qt.rgba(255,255,255,0.04); border.color:uasSim.stackFrames<uasSim.maxFrames?"#fbbf24":Qt.rgba(255,255,255,0.1); border.width:1
                                    Text { id:pushBtn; anchors.centerIn:parent; text:"push frame (call)"; color:uasSim.stackFrames<uasSim.maxFrames?"#fbbf24":Qt.rgba(255,255,255,0.2); font.pixelSize:11 }
                                    MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:if(uasSim.stackFrames<uasSim.maxFrames) uasSim.stackFrames++ }
                                }
                                Rectangle { height:32; width:popBtn.implicitWidth+18; radius:9; color:uasSim.stackFrames>1?Qt.rgba(236/255,72/255,153/255,0.12):Qt.rgba(255,255,255,0.04); border.color:uasSim.stackFrames>1?"#ec4899":Qt.rgba(255,255,255,0.1); border.width:1
                                    Text { id:popBtn; anchors.centerIn:parent; text:"pop frame (return)"; color:uasSim.stackFrames>1?"#ec4899":Qt.rgba(255,255,255,0.2); font.pixelSize:11 }
                                    MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:if(uasSim.stackFrames>1) uasSim.stackFrames-- }
                                }
                            }
                            // Stack frames visual
                            Column { spacing:2; width:parent.width
                                Repeater { model:uasSim.stackFrames
                                    delegate: Rectangle { width:parent.width; height:26; radius:6
                                        color:Qt.rgba(251/255,191/255,36/255, 0.06+index*0.05)
                                        border.color:Qt.rgba(251/255,191/255,36/255,0.25); border.width:1
                                        Row { anchors.left:parent.left; anchors.leftMargin:10; anchors.verticalCenter:parent.verticalCenter; spacing:12
                                            Text { text:index===0?"► sp → frame "+(uasSim.stackFrames-index):"    frame "+(uasSim.stackFrames-index); color:index===0?"#fbbf24":Qt.rgba(255,255,255,0.4); font.pixelSize:10; font.family:"Consolas" }
                                            Text { text:"[ra | s0..s11 | locals]"; color:Qt.rgba(255,255,255,0.2); font.pixelSize:9; font.family:"Consolas" }
                                        }
                                    }
                                }
                                Rectangle { width:parent.width; height:20; radius:6; color:Qt.rgba(244/255,63/255,94/255,0.12); border.color:"#f43f5e"; border.width:1
                                    Text { anchors.centerIn:parent; text:"GUARD PAGE — PTE_V=0 — stack overflow → page fault here"; color:"#f43f5e"; font.pixelSize:9 }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            width:parent.width; height:65
            color:Qt.rgba(16/255,185/255,129/255,0.08); radius:14
            border.color:Qt.rgba(16/255,185/255,129/255,0.35); border.width:1
            RowLayout {
                anchors.fill:parent; anchors.margins:15; spacing:15
                Text{text:"🌟";font.pixelSize:22;Layout.alignment:Qt.AlignVCenter}
                Text {
                    Layout.fillWidth:true; Layout.alignment:Qt.AlignVCenter
                    text:"CORE SUMMARY: A user address space (bottom→top): code (R/X), data (R/W), heap (grows up via sbrk), guard page (unmapped), stack (R/W, grows down, 1 page), trapframe (MAXVA−2, R/W, PTE_U=0), trampoline (MAXVA−1, R/X, PTE_U=0). exec() builds this atomically: allocates a new table, loads ELF segments, sets up stack, commits by swapping p->pagetable. sbrk() grows/shrinks the heap. The guard page catches stack overflow at hardware level."
                    color:"#ffffff"; wrapMode:Text.WordWrap; font.family:"Segoe UI"; font.bold:true; font.pixelSize:12; font.letterSpacing:0.2
                }
            }
        }

        // ── TAKE QUIZ BUTTON ────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 52; radius: 14
            color: quizNavBtn.containsMouse ? Qt.rgba(255,255,255,0.10) : Qt.rgba(255,255,255,0.04)
            border.color: "#ec4899"; border.width: 1
            Behavior on color { ColorAnimation { duration: 180 } }
            Text {
                anchors.centerIn: parent
                text: "QUIZ  →  USER SPACE"
                color: "#ec4899"; font.bold: true; font.pixelSize: 13
                font.family: "Segoe UI"; font.letterSpacing: 0.4
            }
            MouseArea {
                id: quizNavBtn; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: scrollRoot.requestNavigate("UserSpaceQuizPage.qml")
            }
        }
        // ── NEXT LESSON BUTTON ───────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 52; radius: 14
            color: nextBtn.containsMouse ? Qt.rgba(139,92,246/255,0.22) : Qt.rgba(139,92,246/255,0.10)
            border.color: "#8b5cf6"; border.width: 1
            Behavior on color { ColorAnimation { duration: 180 } }
            Row {
                anchors.centerIn: parent; spacing: 12
                Text { text: "→  CONTEXT SWITCH"; color: "#8b5cf6"; font.bold: true; font.pixelSize: 13; font.family: "Segoe UI"; font.letterSpacing: 0.4; anchors.verticalCenter: parent.verticalCenter }
            }
            MouseArea {
                id: nextBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: scrollRoot.requestNavigate("ContextSwitchPage.qml")
            }
        }
    }
}
