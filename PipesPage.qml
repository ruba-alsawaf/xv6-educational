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

    // ── Pipe ring-buffer simulation ───────────────────────────────────
    property int  pipeWritePos: 0
    property int  pipeReadPos:  0
    property int  pipeBytes:    0
    property bool pipeWriteOpen: true
    property bool pipeReadOpen:  true
    property string pipeMsg:    "Type chars below"
    property string pipeBuf:    "        "   // 8 slots visual

    // ── FD table selection ────────────────────────────────────────────
    property int  selectedFD: -1
    property int  selectedProc: 0

    // ── Pipe simulator state (at root level for qmlsc) ───────────────
    property int pipeCapacity: 16
    property var pipeBufArr: []
    property var pipeLog: []

    function simPipeWrite(n) {
        var added = 0
        for(var i = 0; i < n; i++){
            if(scrollRoot.pipeBufArr.length >= scrollRoot.pipeCapacity){
                var l2 = scrollRoot.pipeLog.slice()
                l2.unshift("write("+n+"): BLOCKED — full at byte "+i+"|#f43f5e")
                if(l2.length > 6) l2.pop()
                scrollRoot.pipeLog = l2; return
            }
            var b = scrollRoot.pipeBufArr.slice()
            b.push(String.fromCharCode(65 + scrollRoot.pipeBufArr.length))
            scrollRoot.pipeBufArr = b; added++
        }
        var l = scrollRoot.pipeLog.slice()
        l.unshift("write("+n+"): wrote "+added+" bytes — buf="+scrollRoot.pipeBufArr.length+"/"+scrollRoot.pipeCapacity+"|#10b981")
        if(l.length > 6) l.pop()
        scrollRoot.pipeLog = l
    }

    function simPipeRead(n) {
        if(scrollRoot.pipeBufArr.length === 0){
            var l2 = scrollRoot.pipeLog.slice()
            l2.unshift("read("+n+"): BLOCKED — empty (sleeping...)|#f43f5e")
            if(l2.length > 6) l2.pop()
            scrollRoot.pipeLog = l2; return
        }
        var took = Math.min(n, scrollRoot.pipeBufArr.length)
        var b = scrollRoot.pipeBufArr.slice(); b.splice(0, took)
        scrollRoot.pipeBufArr = b
        var l = scrollRoot.pipeLog.slice()
        l.unshift("read("+n+"): consumed "+took+" bytes — buf="+scrollRoot.pipeBufArr.length+"/"+scrollRoot.pipeCapacity+"|#06b6d4")
        if(l.length > 6) l.pop()
        scrollRoot.pipeLog = l
    }

    function simResetPipe() { scrollRoot.pipeBufArr = []; scrollRoot.pipeLog = [] }

    // ── Accordion ─────────────────────────────────────────────────────
    property int openCard: 0

    property var cardTitles: ["struct pipe — Ring Buffer Internals","pipewrite() — writing to the pipe","piperead() — reading from the pipe","struct file & the Open File Table","File Descriptors — per-process table"]
    property var cardSubs: ["PIPESIZE=512 bytes, nread, nwrite, lock, readopen, writeopen","acquire pipe lock, loop writing bytes, wakeup reader, sleep if full","acquire pipe lock, loop reading bytes, wakeup writer, sleep if empty","struct file in kernel: type, ref, readable, writable, offset, *ip/*pipe","each process has files[NOFILE=16]; index is the fd number"]
    property var cardColors: ["#ec4899","#8b5cf6","#06b6d4","#10b981","#f97316"]
    property var cardR: [236,139,6,16,249]; property var cardG: [72,92,182,185,115]; property var cardB: [153,246,212,129,22]
    property var cardSources: ["kernel/pipe.c","kernel/pipe.c","kernel/pipe.c","kernel/file.h + file.c","kernel/proc.h + sysfile.c"]
    property var cardTheories: [
        "A pipe in xv6 is a fixed-size ring buffer (PIPESIZE = 512 bytes) allocated on the heap. struct pipe contains: char data[PIPESIZE] — the ring buffer itself; uint nread — total bytes read (ever); uint nwrite — total bytes written (ever); int readopen / writeopen — whether each end is still open; struct spinlock lock — protects all fields. The current data in the pipe = nwrite - nread bytes. The buffer is full when nwrite - nread == PIPESIZE. The buffer is empty when nwrite == nread. Buffer position uses modular arithmetic: data[nread % PIPESIZE] is the next byte to read, data[nwrite % PIPESIZE] is the next slot to write. This means nread and nwrite never wrap (they grow forever) — only the index into data[] uses modulo.",
        "pipewrite(struct pipe *pi, uint64 addr, int n): acquires pi->lock. Loops n times: if buffer full (nwrite-nread==PIPESIZE): if no reader (readopen==0): return -1. Otherwise sleep(&pi->nwrite, &pi->lock) — waits for reader to consume. When space available: copy one byte from user addr using either_copyin(), increment nwrite. After each byte written, wakeup(&pi->nread) to notify any sleeping reader. If the write end is closed mid-write (due to signal etc.), may return fewer than n bytes. Returns number of bytes written or -1 on error. The wakeup happens inside the loop so readers can start consuming while writer continues.",
        "piperead(struct pipe *pi, uint64 addr, int n): acquires pi->lock. If empty (nread==nwrite): if no writer (writeopen==0): return 0 (EOF). Otherwise sleep(&pi->nread, &pi->lock) — waits for writer. When data available: copies up to n bytes from data[nread%PIPESIZE] using either_copyout(), increments nread. After reading, wakeup(&pi->nwrite) to unblock any sleeping writer. Returns the number of bytes read. read() returns 0 (EOF) only when the buffer is empty AND the write end is closed — matching POSIX pipe semantics. The sleeping channel is &pi->nread — the address of the nread field itself serves as the unique wakeup channel.",
        "struct file (kernel/file.h): type (FD_NONE/FD_PIPE/FD_INODE/FD_DEVICE); ref (reference count for dup/fork sharing); readable, writable (permission flags); off (current seek offset for inode files); union { struct pipe*; struct inode*; struct devsw* }. The global open file table (struct file ftable[NFILE=100]) holds all open files system-wide. filealloc() finds a free slot (ref=0). filedup() increments ref (for dup() and fork()). fileclose() decrements ref; when ref reaches 0, the slot is freed and (if pipe) pipeclose() is called. Multiple FDs in the same or different processes can share the same struct file (same offset) — this is how dup2() and fork work.",
        "Each process has a files array: struct file *ofile[NOFILE] (kernel/proc.h, NOFILE=16). The index is the file descriptor number. fdalloc() finds the lowest unused index (0, 1, 2...) and installs the struct file* there. Standard I/O: fd 0=stdin, fd 1=stdout, fd 2=stderr (set up by userinit). fork() copies ofile[] into the child: for each slot, if p->ofile[i] != 0, filedup(p->ofile[i]) increments the ref count. Both parent and child share the same struct file* objects, so seeks in one affect the other (POSIX behavior). close() calls fileclose() which decrements ref; when ref==0, the file is truly released. exec() closes FDs with the O_CLOEXEC flag (xv6 doesn't implement this but standard shells rely on it)."
    ]
    property var cardCodes: [
        "// kernel/pipe.c\n#define PIPESIZE 512\nstruct pipe {\n    struct spinlock lock;\n    char data[PIPESIZE];  // ring buffer\n    uint nread;           // total bytes read\n    uint nwrite;          // total bytes written\n    int  readopen;        // is read end open?\n    int  writeopen;       // is write end open?\n};\n// Empty: nread == nwrite\n// Full:  nwrite - nread == PIPESIZE\n// Next write slot: data[nwrite % PIPESIZE]\n// Next read slot:  data[nread  % PIPESIZE]\n// Current bytes:   nwrite - nread\n\n// kernel/sysfile.c — pipe() syscall\nint sys_pipe(void) {\n    int fd[2];\n    struct file *rf, *wf;\n    pipealloc(&rf, &wf);  // allocate pipe + 2 files\n    fdalloc(rf);  // fd[0] = read end\n    fdalloc(wf);  // fd[1] = write end\n}",
        "// kernel/pipe.c\nint pipewrite(struct pipe *pi,\n              uint64 addr, int n) {\n    acquire(&pi->lock);\n    int i = 0;\n    while(i < n) {\n        if(pi->readopen == 0 || killed(myproc())) {\n            release(&pi->lock); return -1;\n        }\n        if(pi->nwrite-pi->nread == PIPESIZE) {\n            // Buffer full: wake reader, sleep\n            wakeup(&pi->nread);\n            sleep(&pi->nwrite, &pi->lock);\n        } else {\n            char ch;\n            either_copyin(&ch, 1, addr+i, 1);\n            pi->data[pi->nwrite++ % PIPESIZE] = ch;\n            i++;\n        }\n    }\n    wakeup(&pi->nread); // final wakeup\n    release(&pi->lock);\n    return i;\n}",
        "// kernel/pipe.c\nint piperead(struct pipe *pi,\n             uint64 addr, int n) {\n    acquire(&pi->lock);\n    // Wait until data available or EOF\n    while(pi->nread == pi->nwrite &&\n          pi->writeopen) {\n        if(killed(myproc())) {\n            release(&pi->lock); return -1;\n        }\n        sleep(&pi->nread, &pi->lock);\n    }\n    int i;\n    for(i=0; i<n && pi->nread<pi->nwrite; i++) {\n        char ch = pi->data[pi->nread++ % PIPESIZE];\n        either_copyout(1, addr+i, &ch, 1);\n    }\n    wakeup(&pi->nwrite); // space freed, wake writer\n    release(&pi->lock);\n    return i; // 0 = EOF (no data, no writer)\n}",
        "// kernel/file.h\nstruct file {\n    enum { FD_NONE, FD_PIPE,\n           FD_INODE, FD_DEVICE } type;\n    int  ref;       // reference count\n    char readable;\n    char writable;\n    struct pipe *pipe;  // if FD_PIPE\n    struct inode *ip;   // if FD_INODE/DEVICE\n    uint off;           // current offset\n    short major;        // if FD_DEVICE\n};\n\n// kernel/file.c — global open file table\nstruct { struct spinlock lock;\n         struct file file[NFILE]; } ftable;\n\nstruct file* filealloc(void) {\n    acquire(&ftable.lock);\n    for(f = ftable.file; f < ftable.file+NFILE; f++)\n        if(f->ref == 0) { f->ref = 1; return f; }\n    release(&ftable.lock); return 0; // ENFILE\n}",
        "// kernel/proc.h\nstruct proc {\n    // ...\n    struct file *ofile[NOFILE]; // open files (NOFILE=16)\n    // fd 0=stdin, 1=stdout, 2=stderr by convention\n};\n// kernel/sysfile.c\nstatic int fdalloc(struct file *f) {\n    struct proc *p = myproc();\n    for(int fd = 0; fd < NOFILE; fd++) {\n        if(p->ofile[fd] == 0) { // empty slot\n            p->ofile[fd] = f;\n            return fd;  // lowest available fd\n        }\n    }\n    return -1;  // EMFILE (too many open files)\n}\n// fork() shares open files:\nfor(int i = 0; i < NOFILE; i++)\n    if(p->ofile[i])\n        np->ofile[i] = filedup(p->ofile[i]); // ref++"
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
            border.color: Qt.rgba(236,72,153,0.25); border.width: 1
            layer.enabled: true
            layer.effect: Glow { radius:10; samples:17; color:Qt.rgba(236,72,153,0.12); spread:0.1 }
            Row {
                anchors.fill: parent; anchors.margins: 15; spacing: 16
                Rectangle {
                    width: 52; height: 52; radius: 12; anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(236,72,153,0.15); border.color: Qt.rgba(236,72,153,0.4); border.width: 1
                    Column { anchors.centerIn: parent; spacing: 1
                        Text { text:"11"; color:"#ec4899"; font.bold:true; font.pixelSize:20; font.family:"Consolas"; anchors.horizontalCenter:parent.horizontalCenter }
                        Text { text:"LESSON"; color:Qt.rgba(236,72,153,0.5); font.pixelSize:7; font.letterSpacing:1; anchors.horizontalCenter:parent.horizontalCenter }
                    }
                }
                Column { anchors.verticalCenter: parent.verticalCenter; spacing: 6
                    Text { text:"PIPES & FILE DESCRIPTORS — The I/O Abstraction Layer"; color:"#ffffff"; font.family:"Segoe UI"; font.bold:true; font.pixelSize:20; font.letterSpacing:0.5 }
                    Text { text:"How xv6 connects processes via pipes (ring buffers), and how file descriptors abstract all I/O through struct file, the open file table, and per-process FD arrays."; color:Qt.rgba(255,255,255,0.55); font.family:"Segoe UI"; font.pixelSize:12 }
                }
            }
        }

        // ── PIPE RING BUFFER VISUALIZER ──────────────────────────────────
        Rectangle {
            width: parent.width; height: ringCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(236,72,153,0.2); border.width: 1

            Column {
                id: ringCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 14

                Row { spacing:10
                    Text{text:"🔄";font.pixelSize:18;anchors.verticalCenter:parent.verticalCenter}
                    Column{spacing:2
                        Text{text:"PIPE RING BUFFER — PIPESIZE = 512 bytes, simplified to 8 slots here";color:"#ec4899";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3}
                        Text{text:"nread and nwrite grow forever; slot = value % 8. Full when nwrite-nread=8. Empty when nwrite=nread.";color:Qt.rgba(255,255,255,0.35);font.pixelSize:11}
                    }
                }

                Row { width:parent.width; spacing:14

                    // Ring buffer visual
                    Column { width:parent.width*0.55; spacing:12

                        // 8 slot ring
                        Row {
                            spacing: 4
                            Repeater {
                                model: 8
                                delegate: Rectangle {
                                    property bool hasData: {
                                        var nr = scrollRoot.pipeReadPos
                                        var nw = scrollRoot.pipeWritePos
                                        if(nw === nr) return false
                                        // check if slot index is between read and write
                                        var bytes = nw - nr
                                        for(var b=0; b<bytes && b<8; b++) {
                                            if((nr+b) % 8 === index) return true
                                        }
                                        return false
                                    }
                                    property bool isWriteSlot: scrollRoot.pipeWritePos % 8 === index && scrollRoot.pipeBytes < 8
                                    property bool isReadSlot: scrollRoot.pipeReadPos % 8 === index
                                    width: (parent.width - 28) / 8; height: 60; radius: 8
                                    color: hasData ? Qt.rgba(236/255,72/255,153/255,0.25) : Qt.rgba(255,255,255,0.03)
                                    border.color: isWriteSlot ? "#10b981" : isReadSlot ? "#f43f5e" : (hasData ? "#ec4899" : Qt.rgba(255,255,255,0.1))
                                    border.width: (isWriteSlot||isReadSlot) ? 2 : 1

                                    Column { anchors.centerIn:parent; spacing:3
                                        Text { text:index.toString(); color:Qt.rgba(255,255,255,0.25); font.pixelSize:9; font.family:"Consolas"; anchors.horizontalCenter:parent.horizontalCenter }
                                        Text { text:hasData?"█":"·"; color:hasData?"#ec4899":Qt.rgba(255,255,255,0.15); font.pixelSize:hasData?18:14; anchors.horizontalCenter:parent.horizontalCenter }
                                        Text { text:isWriteSlot?"W":isReadSlot?"R":""; color:isWriteSlot?"#10b981":"#f43f5e"; font.bold:true; font.pixelSize:8; anchors.horizontalCenter:parent.horizontalCenter }
                                    }
                                }
                            }
                        }

                        // Legend
                        Row { spacing:16
                            Row{spacing:5;Rectangle{width:12;height:12;radius:3;color:"#10b981";anchors.verticalCenter:parent.verticalCenter}Text{text:"nwrite (W)";color:Qt.rgba(255,255,255,0.5);font.pixelSize:10}}
                            Row{spacing:5;Rectangle{width:12;height:12;radius:3;color:"#f43f5e";anchors.verticalCenter:parent.verticalCenter}Text{text:"nread (R)";color:Qt.rgba(255,255,255,0.5);font.pixelSize:10}}
                            Row{spacing:5;Rectangle{width:12;height:12;radius:3;color:"#ec4899";opacity:0.6;anchors.verticalCenter:parent.verticalCenter}Text{text:"data in buffer";color:Qt.rgba(255,255,255,0.5);font.pixelSize:10}}
                        }

                        // nread/nwrite counters
                        Row { spacing:20
                            Column { spacing:3
                                Text{text:"nwrite";color:Qt.rgba(255,255,255,0.3);font.pixelSize:9;font.letterSpacing:0.5}
                                Text{text:scrollRoot.pipeWritePos.toString();color:"#10b981";font.family:"Consolas";font.bold:true;font.pixelSize:20}
                            }
                            Column { spacing:3
                                Text{text:"nread";color:Qt.rgba(255,255,255,0.3);font.pixelSize:9;font.letterSpacing:0.5}
                                Text{text:scrollRoot.pipeReadPos.toString();color:"#f43f5e";font.family:"Consolas";font.bold:true;font.pixelSize:20}
                            }
                            Column { spacing:3
                                Text{text:"bytes";color:Qt.rgba(255,255,255,0.3);font.pixelSize:9;font.letterSpacing:0.5}
                                Text{text:(scrollRoot.pipeWritePos-scrollRoot.pipeReadPos).toString();color:"#ec4899";font.family:"Consolas";font.bold:true;font.pixelSize:20}
                            }
                            Column { spacing:3
                                Text{text:"status";color:Qt.rgba(255,255,255,0.3);font.pixelSize:9;font.letterSpacing:0.5}
                                Text{
                                    text: (scrollRoot.pipeWritePos-scrollRoot.pipeReadPos)===8?"FULL":(scrollRoot.pipeWritePos===scrollRoot.pipeReadPos?"EMPTY":"PARTIAL")
                                    color:(scrollRoot.pipeWritePos-scrollRoot.pipeReadPos)===8?"#f43f5e":(scrollRoot.pipeWritePos===scrollRoot.pipeReadPos?"#fbbf24":"#10b981")
                                    font.family:"Consolas";font.bold:true;font.pixelSize:14
                                }
                            }
                        }

                        // Write/Read buttons
                        Row { spacing:10
                            Rectangle { width:110;height:36;radius:9
                                color:(scrollRoot.pipeWritePos-scrollRoot.pipeReadPos)<8?Qt.rgba(16,185,129,0.15):Qt.rgba(255,255,255,0.03)
                                border.color:(scrollRoot.pipeWritePos-scrollRoot.pipeReadPos)<8?"#10b981":Qt.rgba(255,255,255,0.1);border.width:1
                                Text{anchors.centerIn:parent;text:"WRITE byte";color:(scrollRoot.pipeWritePos-scrollRoot.pipeReadPos)<8?"#10b981":Qt.rgba(255,255,255,0.2);font.bold:true;font.pixelSize:11}
                                MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:{if((scrollRoot.pipeWritePos-scrollRoot.pipeReadPos)<8){scrollRoot.pipeWritePos++}}}
                            }
                            Rectangle { width:110;height:36;radius:9
                                color:scrollRoot.pipeWritePos>scrollRoot.pipeReadPos?Qt.rgba(244,63,94,0.15):Qt.rgba(255,255,255,0.03)
                                border.color:scrollRoot.pipeWritePos>scrollRoot.pipeReadPos?"#f43f5e":Qt.rgba(255,255,255,0.1);border.width:1
                                Text{anchors.centerIn:parent;text:"READ byte";color:scrollRoot.pipeWritePos>scrollRoot.pipeReadPos?"#f43f5e":Qt.rgba(255,255,255,0.2);font.bold:true;font.pixelSize:11}
                                MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:{if(scrollRoot.pipeWritePos>scrollRoot.pipeReadPos){scrollRoot.pipeReadPos++}}}
                            }
                            Rectangle { width:80;height:36;radius:9
                                color:Qt.rgba(255,255,255,0.03); border.color:Qt.rgba(255,255,255,0.15); border.width:1
                                Text{anchors.centerIn:parent;text:"RESET";color:Qt.rgba(255,255,255,0.4);font.bold:true;font.pixelSize:11}
                                MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:{scrollRoot.pipeWritePos=0;scrollRoot.pipeReadPos=0}}
                            }
                        }
                    }

                    // FD abstraction diagram
                    Rectangle {
                        width:parent.width*0.45-14; height:fdDiagCol.implicitHeight+24
                        color:Qt.rgba(0,0,0,0.18); radius:12
                        border.color:Qt.rgba(236,72,153,0.25); border.width:1

                        Column {
                            id:fdDiagCol
                            anchors.top:parent.top;anchors.topMargin:16
                            anchors.left:parent.left;anchors.leftMargin:16
                            anchors.right:parent.right;anchors.rightMargin:16
                            spacing:10

                            Text{text:"FD ABSTRACTION LAYERS";color:"#ec4899";font.bold:true;font.pixelSize:11;font.letterSpacing:0.5}
                            Rectangle{width:parent.width;height:1;color:Qt.rgba(255,255,255,0.06)}

                            Repeater {
                                model:[
                                    ["Process A","fd 0=stdin, fd 1=stdout, fd 4=pipe_read","#ec4899"],
                                    ["↓ ofile[fd]","struct file* pointer lookup in per-process array","#a78bfa"],
                                    ["struct file","type=PIPE, ref=2, readable=1, writable=0","#8b5cf6"],
                                    ["↓ file->pipe","pointer to shared struct pipe","#60a5fa"],
                                    ["struct pipe","data[512], nread, nwrite, lock","#06b6d4"],
                                    ["↓ disk / virtio","(or inode for regular files)","#10b981"]
                                ]
                                delegate: Rectangle {
                                    width:parent.width; height:diagText.implicitHeight+14; radius:7
                                    color:Qt.rgba(0,0,0,0.12)
                                    border.color:Qt.rgba(1,1,1,0.0); border.width:0
                                    Row { anchors.left:parent.left;anchors.leftMargin:10;anchors.verticalCenter:parent.verticalCenter;spacing:8
                                        Rectangle{width:3;height:parent.parent.height-8;radius:1.5;color:modelData[2];anchors.verticalCenter:parent.verticalCenter}
                                        Column { spacing:1
                                            Text{text:modelData[0];color:modelData[2];font.bold:true;font.pixelSize:10;font.family:"Consolas"}
                                            Text{id:diagText;text:modelData[1];color:Qt.rgba(255,255,255,0.5);font.pixelSize:9;wrapMode:Text.WordWrap;width:parent.parent.parent.width-30}
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── ACCORDION — pipe internals ────────────────────────────────────
        Rectangle {
            width: parent.width; height: pipeAccord.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.015); radius: 14
            border.color: Qt.rgba(255,255,255,0.07); border.width: 1

            Column {
                id: pipeAccord
                anchors.top:parent.top;anchors.topMargin:18
                anchors.left:parent.left;anchors.leftMargin:18
                anchors.right:parent.right;anchors.rightMargin:18
                spacing: 6

                Text{text:"DEEP DIVE — five topics on pipes and file descriptors";color:Qt.rgba(236,72,153,0.6);font.bold:true;font.pixelSize:11;font.letterSpacing:0.4}

                Repeater {
                    model: 5
                    delegate: Rectangle {
                        property bool isOpen: scrollRoot.openCard === index
                        width: parent.width; height: isOpen ? pipeBody.implicitHeight + 84 : 52
                        clip: true; radius: 10
                        color: isOpen ? Qt.rgba(scrollRoot.cardR[index]/255,scrollRoot.cardG[index]/255,scrollRoot.cardB[index]/255,0.07) : Qt.rgba(255,255,255,0.02)
                        border.color: isOpen ? scrollRoot.cardColors[index] : Qt.rgba(scrollRoot.cardR[index]/255,scrollRoot.cardG[index]/255,scrollRoot.cardB[index]/255,0.22)
                        border.width: isOpen ? 1.5 : 1
                        Behavior on height { NumberAnimation { duration:270; easing.type:Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration:160 } }

                        Row { anchors.left:parent.left;anchors.leftMargin:14;anchors.right:pChev.left;anchors.rightMargin:8;anchors.top:parent.top;height:52;spacing:10
                            Rectangle{width:6;height:6;radius:3;color:scrollRoot.cardColors[index];anchors.verticalCenter:parent.verticalCenter}
                            Column{anchors.verticalCenter:parent.verticalCenter;spacing:3
                                Text{text:scrollRoot.cardTitles[index];color:isOpen?scrollRoot.cardColors[index]:"#ffffff";font.bold:true;font.pixelSize:12;font.letterSpacing:0.2;Behavior on color{ColorAnimation{duration:160}}}
                                Text{text:scrollRoot.cardSubs[index];color:Qt.rgba(255,255,255,0.3);font.pixelSize:9}
                            }
                        }
                        Text{id:pChev;text:isOpen?"▲":"▼";color:Qt.rgba(255,255,255,0.3);font.pixelSize:10;anchors.right:parent.right;anchors.rightMargin:14;anchors.top:parent.top;anchors.topMargin:21}

                        Row {
                            id: pipeBody
                            anchors.top:parent.top;anchors.topMargin:58
                            anchors.left:parent.left;anchors.leftMargin:14
                            anchors.right:parent.right;anchors.rightMargin:14
                            spacing:12
                            Column { width:(parent.width-12)*0.40;spacing:10
                                Text{text:scrollRoot.cardSources[index];color:scrollRoot.cardColors[index];font.family:"Consolas";font.pixelSize:10;font.bold:true}
                                Rectangle{width:parent.width;height:1;color:Qt.rgba(255,255,255,0.06)}
                                Text{width:parent.width;text:scrollRoot.cardTheories[index];color:Qt.rgba(255,255,255,0.78);wrapMode:Text.WordWrap;font.family:"Segoe UI";font.pixelSize:11;lineHeight:1.55}
                            }
                            Rectangle { width:(parent.width-12)*0.60;height:pipeCode.implicitHeight+32;color:Qt.rgba(0,0,0,0.28);radius:9;border.color:Qt.rgba(255,255,255,0.06);border.width:1
                                Rectangle{width:parent.width;height:22;color:Qt.rgba(255,255,255,0.04);radius:9;
                                    Rectangle{width:parent.width;height:11;anchors.bottom:parent.bottom;color:parent.color}
                                    Row{anchors.left:parent.left;anchors.leftMargin:8;anchors.verticalCenter:parent.verticalCenter;spacing:4;Repeater{model:3;delegate:Rectangle{width:7;height:7;radius:3.5;color:["#f43f5e","#fbbf24","#10b981"][index];opacity:0.7}}}
                                    Text{text:scrollRoot.cardSources[index];color:Qt.rgba(255,255,255,0.22);font.pixelSize:9;font.family:"Consolas";anchors.centerIn:parent}
                                }
                                Text{id:pipeCode;anchors.top:parent.top;anchors.topMargin:28;anchors.left:parent.left;anchors.leftMargin:10;anchors.right:parent.right;anchors.rightMargin:10;text:scrollRoot.cardCodes[index];color:Qt.rgba(255,255,255,0.82);font.family:"Consolas";font.pixelSize:10;wrapMode:Text.WrapAtWordBoundaryOrAnywhere;lineHeight:1.5}
                            }
                        }
                        MouseArea{anchors.left:parent.left;anchors.right:parent.right;anchors.top:parent.top;height:52;cursorShape:Qt.PointingHandCursor;onClicked:scrollRoot.openCard=isOpen?-1:index}
                    }
                }
            }
        }

        // ── FOOTER ──────────────────────────────────────────────────────

        // ── PIPE BUFFER SIMULATOR ───────────────────────────────────────
        Rectangle {
            id: pipeSimRect
            width:parent.width; height:pipeSimCol.implicitHeight+32
            color:Qt.rgba(255,255,255,0.015); radius:14
            border.color:Qt.rgba(249,115,22,0.2); border.width:1

            Column {
                id:pipeSimCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing:14

                Row { spacing:10
                    Text { text:"🔄"; font.pixelSize:18; anchors.verticalCenter:parent.verticalCenter }
                    Column { spacing:2
                        Text { text:"PIPE BUFFER SIMULATOR — PIPESIZE=16 bytes"; color:"#f97316"; font.bold:true; font.pixelSize:13 }
                        Text { text:"write() blocks when full. read() blocks when empty. Both block until conditions change."; color:Qt.rgba(255,255,255,0.32); font.pixelSize:11 }
                    }
                }

                // Buffer visualization
                Row { spacing:3; width:parent.width; height:44
                    Repeater { model:scrollRoot.pipeCapacity
                        delegate: Rectangle {
                            width:(scrollRoot.pipeCapacity>0?(pipeSimCol.width - scrollRoot.pipeCapacity*3)/scrollRoot.pipeCapacity:0); height:44; radius:5
                            color:index<scrollRoot.pipeBufArr.length?Qt.rgba(249/255,115/255,22/255,0.35):Qt.rgba(255,255,255,0.04)
                            border.color:index<scrollRoot.pipeBufArr.length?"#f97316":Qt.rgba(255,255,255,0.08); border.width:1
                            Column { anchors.centerIn:parent; spacing:3
                                Text { text:index<scrollRoot.pipeBufArr.length?scrollRoot.pipeBufArr[index]:"·"; color:index<scrollRoot.pipeBufArr.length?"#fbbf24":Qt.rgba(255,255,255,0.15); font.pixelSize:9; font.family:"Consolas" }
                                Text { text:""+index; color:Qt.rgba(255,255,255,0.15); font.pixelSize:7 }
                            }
                        }
                    }
                }

                // Fill bar
                Row { spacing:10; width:parent.width
                    Text { text:"Buffer:"; color:Qt.rgba(255,255,255,0.35); font.pixelSize:11; anchors.verticalCenter:parent.verticalCenter }
                    Rectangle { id:fillBarBg; width:parent.width-130; height:14; radius:7; color:Qt.rgba(255,255,255,0.06)
                        Rectangle { width:fillBarBg.width*(scrollRoot.pipeBufArr.length/scrollRoot.pipeCapacity); height:14; radius:7
                            color:scrollRoot.pipeBufArr.length>=scrollRoot.pipeCapacity?"#f43f5e":scrollRoot.pipeBufArr.length>scrollRoot.pipeCapacity*0.7?"#fbbf24":"#f97316"
                            Behavior on width{NumberAnimation{duration:120}}
                        }
                    }
                    Text { text:scrollRoot.pipeBufArr.length+"/"+scrollRoot.pipeCapacity; color:"#fbbf24"; font.pixelSize:11; font.family:"Consolas"; width:44 }
                }

                // Controls
                Row { spacing:10; width:parent.width
                    Row { spacing:6
                        Text { text:"write"; color:"#10b981"; font.pixelSize:11; font.bold:true; anchors.verticalCenter:parent.verticalCenter }
                        Repeater { model:[1,4,8]
                            delegate: Rectangle { height:30; width:28; radius:7; color:Qt.rgba(16/255,185/255,129/255,0.15); border.color:"#10b981"; border.width:1
                                Text { anchors.centerIn:parent; text:"+"+modelData; color:"#10b981"; font.pixelSize:10; font.family:"Consolas" }
                                MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:scrollRoot.simPipeWrite(modelData) }
                            }
                        }
                    }
                    Row { spacing:6
                        Text { text:"read"; color:"#06b6d4"; font.pixelSize:11; font.bold:true; anchors.verticalCenter:parent.verticalCenter }
                        Repeater { model:[1,3,8]
                            delegate: Rectangle { height:30; width:28; radius:7; color:Qt.rgba(6/255,182/255,212/255,0.1); border.color:"#06b6d4"; border.width:1
                                Text { anchors.centerIn:parent; text:"-"+modelData; color:"#06b6d4"; font.pixelSize:10; font.family:"Consolas" }
                                MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:scrollRoot.simPipeRead(modelData) }
                            }
                        }
                    }
                    Rectangle { height:30; width:rstPipeBtn.implicitWidth+14; radius:7; color:Qt.rgba(255,255,255,0.04); border.color:Qt.rgba(255,255,255,0.1); border.width:1
                        Text { id:rstPipeBtn; anchors.centerIn:parent; text:"reset"; color:Qt.rgba(255,255,255,0.3); font.pixelSize:10 }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:scrollRoot.simResetPipe() }
                    }
                }

                // Log — stored as "msg|color" strings to avoid var-of-objects model
                Column { spacing:3; width:parent.width
                    Repeater { model:scrollRoot.pipeLog
                        delegate: Text {
                            property string logMsg: modelData.split("|")[0]
                            property string logCol: modelData.split("|")[1]
                            text:"› "+logMsg; color:logCol
                            font.pixelSize:10; font.family:"Consolas"
                            width:pipeSimCol.width; wrapMode:Text.WordWrap
                        }
                    }
                }
            }
        }

        Rectangle {
            width:parent.width; height:65
            color:Qt.rgba(236/255,72/255,153/255,0.08); radius:14
            border.color:Qt.rgba(236/255,72/255,153/255,0.35); border.width:1
            RowLayout {
                anchors.fill:parent; anchors.margins:15; spacing:15
                Text{text:"🌟";font.pixelSize:22;Layout.alignment:Qt.AlignVCenter}
                Text { Layout.fillWidth:true; Layout.alignment:Qt.AlignVCenter
                                        text:"CORE SUMMARY: A pipe = 512-byte ring buffer (struct pipe). nwrite-nread = bytes pending. Full → writer sleeps. Empty → reader sleeps. Both use sleep()/wakeup() for synchronization. struct file wraps pipe/inode/device with ref count and offset. Per-process ofile[NOFILE=16] array maps integer fd → struct file*. fork() shares open files (filedup increments ref). Lowest available index = new fd number."
                    color:"#ffffff"; wrapMode:Text.WordWrap; font.family:"Segoe UI"; font.bold:true; font.pixelSize:12; font.letterSpacing:0.2
                }
            }
        }

        // ── TAKE QUIZ BUTTON ────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 52; radius: 14
            color: quizNavBtn.containsMouse ? Qt.rgba(255,255,255,0.10) : Qt.rgba(255,255,255,0.04)
            border.color: "#6366f1"; border.width: 1
            Behavior on color { ColorAnimation { duration: 180 } }
            Text {
                anchors.centerIn: parent
                text: "QUIZ  →  PIPES & FILE DESC"
                color: "#6366f1"; font.bold: true; font.pixelSize: 13
                font.family: "Segoe UI"; font.letterSpacing: 0.4
            }
            MouseArea {
                id: quizNavBtn; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: scrollRoot.requestNavigate("PipesQuizPage.qml")
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
                Text { text: "→  FS OVERVIEW"; color: "#8b5cf6"; font.bold: true; font.pixelSize: 13; font.family: "Segoe UI"; font.letterSpacing: 0.4; anchors.verticalCenter: parent.verticalCenter }
            }
            MouseArea {
                id: nextBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: scrollRoot.requestNavigate("FsOverviewPage.qml")
            }
        }
    }
}
