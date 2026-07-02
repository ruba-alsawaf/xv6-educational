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

    property int selectedLayer: 3
    property int hoveredLayer: -1
    property int openCard: 0
    property int selDisk: -1

    // ── 7 filesystem layers ───────────────────────────────────────────
    property var layerNames:  ["File Descriptor","Pathname","Directory","Inode","Logging","Buffer Cache","Disk"]
    property var layerFiles:  ["sysfile.c + file.c","fs.c namei()","fs.c dirlookup()","fs.c iget/ilock","log.c","bio.c","virtio_disk.c"]
    property var layerR: [236,249,16,59,251,6,244]
    property var layerG: [72,115,185,130,191,182,63]
    property var layerB: [153,22,129,246,36,212,94]
    property var layerColors: ["#ec4899","#f97316","#10b981","#3b82f6","#fbbf24","#06b6d4","#f43f5e"]
    property var layerDescs: [
        "The top layer — exposes Unix file descriptors (integers) to processes. System calls: open(), read(), write(), close(), dup(), pipe(). filealloc() finds a free slot in the global ftable[NFILE]. fdalloc() finds the lowest unused index in p->ofile[NOFILE]. struct file wraps pipe, inode, or device with ref count + seek offset. fork() shares open files via filedup() (ref++). This layer hides whether the fd refers to a pipe, device, or file — all look identical to the process.",
        "Resolves path strings like /usr/bin/sh to inodes using namei(). namex() walks path components: for each component, locks the current directory inode, calls dirlookup() to find the next inode, unlocks the current one. namei() handles absolute paths (start at root inode) and relative paths (start at p->cwd). The final component may or may not need to exist depending on the system call (O_CREATE vs open-existing). nameiparent() returns the parent directory inode — used by create(), unlink(), rename().",
        "Directories are just files whose content has a specific format: an array of struct dirent {inum: uint16; name: char[DIRSIZ=14]}. inum=0 means the slot is free. dirlookup(dp, name, poff) scans the directory's data blocks for a matching name, returns the inode. dirlink(dp, name, inum) finds a free dirent slot (inum==0) and writes the new entry. The root directory inode number is ROOTINO=1. Every directory has '.' (self) and '..' (parent) entries. xv6 directories are flat arrays — no hash table or B-tree, linear scan for lookup.",
        "Inodes are the core metadata objects for files and directories. On-disk: struct dinode {type, major, minor, nlink, size, addrs[NDIRECT+1]}. In-memory: struct inode adds refcnt, valid, lock, dev, inum on top of dinode. iget(dev,inum) returns an in-memory inode (reference counted, no disk read yet). ilock() reads from disk if not valid, acquires sleeplock. iput() decrements ref; when ref=0, drops from cache; when nlink=0 and ref=0, file is deleted (itrunc + inode type=0). Data blocks: addrs[0..11] = direct, addrs[12] = singly-indirect (points to block of 128 block numbers). Max file size: 12 + 128 = 140 blocks = 140×4096 bytes.",
        "The logging layer provides crash recovery via write-ahead logging. begin_op() starts a transaction, increments log.outstanding. log_write(b) adds a buffer to the current transaction's list (instead of writing directly to disk). end_op() decrements outstanding; when 0, commit(): write_log() copies all modified buffers to the log area on disk, write_head() writes the log header (committing the transaction atomically), install_trans() copies log blocks to their real disk locations, clear the log header. On crash recovery (initlog), xv6 replays any committed but not installed transactions. The key insight: the log header write is atomic — either it happens (transaction committed) or it doesn't (transaction rolled back).",
        "The buffer cache (bio.c) sits between the logging layer and raw disk. It maintains a pool of NBUF=30 in-memory buffers (struct buf), each holding one 4096-byte disk block. A doubly-linked LRU list (bcache.head) orders buffers by recency. bget() searches the cache for the requested (dev, blockno); if found, increments refcnt (BGET_HIT). If not found, recycles the LRU buffer with refcnt=0 (BGET_MISS). bread() calls bget() then reads from disk if !valid. bwrite() issues a disk write. brelse() decrements refcnt; when 0, moves buffer to the head (MRU). The global bcache.lock (spinlock) protects the list; each buffer has its own sleeplock protecting content.",
        "The disk layer is the raw storage device. xv6 uses a VIRTIO disk (virtual disk in QEMU). virtio_disk_rw(b, write) issues read or write I/O to block b->blockno. DMA-based: the CPU sets up descriptor ring entries pointing to the data buffer, rings the device doorbell (VIRTIO_MMIO_QUEUE_NOTIFY), then sleeps on the buffer (sleep(b, &b->lock)). The disk interrupt handler calls wakeup(b) when I/O completes. xv6 disk layout (blocks): 0=boot, 1=superblock, 2..=log, log+logsize..=inodes, inode_end..=bitmap, bitmap_end..=data blocks. struct superblock describes these sizes and offsets."
    ]

    // ── Disk layout data ──────────────────────────────────────────────
    property var diskBlocks:  ["BOOT\nblk 0","SUPER\nblk 1","LOG AREA\nblk 2…logsize","INODES\nlogsize+…","BITMAP\n1 block/8192 data","DATA BLOCKS\nremaining disk"]
    property var diskColors:  ["#374151","#6b7280","#fbbf24","#3b82f6","#10b981","#8b5cf6"]
    property var diskWidths:  [0.06,0.06,0.18,0.18,0.12,0.40]
    property var diskDescs: [
        "Block 0: Boot block — loaded by firmware at startup, contains the bootloader. xv6 leaves it mostly unused for simplicity.",
        "Block 1: Superblock — describes the disk layout. struct superblock: magic, size (total blocks), nblocks (data), ninodes, nlog, logstart, inodestart, bmapstart.",
        "Log area: starts at block logstart, spans nlog blocks. Stores the write-ahead log: header block (log.h: n, block[]) followed by n data blocks. Crash recovery replays from here.",
        "Inode blocks: start at inodestart. Each block holds IPB = BSIZE/sizeof(dinode) inodes. Block for inode i = inodestart + i/IPB. Offset within block = i % IPB. nlink=0 + no references → inode freed.",
        "Bitmap blocks: one bit per data block. BSIZE*8 = 32768 bits per bitmap block. balloc() scans for 0-bit (free block), sets it. bfree() clears the bit. Protects against double-allocation.",
        "Data blocks: actual file and directory content. Managed by balloc()/bfree(). Addressed via inode addrs[]: first 12 direct, then one indirect block (holds 128 block numbers). Total max: 140 blocks per file."
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
            border.color: Qt.rgba(59,130,246,0.25); border.width: 1
            layer.enabled: true
            layer.effect: Glow { radius:10; samples:17; color:Qt.rgba(59,130,246,0.12); spread:0.1 }
            Row {
                anchors.fill: parent; anchors.margins: 15; spacing: 16
                Rectangle {
                    width: 52; height: 52; radius: 12; anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(59,130,246,0.15); border.color: Qt.rgba(59,130,246,0.4); border.width: 1
                    Column { anchors.centerIn: parent; spacing: 1
                        Text { text:"12"; color:"#3b82f6"; font.bold:true; font.pixelSize:20; font.family:"Consolas"; anchors.horizontalCenter:parent }
                        Text { text:"LESSON"; color:Qt.rgba(59,130,246,0.5); font.pixelSize:7; font.letterSpacing:1; anchors.horizontalCenter:parent }
                    }
                }
                Column { anchors.verticalCenter: parent.verticalCenter; spacing: 6
                    Text { text:"FILE SYSTEM OVERVIEW — Seven Layers from FD to Disk"; color:"#ffffff"; font.family:"Segoe UI"; font.bold:true; font.pixelSize:20; font.letterSpacing:0.5 }
                    Text { text:"The xv6 filesystem is a 7-layer stack: FD → Pathname → Directory → Inode → Logging → Buffer Cache → Disk. Each layer hides complexity from the one above it."; color:Qt.rgba(255,255,255,0.55); font.family:"Segoe UI"; font.pixelSize:12 }
                }
            }
        }

        // ── 7-LAYER INTERACTIVE STACK ────────────────────────────────────
        Rectangle {
            width: parent.width; height: layerRow.implicitHeight + 40
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(59,130,246,0.15); border.width: 1

            Row {
                id: layerRow
                anchors.top:parent.top; anchors.topMargin:20
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 18

                // Stack (left)
                Column {
                    width: parent.width * 0.35; spacing: 4
                    Text { text:"CLICK A LAYER — calls flow top→bottom, data returns bottom→top"; color:Qt.rgba(59,130,246,0.5); font.pixelSize:9; font.bold:true; font.letterSpacing:0.5; bottomPadding:6 }
                    Repeater {
                        model: 7
                        delegate: Rectangle {
                            property bool isSel: scrollRoot.selectedLayer === index
                            property bool isHov: scrollRoot.hoveredLayer === index
                            width: parent.width; height: 46; radius: 10
                            color: isSel ? Qt.rgba(scrollRoot.layerR[index]/255,scrollRoot.layerG[index]/255,scrollRoot.layerB[index]/255,0.22) : isHov ? Qt.rgba(scrollRoot.layerR[index]/255,scrollRoot.layerG[index]/255,scrollRoot.layerB[index]/255,0.1) : Qt.rgba(255,255,255,0.02)
                            border.color: isSel ? scrollRoot.layerColors[index] : Qt.rgba(scrollRoot.layerR[index]/255,scrollRoot.layerG[index]/255,scrollRoot.layerB[index]/255,0.3)
                            border.width: isSel ? 2 : 1
                            Behavior on color { ColorAnimation { duration:120 } }

                            Rectangle { width:4; height:parent.height-6; anchors.left:parent.left; anchors.verticalCenter:parent.verticalCenter; color:scrollRoot.layerColors[index]; radius:2 }
                            Column {
                                anchors.left:parent.left;anchors.leftMargin:12;anchors.verticalCenter:parent.verticalCenter;spacing:2
                                Text { text:(index+1)+". "+scrollRoot.layerNames[index].toUpperCase(); color:isSel?scrollRoot.layerColors[index]:"#ffffff"; font.bold:true; font.pixelSize:11; font.letterSpacing:0.3; Behavior on color{ColorAnimation{duration:120}} }
                                Text { text:scrollRoot.layerFiles[index]; color:Qt.rgba(255,255,255,0.3); font.family:"Consolas"; font.pixelSize:9 }
                            }
                            MouseArea { anchors.fill:parent; hoverEnabled:true; cursorShape:Qt.PointingHandCursor; onClicked:scrollRoot.selectedLayer=index; onEntered:scrollRoot.hoveredLayer=index; onExited:scrollRoot.hoveredLayer=-1 }
                        }
                    }
                }

                // Detail panel (right)
                Rectangle {
                    width: parent.width * 0.65 - 18
                    height: layerDetailCol.implicitHeight + 28
                    color: Qt.rgba(0,0,0,0.18); radius:12
                    border.color: scrollRoot.selectedLayer>=0 ? Qt.rgba(scrollRoot.layerR[scrollRoot.selectedLayer]/255,scrollRoot.layerG[scrollRoot.selectedLayer]/255,scrollRoot.layerB[scrollRoot.selectedLayer]/255,0.4) : Qt.rgba(255,255,255,0.06)
                    border.width: 1.5

                    Column {
                        id: layerDetailCol
                        anchors.top:parent.top;anchors.topMargin:16;anchors.left:parent.left;anchors.leftMargin:16;anchors.right:parent.right;anchors.rightMargin:16
                        spacing:10

                        Row { spacing:10
                            Rectangle{width:10;height:10;radius:5;anchors.verticalCenter:parent.verticalCenter;color:scrollRoot.selectedLayer>=0?scrollRoot.layerColors[scrollRoot.selectedLayer]:"#888"}
                            Text{text:scrollRoot.selectedLayer>=0?"Layer "+(scrollRoot.selectedLayer+1)+": "+scrollRoot.layerNames[scrollRoot.selectedLayer]:"Select a layer";color:scrollRoot.selectedLayer>=0?scrollRoot.layerColors[scrollRoot.selectedLayer]:Qt.rgba(255,255,255,0.4);font.bold:true;font.pixelSize:14;font.letterSpacing:0.4}
                        }
                        Row{spacing:16;visible:scrollRoot.selectedLayer>=0
                            Column{spacing:2;Text{text:"FILE";color:Qt.rgba(255,255,255,0.22);font.pixelSize:8;font.letterSpacing:0.8}Text{text:scrollRoot.selectedLayer>=0?scrollRoot.layerFiles[scrollRoot.selectedLayer]:"";color:Qt.rgba(255,255,255,0.6);font.family:"Consolas";font.pixelSize:10}}
                        }
                        Rectangle{width:parent.width;height:1;color:Qt.rgba(255,255,255,0.05);visible:scrollRoot.selectedLayer>=0}
                        Text{width:parent.width;text:scrollRoot.selectedLayer>=0?scrollRoot.layerDescs[scrollRoot.selectedLayer]:"Click any layer";color:scrollRoot.selectedLayer>=0?Qt.rgba(255,255,255,0.78):Qt.rgba(255,255,255,0.28);wrapMode:Text.WordWrap;font.family:"Segoe UI";font.pixelSize:11;lineHeight:1.55}
                    }
                }
            }
        }

        // ── DISK LAYOUT VISUALIZER ────────────────────────────────────────
        Rectangle {
            width: parent.width; height: diskCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.015); radius: 14
            border.color: Qt.rgba(255,255,255,0.07); border.width: 1

            Column {
                id: diskCol
                anchors.top:parent.top;anchors.topMargin:18;anchors.left:parent.left;anchors.leftMargin:18;anchors.right:parent.right;anchors.rightMargin:18
                spacing:14

                Row{spacing:10;Text{text:"💾";font.pixelSize:18;anchors.verticalCenter:parent.verticalCenter}Column{spacing:2;Text{text:"ON-DISK LAYOUT — click any region to understand its role";color:"#3b82f6";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3}Text{text:"xv6 disk structure described in struct superblock (kernel/fs.h)";color:Qt.rgba(255,255,255,0.35);font.pixelSize:11}}}

                // Disk bar
                Row {
                    width: parent.width; height: 56; spacing: 0
                    Repeater {
                        model: 6
                        delegate: Rectangle {
                            property bool isSel: scrollRoot.selDisk === index
                            width: parent.width * scrollRoot.diskWidths[index]; height: parent.height
                            color: "transparent"
                            Rectangle { anchors.fill:parent; anchors.margins:1; radius:index===0?8:index===5?8:0
                                color:Qt.rgba(
                                    [236,249,251,59,16,139][index]/255,
                                    [72,115,191,130,185,92][index]/255,
                                    [153,22,36,246,129,246][index]/255,
                                    isSel?0.25:0.12)
                                border.color:scrollRoot.diskColors[index]; border.width:isSel?2:1
                                Behavior on color{ColorAnimation{duration:120}}
                                Column { anchors.centerIn:parent; spacing:2
                                    Text{text:scrollRoot.diskBlocks[index].split("\n")[0];color:scrollRoot.diskColors[index];font.bold:true;font.pixelSize:9;font.letterSpacing:0.3;anchors.horizontalCenter:parent}
                                    Text{text:scrollRoot.diskBlocks[index].split("\n")[1];color:Qt.rgba(255,255,255,0.35);font.pixelSize:7;anchors.horizontalCenter:parent}
                                }
                            }
                            MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:scrollRoot.selDisk=(scrollRoot.selDisk===index?-1:index)}
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: diskDescText.implicitHeight + 20; radius:10
                    color: scrollRoot.selDisk>=0 ? Qt.rgba(59/255,130/255,246/255,0.07) : Qt.rgba(255,255,255,0.02)
                    border.color: scrollRoot.selDisk>=0 ? Qt.rgba(59/255,130/255,246/255,0.3) : Qt.rgba(255,255,255,0.06); border.width:1
                    Behavior on color{ColorAnimation{duration:120}}

                    Text {
                        id: diskDescText
                        anchors.left:parent.left;anchors.leftMargin:14;anchors.right:parent.right;anchors.rightMargin:14;anchors.verticalCenter:parent.verticalCenter
                        text: scrollRoot.selDisk>=0 ? scrollRoot.diskDescs[scrollRoot.selDisk] : "Click a disk region above to learn what it stores and why."
                        color: scrollRoot.selDisk>=0 ? Qt.rgba(255,255,255,0.78) : Qt.rgba(255,255,255,0.28)
                        wrapMode:Text.WordWrap; font.family:"Segoe UI"; font.pixelSize:11; lineHeight:1.5
                    }
                }

                // Superblock fields
                Rectangle {
                    width:parent.width; height:sbRow.implicitHeight+24; color:Qt.rgba(0,0,0,0.2); radius:10; border.color:Qt.rgba(255,255,255,0.06); border.width:1
                    Column {
                        id: sbRow
                        anchors.top:parent.top;anchors.topMargin:12;anchors.left:parent.left;anchors.leftMargin:14;anchors.right:parent.right;anchors.rightMargin:14; spacing:6
                        Text{text:"struct superblock fields (kernel/fs.h)";color:Qt.rgba(59,130,246,0.7);font.family:"Consolas";font.bold:true;font.pixelSize:11}
                        Flow { width:parent.width; spacing:8
                            Repeater {
                                model:["magic — 0x10203040 sanity check","size — total disk blocks","nblocks — data blocks","ninodes — max inodes","nlog — log area blocks","logstart — first log block","inodestart — first inode block","bmapstart — bitmap block"]
                                delegate: Rectangle { height:24; width:sbFieldText.implicitWidth+20; radius:6; color:Qt.rgba(59/255,130/255,246/255,0.1); border.color:Qt.rgba(59/255,130/255,246/255,0.25); border.width:1
                                    Text{id:sbFieldText;anchors.centerIn:parent;text:modelData;color:Qt.rgba(255,255,255,0.65);font.family:"Consolas";font.pixelSize:10}
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── FOOTER ──────────────────────────────────────────────────────
        Rectangle {
            width:parent.width; height:65
            color:Qt.rgba(59/255,130/255,246/255,0.08); radius:14
            border.color:Qt.rgba(59/255,130/255,246/255,0.35); border.width:1
            RowLayout {
                anchors.fill:parent; anchors.margins:15; spacing:15
                Text{text:"🌟";font.pixelSize:22;Layout.alignment:Qt.AlignVCenter}
                Text { Layout.fillWidth:true; Layout.alignment:Qt.AlignVCenter
                    text:"CORE SUMMARY: xv6 filesystem = 7 layers: FD→Pathname→Directory→Inode→Logging→Buffer Cache→Disk. Disk layout: boot | superblock | log | inodes | bitmap | data. open() call path: namei→iget/ilock→filealloc→fdalloc. Data blocks: 12 direct + 1 indirect (128 blocks) per inode = max 140 pages. Logging ensures crash safety: all writes go through log first, then installed atomically."
                    color:"#ffffff"; wrapMode:Text.WordWrap; font.family:"Segoe UI"; font.bold:true; font.pixelSize:12; font.letterSpacing:0.2
                }
            }
        }
    }
}
