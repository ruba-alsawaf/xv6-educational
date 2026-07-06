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
    signal attendanceChanged()

    // ── Race condition simulator ──────────────────────────────────────
    property int  raceStep:     0
    property bool lockHeld:     false
    property int  sharedVal:    0
    property int  p0Val:        0
    property int  p1Val:        0
    property bool raceResult:   false   // true = bad interleave, false = correct

    // ── Accordion ────────────────────────────────────────────────────
    property int openCard: 0

    // ── Deadlock simulator ───────────────────────────────────────────
    property bool p0HasA: false
    property bool p0HasB: false
    property bool p1HasA: false
    property bool p1HasB: false
    property bool deadlockDetected: false

    // ── Animation dot ─────────────────────────────────────────────────
    property real lockDot: 0.0
    Timer {
        interval: 22; running: true; repeat: true
        onTriggered: scrollRoot.lockDot = (scrollRoot.lockDot + 0.005) % 1.0
    }

    // ── Theory data ────────────────────────────────────────────────────
    property var cardTitles: ["SPINLOCK — acquire() & release()","SLEEPLOCK — acquiresleep() & releasesleep()","LOCK ORDERING — Preventing Deadlock","REENTRANCY & INTERRUPT SAFETY","MEMORY BARRIERS & __sync_synchronize()"]
    property var cardSubs: ["busy-wait loop on lk->locked using RISC-V amoswap","sleeps while waiting; uses a spinlock to protect its own state","always acquire in the same global order across all code paths","xv6 spinlocks disable interrupts; must not be held across sleep","prevents CPU/compiler from reordering memory ops across lock boundary"]
    property var cardColors: ["#06b6d4","#8b5cf6","#f43f5e","#fbbf24","#10b981"]
    property var cardR: [6,139,244,251,16]; property var cardG: [182,92,63,191,185]; property var cardB: [212,246,94,36,129]
    property var cardSources: ["kernel/spinlock.c","kernel/sleeplock.c","kernel/spinlock.c + bio.c + proc.c","kernel/spinlock.c","kernel/spinlock.c"]
    property var cardTheories: [
        "A spinlock busy-waits until the lock is free. acquire() disables interrupts on the current CPU (push_off()), then loops on 'while(__sync_lock_test_and_set(&lk->locked, 1) != 0)' — this is an atomic swap that returns the old value. If it returns 0, we won the lock. If 1, someone else holds it — we keep spinning. The memory barrier __sync_synchronize() after the swap prevents the compiler from moving critical-section code before the lock. release() uses __sync_lock_release(&lk->locked) (atomic store 0) followed by another barrier, then pop_off() to re-enable interrupts. Spinlocks are appropriate for short critical sections where sleeping is impossible (interrupt handlers, scheduler code).",
        "A sleeplock allows a thread to sleep while waiting, unlike a spinlock which busy-waits. struct sleeplock contains: locked (int), lk (spinlock protecting sleeplock state), name, pid. acquiresleep(): acquires the inner spinlock, then while(sl->locked) sleep(&sl->locked, &sl->lk) — sleeping releases the inner spinlock atomically. When woken up, the loop re-checks. Sets sl->locked=1 and sl->pid=myproc()->pid. releasesleep(): acquires inner spinlock, sets sl->locked=0, wakeup(&sl->locked), releases inner spinlock. Use sleeplocks for long operations: disk I/O (buffer sleeplock), inode locking. Sleeplocks CANNOT be used in interrupt context because sleep() is not valid there.",
        "Deadlock occurs when process A holds lock X and waits for Y, while process B holds lock Y and waits for X — circular wait. xv6 prevents deadlock by requiring all code to acquire locks in the SAME global order. Example ordering: bcache.lock → buf->lock (always acquire bcache.lock first). In proc.c: p->lock is acquired BEFORE changing state — the scheduler always acquires p->lock before touching p->state. xv6's initlock() records the lock name for debugging. If you ever need two locks simultaneously, pick a consistent ordering (alphabetical by name, or by memory address: always acquire the lower-address lock first). Holding a lock and calling any function that might acquire the same lock is a guaranteed deadlock.",
        "Spinlocks in xv6 disable interrupts via push_off() on acquire and re-enable via pop_off() on release. This is critical: if an interrupt fires while a spinlock is held, and the interrupt handler tries to acquire the same lock, it will spin forever (the interrupted code can never run to release it). xv6 tracks nesting depth with cpu->noff (number of outstanding push_off calls) and cpu->intena (saved interrupt-enable state). pop_off() only restores interrupts when noff reaches 0. This means: once you call acquire(), the CPU stays interrupt-disabled until the matching release(). Consequence: no sleeping inside spinlock critical sections — sleep() eventually calls sched() which calls swtch(), but switching away from a CPU while holding one of its spinlocks would violate the invariant that spinlocks are released on the same CPU.",
        "Modern CPUs and compilers reorder memory operations for performance. Without barriers, the CPU might execute critical-section code before the lock acquisition, or flush the unlock after critical-section stores. xv6 uses two GCC built-in barriers: __sync_synchronize() inserts a full memory fence — no load or store crosses it in either direction. __sync_lock_test_and_set() is an atomic read-modify-write (RISC-V amoswap.w.aq/rl) with acquire semantics. __sync_lock_release() is an atomic store with release semantics. Together they ensure: all stores inside the critical section are visible to other CPUs before the lock is released, and all loads inside see any stores that happened before lock acquisition."
    ]
    property var cardCodes: [
        "// kernel/spinlock.c\nvoid acquire(struct spinlock *lk) {\n    push_off();  // disable interrupts\n    if(holding(lk)) panic(\"acquire\");\n\n    // Atomic: swap 1 into lk->locked\n    // Loop until we see old value was 0 (free)\n    while(__sync_lock_test_and_set(\n                &lk->locked, 1) != 0)\n        ;  // spin\n\n    // Memory barrier: no code moves above this\n    __sync_synchronize();\n    lk->cpu = mycpu();\n}\nvoid release(struct spinlock *lk) {\n    if(!holding(lk)) panic(\"release\");\n    lk->cpu = 0;\n    __sync_synchronize();  // flush writes\n    __sync_lock_release(&lk->locked); // = 0\n    pop_off();  // re-enable interrupts\n}",
        "// kernel/sleeplock.c\nvoid acquiresleep(struct sleeplock *lk) {\n    acquire(&lk->lk);          // inner spinlock\n    while (lk->locked) {       // already held?\n        sleep(lk, &lk->lk);    // sleep; releases lk->lk\n    }                          // woken: re-check\n    lk->locked = 1;\n    lk->pid = myproc()->pid;\n    release(&lk->lk);\n}\nvoid releasesleep(struct sleeplock *lk) {\n    acquire(&lk->lk);\n    lk->locked = 0;\n    lk->pid = 0;\n    wakeup(lk);                // wake all waiters\n    release(&lk->lk);\n}\n// kernel/buf.h\nstruct buf {\n    struct sleeplock lock;  // per-buffer sleeplock\n    // ...\n};",
        "// CORRECT lock ordering — always bcache.lock first\nvoid bget(uint dev, uint blockno) {\n    acquire(&bcache.lock);   // 1st: global cache lock\n    // ... search/allocate buffer ...\n    acquiresleep(&b->lock);  // 2nd: per-buffer lock\n    release(&bcache.lock);\n    return b;\n}\n// WRONG — would deadlock if another thread\n// already holds bcache.lock and waits for b->lock\nvoid bad() {\n    acquiresleep(&b->lock);  // acquire b->lock FIRST (wrong)\n    acquire(&bcache.lock);   // then bcache.lock → DEADLOCK\n}\n// xv6 global ordering (partial):\n// proc.lock > p->lock > bcache.lock > buf.lock\n// consolelk > tickslock (never reversed)",
        "// kernel/spinlock.c — interrupt nesting\nvoid push_off(void) {\n    int old = intr_get();      // read sstatus.SIE\n    intr_off();                // clear SIE\n    if(mycpu()->noff == 0)     // first acquire?\n        mycpu()->intena = old; // save original state\n    mycpu()->noff += 1;\n}\nvoid pop_off(void) {\n    struct cpu *c = mycpu();\n    if(intr_get()) panic(\"pop_off - interruptible\");\n    if(c->noff < 1) panic(\"pop_off\");\n    c->noff -= 1;\n    if(c->noff == 0 && c->intena)\n        intr_on();  // only restore if outermost\n}\n// Example: nested acquires keep interrupts off\nacquire(&lk1);  // noff=1, intena saved\nacquire(&lk2);  // noff=2, intena unchanged\nrelease(&lk2);  // noff=1, NO interrupt restore yet\nrelease(&lk1);  // noff=0, interrupts restored",
        "// RISC-V atomic instructions in xv6\n// amoswap.w.aq: atomic swap with acquire fence\n//   → no subsequent loads/stores move before it\n// amoswap.w.rl: with release fence\n//   → no prior loads/stores move after it\n\n// GCC built-ins used by xv6:\n__sync_lock_test_and_set(&lk->locked, 1)\n// → amoswap.w.aq t0, t1, (a0)\n//   returns old value; atomically sets to 1\n\n__sync_lock_release(&lk->locked)\n// → amoswap.w.rl x0, x0, (a0)\n//   atomically stores 0, release fence\n\n__sync_synchronize()\n// → fence (full barrier)\n//   ALL prior memory ops visible before ANY\n//   subsequent memory op — in hardware and compiler\n\n// Without these: critical section code could\n// be reordered OUTSIDE the lock by the CPU,\n// breaking mutual exclusion completely."
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
            border.color: Qt.rgba(6,182,212,0.25); border.width: 1
            layer.enabled: true
            layer.effect: Glow { radius:10; samples:17; color:Qt.rgba(6,182,212,0.12); spread:0.1 }
            Row {
                anchors.fill: parent; anchors.margins: 15; spacing: 16
                Rectangle {
                    width: 52; height: 52; radius: 12
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(6,182,212,0.15); border.color: Qt.rgba(6,182,212,0.4); border.width: 1
                    Column {
                        anchors.centerIn: parent; spacing: 1
                        Text { text:"11"; color:"#06b6d4"; font.bold:true; font.pixelSize:20; font.family:"Consolas"; anchors.horizontalCenter:parent.horizontalCenter }
                        Text { text:"LESSON"; color:Qt.rgba(6,182,212,0.5); font.pixelSize:7; font.letterSpacing:1; anchors.horizontalCenter:parent.horizontalCenter }
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 6
                    Text { text:"LOCKS & SYNCHRONIZATION — Spinlocks, Sleeplocks, Deadlock"; color:"#ffffff"; font.family:"Segoe UI"; font.bold:true; font.pixelSize:20; font.letterSpacing:0.5 }
                    Text { text:"How xv6 protects shared data: spinlocks (busy-wait, interrupt-safe), sleeplocks (blocking), lock ordering to avoid deadlock, and memory barriers."; color:Qt.rgba(255,255,255,0.55); font.family:"Segoe UI"; font.pixelSize:12 }
                }
            }
        }

        // ── RACE CONDITION SIMULATOR ─────────────────────────────────────
        Rectangle {
            width: parent.width
            height: raceCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(6,182,212,0.2); border.width: 1

            Column {
                id: raceCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 14

                Row { spacing:10
                    Text{text:"⚡";font.pixelSize:18;anchors.verticalCenter:parent.verticalCenter}
                    Column { spacing:2
                        Text{text:"RACE CONDITION SIMULATOR — what happens when two processes share a counter without a lock";color:"#06b6d4";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3}
                        Text{text:"The classic read-modify-write race: both processes read stale value, both write back, one increment is lost";color:Qt.rgba(255,255,255,0.35);font.pixelSize:11}
                    }
                }

                Row { width:parent.width; spacing:14

                    // Steps panel (left)
                    Column {
                        width:(parent.width-14)*0.52; spacing:10

                        Row { spacing:8
                            Repeater {
                                model: ["NO LOCK (race)", "WITH LOCK (correct)"]
                                delegate: Rectangle {
                                    property bool active: (index===0) === !scrollRoot.lockHeld
                                    width: ((parent.parent.width-8)/2); height:32; radius:8
                                    color: active ? Qt.rgba(6/255,182/255,212/255,0.18) : Qt.rgba(255,255,255,0.03)
                                    border.color: active ? "#06b6d4" : Qt.rgba(255,255,255,0.1); border.width:active?1.5:1
                                    Text { anchors.centerIn:parent; text:modelData; color:active?"#06b6d4":Qt.rgba(255,255,255,0.35); font.bold:true; font.pixelSize:10; font.letterSpacing:0.3 }
                                    MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:{ scrollRoot.lockHeld=(index===1); scrollRoot.raceStep=0; scrollRoot.sharedVal=0; scrollRoot.p0Val=0; scrollRoot.p1Val=0; scrollRoot.raceResult=false } }
                                }
                            }
                        }

                        // Steps
                        Repeater {
                            model: 5
                            delegate: Rectangle {
                                property bool isDone: scrollRoot.raceStep > index
                                property bool isCurr: scrollRoot.raceStep === index
                                property var noLockSteps: ["P0 reads shared → p0_temp = 0","P1 reads shared → p1_temp = 0  (STALE!)","P0 writes back: shared = p0_temp+1 = 1","P1 writes back: shared = p1_temp+1 = 1  ← LOST!","Result: shared=1 (should be 2) — race condition!"]
                                property var lockSteps: ["P0: acquire(lock) → lock granted","P0 reads shared → p0_temp = 0, writes back → shared=1, release(lock)","P1: acquire(lock) → waits (lock busy, P0 holds it)","P0 releases → P1 acquires → reads shared=1, writes back → shared=2","Result: shared=2 ✓ — correct, no race"]
                                width: parent.width; height: Math.max(36, stepText.implicitHeight+16); radius:8
                                color: isCurr ? Qt.rgba(6/255,182/255,212/255,0.12) : isDone ? Qt.rgba(16/255,185/255,129/255,0.08) : Qt.rgba(255,255,255,0.02)
                                border.color: isCurr?"#06b6d4":isDone?"#10b981":Qt.rgba(255,255,255,0.06); border.width:isCurr?1.5:1
                                Row {
                                    anchors.left:parent.left;anchors.leftMargin:12;anchors.right:parent.right;anchors.rightMargin:12;anchors.verticalCenter:parent.verticalCenter;spacing:10
                                    Text { text:isDone?"✓":isCurr?"▶":"○"; color:isDone?"#10b981":isCurr?"#06b6d4":Qt.rgba(255,255,255,0.2); font.pixelSize:11; font.bold:true }
                                    Text { id:stepText; text:scrollRoot.lockHeld?lockSteps[index]:noLockSteps[index]; color:isDone?Qt.rgba(255,255,255,0.5):isCurr?"#ffffff":Qt.rgba(255,255,255,0.3); font.pixelSize:11; font.family:"Consolas"; wrapMode:Text.WordWrap; width:parent.width-30 }
                                }
                            }
                        }

                        Row { spacing:10
                            Rectangle { width:90;height:32;radius:8; color:scrollRoot.raceStep>0?Qt.rgba(6,182,212,0.12):Qt.rgba(255,255,255,0.03); border.color:scrollRoot.raceStep>0?"#06b6d4":Qt.rgba(255,255,255,0.1); border.width:1
                                Text{anchors.centerIn:parent;text:"← PREV";color:scrollRoot.raceStep>0?"#06b6d4":Qt.rgba(255,255,255,0.2);font.bold:true;font.pixelSize:10}
                                MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:if(scrollRoot.raceStep>0)scrollRoot.raceStep--}
                            }
                            Rectangle { width:90;height:32;radius:8; color:scrollRoot.raceStep<5?Qt.rgba(6,182,212,0.12):Qt.rgba(255,255,255,0.03); border.color:scrollRoot.raceStep<5?"#06b6d4":Qt.rgba(255,255,255,0.1); border.width:1
                                Text{anchors.centerIn:parent;text:"NEXT →";color:scrollRoot.raceStep<5?"#06b6d4":Qt.rgba(255,255,255,0.2);font.bold:true;font.pixelSize:10}
                                MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:if(scrollRoot.raceStep<5)scrollRoot.raceStep++}
                            }
                        }
                    }

                    // Result display (right)
                    Rectangle {
                        width:(parent.width-14)*0.48; height:raceResultCol.implicitHeight+28
                        color:Qt.rgba(0,0,0,0.2); radius:12
                        border.color:Qt.rgba(6,182,212,0.2); border.width:1

                        Column {
                            id: raceResultCol
                            anchors.top:parent.top;anchors.topMargin:16
                            anchors.left:parent.left;anchors.leftMargin:16
                            anchors.right:parent.right;anchors.rightMargin:16
                            spacing:12

                            Text { text:"SHARED COUNTER STATE"; color:Qt.rgba(255,255,255,0.3); font.pixelSize:9; font.bold:true; font.letterSpacing:0.8 }

                            Row { spacing:14
                                Column { spacing:4
                                    Text { text:"shared"; color:Qt.rgba(255,255,255,0.3); font.pixelSize:9; font.letterSpacing:0.5 }
                                    Rectangle { width:70;height:42;radius:8; color:Qt.rgba(6/255,182/255,212/255,0.15); border.color:"#06b6d4"; border.width:1
                                        Text { anchors.centerIn:parent; text: {
                                            if(!scrollRoot.lockHeld) {
                                                if(scrollRoot.raceStep<=2) return "0"
                                                if(scrollRoot.raceStep===3) return "1"
                                                return "1 ⚠"
                                            } else {
                                                if(scrollRoot.raceStep<=1) return "0"
                                                if(scrollRoot.raceStep<=3) return "1"
                                                return "2 ✓"
                                            }
                                        } color:"#06b6d4"; font.family:"Consolas"; font.bold:true; font.pixelSize:18 }
                                    }
                                }
                                Column { spacing:4
                                    Text { text:"lock"; color:Qt.rgba(255,255,255,0.3); font.pixelSize:9; font.letterSpacing:0.5 }
                                    Rectangle { width:70;height:42;radius:8
                                        color:scrollRoot.lockHeld&&scrollRoot.raceStep>=1&&scrollRoot.raceStep<=2?Qt.rgba(244/255,63/255,94/255,0.2):Qt.rgba(16/255,185/255,129/255,0.15)
                                        border.color:scrollRoot.lockHeld&&scrollRoot.raceStep>=1&&scrollRoot.raceStep<=2?"#f43f5e":"#10b981"; border.width:1
                                        Text { anchors.centerIn:parent; text:!scrollRoot.lockHeld?"OFF":(scrollRoot.raceStep>=1&&scrollRoot.raceStep<=2?"HELD":"FREE")
                                            color:!scrollRoot.lockHeld?"#f43f5e":(scrollRoot.raceStep>=1&&scrollRoot.raceStep<=2?"#f43f5e":"#10b981")
                                            font.family:"Consolas"; font.bold:true; font.pixelSize:12 }
                                    }
                                }
                            }

                            Rectangle { width:parent.width; height:1; color:Qt.rgba(255,255,255,0.06) }

                            Text {
                                width:parent.width
                                text: scrollRoot.lockHeld
                                    ? "WITH LOCK: P0 reads shared=0, increments, writes back=1. P1 must wait. P1 reads shared=1, writes back=2. Final: 2 ✓ Both increments counted."
                                    : "WITHOUT LOCK: Both P0 and P1 read shared=0 simultaneously. Both compute 0+1=1. Both write back 1. Final: 1 ✗ One increment lost — classic read-modify-write race."
                                color:scrollRoot.lockHeld?Qt.rgba(16,185,129,0.85):Qt.rgba(244,63,94,0.85)
                                wrapMode:Text.WordWrap; font.family:"Segoe UI"; font.pixelSize:11; lineHeight:1.5
                            }

                            Text {
                                width:parent.width
                                text:"xv6 kernel code: uint64 n = shared; n++; shared = n; — three instructions, NOT atomic. Any interrupt between them allows another CPU to see the old value."
                                color:Qt.rgba(255,255,255,0.4); wrapMode:Text.WordWrap; font.family:"Consolas"; font.pixelSize:10; lineHeight:1.5
                            }
                        }
                    }
                }
            }
        }

        // ── ACCORDION — spinlock vs sleeplock theory ─────────────────────
        Rectangle {
            width: parent.width
            height: accordOuter.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.015); radius: 14
            border.color: Qt.rgba(255,255,255,0.07); border.width: 1

            Column {
                id: accordOuter
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 6

                Text { text:"DEEP DIVE — five lock topics, click to expand"; color:Qt.rgba(6,182,212,0.6); font.bold:true; font.pixelSize:11; font.letterSpacing:0.4 }

                Repeater {
                    model: 5
                    delegate: Rectangle {
                        property bool isOpen: scrollRoot.openCard === index
                        width: parent.width
                        height: isOpen ? lockBody.implicitHeight + 84 : 52
                        clip: true; radius: 10
                        color: isOpen ? Qt.rgba(scrollRoot.cardR[index]/255,scrollRoot.cardG[index]/255,scrollRoot.cardB[index]/255,0.07) : Qt.rgba(255,255,255,0.02)
                        border.color: isOpen ? scrollRoot.cardColors[index] : Qt.rgba(scrollRoot.cardR[index]/255,scrollRoot.cardG[index]/255,scrollRoot.cardB[index]/255,0.22)
                        border.width: isOpen ? 1.5 : 1
                        Behavior on height { NumberAnimation { duration:270; easing.type:Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration:160 } }

                        // Header
                        Row {
                            anchors.left:parent.left;anchors.leftMargin:14
                            anchors.right:chevL.left;anchors.rightMargin:8
                            anchors.top:parent.top; height:52; spacing:10
                            Rectangle { width:6;height:6;radius:3;color:scrollRoot.cardColors[index];anchors.verticalCenter:parent.verticalCenter }
                            Column { anchors.verticalCenter:parent.verticalCenter; spacing:3
                                Text { text:scrollRoot.cardTitles[index]; color:isOpen?scrollRoot.cardColors[index]:"#ffffff"; font.bold:true; font.pixelSize:12; font.letterSpacing:0.2; Behavior on color{ColorAnimation{duration:160}} }
                                Text { text:scrollRoot.cardSubs[index]; color:Qt.rgba(255,255,255,0.3); font.pixelSize:9 }
                            }
                        }
                        Text { id:chevL; text:isOpen?"▲":"▼"; color:Qt.rgba(255,255,255,0.3); font.pixelSize:10; anchors.right:parent.right;anchors.rightMargin:14;anchors.top:parent.top;anchors.topMargin:21 }

                        // Body
                        Row {
                            id: lockBody
                            anchors.top:parent.top; anchors.topMargin:58
                            anchors.left:parent.left;anchors.leftMargin:14
                            anchors.right:parent.right;anchors.rightMargin:14
                            spacing:12
                            Column {
                                width:(parent.width-12)*0.40; spacing:10
                                Text { text:scrollRoot.cardSources[index]; color:scrollRoot.cardColors[index]; font.family:"Consolas"; font.pixelSize:10; font.bold:true }
                                Rectangle { width:parent.width; height:1; color:Qt.rgba(255,255,255,0.06) }
                                Text { width:parent.width; text:scrollRoot.cardTheories[index]; color:Qt.rgba(255,255,255,0.78); wrapMode:Text.WordWrap; font.family:"Segoe UI"; font.pixelSize:11; lineHeight:1.55 }
                            }
                            Rectangle {
                                width:(parent.width-12)*0.60; height:lockCode.implicitHeight+32
                                color:Qt.rgba(0,0,0,0.28);radius:9;border.color:Qt.rgba(255,255,255,0.06);border.width:1
                                Rectangle{width:parent.width;height:22;color:Qt.rgba(255,255,255,0.04);radius:9;
                                    Rectangle{width:parent.width;height:11;anchors.bottom:parent.bottom;color:parent.color}
                                    Row{anchors.left:parent.left;anchors.leftMargin:8;anchors.verticalCenter:parent.verticalCenter;spacing:4;Repeater{model:3;delegate:Rectangle{width:7;height:7;radius:3.5;color:["#f43f5e","#fbbf24","#10b981"][index];opacity:0.7}}}
                                    Text{text:scrollRoot.cardSources[index];color:Qt.rgba(255,255,255,0.22);font.pixelSize:9;font.family:"Consolas";anchors.centerIn:parent}
                                }
                                Text { id:lockCode; anchors.top:parent.top;anchors.topMargin:28;anchors.left:parent.left;anchors.leftMargin:10;anchors.right:parent.right;anchors.rightMargin:10; text:scrollRoot.cardCodes[index]; color:Qt.rgba(255,255,255,0.82);font.family:"Consolas";font.pixelSize:10;wrapMode:Text.WrapAtWordBoundaryOrAnywhere;lineHeight:1.5 }
                            }
                        }
                        MouseArea { anchors.left:parent.left;anchors.right:parent.right;anchors.top:parent.top;height:52;cursorShape:Qt.PointingHandCursor;onClicked:scrollRoot.openCard=isOpen?-1:index }
                    }
                }
            }
        }

        // ── SPINLOCK vs SLEEPLOCK COMPARISON ─────────────────────────────
        Rectangle {
            width: parent.width; height: cmpCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(6,182,212,0.18); border.width: 1

            Column {
                id: cmpCol
                anchors.top:parent.top;anchors.topMargin:18;anchors.left:parent.left;anchors.leftMargin:18;anchors.right:parent.right;anchors.rightMargin:18
                spacing:14

                Row { spacing:10
                    Text{text:"⚖️";font.pixelSize:18;anchors.verticalCenter:parent.verticalCenter}
                    Column{spacing:2
                        Text{text:"SPINLOCK vs SLEEPLOCK — when to use each";color:"#06b6d4";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3}
                        Text{text:"Choosing the wrong type leads to deadlock or wasted CPU cycles";color:Qt.rgba(255,255,255,0.35);font.pixelSize:11}
                    }
                }

                Row { width:parent.width; spacing:10
                    Rectangle { width:(parent.width-10)*0.5; height:spinCol.implicitHeight+20; color:Qt.rgba(6/255,182/255,212/255,0.07); radius:10; border.color:Qt.rgba(6/255,182/255,212/255,0.3); border.width:1.5
                        Column { id:spinCol; anchors.top:parent.top;anchors.topMargin:14;anchors.left:parent.left;anchors.leftMargin:14;anchors.right:parent.right;anchors.rightMargin:14; spacing:8
                            Row{spacing:8;Rectangle{width:8;height:8;radius:4;color:"#06b6d4";anchors.verticalCenter:parent.verticalCenter}Text{text:"SPINLOCK";color:"#06b6d4";font.bold:true;font.pixelSize:12;font.letterSpacing:0.4}}
                            Repeater { model:["✓ Interrupt context (ISRs) — can't sleep","✓ Very short critical sections (< μs)","✓ Scheduler code — must not context-switch","✓ When holding across CPU cores only","✗ NEVER hold across blocking operations","✗ NEVER call sleep() while holding spinlock","✗ Wastes CPU if contended for long time","Examples: bcache.lock, ptable.lock, consolelk"]
                                delegate:Row{spacing:8;Text{text:modelData.startsWith("✗")?"✗":modelData.startsWith("✓")?"✓":"·";color:modelData.startsWith("✗")?"#f43f5e":modelData.startsWith("✓")?"#10b981":"#fbbf24";font.pixelSize:11;font.bold:true}Text{text:modelData.substring(2);color:Qt.rgba(255,255,255,0.65);font.pixelSize:11;wrapMode:Text.WordWrap;width:parent.parent.width-30}}
                            }
                        }
                    }
                    Rectangle { width:(parent.width-10)*0.5; height:sleepCol.implicitHeight+20; color:Qt.rgba(139/255,92/255,246/255,0.07); radius:10; border.color:Qt.rgba(139/255,92/255,246/255,0.3); border.width:1.5
                        Column { id:sleepCol; anchors.top:parent.top;anchors.topMargin:14;anchors.left:parent.left;anchors.leftMargin:14;anchors.right:parent.right;anchors.rightMargin:14; spacing:8
                            Row{spacing:8;Rectangle{width:8;height:8;radius:4;color:"#8b5cf6";anchors.verticalCenter:parent.verticalCenter}Text{text:"SLEEPLOCK";color:"#8b5cf6";font.bold:true;font.pixelSize:12;font.letterSpacing:0.4}}
                            Repeater { model:["✓ Long operations: disk I/O, file read/write","✓ When contention causes significant wait","✓ Any code that may call sleep() inside","✓ Per-inode lock (struct inode.lock)","✓ Per-buffer lock (struct buf.lock)","✗ NEVER in interrupt handlers","✗ Heavier — inner spinlock overhead","Examples: buf.lock (bread/bwrite), inode.lock"]
                                delegate:Row{spacing:8;Text{text:modelData.startsWith("✗")?"✗":modelData.startsWith("✓")?"✓":"·";color:modelData.startsWith("✗")?"#f43f5e":modelData.startsWith("✓")?"#10b981":"#fbbf24";font.pixelSize:11;font.bold:true}Text{text:modelData.substring(2);color:Qt.rgba(255,255,255,0.65);font.pixelSize:11;wrapMode:Text.WordWrap;width:parent.parent.width-30}}
                            }
                        }
                    }
                }
            }
        }

        // ── FOOTER ──────────────────────────────────────────────────────

        // ── DEADLOCK SIMULATOR ──────────────────────────────────────────
        Rectangle {
            id: lockSim
            width:parent.width; height:dlCol.implicitHeight+32
            color:Qt.rgba(255,255,255,0.015); radius:14
            border.color:Qt.rgba(244,63,94,0.2); border.width:1

            property bool lockAheldBy1: false
            property bool lockBheldBy1: false
            property bool lockAheldBy2: false
            property bool lockBheldBy2: false
            property var log: []
            property bool deadlocked: false
            property bool safeOrder: true

            function addLog(msg, color) {
                var l=log.slice(); l.unshift({msg:msg,color:color}); if(l.length>8) l.pop(); log=l
            }

            function p1AcquireA() {
                if(lockAheldBy2){addLog("P1 → acquire(lockA): BLOCKED — held by P2",  "#f43f5e"); checkDeadlock(); return}
                if(lockAheldBy1){addLog("P1 → acquire(lockA): already held",  "#fbbf24"); return}
                lockAheldBy1=true; addLog("P1 → acquire(lockA): OK ✓", "#10b981")
            }
            function p1AcquireB() {
                if(lockBheldBy2){addLog("P1 → acquire(lockB): BLOCKED — held by P2", "#f43f5e"); checkDeadlock(); return}
                if(lockBheldBy1){addLog("P1 → acquire(lockB): already held", "#fbbf24"); return}
                lockBheldBy1=true; addLog("P1 → acquire(lockB): OK ✓", "#10b981")
            }
            function p2AcquireB() {
                if(lockBheldBy1){addLog("P2 → acquire(lockB): BLOCKED — held by P1", "#f43f5e"); checkDeadlock(); return}
                if(lockBheldBy2){addLog("P2 → acquire(lockB): already held", "#fbbf24"); return}
                lockBheldBy2=true; addLog("P2 → acquire(lockB): OK ✓", "#10b981")
            }
            function p2AcquireA() {
                if(lockAheldBy1){addLog("P2 → acquire(lockA): BLOCKED — held by P1", "#f43f5e"); checkDeadlock(); return}
                if(lockAheldBy2){addLog("P2 → acquire(lockA): already held", "#fbbf24"); return}
                lockAheldBy2=true; addLog("P2 → acquire(lockA): OK ✓", "#10b981")
            }
            function p1Release() { lockAheldBy1=false; lockBheldBy1=false; deadlocked=false; addLog("P1 → release all locks", "#a78bfa") }
            function p2Release() { lockAheldBy2=false; lockBheldBy2=false; deadlocked=false; addLog("P2 → release all locks", "#a78bfa") }
            function checkDeadlock() {
                if((lockAheldBy1 && lockBheldBy2) || (lockBheldBy1 && lockAheldBy2))
                    { deadlocked=true; addLog("☠ DEADLOCK DETECTED — circular wait!", "#f43f5e") }
            }
            function resetAll() { lockAheldBy1=false; lockBheldBy1=false; lockAheldBy2=false; lockBheldBy2=false; deadlocked=false; log=[] }

            Column {
                id:dlCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing:14

                Row { spacing:10
                    Text { text:"🔒"; font.pixelSize:18; anchors.verticalCenter:parent.verticalCenter }
                    Column { spacing:2
                        Text { text:"DEADLOCK SIMULATOR — two processes, two locks"; color:"#f43f5e"; font.bold:true; font.pixelSize:13 }
                        Text { text:"Acquire in opposite order to trigger deadlock. Same order to stay safe."; color:Qt.rgba(255,255,255,0.32); font.pixelSize:11 }
                    }
                }

                // Deadlock warning
                Rectangle {
                    width:parent.width; height:32; radius:8; visible:lockSim.deadlocked
                    color:Qt.rgba(244/255,63/255,94/255,0.2); border.color:"#f43f5e"; border.width:1
                    Text { anchors.centerIn:parent; text:"☠  DEADLOCK — both processes are waiting forever. Only option: kernel panic or lock timeout."; color:"#f43f5e"; font.bold:true; font.pixelSize:11 }
                }

                // Lock status row
                Row { spacing:20; width:parent.width; height:52
                    Repeater { model:[{name:"lockA",color:"#a78bfa"},{name:"lockB",color:"#06b6d4"}]
                        delegate: Rectangle { width:(parent.width-20)/2; height:52; radius:10; border.width:1
                            property bool heldBy1: modelData.name==="lockA"?lockSim.lockAheldBy1:lockSim.lockBheldBy1
                            property bool heldBy2: modelData.name==="lockA"?lockSim.lockAheldBy2:lockSim.lockBheldBy2
                            color:heldBy1||heldBy2?Qt.rgba(0,0,0,0.2):Qt.rgba(255,255,255,0.02)
                            border.color:heldBy1?modelData.color:heldBy2?"#ec4899":Qt.rgba(255,255,255,0.1)
                            Row { anchors.centerIn:parent; spacing:12
                                Text { text:modelData.name; color:modelData.color; font.bold:true; font.pixelSize:14; font.family:"Consolas" }
                                Text {
                                    text: lockSim.heldBy1&&lockSim.heldBy2?"ERR":lockSim.heldBy1?"held by P1":lockSim.heldBy2?"held by P2":"FREE"
                                    color:lockSim.heldBy1?"#a78bfa":lockSim.heldBy2?"#ec4899":"#10b981"
                                    font.pixelSize:12; font.bold:true
                                }
                            }
                        }
                    }
                }

                // Process button panels
                Row { spacing:12; width:parent.width
                    // P1 panel
                    Rectangle { width:(parent.width-12)/2; height:p1col.implicitHeight+20; radius:10; color:Qt.rgba(139/255,92/255,246/255,0.08); border.color:"#a78bfa"; border.width:1
                        Column { id:p1col; anchors.top:parent.top; anchors.topMargin:12; anchors.left:parent.left; anchors.leftMargin:12; anchors.right:parent.right; anchors.rightMargin:12; spacing:8
                            Text { text:"PROCESS 1"; color:"#a78bfa"; font.bold:true; font.pixelSize:12 }
                            Row { spacing:6
                                Rectangle { height:30; width:p1a.implicitWidth+16; radius:8; color:Qt.rgba(139/255,92/255,246/255,0.15); border.color:"#a78bfa"; border.width:1
                                    Text { id:p1a; anchors.centerIn:parent; text:"acquire(lockA)"; color:"#a78bfa"; font.pixelSize:10; font.family:"Consolas" }
                                    MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:lockSim.p1AcquireA() }
                                }
                                Rectangle { height:30; width:p1b.implicitWidth+16; radius:8; color:Qt.rgba(6/255,182/255,212/255,0.1); border.color:"#06b6d4"; border.width:1
                                    Text { id:p1b; anchors.centerIn:parent; text:"acquire(lockB)"; color:"#06b6d4"; font.pixelSize:10; font.family:"Consolas" }
                                    MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:lockSim.p1AcquireB() }
                                }
                            }
                            Rectangle { height:28; width:p1rel.implicitWidth+16; radius:8; color:Qt.rgba(255,255,255,0.04); border.color:Qt.rgba(255,255,255,0.1); border.width:1
                                Text { id:p1rel; anchors.centerIn:parent; text:"release all"; color:Qt.rgba(255,255,255,0.35); font.pixelSize:10 }
                                MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:lockSim.p1Release() }
                            }
                        }
                    }
                    // P2 panel
                    Rectangle { width:(parent.width-12)/2; height:p2col.implicitHeight+20; radius:10; color:Qt.rgba(236/255,72/255,153/255,0.08); border.color:"#ec4899"; border.width:1
                        Column { id:p2col; anchors.top:parent.top; anchors.topMargin:12; anchors.left:parent.left; anchors.leftMargin:12; anchors.right:parent.right; anchors.rightMargin:12; spacing:8
                            Text { text:"PROCESS 2"; color:"#ec4899"; font.bold:true; font.pixelSize:12 }
                            Row { spacing:6
                                Rectangle { height:30; width:p2b.implicitWidth+16; radius:8; color:Qt.rgba(6/255,182/255,212/255,0.1); border.color:"#06b6d4"; border.width:1
                                    Text { id:p2b; anchors.centerIn:parent; text:"acquire(lockB)"; color:"#06b6d4"; font.pixelSize:10; font.family:"Consolas" }
                                    MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:lockSim.p2AcquireB() }
                                }
                                Rectangle { height:30; width:p2a.implicitWidth+16; radius:8; color:Qt.rgba(139/255,92/255,246/255,0.15); border.color:"#a78bfa"; border.width:1
                                    Text { id:p2a; anchors.centerIn:parent; text:"acquire(lockA)"; color:"#a78bfa"; font.pixelSize:10; font.family:"Consolas" }
                                    MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:lockSim.p2AcquireA() }
                                }
                            }
                            Rectangle { height:28; width:p2rel.implicitWidth+16; radius:8; color:Qt.rgba(255,255,255,0.04); border.color:Qt.rgba(255,255,255,0.1); border.width:1
                                Text { id:p2rel; anchors.centerIn:parent; text:"release all"; color:Qt.rgba(255,255,255,0.35); font.pixelSize:10 }
                                MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:lockSim.p2Release() }
                            }
                        }
                    }
                }

                // Event log
                Column { spacing:4; width:parent.width
                    Row { spacing:10; width:parent.width
                        Text { text:"EVENT LOG"; color:Qt.rgba(255,255,255,0.25); font.pixelSize:9; font.letterSpacing:1; anchors.verticalCenter:parent.verticalCenter }
                        Rectangle { height:22; width:rstDl.implicitWidth+14; radius:6; color:Qt.rgba(255,255,255,0.04); border.color:Qt.rgba(255,255,255,0.1); border.width:1
                            Text { id:rstDl; anchors.centerIn:parent; text:"↺ reset"; color:Qt.rgba(255,255,255,0.3); font.pixelSize:9 }
                            MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:lockSim.resetAll() }
                        }
                    }
                    Repeater { model:lockSim.log
                        delegate: Text { text:"  "+modelData.msg; color:modelData.color; font.pixelSize:10; font.family:"Consolas"; width:parent.width; wrapMode:Text.WordWrap }
                    }
                }
            }
        }

        Rectangle {
            width:parent.width; height:65
            color:Qt.rgba(6/255,182/255,212/255,0.08); radius:14
            border.color:Qt.rgba(6/255,182/255,212/255,0.35); border.width:1
            RowLayout {
                anchors.fill:parent; anchors.margins:15; spacing:15
                Text{text:"🌟";font.pixelSize:22;Layout.alignment:Qt.AlignVCenter}
                Text { Layout.fillWidth:true; Layout.alignment:Qt.AlignVCenter
                    text:"CORE SUMMARY: Spinlock = busy-wait + disable interrupts (push_off/pop_off), use for short sections + ISRs. Sleeplock = sleep while waiting + inner spinlock, use for long blocking ops (disk I/O). Both use __sync_synchronize() memory barriers. Lock ordering prevents deadlock — always acquire in the same global order. Never hold a spinlock while calling sleep()."
                    color:"#ffffff"; wrapMode:Text.WordWrap; font.family:"Segoe UI"; font.bold:true; font.pixelSize:12; font.letterSpacing:0.2
                }
            }
        }


        // ── MARK AS ATTENDED BUTTON ──────────────────────────────────────
        Rectangle {
            id: attendBtn
            width: parent.width; height: 52; radius: 14
            property bool done: false
            Component.onCompleted: {
                var user = dbManager.getCurrentUser()
                done = dbManager.isAttended(user, "LocksPage.qml")
            }
            color: done ? Qt.rgba(16,185,129,0.12) : (attendMouse.containsMouse ? Qt.rgba(16,185,129,0.18) : Qt.rgba(16,185,129,0.07))
            border.color: done ? "#10b981" : Qt.rgba(16,185,129,0.4); border.width: 1
            Behavior on color { ColorAnimation { duration: 180 } }
            Row {
                anchors.centerIn: parent; spacing: 10
                Text { text: attendBtn.done ? "✅" : "☑"; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: attendBtn.done ? "Lesson marked as attended" : "Mark as Attended"
                    color: attendBtn.done ? "#10b981" : Qt.rgba(255,255,255,0.25); font.bold: true; font.pixelSize: 13; font.family: "Segoe UI"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            MouseArea {
                id: attendMouse; anchors.fill: parent; hoverEnabled: true
                cursorShape: attendBtn.done ? Qt.ArrowCursor : Qt.PointingHandCursor
                onClicked: {
                    if (!attendBtn.done) {
                        var user = dbManager.getCurrentUser()
                        dbManager.markAttended(user, "LocksPage.qml")
                        attendBtn.done = true
                        scrollRoot.attendanceChanged()
                    }
                }
            }
        }
        // ── TAKE QUIZ BUTTON ────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 52; radius: 14
            color: !attendBtn.done ? Qt.rgba(255,255,255,0.02) : (quizNavBtn.containsMouse ? Qt.rgba(255,255,255,0.10) : Qt.rgba(255,255,255,0.04))
            border.color: "#f59e0b"; border.width: 1
            Behavior on color { ColorAnimation { duration: 180 } }
            Text {
                anchors.centerIn: parent
                text: "QUIZ  →  LOCKS"
                color: "#f59e0b"; font.bold: true; font.pixelSize: 13
                font.family: "Segoe UI"; font.letterSpacing: 0.4
            }
            MouseArea {
                id: quizNavBtn; anchors.fill: parent; hoverEnabled: true
                cursorShape: attendBtn.done ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                onClicked: if (attendBtn.done) scrollRoot.requestNavigate("LocksQuizPage.qml")
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
                Text { text: "→  PIPES & FILE DESC"; color: attendBtn.done ? "#8b5cf6" : Qt.rgba(255,255,255,0.25); font.bold: true; font.pixelSize: 13; font.family: "Segoe UI"; font.letterSpacing: 0.4; anchors.verticalCenter: parent.verticalCenter }
            }
            MouseArea {
                id: nextBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: scrollRoot.requestNavigate("PipesPage.qml")
            }
        }
    }
}
