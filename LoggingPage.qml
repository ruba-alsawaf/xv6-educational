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

    property int  txStep:    0
    property int  openCard:  0
    property real logDot:    0.0

    Timer { interval:22; running:true; repeat:true; onTriggered: scrollRoot.logDot=(scrollRoot.logDot+0.004)%1.0 }

    // ── Transaction step data ─────────────────────────────────────────
    property var txTitles: ["begin_op() — start transaction","log_write(b) — mark buffer for log","end_op() — last op done, maybe commit","write_log() — copy bufs → log area on disk","write_head() — commit atomically","install_trans() — copy log → real locations","Clear log header — transaction complete"]
    property var txColors: ["#f97316","#fbbf24","#10b981","#06b6d4","#f43f5e","#8b5cf6","#a78bfa"]
    property var txDescs: [
        "begin_op() starts a filesystem transaction. It acquires log.lock, then waits (sleep) while the log is committing or while adding another transaction would exceed log capacity (log.outstanding * MAXOPBLOCKS > LOGSIZE - log.lh.n). When safe: increments log.outstanding (transaction count). Releases log.lock. From this point, all bread/bwrite calls should go through log_write() to ensure they are included in the transaction. Multiple system calls can share a transaction — xv6 groups calls together to amortize the commit overhead.",
        "log_write(b) absorbs a buffer write into the current transaction. Acquires log.lock. Checks if block is already in log.lh.block[] (absorption — avoids duplicate log entries for same block). If not: appends b->blockno to log.lh.block[log.lh.n++]. Calls bpin(b) to keep the buffer in memory until commit. Releases log.lock. CRITICAL: log_write does NOT touch the disk. It just records which buffers are dirty and must be logged. The actual data is still only in the in-memory buffer. bwrite() is never called directly by filesystem code above the logging layer.",
        "end_op() signals that the current call has finished its file operations. Acquires log.lock. Decrements log.outstanding. If log.outstanding > 0: other transactions are still running, so just wake up anyone waiting in begin_op() and return. If log.outstanding == 0: time to commit. Sets log.committing=1, releases log.lock. Calls commit() which does write_log + write_head + install_trans + clear_header. Then reacquires log.lock, sets log.committing=0, wakeup() any waiting begin_op() callers. The commit is always done by the last transaction to finish.",
        "write_log() copies all dirty buffers from memory to the log area on disk. Iterates log.lh.n dirty blocks. For each: reads the log sector (tail = log block i+1), copies the data from the in-memory dirty buffer into this log sector buffer, writes it to disk with bwrite(), releases it. After write_log(), every dirty block has its data persisted in the log area. If a crash occurs after write_log() but before write_head(), recovery ignores the uncommitted log (log header shows n=0).",
        "write_head() is the commit point — the single atomic write that makes the transaction permanent. Reads the log header block from disk into a buffer. Copies log.lh.n (count) and log.lh.block[] (block numbers) into the on-disk header. bwrite()s the header block. THIS IS THE COMMIT. If the system crashes before this write: transaction is rolled back. If it crashes after: transaction will be replayed on recovery. The header write must be atomic (single sector write = atomic on VIRTIO disk). That's why n is written in a single header block.",
        "install_trans(recovering) copies log blocks back to their real disk locations. For i in 0..log.lh.n-1: reads log block (log.logstart + i + 1) into lbuf. Reads the destination block (log.lh.block[i]) into dbuf. Copies lbuf->data into dbuf->data. If not recovering: marks dbuf dirty (but does not bwrite — buffer cache handles it). Writes dbuf with bwrite(). Releases both buffers. Then calls bunpin() on each dirty buffer (paired with bpin() from log_write). After install_trans(), the real disk blocks have the committed data.",
        "After install_trans(), the log is logically complete. Clearing the log header makes this official: sets log.lh.n = 0, writes the header block to disk (write_head again with n=0). Now if a crash occurs, recovery sees an empty log and does nothing. The committed data is already at its real location. This is the only log entry that gets cleared — everything else is overwritten in place next transaction. begin_op() callers blocked waiting for log space are now woken up."
    ]
    property var txCodes: [
        "// kernel/log.c\nvoid begin_op(void) {\n    acquire(&log.lock);\n    while(1) {\n        if(log.committing) {\n            sleep(&log, &log.lock);\n        } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE) {\n            // Not enough log space: wait\n            sleep(&log, &log.lock);\n        } else {\n            log.outstanding++;\n            release(&log.lock);\n            return;\n        }\n    }\n}",
        "// kernel/log.c\nvoid log_write(struct buf *b) {\n    acquire(&log.lock);\n    // Check for absorption (same block again)\n    int i;\n    for(i=0; i<log.lh.n; i++)\n        if(log.lh.block[i] == b->blockno)\n            break;  // already in log, reuse slot\n    log.lh.block[i] = b->blockno;\n    if(i == log.lh.n) {  // new entry\n        bpin(b);  // keep in memory until commit\n        log.lh.n++;\n    }\n    release(&log.lock);\n    // NO disk write here — just bookkeeping\n}",
        "// kernel/log.c\nvoid end_op(void) {\n    acquire(&log.lock);\n    log.outstanding--;\n    if(log.committing) panic(\"log.committing\");\n    if(log.outstanding == 0) {\n        log.committing = 1;\n        release(&log.lock);\n        commit();  // write_log+write_head+install\n        acquire(&log.lock);\n        log.committing = 0;\n    }\n    wakeup(&log);  // wake begin_op waiters\n    release(&log.lock);\n}",
        "// kernel/log.c\nstatic void write_log(void) {\n    for(int tail=0; tail<log.lh.n; tail++) {\n        // Log sector = logstart + tail + 1\n        struct buf *to   = bread(log.dev,\n            log.start + tail + 1);\n        struct buf *from = bread(log.dev,\n            log.lh.block[tail]); // dirty buffer\n        memmove(to->data, from->data, BSIZE);\n        bwrite(to);   // write to log area on disk\n        brelse(from);\n        brelse(to);\n    }\n}",
        "// kernel/log.c — THE COMMIT POINT\nstatic void write_head(void) {\n    struct buf *buf = bread(log.dev, log.start);\n    struct logheader *hb = (struct logheader*)(buf->data);\n    hb->n = log.lh.n;  // write count\n    for(int i=0; i<log.lh.n; i++)\n        hb->block[i] = log.lh.block[i]; // block list\n    bwrite(buf);  // ← ATOMIC COMMIT\n    // After this write: crash = replay on recovery\n    // Before this write: crash = no effect (rolled back)\n    brelse(buf);\n}",
        "// kernel/log.c\nstatic void install_trans(int recovering) {\n    for(int tail=0; tail<log.lh.n; tail++) {\n        struct buf *lbuf = bread(log.dev,\n            log.start + tail + 1); // log copy\n        struct buf *dbuf = bread(log.dev,\n            log.lh.block[tail]);   // real location\n        memmove(dbuf->data, lbuf->data, BSIZE);\n        bwrite(dbuf);  // write to real block\n        if(recovering == 0)\n            bunpin(dbuf); // paired with bpin in log_write\n        brelse(lbuf);\n        brelse(dbuf);\n    }\n}",
        "// kernel/log.c\nstatic void commit() {\n    if(log.lh.n > 0) {\n        write_log();      // 1. dirty bufs → log disk\n        write_head();     // 2. COMMIT (header write)\n        install_trans(0); // 3. log → real locations\n        log.lh.n = 0;     // 4. clear in memory\n        write_head();     // 5. clear on disk (n=0)\n    }\n}\n\n// Recovery (on boot after crash):\nvoid recover_from_log(void) {\n    read_head();         // read log header\n    install_trans(1);    // replay if lh.n > 0\n    log.lh.n = 0;\n    write_head();        // clear the log\n}"
    ]

    property var cardTitles: ["WHY LOGGING? The Crash Safety Problem","The Log on Disk — Structure & Layout","Log Absorption — Deduplication Optimization","MAXOPBLOCKS & LOGSIZE — capacity constraints","Recovery — what happens on boot after crash"]
    property var cardSubs: ["Without logging: partial writes leave filesystem in inconsistent state","logstart, nlog blocks; header block + nlog data blocks","same block modified twice in one tx → only one log entry needed","each syscall uses at most MAXOPBLOCKS; LOGSIZE must fit all outstanding ops","initlog() → recover_from_log() → install_trans() → clear header"]
    property var cardColors2: ["#f97316","#fbbf24","#10b981","#06b6d4","#f43f5e"]
    property var cardR2: [249,251,16,6,244]; property var cardG2: [115,191,185,182,63]; property var cardB2: [22,36,129,212,94]
    property var cardSrc2: ["kernel/log.c","kernel/fs.h + log.c","kernel/log.c","kernel/log.c","kernel/log.c"]
    property var cardTh2: [
        "Consider a file creation: xv6 must write the inode (mark as used), write the directory entry (link name to inode), update the bitmap (mark data block allocated). If the system crashes after inode write but before directory write, the inode is allocated but unreachable — a leak. Without logging, the filesystem is inconsistent. The logging layer solves this with atomicity: either ALL writes in a transaction appear on disk, or NONE do. The key insight: the log header write (write_head) is a single-sector write and is atomic on VIRTIO. It either completes or doesn't — no partial state.",
        "The log occupies a contiguous region on disk starting at block logstart (from superblock). Block logstart+0 is the header block: struct logheader { int n; int block[LOGSIZE] }. n is the count of dirty blocks in the current committed transaction. block[i] is the real disk block number for log data block i. Log data blocks: logstart+1 through logstart+n. On boot, initlog() reads this header. If n>0, there's a committed but not fully installed transaction — recover_from_log() replays it. If n=0, the log is clean.",
        "A critical optimization: log absorption. If the same disk block is log_write()d multiple times within one transaction (e.g., allocating multiple inodes in the same inode block), log_write() detects it: scans log.lh.block[] for an existing entry with the same blockno. If found, it reuses that slot (i stays at the found index, no bpin, no increment of log.lh.n). This avoids duplicate log entries for the same block, reducing log size and disk writes. Without absorption, a transaction that touches the same bitmap block 10 times would need 10 log entries instead of 1.",
        "LOGSIZE is the total log capacity in blocks (kernel/param.h, typically 30). MAXOPBLOCKS is the max number of blocks one filesystem syscall can dirty (typically 10). The constraint: log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS <= LOGSIZE. begin_op() sleeps if this would be violated. This ensures the log always has room to absorb one more complete operation. If MAXOPBLOCKS is too small, some operations corrupt the log. If LOGSIZE is too small, all operations sleep waiting for commits. xv6's values (LOGSIZE=30, MAXOPBLOCKS=10) allow at most 3 concurrent operations before blocking.",
        "On every boot, initlog() calls recover_from_log() before any filesystem activity. recover_from_log(): reads the log header (read_head). If log.lh.n > 0: there's a committed transaction not yet installed (crash between write_head and final clear). Calls install_trans(1) to copy all log data blocks to their real locations, then write_head() with n=0 to clear the log. If n=0: log is clean, nothing to do. This replay is idempotent — install_trans with the same data is safe to run multiple times. After recovery, the filesystem is consistent and normal operation resumes."
    ]
    property var cardCode2: [
        "// The three-write problem (no logging):\n// Step 1: write inode (type = T_FILE)\n// Step 2: write directory entry\n// Step 3: write bitmap (alloc data block)\n// CRASH after step 1:\n//   inode=allocated, dir entry=missing,\n//   bitmap=unchanged → inode leak + inconsistency\n\n// With logging: all three are in one transaction\nbegin_op();\n  // Step 1: iget + ilock + modify + log_write\n  // Step 2: dirlink() → log_write\n  // Step 3: balloc() → log_write\nend_op();  // atomic commit\n// Either all 3 appear on disk, or none",
        "// kernel/fs.h\n#define LOGSIZE (MAXOPBLOCKS*3) // 30 blocks\nstruct logheader {\n    int n;               // # entries in log\n    int block[LOGSIZE];  // real block numbers\n};\n// kernel/log.c\nstruct log {\n    struct spinlock lock;\n    int start;           // log area start block\n    int size;            // # log blocks\n    int outstanding;     // active begin_op() calls\n    int committing;      // in commit()?\n    int dev;\n    struct logheader lh; // in-memory log header\n};\n// Disk layout of log area:\n// [logstart+0]: header block (n + block[])\n// [logstart+1..logstart+n]: dirty data copies",
        "// kernel/log.c — absorption in log_write\nvoid log_write(struct buf *b) {\n    acquire(&log.lock);\n    int i;\n    for(i=0; i<log.lh.n; i++)\n        if(log.lh.block[i] == b->blockno)\n            break;  // found: reuse slot, no bpin\n    log.lh.block[i] = b->blockno;\n    if(i == log.lh.n) {   // truly new entry\n        bpin(b);           // keep in memory\n        log.lh.n++;\n        if(log.lh.n >= LOGSIZE) panic(\"too big\");\n    }\n    release(&log.lock);\n}\n// Example: ialloc touches same inode block 3x\n// → only 1 log entry, 1 disk write at commit",
        "// kernel/param.h\n#define MAXOPBLOCKS 10   // max blocks per syscall\n#define LOGSIZE (MAXOPBLOCKS*3)  // = 30\n\n// begin_op() constraint:\n// log.lh.n + (log.outstanding+1)*MAXOPBLOCKS\n//           <= LOGSIZE\n// Worst case: 3 concurrent syscalls each touching\n// 10 blocks → 30 log entries (LOGSIZE).\n// A 4th would need space for 10 more = 40 > 30\n// → it sleeps in begin_op().\n\n// Which syscalls use the most blocks?\n// write(): up to MAXOPBLOCKS per call\n// create(): inode + dir + bitmap = ~4 blocks\n// unlink(): inode + dir + bitmap = ~4 blocks",
        "// kernel/log.c\nvoid initlog(int dev, struct superblock *sb) {\n    log.start = sb->logstart;\n    log.size   = sb->nlog;\n    log.dev    = dev;\n    recover_from_log();\n}\nstatic void recover_from_log(void) {\n    read_head();         // load log header from disk\n    install_trans(1);    // replay if lh.n > 0\n    log.lh.n = 0;\n    write_head();        // clear log (n=0 on disk)\n}\n// install_trans is idempotent:\n// Running it twice with the same log data is safe\n// — it just copies the same bytes twice.\n// This is crucial for crash recovery correctness."
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
            border.color: Qt.rgba(249,115,22,0.25); border.width: 1
            layer.enabled: true
            layer.effect: Glow { radius:10; samples:17; color:Qt.rgba(249,115,22,0.12); spread:0.1 }
            Row {
                anchors.fill: parent; anchors.margins: 15; spacing: 16
                Rectangle {
                    width: 52; height: 52; radius: 12; anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(249,115,22,0.15); border.color: Qt.rgba(249,115,22,0.4); border.width: 1
                    Column { anchors.centerIn: parent; spacing: 1
                        Text { text:"14"; color:"#f97316"; font.bold:true; font.pixelSize:20; font.family:"Consolas"; anchors.horizontalCenter:parent }
                        Text { text:"LESSON"; color:Qt.rgba(249,115,22,0.5); font.pixelSize:7; font.letterSpacing:1; anchors.horizontalCenter:parent }
                    }
                }
                Column { anchors.verticalCenter: parent.verticalCenter; spacing: 6
                    Text { text:"LOGGING & CRASH RECOVERY — Write-Ahead Log (log.c)"; color:"#ffffff"; font.family:"Segoe UI"; font.bold:true; font.pixelSize:20; font.letterSpacing:0.5 }
                    Text { text:"How xv6 guarantees filesystem consistency after crashes: write-ahead logging with begin_op/log_write/end_op, atomic commit via write_head(), and automatic recovery on boot."; color:Qt.rgba(255,255,255,0.55); font.family:"Segoe UI"; font.pixelSize:12 }
                }
            }
        }

        // ── TRANSACTION LIFECYCLE STEPPER ─────────────────────────────────
        Rectangle {
            width: parent.width; height: txStepCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(249,115,22,0.2); border.width: 1

            Column {
                id: txStepCol
                anchors.top:parent.top;anchors.topMargin:18;anchors.left:parent.left;anchors.leftMargin:18;anchors.right:parent.right;anchors.rightMargin:18
                spacing:16

                Row{spacing:10;Text{text:"🔐";font.pixelSize:18;anchors.verticalCenter:parent.verticalCenter}Column{spacing:2;Text{text:"TRANSACTION LIFECYCLE — step through a complete logging cycle from begin_op to commit";color:"#f97316";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3}Text{text:"Every filesystem write goes through this pipeline to guarantee crash-safety";color:Qt.rgba(255,255,255,0.35);font.pixelSize:11}}}

                // Step dots
                Row { spacing:6
                    Repeater { model:7; delegate: Row { spacing:0
                        Rectangle { width:24;height:24;radius:12
                            color:scrollRoot.txStep>=index?scrollRoot.txColors[index]:Qt.rgba(255,255,255,0.05)
                            border.color:scrollRoot.txColors[index];border.width:scrollRoot.txStep>=index?0:1
                            Behavior on color{ColorAnimation{duration:180}}
                            Text{anchors.centerIn:parent;text:(index+1).toString();color:scrollRoot.txStep>=index?"#fff":Qt.rgba(255,255,255,0.3);font.bold:true;font.pixelSize:9;font.family:"Consolas"}
                            MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:scrollRoot.txStep=index}
                        }
                        Rectangle{visible:index<6;width:12;height:2;anchors.verticalCenter:parent.verticalCenter;color:scrollRoot.txStep>index?scrollRoot.txColors[index]:Qt.rgba(255,255,255,0.1);Behavior on color{ColorAnimation{duration:180}}}
                    }}
                }

                Text{text:scrollRoot.txTitles[scrollRoot.txStep];color:scrollRoot.txColors[scrollRoot.txStep];font.bold:true;font.pixelSize:14;font.letterSpacing:0.3}

                Row { width:parent.width; spacing:14
                    Text { width:parent.width*0.38; text:scrollRoot.txDescs[scrollRoot.txStep]; color:Qt.rgba(255,255,255,0.75);font.family:"Segoe UI";font.pixelSize:11;wrapMode:Text.WordWrap;lineHeight:1.55 }
                    Rectangle { width:parent.width*0.62-14;height:txCode.implicitHeight+32;color:Qt.rgba(0,0,0,0.3);radius:10;border.color:Qt.rgba(255,255,255,0.06);border.width:1
                        Rectangle{width:parent.width;height:22;color:Qt.rgba(255,255,255,0.04);radius:10;Rectangle{width:parent.width;height:11;anchors.bottom:parent.bottom;color:parent.color}Row{anchors.left:parent.left;anchors.leftMargin:8;anchors.verticalCenter:parent.verticalCenter;spacing:4;Repeater{model:3;delegate:Rectangle{width:7;height:7;radius:3.5;color:["#f43f5e","#fbbf24","#10b981"][index];opacity:0.7}}}Text{text:"kernel/log.c";color:Qt.rgba(255,255,255,0.18);font.pixelSize:9;font.family:"Consolas";anchors.centerIn:parent}}
                        Text{id:txCode;anchors.top:parent.top;anchors.topMargin:28;anchors.left:parent.left;anchors.leftMargin:12;anchors.right:parent.right;anchors.rightMargin:12;text:scrollRoot.txCodes[scrollRoot.txStep];color:Qt.rgba(255,255,255,0.82);font.family:"Consolas";font.pixelSize:10;wrapMode:Text.WrapAtWordBoundaryOrAnywhere;lineHeight:1.5}
                    }
                }

                Row{spacing:10
                    Rectangle{width:90;height:32;radius:9;color:scrollRoot.txStep>0?Qt.rgba(249,115,22,0.15):Qt.rgba(255,255,255,0.03);border.color:scrollRoot.txStep>0?"#f97316":Qt.rgba(255,255,255,0.1);border.width:1;Text{anchors.centerIn:parent;text:"← PREV";color:scrollRoot.txStep>0?"#f97316":Qt.rgba(255,255,255,0.2);font.bold:true;font.pixelSize:11}MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:if(scrollRoot.txStep>0)scrollRoot.txStep--}}
                    Rectangle{width:90;height:32;radius:9;color:scrollRoot.txStep<6?Qt.rgba(249,115,22,0.15):Qt.rgba(255,255,255,0.03);border.color:scrollRoot.txStep<6?"#f97316":Qt.rgba(255,255,255,0.1);border.width:1;Text{anchors.centerIn:parent;text:"NEXT →";color:scrollRoot.txStep<6?"#f97316":Qt.rgba(255,255,255,0.2);font.bold:true;font.pixelSize:11}MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:if(scrollRoot.txStep<6)scrollRoot.txStep++}}
                    Text{anchors.verticalCenter:parent.verticalCenter;text:"Step "+(scrollRoot.txStep+1)+" of 7";color:Qt.rgba(255,255,255,0.2);font.pixelSize:11}
                }
            }
        }

        // ── ACCORDION — deeper topics ─────────────────────────────────────
        Rectangle {
            width: parent.width; height: logAccord.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.015); radius: 14
            border.color: Qt.rgba(255,255,255,0.07); border.width: 1

            Column {
                id: logAccord
                anchors.top:parent.top;anchors.topMargin:18;anchors.left:parent.left;anchors.leftMargin:18;anchors.right:parent.right;anchors.rightMargin:18
                spacing:6
                Text{text:"DEEP DIVE — five logging topics";color:Qt.rgba(249,115,22,0.6);font.bold:true;font.pixelSize:11;font.letterSpacing:0.4}
                Repeater {
                    model:5
                    delegate: Rectangle {
                        property bool isOpen: scrollRoot.openCard===index
                        width:parent.width; height:isOpen?logBody.implicitHeight+84:52; clip:true; radius:10
                        color:isOpen?Qt.rgba(scrollRoot.cardR2[index]/255,scrollRoot.cardG2[index]/255,scrollRoot.cardB2[index]/255,0.07):Qt.rgba(255,255,255,0.02)
                        border.color:isOpen?scrollRoot.cardColors2[index]:Qt.rgba(scrollRoot.cardR2[index]/255,scrollRoot.cardG2[index]/255,scrollRoot.cardB2[index]/255,0.22); border.width:isOpen?1.5:1
                        Behavior on height{NumberAnimation{duration:270;easing.type:Easing.OutCubic}} Behavior on color{ColorAnimation{duration:160}}
                        Row{anchors.left:parent.left;anchors.leftMargin:14;anchors.right:lChev.left;anchors.rightMargin:8;anchors.top:parent.top;height:52;spacing:10
                            Rectangle{width:6;height:6;radius:3;color:scrollRoot.cardColors2[index];anchors.verticalCenter:parent.verticalCenter}
                            Column{anchors.verticalCenter:parent.verticalCenter;spacing:3
                                Text{text:scrollRoot.cardTitles[index];color:isOpen?scrollRoot.cardColors2[index]:"#ffffff";font.bold:true;font.pixelSize:12;font.letterSpacing:0.2;Behavior on color{ColorAnimation{duration:160}}}
                                Text{text:scrollRoot.cardSubs[index];color:Qt.rgba(255,255,255,0.3);font.pixelSize:9}
                            }
                        }
                        Text{id:lChev;text:isOpen?"▲":"▼";color:Qt.rgba(255,255,255,0.3);font.pixelSize:10;anchors.right:parent.right;anchors.rightMargin:14;anchors.top:parent.top;anchors.topMargin:21}
                        Row{id:logBody;anchors.top:parent.top;anchors.topMargin:58;anchors.left:parent.left;anchors.leftMargin:14;anchors.right:parent.right;anchors.rightMargin:14;spacing:12
                            Column{width:(parent.width-12)*0.40;spacing:10;Text{text:scrollRoot.cardSrc2[index];color:scrollRoot.cardColors2[index];font.family:"Consolas";font.pixelSize:10;font.bold:true}Rectangle{width:parent.width;height:1;color:Qt.rgba(255,255,255,0.06)}Text{width:parent.width;text:scrollRoot.cardTh2[index];color:Qt.rgba(255,255,255,0.78);wrapMode:Text.WordWrap;font.family:"Segoe UI";font.pixelSize:11;lineHeight:1.55}}
                            Rectangle{width:(parent.width-12)*0.60;height:logCode.implicitHeight+32;color:Qt.rgba(0,0,0,0.28);radius:9;border.color:Qt.rgba(255,255,255,0.06);border.width:1
                                Rectangle{width:parent.width;height:22;color:Qt.rgba(255,255,255,0.04);radius:9;Rectangle{width:parent.width;height:11;anchors.bottom:parent.bottom;color:parent.color}Row{anchors.left:parent.left;anchors.leftMargin:8;anchors.verticalCenter:parent.verticalCenter;spacing:4;Repeater{model:3;delegate:Rectangle{width:7;height:7;radius:3.5;color:["#f43f5e","#fbbf24","#10b981"][index];opacity:0.7}}}Text{text:scrollRoot.cardSrc2[index];color:Qt.rgba(255,255,255,0.22);font.pixelSize:9;font.family:"Consolas";anchors.centerIn:parent}}
                                Text{id:logCode;anchors.top:parent.top;anchors.topMargin:28;anchors.left:parent.left;anchors.leftMargin:10;anchors.right:parent.right;anchors.rightMargin:10;text:scrollRoot.cardCode2[index];color:Qt.rgba(255,255,255,0.82);font.family:"Consolas";font.pixelSize:10;wrapMode:Text.WrapAtWordBoundaryOrAnywhere;lineHeight:1.5}
                            }
                        }
                        MouseArea{anchors.left:parent.left;anchors.right:parent.right;anchors.top:parent.top;height:52;cursorShape:Qt.PointingHandCursor;onClicked:scrollRoot.openCard=isOpen?-1:index}
                    }
                }
            }
        }

        // ── FOOTER ──────────────────────────────────────────────────────

        // ── CRASH RECOVERY SIMULATOR ────────────────────────────────────
        Rectangle {
            id: logSim
            width:parent.width; height:crashCol.implicitHeight+32
            color:Qt.rgba(255,255,255,0.015); radius:14
            border.color:Qt.rgba(249,115,22,0.2); border.width:1

            property int crashPoint: -1   // -1=no crash, 0=before write_head, 1=after write_head
            property bool recovered: false

            // Transaction steps visual
            property var txSteps: [
                {label:"begin_op()",    desc:"Transaction starts. log.outstanding++.", done:true,  isCommit:false},
                {label:"log_write(b)",  desc:"Modified buffers added to log list (not disk yet).", done:true,  isCommit:false},
                {label:"end_op()",      desc:"outstanding--. If 0, triggers commit.", done:true,  isCommit:false},
                {label:"write_log()",   desc:"Copies data buffers → log area on disk.", done:true,  isCommit:false},
                {label:"write_head()",  desc:"⬅ COMMIT POINT: writes log header to disk. Atomic sector write.", done:false, isCommit:true},
                {label:"install_trans()",desc:"Copies log blocks → real disk locations.", done:false, isCommit:false},
                {label:"clear header",  desc:"Sets log.n=0, writes header. Transaction complete.", done:false, isCommit:false}
            ]


            Column {
                id:crashCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing:14

                Row { spacing:10
                    Text { text:"💥"; font.pixelSize:18; anchors.verticalCenter:parent.verticalCenter }
                    Column { spacing:2
                        Text { text:"CRASH RECOVERY SIMULATOR — what does xv6 do on the next boot?"; color:"#f97316"; font.bold:true; font.pixelSize:13 }
                        Text { text:"write_head() is the atomic commit point. Crash before it = rollback. Crash after = replay."; color:Qt.rgba(255,255,255,0.32); font.pixelSize:11 }
                    }
                }
                Row { spacing:6; width:parent.width
                    Repeater {
                        model: logSim.txSteps
                        delegate: Rectangle {
                            property bool isDone: logSim.crashPoint === -1 ? modelData.done : (logSim.crashPoint===0 ? modelData.done && !modelData.isCommit && index < 4 : true)
                            width:(parent.width-36)/7; height:56; radius:8
                            color:modelData.isCommit?Qt.rgba(249/255,115/255,22/255,0.2):isDone?Qt.rgba(16/255,185/255,129/255,0.15):Qt.rgba(255,255,255,0.04)
                            border.color:modelData.isCommit?"#f97316":isDone?"#10b981":Qt.rgba(255,255,255,0.1); border.width:modelData.isCommit?2:1
                            Column { anchors.centerIn:parent; spacing:3
                                Text { text:modelData.label; color:modelData.isCommit?"#f97316":isDone?"#10b981":Qt.rgba(255,255,255,0.4); font.pixelSize:8; font.bold:true; font.family:"Consolas"; anchors.horizontalCenter:parent; horizontalAlignment:Text.AlignHCenter; wrapMode:Text.WordWrap; width:parent.parent.width-8 }
                                Text { text:isDone?"✓":"○"; color:isDone?(modelData.isCommit?"#f97316":"#10b981"):Qt.rgba(255,255,255,0.2); font.pixelSize:14; font.bold:true; anchors.horizontalCenter:parent }
                            }
                        }
                    }
                }

                // Crash buttons
                Row { spacing:10; width:parent.width
                    Rectangle {
                        height:36; width:crashBtn1.implicitWidth+24; radius:9
                        color:logSim.crashPoint===0?Qt.rgba(244/255,63/255,94/255,0.25):Qt.rgba(244/255,63/255,94/255,0.12)
                        border.color:"#f43f5e"; border.width:logSim.crashPoint===0?2:1
                        Text { id:crashBtn1; anchors.centerIn:parent; text:"💥 CRASH before write_head()"; color:"#f43f5e"; font.bold:true; font.pixelSize:11 }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:{ logSim.crashPoint=0; logSim.recovered=false } }
                    }
                    Rectangle {
                        height:36; width:crashBtn2.implicitWidth+24; radius:9
                        color:logSim.crashPoint===1?Qt.rgba(249/255,115/255,22/255,0.25):Qt.rgba(249/255,115/255,22/255,0.12)
                        border.color:"#f97316"; border.width:logSim.crashPoint===1?2:1
                        Text { id:crashBtn2; anchors.centerIn:parent; text:"💥 CRASH after write_head()"; color:"#f97316"; font.bold:true; font.pixelSize:11 }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:{ logSim.crashPoint=1; logSim.recovered=false } }
                    }
                    Rectangle {
                        height:36; width:bootBtn.implicitWidth+24; radius:9
                        color:Qt.rgba(16/255,185/255,129/255,0.15); border.color:"#10b981"; border.width:1
                        Text { id:bootBtn; anchors.centerIn:parent; text:"🔄 BOOT (run initlog)"; color:"#10b981"; font.bold:true; font.pixelSize:11 }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:logSim.recovered=true }
                    }
                    Rectangle {
                        height:36; width:72; radius:9
                        color:Qt.rgba(255,255,255,0.05); border.color:Qt.rgba(255,255,255,0.1); border.width:1
                        Text { anchors.centerIn:parent; text:"↺ RESET"; color:Qt.rgba(255,255,255,0.4); font.bold:true; font.pixelSize:11 }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:{ logSim.crashPoint=-1; logSim.recovered=false } }
                    }
                }

                // Result panel
                Rectangle {
                    width:parent.width; height:recovText.implicitHeight+24; radius:10
                    color: {
                        if(parent.crashPoint===-1) return Qt.rgba(255,255,255,0.02)
                        if(!parent.recovered) return Qt.rgba(244/255,63/255,94/255,0.08)
                        return parent.crashPoint===0?Qt.rgba(16/255,185/255,129/255,0.08):Qt.rgba(249/255,115/255,22/255,0.08)
                    }
                    border.color: {
                        if(parent.crashPoint===-1) return Qt.rgba(255,255,255,0.06)
                        if(!parent.recovered) return Qt.rgba(244,63,94,0.3)
                        return parent.crashPoint===0?"#10b981":"#f97316"
                    }
                    border.width:1
                    Text {
                        id:recovText
                        anchors.left:parent.left; anchors.leftMargin:16
                        anchors.right:parent.right; anchors.rightMargin:16
                        anchors.verticalCenter:parent.verticalCenter
                        text: {
                            var cp = logSim.crashPoint
                            var rec = logSim.recovered
                            if(cp===-1) return "Select a crash point above, then press BOOT to see what xv6 does on recovery."
                            if(cp===0 && !rec) return "💥 CRASHED before write_head(). Log header was never written (n=0). System is in an unknown state."
                            if(cp===0 && rec) return "✓ SAFE ROLLBACK: initlog() reads log header. n=0 (write_head never wrote). No replay needed. Disk is in the state BEFORE the transaction — as if it never happened. Data is consistent."
                            if(cp===1 && !rec) return "💥 CRASHED after write_head(). Log header on disk has n>0. install_trans() was not completed."
                            if(cp===1 && rec) return "✓ REPLAYED: initlog() reads header, finds n>0 — committed transaction. Calls install_trans() to copy log→real disk. Then clears header (n=0). Disk is now FULLY updated. Idempotent: safe to replay multiple times."
                            return ""
                        }
                        color: {
                            var cp = logSim.crashPoint; var rec = logSim.recovered
                            if(cp===-1) return Qt.rgba(255,255,255,0.28)
                            if(!rec) return "#f43f5e"
                            return cp===0?"#10b981":"#fbbf24"
                        }
                        wrapMode:Text.WordWrap; font.pixelSize:12; lineHeight:1.6; font.bold:logSim.recovered
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
                Text{text:"🌟";font.pixelSize:22;Layout.alignment:Qt.AlignVCenter}
                Text{Layout.fillWidth:true;Layout.alignment:Qt.AlignVCenter;text:"CORE SUMMARY: Write-ahead logging: begin_op→log_write→end_op→commit(write_log+write_head+install_trans+clear). write_head() is THE commit point — single atomic sector write. Crash before write_head: transaction rolled back. Crash after: replayed on recovery. log_write() only records block numbers (absorption deduplicates). install_trans() copies log→real disk. Recovery: read header, if n>0 replay, then clear.";color:"#ffffff";wrapMode:Text.WordWrap;font.family:"Segoe UI";font.bold:true;font.pixelSize:12;font.letterSpacing:0.2}
            }
        }
    }
}
