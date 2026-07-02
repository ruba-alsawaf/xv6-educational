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

    property int  openCard:   0
    property int  pathStep:   0
    property int  blockNum:   0
    property int  selType:    0   // 0=T_FILE,1=T_DIR,2=T_DEVICE

    // block map type: 0=direct, 1=single-indirect, 2=double-indirect (xv6 has none but we show concept)
    property bool isDirect:    blockNum < 12
    property bool isSingleInd: blockNum >= 12 && blockNum < 268

    property var pathSteps: [
        "/usr/bin/ls",
        "namei(\"/usr/bin/ls\")\n→ calls namex(path, 0, name)",
        "namex: begin at root inode (inum=1)\nname = nextelem(path) → \"usr\"",
        "dirlookup(root, \"usr\", &off)\n→ scan dir entries → found inum=7\nilock(inum=7) → inode for /usr",
        "nextelem → \"bin\"\ndirlookup(inode#7, \"bin\", &off)\n→ found inum=18\nilock(inum=18) → inode for /usr/bin",
        "nextelem → \"ls\" (last component)\nnameiparent=0 → look up \"ls\" in /usr/bin\ndirlookup(inode#18, \"ls\", &off)\n→ found inum=34",
        "ilock(inum=34)\nreturn inode for /usr/bin/ls\n→ type=T_FILE, nlink=1, size=8192"
    ]
    property var pathColors: ["#10b981","#34d399","#6ee7b7","#a7f3d0","#10b981","#34d399","#6ee7b7"]

    property var cardTitles: ["struct dinode & struct inode — on-disk vs in-memory","iget() — reference counting & inode cache","ilock() / iunlock() — sleeplock for content access","iput() — decrement refcnt, free if nlink==0 && refcnt==0","itrunc() — free all data blocks, set size=0","stati() / readi() / writei() — I/O through inode"]
    property var cardSubs: ["32 inode blocks on disk; icache.inode[] in memory (NINODE=50)","iget finds/allocates cache slot; does NOT lock or read disk","sleeplock prevents concurrent block reads/writes","careful ordering: sleeplock released before nlink==0 free","walks direct + indirect table, calls bfree for each","stat() fills struct stat; readi/writei use bmap() to resolve blocks"]
    property var cardColors: ["#10b981","#34d399","#06b6d4","#f97316","#f43f5e","#8b5cf6"]
    property var cardR: [16,52,6,249,244,139]; property var cardG: [185,211,182,115,63,91]; property var cardB: [129,177,212,22,94,246]
    property var cardSrc: ["kernel/fs.h","kernel/fs.c","kernel/fs.c","kernel/fs.c","kernel/fs.c","kernel/fs.c"]
    property var cardTh: [
        "On-disk inode (struct dinode, 64 bytes, in mkfs-generated inode blocks): type(short), major/minor(short), nlink(short), size(uint), addrs[NDIRECT+1](uint). struct inode is the in-memory copy: adds dev, inum, ref (cache ref count), valid (whether disk copy loaded), and a sleeplock. NDIRECT=12 direct block addresses. addrs[NDIRECT] = single indirect block pointer → points to a disk block containing 256 block numbers (BSIZE/4). Max file size = 12 + 256 = 268 blocks = 268*1024 = 274432 bytes. xv6 does NOT implement double-indirect blocks. struct dirent = { ushort inum; char name[DIRSIZ] } (16 bytes). A directory is a file whose blocks contain dirent arrays.",
        "iget(dev, inum) scans icache.inode[] for a matching (dev,inum) entry. If found and ref>0: increment ref, return it (cache hit). Otherwise: find an empty slot (ref==0). Fill in dev, inum, ref=1, valid=0 (NOT yet loaded from disk — that happens in ilock). iget holds icache.lock only long enough to update the table; it does NOT sleeplock. Multiple iget() calls for the same inum return the same inode pointer (same cache slot). The inode stays cached as long as ref>0. idup() just increments ref and returns the pointer (used when passing an inode to another part of the kernel).",
        "ilock(ip) acquires ip->lock (sleeplock). Once held: if ip->valid==0, reads the disk inode (bread, bp=bread(ip->dev, IBLOCK(ip->inum,sb)), copy dinode fields into ip, brelse(bp)), sets ip->valid=1. Why separate iget/ilock? It allows passing inode pointers without holding the sleeplock, and allows multiple processes to look up the same inode concurrently. iunlock(ip) releases ip->lock. ilock is the only place that reads the disk inode — after it returns, type/size/addrs are guaranteed valid. Code must not dereference ip->type or ip->addrs without holding ip->lock.",
        "iput(ip) decrements ip->ref. If ref reaches 0 AND ip->nlink==0: the file has no directory entries pointing to it AND no open file descriptors. Must free the inode: ilock(ip) (need lock to check/modify), call itrunc(ip) (free data blocks), ip->type=0, iupdate(ip) (write back to disk), iunlock(ip). Then release icache.lock. The subtlety: nlink==0 is set by unlink(); ref reaches 0 when the last fd is closed. Together they mean: delete file content when last fd closed after unlink. Race condition carefully avoided: ip->ref is checked while holding icache.lock.",
        "itrunc(ip) frees all data blocks assigned to the inode. For each of the NDIRECT direct blocks (addrs[0..11]): if non-zero, calls bfree(ip->dev, addrs[i]), zeros addrs[i]. Then for the indirect block (addrs[NDIRECT]): if non-zero, reads the indirect block (bp=bread), iterates 256 entries, bfree each non-zero block number, brelse the indirect block, bfree the indirect block itself, zeros addrs[NDIRECT]. Finally: sets ip->size=0, calls iupdate(ip) to persist. itrunc is called from iput (delete) and truncate system call. It does NOT release the inode itself — just frees its data blocks.",
        "stati(ip, st) fills struct stat { int dev; uint ino; short type; short nlink; uint64 size }. readi(ip, dst, off, n): reads n bytes from offset off into dst. Uses bmap() to find each block, bread it, copy bytes, brelse. Handles crossing block boundaries in a loop. writei(ip, src, off, n): symmetric — bmap(ip, bn, 1) allocates block if needed (balloc), then write. bmap(ip, bn, alloc): if bn<NDIRECT return addrs[bn] (alloc if needed). Else: bn-=NDIRECT, look in indirect table: read/alloc indirect block, return addrs[bn] (alloc if needed). After writei: if off+n > ip->size, update ip->size, iupdate(ip)."
    ]
    property var cardCode: [
        "// kernel/fs.h\n#define NDIRECT 12\n#define NINDIRECT (BSIZE / sizeof(uint)) // 256\n#define MAXFILE (NDIRECT + NINDIRECT)    // 268\nstruct dinode {\n    short type;        // T_FILE=1, T_DIR=2, T_DEVICE=3\n    short major;       // device major (T_DEVICE only)\n    short minor;       // device minor\n    short nlink;       // # directory entries pointing here\n    uint  size;        // file size in bytes\n    uint  addrs[NDIRECT+1]; // [0..11]=direct, [12]=indirect ptr\n};\nstruct inode {       // in-memory copy\n    uint dev; uint inum;\n    int ref;           // reference count (# pointers held)\n    struct sleeplock lock; // protects fields below:\n    int valid;         // 0=not yet loaded from disk\n    // == copy of dinode fields ==\n    short type; short major; short minor;\n    short nlink; uint size;\n    uint addrs[NDIRECT+1];\n};",
        "// kernel/fs.c\nstruct inode* iget(uint dev, uint inum) {\n    struct inode *ip, *empty = 0;\n    acquire(&icache.lock);\n    for(ip=&icache.inode[0]; ip<&icache.inode[NINODE]; ip++){\n        if(ip->ref > 0 && ip->dev==dev && ip->inum==inum){\n            ip->ref++;        // cache hit\n            release(&icache.lock);\n            return ip;\n        }\n        if(empty==0 && ip->ref==0)\n            empty = ip;       // remember free slot\n    }\n    // cache miss: use empty slot\n    ip = empty;\n    ip->dev=dev; ip->inum=inum;\n    ip->ref=1; ip->valid=0;   // NOT yet read from disk\n    release(&icache.lock);\n    return ip;  // caller must call ilock() to read disk\n}",
        "// kernel/fs.c\nvoid ilock(struct inode *ip) {\n    struct buf *bp;\n    struct dinode *dip;\n    acquiresleep(&ip->lock);  // may sleep waiting\n    if(ip->valid == 0) {      // first lock: load from disk\n        bp = bread(ip->dev, IBLOCK(ip->inum, sb));\n        dip = (struct dinode*)bp->data\n              + ip->inum % IPB;\n        ip->type  = dip->type;\n        ip->major = dip->major;\n        ip->minor = dip->minor;\n        ip->nlink = dip->nlink;\n        ip->size  = dip->size;\n        memmove(ip->addrs, dip->addrs,\n                sizeof(ip->addrs));\n        brelse(bp);\n        ip->valid = 1;\n        if(ip->type == 0) panic(\"ilock: no type\");\n    }\n    // ip->type, size, addrs now valid and protected\n}\nvoid iunlock(struct inode *ip) {\n    releasesleep(&ip->lock);\n}",
        "// kernel/fs.c\nvoid iput(struct inode *ip) {\n    acquire(&icache.lock);\n    if(ip->ref==1 && ip->valid && ip->nlink==0){\n        // Last reference and no directory links\n        // → truncate and free inode\n        release(&icache.lock);\n        ilock(ip);\n        itrunc(ip);      // free all data blocks\n        ip->type = 0;    // mark free on disk\n        iupdate(ip);     // write back to disk\n        iunlock(ip);\n        acquire(&icache.lock);\n        ip->valid = 0;   // invalidate cache entry\n    }\n    ip->ref--;\n    release(&icache.lock);\n}\n// Pattern used everywhere:\n// iget → ilock → (use) → iunlock → iput",
        "// kernel/fs.c\nstatic void itrunc(struct inode *ip) {\n    int i, j;\n    struct buf *bp;\n    uint *a;\n    for(i=0; i<NDIRECT; i++){\n        if(ip->addrs[i]){\n            bfree(ip->dev, ip->addrs[i]);\n            ip->addrs[i] = 0;\n        }\n    }\n    if(ip->addrs[NDIRECT]){\n        bp = bread(ip->dev, ip->addrs[NDIRECT]);\n        a = (uint*)bp->data;\n        for(j=0; j<NINDIRECT; j++)\n            if(a[j]) bfree(ip->dev, a[j]);\n        brelse(bp);\n        bfree(ip->dev, ip->addrs[NDIRECT]);\n        ip->addrs[NDIRECT] = 0;\n    }\n    ip->size = 0;\n    iupdate(ip);  // persist to disk\n}",
        "// kernel/fs.c — bmap() resolves logical → physical block\nstatic uint bmap(struct inode *ip, uint bn, int alloc){\n    uint addr, *a;\n    struct buf *bp;\n    if(bn < NDIRECT) {         // direct block\n        if((addr=ip->addrs[bn])==0 && alloc)\n            ip->addrs[bn]=addr=balloc(ip->dev);\n        return addr;\n    }\n    bn -= NDIRECT;             // adjust for indirect\n    if(bn < NINDIRECT) {       // single-indirect\n        if((addr=ip->addrs[NDIRECT])==0 && alloc)\n            ip->addrs[NDIRECT]=addr=balloc(ip->dev);\n        bp = bread(ip->dev, addr);\n        a = (uint*)bp->data;\n        if((addr=a[bn])==0 && alloc)\n            a[bn]=addr=balloc(ip->dev), log_write(bp);\n        brelse(bp);\n        return addr;\n    }\n    panic(\"bmap: out of range\"); // no double-indirect\n}"
    ]

    Column {
        id: mainColumn
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        spacing: 25

        // ── HEADER ─────────────────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 95
            color: Qt.rgba(255,255,255,0.03); radius: 14
            border.color: Qt.rgba(16,185,129,0.25); border.width: 1
            layer.enabled: true
            layer.effect: Glow { radius:10; samples:17; color:Qt.rgba(16,185,129,0.12); spread:0.1 }
            Row {
                anchors.fill: parent; anchors.margins: 15; spacing: 16
                Rectangle {
                    width: 52; height: 52; radius: 12; anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(16,185,129,0.15); border.color: Qt.rgba(16,185,129,0.4); border.width: 1
                    Column { anchors.centerIn: parent; spacing: 1
                        Text { text:"15"; color:"#10b981"; font.bold:true; font.pixelSize:20; font.family:"Consolas"; anchors.horizontalCenter:parent }
                        Text { text:"LESSON"; color:Qt.rgba(16,185,129,0.5); font.pixelSize:7; font.letterSpacing:1; anchors.horizontalCenter:parent }
                    }
                }
                Column { anchors.verticalCenter: parent.verticalCenter; spacing: 6
                    Text { text:"INODES, DIRECTORIES & PATH TRAVERSAL — The Heart of the xv6 FS (fs.c)"; color:"#ffffff"; font.family:"Segoe UI"; font.bold:true; font.pixelSize:20; font.letterSpacing:0.5 }
                    Text { text:"struct dinode on disk · iget/ilock/iput lifecycle · bmap direct+indirect · dirlookup/dirlink · namei/namex path resolution"; color:Qt.rgba(255,255,255,0.55); font.family:"Segoe UI"; font.pixelSize:12 }
                }
            }
        }

        // ── BLOCK ADDRESS RESOLVER + INODE STRUCTURE ──────────────────────
        Row {
            width: parent.width; spacing: 16

            // Block resolver
            Rectangle {
                width: parent.width * 0.44; height: blockResolverCol.implicitHeight + 36
                color: Qt.rgba(255,255,255,0.02); radius: 14
                border.color: Qt.rgba(16,185,129,0.2); border.width: 1

                Column {
                    id: blockResolverCol
                    anchors.top:parent.top; anchors.topMargin:18; anchors.left:parent.left; anchors.leftMargin:18; anchors.right:parent.right; anchors.rightMargin:18
                    spacing:14

                    Row{spacing:8;Text{text:"🗂";font.pixelSize:16;anchors.verticalCenter:parent.verticalCenter}Text{text:"BLOCK ADDRESS RESOLVER — bmap()";color:"#10b981";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3;anchors.verticalCenter:parent.verticalCenter}}
                    Text{text:"Logical block # → physical disk block (via addrs[] and indirect table)";color:Qt.rgba(255,255,255,0.4);font.pixelSize:11}

                    Row{spacing:12;anchors.horizontalCenter:parent.horizontalCenter
                        Text{text:"Block #";color:Qt.rgba(255,255,255,0.5);font.pixelSize:12;anchors.verticalCenter:parent.verticalCenter}
                        Rectangle{width:90;height:36;radius:9;color:Qt.rgba(16,185,129,0.08);border.color:Qt.rgba(16,185,129,0.3);border.width:1
                            TextInput{anchors.centerIn:parent;text:scrollRoot.blockNum.toString();color:"#10b981";font.bold:true;font.pixelSize:16;font.family:"Consolas";inputMethodHints:Qt.ImhDigitsOnly;onAccepted:{var v=parseInt(text);if(!isNaN(v)&&v>=0&&v<268)scrollRoot.blockNum=v;else scrollRoot.blockNum=0;}}
                        }
                        Row{spacing:6
                            Repeater{model:["0","5","11","12","50","267"];delegate:Rectangle{width:36;height:28;radius:7;color:Qt.rgba(16,185,129,0.08);border.color:Qt.rgba(16,185,129,0.25);border.width:1;Text{anchors.centerIn:parent;text:modelData;color:"#10b981";font.pixelSize:11;font.family:"Consolas"}MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:scrollRoot.blockNum=parseInt(modelData)}}}
                        }
                    }

                    // Visual addrs[] strip
                    Column{spacing:6;anchors.horizontalCenter:parent.horizontalCenter;width:parent.width
                        Text{text:"addrs[] — 13 slots in struct inode";color:Qt.rgba(255,255,255,0.35);font.pixelSize:10;font.family:"Consolas"}
                        Row{spacing:3
                            Repeater{model:13;delegate:Rectangle{
                                property bool isTarget: index===Math.min(scrollRoot.blockNum,12)&&(index<12?scrollRoot.blockNum===index:true)
                                property bool isDirect2: index<12
                                width:30;height:30;radius:6
                                color:isTarget?Qt.rgba(16,185,129,0.35):(isDirect2?Qt.rgba(16,185,129,0.06):Qt.rgba(139,92,246,0.15))
                                border.color:isTarget?"#10b981":(isDirect2?Qt.rgba(16,185,129,0.25):Qt.rgba(139,92,246,0.4));border.width:isTarget?2:1
                                Text{anchors.centerIn:parent;text:index<12?index.toString():"IN";color:isDirect2?(isTarget?"#10b981":Qt.rgba(255,255,255,0.4)):Qt.rgba(139,92,246,0.8);font.pixelSize:8;font.family:"Consolas";font.bold:isTarget}
                            }}
                        }
                    }

                    // Result card
                    Rectangle{
                        width:parent.width;height:resultCol.implicitHeight+28
                        color:scrollRoot.isDirect?Qt.rgba(16,185,129,0.08):Qt.rgba(139,92,246,0.08)
                        radius:10; border.color:scrollRoot.isDirect?"#10b981":"#8b5cf6"; border.width:1
                        Column{id:resultCol;anchors.top:parent.top;anchors.topMargin:14;anchors.left:parent.left;anchors.leftMargin:14;anchors.right:parent.right;anchors.rightMargin:14;spacing:6
                            Text{text:scrollRoot.isDirect?"✅ DIRECT BLOCK":"⇢ SINGLE INDIRECT";color:scrollRoot.isDirect?"#10b981":"#8b5cf6";font.bold:true;font.pixelSize:13}
                            Text{text:scrollRoot.isDirect?"bmap() returns addrs["+scrollRoot.blockNum+"] directly.\nNo extra disk read needed — O(1) lookup.\nCovers logical blocks 0–11 (first 12 KB of file).\n":"bmap() reads addrs[12] → indirect block\n(1 disk block = 256 uint entries).\nEntry index = "+scrollRoot.blockNum+"-12 = "+(scrollRoot.blockNum-12)+".\nTotal: 12+256=268 blocks max (274,432 bytes).";color:Qt.rgba(255,255,255,0.75);font.pixelSize:11;font.family:"Segoe UI";wrapMode:Text.WordWrap;lineHeight:1.5}
                        }
                    }
                }
            }

            // Inode type explorer + dinode layout
            Rectangle {
                width: parent.width - parent.width * 0.44 - 16; height: blockResolverCol.implicitHeight + 36
                color: Qt.rgba(255,255,255,0.02); radius: 14
                border.color: Qt.rgba(16,185,129,0.2); border.width: 1

                Column {
                    anchors.top:parent.top; anchors.topMargin:18; anchors.left:parent.left; anchors.leftMargin:18; anchors.right:parent.right; anchors.rightMargin:18
                    spacing:14

                    Row{spacing:8;Text{text:"📁";font.pixelSize:16;anchors.verticalCenter:parent.verticalCenter}Text{text:"INODE LAYOUT — struct dinode (64 bytes on disk)";color:"#10b981";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3;anchors.verticalCenter:parent.verticalCenter}}

                    // dinode fields
                    Column{spacing:4;width:parent.width
                        Repeater{model:[["type","short (2B)","T_FILE=1 T_DIR=2 T_DEVICE=3","#f97316"],["major","short (2B)","Device major number (T_DEVICE only)","#fbbf24"],["minor","short (2B)","Device minor number","#fbbf24"],["nlink","short (2B)","# dir entries pointing to this inode","#06b6d4"],["size","uint (4B)","File size in bytes","#10b981"],["addrs[0..11]","uint×12 (48B)","Direct block addresses (blocks 0–11)","#10b981"],["addrs[12]","uint (4B)","Pointer to single-indirect block","#8b5cf6"]]
                        delegate: Rectangle{width:parent.width;height:22;radius:5;color:Qt.rgba(255,255,255,index%2?0.03:0.01)
                            Row{anchors.fill:parent;anchors.leftMargin:8;anchors.rightMargin:8;spacing:8
                                Text{width:80;text:modelData[0];color:modelData[3];font.family:"Consolas";font.pixelSize:10;font.bold:true;anchors.verticalCenter:parent.verticalCenter}
                                Text{width:70;text:modelData[1];color:Qt.rgba(255,255,255,0.4);font.family:"Consolas";font.pixelSize:9;anchors.verticalCenter:parent.verticalCenter}
                                Text{width:parent.width-158;text:modelData[2];color:Qt.rgba(255,255,255,0.65);font.pixelSize:10;anchors.verticalCenter:parent.verticalCenter;elide:Text.ElideRight}
                            }
                        }}
                    }

                    // type selector
                    Column{spacing:8;width:parent.width
                        Text{text:"INODE TYPE — click to explore";color:Qt.rgba(255,255,255,0.35);font.pixelSize:10}
                        Row{spacing:8
                            Repeater{model:[["T_FILE (1)","Regular file — nlink tracks hard links, size=bytes","#10b981"],["T_DIR (2)","Directory — blocks contain struct dirent arrays","#06b6d4"],["T_DEVICE (3)","Device — reads/writes go to major/minor handler","#f97316"]]
                            delegate:Rectangle{
                                property bool sel: scrollRoot.selType===index
                                width:130;height:52;radius:9
                                color:sel?Qt.rgba(parseInt(modelData[2].slice(1,3),16)/255,parseInt(modelData[2].slice(3,5),16)/255,parseInt(modelData[2].slice(5,7),16)/255,0.15):Qt.rgba(255,255,255,0.03)
                                border.color:sel?modelData[2]:Qt.rgba(255,255,255,0.1); border.width:sel?1.5:1
                                Column{anchors.centerIn:parent;spacing:4;Text{text:modelData[0];color:sel?modelData[2]:"#fff";font.bold:true;font.pixelSize:10;anchors.horizontalCenter:parent}Text{width:parent.parent.width-16;text:modelData[1];color:Qt.rgba(255,255,255,0.4);font.pixelSize:8;wrapMode:Text.WordWrap;anchors.horizontalCenter:parent}}
                                MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:scrollRoot.selType=index}
                            }}
                        }
                        Text{
                            width:parent.width; wrapMode:Text.WordWrap; font.pixelSize:11; font.family:"Segoe UI"; lineHeight:1.5
                            color:Qt.rgba(255,255,255,0.7)
                            text:[
                                "Regular files (T_FILE): nlink counts hard links created with link(). Data stored in addrs[]. writei/readi use bmap() to resolve logical→physical blocks. Truncated on unlink when nlink reaches 0 and ref=0.",
                                "Directories (T_DIR): Data blocks contain struct dirent { ushort inum; char name[DIRSIZ] }. dirlookup() scans entries linearly for a name match. dirlink() finds a free entry (inum==0) and writes a new one. Root directory always has inum=1.",
                                "Device files (T_DEVICE): type=T_DEVICE. major/minor fields identify the driver. readi/writei dispatch to devsw[major].read/write instead of bmap(). Used for /console (major=CONSOLE=1)."
                            ][scrollRoot.selType]
                        }
                    }
                }
            }
        }

        // ── PATH TRAVERSAL STEPPER ─────────────────────────────────────────
        Rectangle {
            width: parent.width; height: pathCol.implicitHeight + 36
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(16,185,129,0.2); border.width: 1

            Column {
                id: pathCol
                anchors.top:parent.top; anchors.topMargin:18; anchors.left:parent.left; anchors.leftMargin:18; anchors.right:parent.right; anchors.rightMargin:18
                spacing:14

                Row{spacing:8;Text{text:"🔍";font.pixelSize:16;anchors.verticalCenter:parent.verticalCenter}Column{spacing:2;Text{text:"PATH TRAVERSAL — namei() / namex() step-by-step";color:"#10b981";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3}Text{text:"Resolving  /usr/bin/ls  to an inode number";color:Qt.rgba(255,255,255,0.35);font.pixelSize:11}}}

                // step progress
                Row{spacing:4
                    Repeater{model:7;delegate:Row{spacing:0
                        Rectangle{width:22;height:22;radius:11
                            color:scrollRoot.pathStep>=index?scrollRoot.pathColors[index]:Qt.rgba(255,255,255,0.05)
                            border.color:scrollRoot.pathColors[index];border.width:scrollRoot.pathStep>=index?0:1
                            Behavior on color{ColorAnimation{duration:180}}
                            Text{anchors.centerIn:parent;text:(index).toString();color:scrollRoot.pathStep>=index?"#fff":Qt.rgba(255,255,255,0.3);font.bold:true;font.pixelSize:8;font.family:"Consolas"}
                            MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:scrollRoot.pathStep=index}
                        }
                        Rectangle{visible:index<6;width:18;height:2;anchors.verticalCenter:parent.verticalCenter;color:scrollRoot.pathStep>index?scrollRoot.pathColors[index]:Qt.rgba(255,255,255,0.1);Behavior on color{ColorAnimation{duration:180}}}
                    }}
                }

                Rectangle{width:parent.width;height:pathText.implicitHeight+28;color:Qt.rgba(16,185,129,0.06);radius:10;border.color:Qt.rgba(16,185,129,0.2);border.width:1
                    Text{id:pathText;anchors.top:parent.top;anchors.topMargin:14;anchors.left:parent.left;anchors.leftMargin:14;anchors.right:parent.right;anchors.rightMargin:14;text:scrollRoot.pathSteps[scrollRoot.pathStep];color:Qt.rgba(255,255,255,0.85);font.family:"Consolas";font.pixelSize:11;wrapMode:Text.WordWrap;lineHeight:1.6}
                }

                Row{spacing:10
                    Rectangle{width:80;height:30;radius:8;color:scrollRoot.pathStep>0?Qt.rgba(16,185,129,0.15):Qt.rgba(255,255,255,0.03);border.color:scrollRoot.pathStep>0?"#10b981":Qt.rgba(255,255,255,0.1);border.width:1;Text{anchors.centerIn:parent;text:"← BACK";color:scrollRoot.pathStep>0?"#10b981":Qt.rgba(255,255,255,0.2);font.bold:true;font.pixelSize:10}MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:if(scrollRoot.pathStep>0)scrollRoot.pathStep--}}
                    Rectangle{width:80;height:30;radius:8;color:scrollRoot.pathStep<6?Qt.rgba(16,185,129,0.15):Qt.rgba(255,255,255,0.03);border.color:scrollRoot.pathStep<6?"#10b981":Qt.rgba(255,255,255,0.1);border.width:1;Text{anchors.centerIn:parent;text:"NEXT →";color:scrollRoot.pathStep<6?"#10b981":Qt.rgba(255,255,255,0.2);font.bold:true;font.pixelSize:10}MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:if(scrollRoot.pathStep<6)scrollRoot.pathStep++}}
                    Text{anchors.verticalCenter:parent.verticalCenter;text:"Step "+scrollRoot.pathStep+" / 6";color:Qt.rgba(255,255,255,0.2);font.pixelSize:10}
                }
            }
        }

        // ── ACCORDION — deep inode topics ─────────────────────────────────
        Rectangle {
            width: parent.width; height: inoAccord.implicitHeight + 36
            color: Qt.rgba(255,255,255,0.015); radius: 14
            border.color: Qt.rgba(255,255,255,0.07); border.width: 1

            Column {
                id: inoAccord
                anchors.top:parent.top; anchors.topMargin:18; anchors.left:parent.left; anchors.leftMargin:18; anchors.right:parent.right; anchors.rightMargin:18
                spacing:6
                Text{text:"INODE OPERATIONS — six function deep dives";color:Qt.rgba(16,185,129,0.6);font.bold:true;font.pixelSize:11;font.letterSpacing:0.4}
                Repeater {
                    model:6
                    delegate: Rectangle {
                        property bool isOpen: scrollRoot.openCard===index
                        width:parent.width; height:isOpen?inoBody.implicitHeight+84:52; clip:true; radius:10
                        color:isOpen?Qt.rgba(scrollRoot.cardR[index]/255,scrollRoot.cardG[index]/255,scrollRoot.cardB[index]/255,0.07):Qt.rgba(255,255,255,0.02)
                        border.color:isOpen?scrollRoot.cardColors[index]:Qt.rgba(scrollRoot.cardR[index]/255,scrollRoot.cardG[index]/255,scrollRoot.cardB[index]/255,0.22); border.width:isOpen?1.5:1
                        Behavior on height{NumberAnimation{duration:270;easing.type:Easing.OutCubic}} Behavior on color{ColorAnimation{duration:160}}
                        Row{anchors.left:parent.left;anchors.leftMargin:14;anchors.right:iChev.left;anchors.rightMargin:8;anchors.top:parent.top;height:52;spacing:10
                            Rectangle{width:6;height:6;radius:3;color:scrollRoot.cardColors[index];anchors.verticalCenter:parent.verticalCenter}
                            Column{anchors.verticalCenter:parent.verticalCenter;spacing:3
                                Text{text:scrollRoot.cardTitles[index];color:isOpen?scrollRoot.cardColors[index]:"#ffffff";font.bold:true;font.pixelSize:12;font.letterSpacing:0.2;Behavior on color{ColorAnimation{duration:160}}}
                                Text{text:scrollRoot.cardSubs[index];color:Qt.rgba(255,255,255,0.3);font.pixelSize:9}
                            }
                        }
                        Text{id:iChev;text:isOpen?"▲":"▼";color:Qt.rgba(255,255,255,0.3);font.pixelSize:10;anchors.right:parent.right;anchors.rightMargin:14;anchors.top:parent.top;anchors.topMargin:21}
                        Row{id:inoBody;anchors.top:parent.top;anchors.topMargin:58;anchors.left:parent.left;anchors.leftMargin:14;anchors.right:parent.right;anchors.rightMargin:14;spacing:12
                            Column{width:(parent.width-12)*0.38;spacing:10;Text{text:scrollRoot.cardSrc[index];color:scrollRoot.cardColors[index];font.family:"Consolas";font.pixelSize:10;font.bold:true}Rectangle{width:parent.width;height:1;color:Qt.rgba(255,255,255,0.06)}Text{width:parent.width;text:scrollRoot.cardTh[index];color:Qt.rgba(255,255,255,0.78);wrapMode:Text.WordWrap;font.family:"Segoe UI";font.pixelSize:11;lineHeight:1.55}}
                            Rectangle{width:(parent.width-12)*0.62;height:inoCode.implicitHeight+32;color:Qt.rgba(0,0,0,0.28);radius:9;border.color:Qt.rgba(255,255,255,0.06);border.width:1
                                Rectangle{width:parent.width;height:22;color:Qt.rgba(255,255,255,0.04);radius:9;Rectangle{width:parent.width;height:11;anchors.bottom:parent.bottom;color:parent.color}Row{anchors.left:parent.left;anchors.leftMargin:8;anchors.verticalCenter:parent.verticalCenter;spacing:4;Repeater{model:3;delegate:Rectangle{width:7;height:7;radius:3.5;color:["#f43f5e","#fbbf24","#10b981"][index];opacity:0.7}}}Text{text:scrollRoot.cardSrc[index];color:Qt.rgba(255,255,255,0.22);font.pixelSize:9;font.family:"Consolas";anchors.centerIn:parent}}
                                Text{id:inoCode;anchors.top:parent.top;anchors.topMargin:28;anchors.left:parent.left;anchors.leftMargin:10;anchors.right:parent.right;anchors.rightMargin:10;text:scrollRoot.cardCode[index];color:Qt.rgba(255,255,255,0.82);font.family:"Consolas";font.pixelSize:10;wrapMode:Text.WrapAtWordBoundaryOrAnywhere;lineHeight:1.5}
                            }
                        }
                        MouseArea{anchors.left:parent.left;anchors.right:parent.right;anchors.top:parent.top;height:52;cursorShape:Qt.PointingHandCursor;onClicked:scrollRoot.openCard=isOpen?-1:index}
                    }
                }
            }
        }

        // ── FOOTER ──────────────────────────────────────────────────────────
        Rectangle {
            width:parent.width; height:66
            color:Qt.rgba(16/255,185/255,129/255,0.08); radius:14
            border.color:Qt.rgba(16/255,185/255,129/255,0.35); border.width:1
            RowLayout {
                anchors.fill:parent; anchors.margins:15; spacing:15
                Text{text:"🌟";font.pixelSize:22;Layout.alignment:Qt.AlignVCenter}
                Text{Layout.fillWidth:true;Layout.alignment:Qt.AlignVCenter;text:"CORE SUMMARY: Inode lifecycle: iget (ref++) → ilock (sleeplock + load disk) → use → iunlock → iput (ref--; if ref==0 && nlink==0 → truncate + free). bmap() resolves logical block# to physical: 0–11 direct (addrs[]), 12–267 single-indirect (addrs[12]→256-entry block). Directories = files of struct dirent[]. Path resolution: namex walks components left-to-right, calls dirlookup per segment, returns final inode.";color:"#ffffff";wrapMode:Text.WordWrap;font.family:"Segoe UI";font.bold:true;font.pixelSize:12;font.letterSpacing:0.2}
            }
        }
    }
}
