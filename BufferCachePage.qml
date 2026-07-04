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

    property int  openCard:      0
    property int  selectedOp:    0
    property real cacheDot:      0.0
    property int  hoveredBuf:    -1
    property int  selectedBuf:   -1

    // ── LRU buffer state (8 visual slots) ────────────────────────────
    property var bufValid:   [true, true, false, true, true, false, true, false]
    property var bufBlockno: [  42,   17,    -1,   99,    5,   -1,   23,   -1]
    property var bufRefcnt:  [   0,    1,     0,    0,    2,    0,    0,    0]
    property var bufDirty:   [false, true, false, false, false, false, true, false]

    Timer {
        interval: 22; running: true; repeat: true
        onTriggered: scrollRoot.cacheDot = (scrollRoot.cacheDot + 0.004) % 1.0

        // ── TAKE QUIZ BUTTON ────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 52; radius: 14
            color: quizNavBtn.containsMouse ? Qt.rgba(255,255,255,0.10) : Qt.rgba(255,255,255,0.04)
            border.color: "#22d3ee"; border.width: 1
            Behavior on color { ColorAnimation { duration: 180 } }
            Text {
                anchors.centerIn: parent
                text: "QUIZ  →  BUFFER CACHE"
                color: "#22d3ee"; font.bold: true; font.pixelSize: 13
                font.family: "Segoe UI"; font.letterSpacing: 0.4
            }
            MouseArea {
                id: quizNavBtn; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: scrollRoot.requestNavigate("BufferCacheQuizPage.qml")
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
                Text { text: "→  LOGGING"; color: "#8b5cf6"; font.bold: true; font.pixelSize: 13; font.family: "Segoe UI"; font.letterSpacing: 0.4; anchors.verticalCenter: parent.verticalCenter }
            }
            MouseArea {
                id: nextBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: scrollRoot.requestNavigate("LoggingPage.qml")
            }
        }
    }

    // ── Operation descriptions ────────────────────────────────────────
    property var opNames: ["bread(dev, blockno)","bwrite(buf)","brelse(buf)","bpin(buf)","bunpin(buf)","bget(dev, blockno)"]
    property var opColors: ["#fbbf24","#f97316","#10b981","#8b5cf6","#06b6d4","#f43f5e"]
    property var opDescs: [
        "bread() is the primary read interface. It calls bget(dev, blockno) to get a locked buffer (either from cache or recycling LRU). If the buffer's valid flag is 0 (cache miss), it issues a disk read via virtio_disk_rw(b, 0) to fill the buffer, then sets valid=1. Returns the locked buffer to the caller — caller must call brelse() when done. Never returns without a valid buffer. Typical use: struct buf *b = bread(dev, bn); // read + modify; bwrite(b); brelse(b);",
        "bwrite() flushes the buffer content to disk by calling virtio_disk_rw(b, 1). The caller must hold the buffer's sleeplock before calling bwrite(). After bwrite(), the buffer is not released — the caller still owns it and must call brelse(). Note: bwrite() does NOT go through the log. Higher-level code (log_write) is responsible for ensuring write ordering and crash safety. The logging layer calls bwrite() only during commit(), after all log entries are written.",
        "brelse() releases a buffer acquired by bread(). It releases the sleeplock (releasesleep(&b->lock)), then acquires bcache.lock. Decrements b->refcnt. If refcnt reaches 0: removes b from its current list position and moves it to bcache.head.next — making it the MRU (most recently used). This ensures the LRU buffer (bcache.head.prev) is always the best candidate for recycling. After brelse(), do not access the buffer — it may be recycled immediately.",
        "bpin() increments b->refcnt while holding bcache.lock. This prevents the buffer from being recycled by bget() (recycling requires refcnt==0). The logging layer pins all buffers that have been log_write()d during a transaction — it needs them to survive until commit() writes them to the log. Called inside log_write() after acquiring bcache.lock.",
        "bunpin() decrements b->refcnt while holding bcache.lock. Called by the logging layer after install_trans() has written the buffer's data to its real disk location. Once unpinned and brelse()d, the buffer can be recycled by bget(). The log layer is careful to bpin() before any release and bunpin() after install, maintaining the invariant that pinned buffers are never evicted.",
        "bget() is the core cache lookup + allocation function. Holds bcache.lock throughout. First pass: scan all buffers for matching dev+blockno AND valid. If found: increment refcnt, acquire sleeplock, return (BGET_HIT). Second pass (miss): scan for refcnt==0 to find an LRU candidate. Takes the tail (LRU) first, or the next closest. Sets b->dev=dev, b->blockno=blockno, b->valid=0, b->refcnt=1. Acquires sleeplock, releases bcache.lock, returns. bread() will then fill it from disk. If no free buffer: panic('bget: no buffers') — xv6 has no eviction wait."
    ]
    property var opCodes: [
        "// kernel/bio.c\nstruct buf* bread(uint dev, uint blockno) {\n    struct buf *b = bget(dev, blockno);\n    if(!b->valid) {\n        // Cache miss: read from disk\n        virtio_disk_rw(b, 0);  // 0 = read\n        b->valid = 1;\n    }\n    return b;  // sleeplock held by caller\n    // caller must call brelse(b) when done\n}",
        "// kernel/bio.c\nvoid bwrite(struct buf *b) {\n    if(!holdingsleep(&b->lock))\n        panic(\"bwrite\");\n    virtio_disk_rw(b, 1);  // 1 = write\n    // Does NOT go through log!\n    // Logging layer calls bwrite only during\n    // commit(), AFTER log_write + write_log.\n}",
        "// kernel/bio.c\nvoid brelse(struct buf *b) {\n    if(!holdingsleep(&b->lock))\n        panic(\"brelse\");\n    releasesleep(&b->lock);   // release data lock\n    acquire(&bcache.lock);\n    b->refcnt--;\n    if (b->refcnt == 0) {\n        // Move to head (MRU) of LRU list\n        b->next->prev = b->prev;\n        b->prev->next = b->next;\n        b->next = bcache.head.next;\n        b->prev = &bcache.head;\n        bcache.head.next->prev = b;\n        bcache.head.next = b;\n    }\n    release(&bcache.lock);\n}",
        "// kernel/bio.c — used by log layer\nvoid bpin(struct buf *b) {\n    acquire(&bcache.lock);\n    b->refcnt++;  // prevent eviction\n    release(&bcache.lock);\n    // Buffer can now NOT be recycled\n    // log_write() pins all bufs in transaction\n}",
        "// kernel/bio.c\nvoid bunpin(struct buf *b) {\n    acquire(&bcache.lock);\n    b->refcnt--;  // allow eviction again\n    release(&bcache.lock);\n    // install_trans() calls bunpin after\n    // writing log data to real disk location\n}",
        "// kernel/bio.c\nstatic struct buf* bget(uint dev, uint blockno) {\n    acquire(&bcache.lock);\n    // Pass 1: is it already cached?\n    for(b=bcache.head.next; b!=&bcache.head; b=b->next)\n        if(b->dev==dev && b->blockno==blockno) {\n            b->refcnt++;\n            release(&bcache.lock);\n            acquiresleep(&b->lock);\n            return b;  // HIT\n        }\n    // Pass 2: find LRU (refcnt==0, from tail)\n    for(b=bcache.head.prev; b!=&bcache.head; b=b->prev)\n        if(b->refcnt==0) {\n            b->dev=dev; b->blockno=blockno;\n            b->valid=0; b->refcnt=1;\n            release(&bcache.lock);\n            acquiresleep(&b->lock);\n            return b;  // MISS: recycled\n        }\n    panic(\"bget: no buffers\");\n}"
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
            border.color: Qt.rgba(251,191,36,0.25); border.width: 1
            layer.enabled: true
            layer.effect: Glow { radius:10; samples:17; color:Qt.rgba(251,191,36,0.12); spread:0.1 }
            Row {
                anchors.fill: parent; anchors.margins: 15; spacing: 16
                Rectangle {
                    width: 52; height: 52; radius: 12; anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(251,191,36,0.15); border.color: Qt.rgba(251,191,36,0.4); border.width: 1
                    Column { anchors.centerIn: parent; spacing: 1
                        Text { text:"13"; color:"#fbbf24"; font.bold:true; font.pixelSize:20; font.family:"Consolas"; anchors.horizontalCenter:parent.horizontalCenter }
                        Text { text:"LESSON"; color:Qt.rgba(251,191,36,0.5); font.pixelSize:7; font.letterSpacing:1; anchors.horizontalCenter:parent.horizontalCenter }
                    }
                }
                Column { anchors.verticalCenter: parent.verticalCenter; spacing: 6
                    Text { text:"BUFFER CACHE — LRU Pool, bread/bwrite/brelse (bio.c)"; color:"#ffffff"; font.family:"Segoe UI"; font.bold:true; font.pixelSize:20; font.letterSpacing:0.5 }
                    Text { text:"How xv6 caches disk blocks in memory: NBUF=30 buffers in a doubly-linked LRU list. Cache hit avoids disk I/O; miss recycles the least recently used buffer."; color:Qt.rgba(255,255,255,0.55); font.family:"Segoe UI"; font.pixelSize:12 }
                }
            }
        }

        // ── LRU CACHE VISUALIZER ──────────────────────────────────────────
        Rectangle {
            width: parent.width; height: lruCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(251,191,36,0.2); border.width: 1

            Column {
                id: lruCol
                anchors.top:parent.top;anchors.topMargin:18;anchors.left:parent.left;anchors.leftMargin:18;anchors.right:parent.right;anchors.rightMargin:18
                spacing: 14

                Row{spacing:10;Text{text:"🗄️";font.pixelSize:18;anchors.verticalCenter:parent.verticalCenter}Column{spacing:2;Text{text:"LRU BUFFER POOL — 8 buffers shown (xv6 uses NBUF=30)";color:"#fbbf24";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3}Text{text:"MRU (head.next) ← most recently used ··· least recently used → LRU (head.prev) — recycled first";color:Qt.rgba(255,255,255,0.35);font.pixelSize:11}}}

                // MRU → LRU arrow labels
                Row { width:parent.width; spacing:0
                    Text{text:"◀ MRU";color:Qt.rgba(16,185,129,0.6);font.pixelSize:9;font.bold:true;font.letterSpacing:0.5}
                    Item{Layout.fillWidth:true;width:1;height:1}
                    Text{text:"LRU ▶";color:Qt.rgba(244,63,94,0.6);font.pixelSize:9;font.bold:true;font.letterSpacing:0.5;anchors.right:parent.right}
                }

                // Buffer tiles
                Row {
                    spacing: 6; width: parent.width
                    Repeater {
                        model: 8
                        delegate: Rectangle {
                            property bool isSel: scrollRoot.selectedBuf === index
                            property bool isHov: scrollRoot.hoveredBuf === index
                            property bool canRecycle: scrollRoot.bufRefcnt[index] === 0
                            width: (parent.width - 42) / 8; height: 90; radius: 9
                            color: isSel ? Qt.rgba(251/255,191/255,36/255,0.18) : (canRecycle&&isHov) ? Qt.rgba(244/255,63/255,94/255,0.1) : Qt.rgba(255,255,255,0.03)
                            border.color: isSel?"#fbbf24":scrollRoot.bufDirty[index]?"#f97316":scrollRoot.bufValid[index]?"#10b981":Qt.rgba(255,255,255,0.1)
                            border.width: isSel?2:1.5
                            Behavior on color{ColorAnimation{duration:130}}

                            Column { anchors.centerIn:parent; spacing:4
                                Text{text:"buf"+index;color:Qt.rgba(255,255,255,0.3);font.pixelSize:8;font.family:"Consolas";anchors.horizontalCenter:parent.horizontalCenter}
                                Text{text:scrollRoot.bufBlockno[index]>=0?"blk\n"+scrollRoot.bufBlockno[index]:"FREE";color:scrollRoot.bufBlockno[index]>=0?"#fbbf24":"#4b5563";font.family:"Consolas";font.bold:true;font.pixelSize:scrollRoot.bufBlockno[index]>=0?11:9;horizontalAlignment:Text.AlignHCenter;anchors.horizontalCenter:parent.horizontalCenter}
                                Row{spacing:4;anchors.horizontalCenter:parent
                                    Rectangle{width:14;height:14;radius:3;color:scrollRoot.bufValid[index]?Qt.rgba(16,185,129,0.3):Qt.rgba(255,255,255,0.05);border.color:scrollRoot.bufValid[index]?"#10b981":Qt.rgba(255,255,255,0.15);border.width:1;Text{anchors.centerIn:parent;text:"V";color:scrollRoot.bufValid[index]?"#10b981":Qt.rgba(255,255,255,0.2);font.pixelSize:8;font.bold:true}}
                                    Rectangle{width:14;height:14;radius:3;color:scrollRoot.bufDirty[index]?Qt.rgba(249,115,22,0.3):Qt.rgba(255,255,255,0.05);border.color:scrollRoot.bufDirty[index]?"#f97316":Qt.rgba(255,255,255,0.15);border.width:1;Text{anchors.centerIn:parent;text:"D";color:scrollRoot.bufDirty[index]?"#f97316":Qt.rgba(255,255,255,0.2);font.pixelSize:8;font.bold:true}}
                                }
                                Text{text:"ref="+scrollRoot.bufRefcnt[index];color:scrollRoot.bufRefcnt[index]>0?"#a78bfa":Qt.rgba(255,255,255,0.3);font.pixelSize:9;font.family:"Consolas";anchors.horizontalCenter:parent.horizontalCenter}
                            }
                            MouseArea{anchors.fill:parent;hoverEnabled:true;cursorShape:Qt.PointingHandCursor;onClicked:scrollRoot.selectedBuf=(scrollRoot.selectedBuf===index?-1:index);onEntered:scrollRoot.hoveredBuf=index;onExited:scrollRoot.hoveredBuf=-1}
                        }
                    }
                }

                // Legend
                Row{spacing:20
                    Row{spacing:6;Rectangle{width:12;height:12;radius:3;color:"#10b981";anchors.verticalCenter:parent.verticalCenter}Text{text:"V=valid";color:Qt.rgba(255,255,255,0.45);font.pixelSize:10}}
                    Row{spacing:6;Rectangle{width:12;height:12;radius:3;color:"#f97316";anchors.verticalCenter:parent.verticalCenter}Text{text:"D=dirty";color:Qt.rgba(255,255,255,0.45);font.pixelSize:10}}
                    Row{spacing:6;Rectangle{width:12;height:12;radius:3;color:"#a78bfa";anchors.verticalCenter:parent.verticalCenter}Text{text:"ref>0=in use";color:Qt.rgba(255,255,255,0.45);font.pixelSize:10}}
                    Row{spacing:6;Rectangle{width:12;height:12;radius:3;color:Qt.rgba(255,255,255,0.06);border.color:Qt.rgba(255,255,255,0.15);border.width:1;anchors.verticalCenter:parent.verticalCenter}Text{text:"FREE (recyclable)";color:Qt.rgba(255,255,255,0.45);font.pixelSize:10}}
                }

                // Selected buffer info
                Rectangle {
                    width:parent.width; height:bufInfoText.implicitHeight+20; radius:10
                    color:scrollRoot.selectedBuf>=0?Qt.rgba(251/255,191/255,36/255,0.07):Qt.rgba(255,255,255,0.02)
                    border.color:scrollRoot.selectedBuf>=0?Qt.rgba(251/255,191/255,36/255,0.3):Qt.rgba(255,255,255,0.06);border.width:1
                    Text {
                        id:bufInfoText
                        anchors.left:parent.left;anchors.leftMargin:14;anchors.right:parent.right;anchors.rightMargin:14;anchors.verticalCenter:parent.verticalCenter
                        text: scrollRoot.selectedBuf>=0
                            ? "buf"+scrollRoot.selectedBuf+": blockno="+scrollRoot.bufBlockno[scrollRoot.selectedBuf]+" | valid="+scrollRoot.bufValid[scrollRoot.selectedBuf]+" | dirty="+scrollRoot.bufDirty[scrollRoot.selectedBuf]+" | refcnt="+scrollRoot.bufRefcnt[scrollRoot.selectedBuf]+(scrollRoot.bufRefcnt[scrollRoot.selectedBuf]===0?" → CAN be recycled by bget()":" → CANNOT be recycled (in use)")
                            : "Click a buffer tile above to inspect its state"
                        color:scrollRoot.selectedBuf>=0?Qt.rgba(255,255,255,0.75):Qt.rgba(255,255,255,0.28)
                        wrapMode:Text.WordWrap; font.family:"Consolas"; font.pixelSize:11
                    }
                }
            }
        }

        // ── OPERATION SELECTOR + CODE ─────────────────────────────────────
        Rectangle {
            width: parent.width; height: opCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.015); radius: 14
            border.color: Qt.rgba(255,255,255,0.07); border.width: 1

            Column {
                id: opCol
                anchors.top:parent.top;anchors.topMargin:18;anchors.left:parent.left;anchors.leftMargin:18;anchors.right:parent.right;anchors.rightMargin:18
                spacing:14

                Row{spacing:10;Text{text:"🔧";font.pixelSize:18;anchors.verticalCenter:parent.verticalCenter}Column{spacing:2;Text{text:"FUNCTION EXPLORER — click any operation to see theory + code";color:"#fbbf24";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3}Text{text:"All six bio.c functions that form the complete buffer cache API";color:Qt.rgba(255,255,255,0.35);font.pixelSize:11}}}

                // Operation pills
                Flow { width:parent.width; spacing:8
                    Repeater {
                        model: 6
                        delegate: Rectangle {
                            property bool active: scrollRoot.selectedOp === index
                            height:34; width:opPillText.implicitWidth+24; radius:9
                            color:active?Qt.rgba(251/255,191/255,36/255,0.18):Qt.rgba(255,255,255,0.03)
                            border.color:active?"#fbbf24":Qt.rgba(255,255,255,0.1);border.width:active?1.5:1
                            Behavior on color{ColorAnimation{duration:130}}
                            Text{id:opPillText;anchors.centerIn:parent;text:scrollRoot.opNames[index];color:active?"#fbbf24":Qt.rgba(255,255,255,0.45);font.bold:true;font.pixelSize:11;font.family:"Consolas"}
                            MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:scrollRoot.selectedOp=index}
                        }
                    }
                }

                // Theory + code
                Row { width:parent.width; spacing:14
                    Text {
                        width:parent.width*0.40; text:scrollRoot.opDescs[scrollRoot.selectedOp]
                        color:Qt.rgba(255,255,255,0.75);font.family:"Segoe UI";font.pixelSize:11;wrapMode:Text.WordWrap;lineHeight:1.55
                    }
                    Rectangle {
                        width:parent.width*0.60-14; height:opCodeText.implicitHeight+32
                        color:Qt.rgba(0,0,0,0.28);radius:10;border.color:Qt.rgba(255,255,255,0.06);border.width:1
                        Rectangle{width:parent.width;height:22;color:Qt.rgba(255,255,255,0.04);radius:10;
                            Rectangle{width:parent.width;height:11;anchors.bottom:parent.bottom;color:parent.color}
                            Row{anchors.left:parent.left;anchors.leftMargin:8;anchors.verticalCenter:parent.verticalCenter;spacing:4;Repeater{model:3;delegate:Rectangle{width:7;height:7;radius:3.5;color:["#f43f5e","#fbbf24","#10b981"][index];opacity:0.7}}}
                            Text{text:"kernel/bio.c";color:Qt.rgba(255,255,255,0.18);font.pixelSize:9;font.family:"Consolas";anchors.centerIn:parent}
                        }
                        Text{id:opCodeText;anchors.top:parent.top;anchors.topMargin:28;anchors.left:parent.left;anchors.leftMargin:12;anchors.right:parent.right;anchors.rightMargin:12;text:scrollRoot.opCodes[scrollRoot.selectedOp];color:Qt.rgba(255,255,255,0.82);font.family:"Consolas";font.pixelSize:10;wrapMode:Text.WrapAtWordBoundaryOrAnywhere;lineHeight:1.5}
                    }
                }
            }
        }

        // ── FOOTER ──────────────────────────────────────────────────────

        // ── BUFFER CACHE SIMULATOR ──────────────────────────────────────
        Rectangle {
            id: bcSim
            width:parent.width; height:bcSimCol.implicitHeight+32
            color:Qt.rgba(255,255,255,0.015); radius:14
            border.color:Qt.rgba(16,185,129,0.2); border.width:1

            property var cache: []      // {dev, block, dirty, age}
            property int capacity: 5
            property int clock: 0
            property string lastResult: ""
            property string lastColor: "#a0a0a0"
            property var history: []

            property var devOptions:   [1, 1, 2, 2]
            property var blockOptions: [0, 1, 0, 5]
            property int selDev:   1
            property int selBlock: 0

            function bread(dev, blk) {
                clock++
                // check cache
                for(var i=0;i<cache.length;i++){
                    if(cache[i].dev===dev && cache[i].block===blk){
                        var c2=cache.slice()
                        c2[i]={dev:dev,block:blk,dirty:c2[i].dirty,age:clock}
                        cache=c2
                        var h2=history.slice(); h2.unshift({op:"HIT",dev:dev,blk:blk,color:"#10b981"}); if(h2.length>6) h2.pop(); history=h2
                        lastResult="✓ CACHE HIT — block (dev="+dev+", blk="+blk+") found in buffer. No disk I/O."; lastColor="#10b981"; return
                    }
                }
                // miss — need to insert (evict LRU if full)
                var c3=cache.slice()
                if(c3.length>=capacity){
                    var lru=0
                    for(var j=1;j<c3.length;j++) if(c3[j].age<c3[lru].age) lru=j
                    var evicted=c3[lru]
                    c3.splice(lru,1)
                    var h3=history.slice(); h3.unshift({op:"EVICT",dev:evicted.dev,blk:evicted.block,color:"#f43f5e"}); if(h3.length>6) h3.pop(); history=h3
                }
                c3.push({dev:dev,block:blk,dirty:false,age:clock})
                cache=c3
                var h4=history.slice(); h4.unshift({op:"MISS→LOAD",dev:dev,blk:blk,color:"#fbbf24"}); if(h4.length>6) h4.pop(); history=h4
                lastResult="✗ CACHE MISS — disk I/O issued for (dev="+dev+", blk="+blk+"). Block loaded into buffer cache."; lastColor="#fbbf24"
            }

            function bwrite(dev, blk) {
                for(var i=0;i<cache.length;i++){
                    if(cache[i].dev===dev && cache[i].block===blk){
                        var c2=cache.slice(); c2[i]={dev:dev,block:blk,dirty:true,age:clock}; cache=c2
                        var h2=history.slice(); h2.unshift({op:"BWRITE",dev:dev,blk:blk,color:"#f97316"}); if(h2.length>6) h2.pop(); history=h2
                        lastResult="✎ BWRITE — block marked dirty. Will be flushed to disk on brelse/sync."; lastColor="#f97316"; return
                    }
                }
                lastResult="⚠ BWRITE failed — block not in cache. Call bread() first."; lastColor="#f43f5e"
            }

            Component.onCompleted: {
                cache=[{dev:1,block:0,dirty:false,age:1},{dev:1,block:1,dirty:false,age:2}]; clock=2
                lastResult="Cache pre-loaded with 2 blocks. Try bread() or bwrite()."
            }

            Column {
                id:bcSimCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing:14

                Row { spacing:10
                    Text { text:"💾"; font.pixelSize:18; anchors.verticalCenter:parent.verticalCenter }
                    Column { spacing:2
                        Text { text:"BUFFER CACHE SIMULATOR — bread(dev,block) / bwrite()"; color:"#10b981"; font.bold:true; font.pixelSize:13 }
                        Text { text:"Cache holds "+bcSim.capacity+" buffers (LRU eviction). Dirty blocks must be flushed before reuse."; color:Qt.rgba(255,255,255,0.32); font.pixelSize:11 }
                    }
                }

                // Cache slots
                Row { spacing:6; width:parent.width
                    Repeater {
                        model: bcSim.capacity
                        delegate: Rectangle {
                            property var entry: index < bcSim.cache.length ? bcSim.cache[index] : null
                            width:(parent.width-24)/5; height:72; radius:10
                            color:entry?(entry.dirty?Qt.rgba(249/255,115/255,22/255,0.2):Qt.rgba(16/255,185/255,129/255,0.15)):Qt.rgba(255,255,255,0.03)
                            border.color:entry?(entry.dirty?"#f97316":"#10b981"):Qt.rgba(255,255,255,0.1); border.width:1
                            Column { anchors.centerIn:parent; spacing:4
                                Text { text:entry?"SLOT "+index:"EMPTY"; color:entry?"#10b981":Qt.rgba(255,255,255,0.2); font.pixelSize:9; font.bold:true; anchors.horizontalCenter:parent.horizontalCenter }
                                Text { text:entry?("dev="+entry.dev+"
blk="+entry.block):"—"; color:entry?Qt.rgba(255,255,255,0.75):Qt.rgba(255,255,255,0.2); font.pixelSize:9; font.family:"Consolas"; anchors.horizontalCenter:parent.horizontalCenter; horizontalAlignment:Text.AlignHCenter }
                                Rectangle { width:38; height:14; radius:4; color:entry?(entry.dirty?Qt.rgba(249/255,115/255,22/255,0.3):Qt.rgba(16/255,185/255,129/255,0.3)):Qt.rgba(255,255,255,0.05); anchors.horizontalCenter:parent
                                    Text { anchors.centerIn:parent; text:entry?(entry.dirty?"dirty":"clean"):"free"; color:entry?(entry.dirty?"#f97316":"#10b981"):Qt.rgba(255,255,255,0.2); font.pixelSize:8 }
                                }
                            }
                        }
                    }
                }

                // Dev/block selector + operation buttons
                Row { spacing:10; width:parent.width
                    Column { spacing:6
                        Text { text:"dev"; color:Qt.rgba(255,255,255,0.4); font.pixelSize:10 }
                        Row { spacing:4
                            Repeater { model:[1,2]
                                delegate: Rectangle {
                                    width:34; height:28; radius:7
                                    color:bcSim.selDev===modelData?Qt.rgba(16/255,185/255,129/255,0.2):Qt.rgba(255,255,255,0.05)
                                    border.color:bcSim.selDev===modelData?"#10b981":Qt.rgba(255,255,255,0.1); border.width:1
                                    Text { anchors.centerIn:parent; text:""+modelData; color:bcSim.selDev===modelData?"#10b981":Qt.rgba(255,255,255,0.4); font.pixelSize:11; font.family:"Consolas" }
                                    MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:bcSim.selDev=modelData }
                                }
                            }
                        }
                    }
                    Column { spacing:6
                        Text { text:"block"; color:Qt.rgba(255,255,255,0.4); font.pixelSize:10 }
                        Row { spacing:4
                            Repeater { model:[0,1,2,5,9]
                                delegate: Rectangle {
                                    width:30; height:28; radius:7
                                    color:bcSim.selBlock===modelData?Qt.rgba(16/255,185/255,129/255,0.2):Qt.rgba(255,255,255,0.05)
                                    border.color:bcSim.selBlock===modelData?"#10b981":Qt.rgba(255,255,255,0.1); border.width:1
                                    Text { anchors.centerIn:parent; text:""+modelData; color:bcSim.selBlock===modelData?"#10b981":Qt.rgba(255,255,255,0.4); font.pixelSize:11; font.family:"Consolas" }
                                    MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:bcSim.selBlock=modelData }
                                }
                            }
                        }
                    }
                    Rectangle { height:36; width:bReadBtn.implicitWidth+20; radius:9; anchors.bottom:parent.bottom
                        color:Qt.rgba(16/255,185/255,129/255,0.15); border.color:"#10b981"; border.width:1
                        Text { id:bReadBtn; anchors.centerIn:parent; text:"bread()"; color:"#10b981"; font.bold:true; font.pixelSize:12; font.family:"Consolas" }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:bcSim.bread(bcSim.selDev, bcSim.selBlock) }
                    }
                    Rectangle { height:36; width:bWrBtn.implicitWidth+20; radius:9; anchors.bottom:parent.bottom
                        color:Qt.rgba(249/255,115/255,22/255,0.15); border.color:"#f97316"; border.width:1
                        Text { id:bWrBtn; anchors.centerIn:parent; text:"bwrite()"; color:"#f97316"; font.bold:true; font.pixelSize:12; font.family:"Consolas" }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:bcSim.bwrite(bcSim.selDev, bcSim.selBlock) }
                    }
                    Rectangle { height:36; width:rstBtn.implicitWidth+20; radius:9; anchors.bottom:parent.bottom
                        color:Qt.rgba(255,255,255,0.04); border.color:Qt.rgba(255,255,255,0.1); border.width:1
                        Text { id:rstBtn; anchors.centerIn:parent; text:"↺ clear cache"; color:Qt.rgba(255,255,255,0.35); font.pixelSize:11 }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:{ bcSim.cache=[]; bcSim.clock=0; bcSim.history=[]; bcSim.lastResult="Cache cleared." ; bcSim.lastColor="#a0a0a0" } }
                    }
                }

                // Result + history
                Row { spacing:12; width:parent.width
                    Rectangle { width:(parent.width-12)*0.6; height:60; radius:10; color:Qt.rgba(0,0,0,0.2); border.color:Qt.rgba(16,185,129,0.15); border.width:1
                        Text { anchors.left:parent.left; anchors.leftMargin:14; anchors.right:parent.right; anchors.rightMargin:14; anchors.verticalCenter:parent.verticalCenter
                            text:bcSim.lastResult; color:bcSim.lastColor
                            wrapMode:Text.WordWrap; font.pixelSize:11; lineHeight:1.5 }
                    }
                    Column { width:(parent.width-12)*0.4; spacing:4
                        Repeater { model:bcSim.history
                            delegate: Row { spacing:6
                                Rectangle { width:70; height:16; radius:4; color:Qt.rgba(255,255,255,0.06)
                                    Text { anchors.centerIn:parent; text:modelData.op; color:modelData.color; font.pixelSize:8; font.bold:true }
                                }
                                Text { text:"dev="+modelData.dev+" blk="+modelData.blk; color:Qt.rgba(255,255,255,0.4); font.pixelSize:9; font.family:"Consolas"; anchors.verticalCenter:parent.verticalCenter }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            width:parent.width; height:65
            color:Qt.rgba(251/255,191/255,36/255,0.08); radius:14
            border.color:Qt.rgba(251/255,191/255,36/255,0.35); border.width:1
            RowLayout {
                anchors.fill:parent; anchors.margins:15; spacing:15
                Text{text:"🌟";font.pixelSize:22;Layout.alignment:Qt.AlignVCenter}
                Text{Layout.fillWidth:true;Layout.alignment:Qt.AlignVCenter;text:"CORE SUMMARY: Buffer cache = NBUF=30 bufs in doubly-linked LRU list. bget() — hit: incr refcnt. miss: recycle tail (LRU, refcnt=0). bread() = bget + disk read if !valid. bwrite() = disk write (no log). brelse() = decr refcnt + move to head (MRU). bpin/bunpin protect buffers from eviction during log transactions. bcache.lock (spinlock) protects list; buf->lock (sleeplock) protects content.";color:"#ffffff";wrapMode:Text.WordWrap;font.family:"Segoe UI";font.bold:true;font.pixelSize:12;font.letterSpacing:0.2}
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
                Text { text: "→  LOGGING"; color: "#8b5cf6"; font.bold: true; font.pixelSize: 13; font.family: "Segoe UI"; font.letterSpacing: 0.4; anchors.verticalCenter: parent.verticalCenter }
            }
            MouseArea {
                id: nextBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: scrollRoot.requestNavigate("LoggingPage.qml")
            }
        }

    }
}
