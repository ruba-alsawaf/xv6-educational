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

    // ── State machine simulation ─────────────────────────────────────
    // 0=UNUSED, 1=USED, 2=SLEEPING, 3=RUNNABLE, 4=RUNNING, 5=ZOMBIE
    property int proc0State: 4   // P0 starts RUNNING
    property int proc1State: 3   // P1 RUNNABLE
    property int proc2State: 2   // P2 SLEEPING
    property int proc3State: 5   // P3 ZOMBIE

    property var stateNames:  ["UNUSED","USED","SLEEPING","RUNNABLE","RUNNING","ZOMBIE"]
    property var stateColors: ["#374151","#6b7280","#3b82f6","#10b981","#8b5cf6","#f43f5e"]
    property var stateDescs: [
        "Slot is free. No process allocated here. The proc table has NPROC=64 slots; unused ones wait for allocproc().",
        "Slot allocated by allocproc(), initial setup in progress. Not yet runnable.",
        "Process is blocked waiting for an event (e.g. disk I/O, pipe read, sleep()). Removed from scheduler consideration until wakeup(chan) is called.",
        "Process is ready to run. scheduler() will pick it up on the next scheduling cycle.",
        "Currently executing on a CPU. There is exactly one RUNNING process per CPU core at any moment.",
        "Process has exited (called exit()). Parent has not yet called wait(). Kernel resources kept alive so parent can read exit status."
    ]

    // ── swtch animation ────────────────────────────────────────────────
    property real switchDot: 0.0
    property int  activePhase: 0  // 0=RUNNING, 1=YIELDING, 2=SCHED, 3=SWTCH, 4=SCHEDULER, 5=NEW_PROC

    Timer {
        interval: 30; running: true; repeat: true
        onTriggered: {
            scrollRoot.switchDot = (scrollRoot.switchDot + 0.005) % 1.0
            var t = scrollRoot.switchDot
            if(t < 0.15)       scrollRoot.activePhase = 0
            else if(t < 0.28)  scrollRoot.activePhase = 1
            else if(t < 0.42)  scrollRoot.activePhase = 2
            else if(t < 0.60)  scrollRoot.activePhase = 3
            else if(t < 0.78)  scrollRoot.activePhase = 4
            else               scrollRoot.activePhase = 5
        }
    }

    // ── swtch deep-dive steps ─────────────────────────────────────────
    property int swtchStep: 0
    property var swtchTitles: ["OVERVIEW — what swtch() does","SAVING context: callee-saved registers","swtch() restores scheduler's context","Scheduler picks next RUNNABLE process","swtch() back into new process","Timer interrupt triggers preemption"]
    property var swtchDescs: [
        "swtch(old, new) is a 24-instruction RISC-V assembly routine that switches CPU execution context. It does NOT save/restore the program counter — instead it manipulates the return address (ra). When process A calls swtch(&p->context, &c->context), execution 'disappears' from A and 'reappears' in the scheduler loop, which previously called swtch(&c->context, &p->context). The magic: swtch() saves ra (return address) as part of the old context, then restores ra from the new context before returning — so 'return' jumps to the saved PC of the new context.",
        "RISC-V calling convention divides registers: caller-saved (a0-a7, t0-t6) are saved by the caller before any function call. Callee-saved (s0-s11, ra, sp) are saved by the callee if it uses them. swtch() only saves/restores callee-saved registers because: (1) swtch is called as a C function, so the caller (yield, sleep, scheduler) has already saved caller-saved registers on the stack. (2) After swtch returns in the new context, execution continues as if that swtch call returned — the caller-saved registers of the new context's caller are on the new stack, which sp now points to.",
        "After swtch() stores the old process's ra+sp+s0-s11 into old->context, it loads ra+sp+s0-s11 from new->context. The final 'ret' instruction jumps to the restored ra — which is the address inside scheduler() right after its swtch() call. The scheduler's sp is now the scheduler stack (one per CPU, separate from any process). The scheduler loop continues: it releases p->lock (it held it for the switch), then searches for the next RUNNABLE process.",
        "The scheduler() loop (kernel/proc.c) runs on a dedicated per-CPU stack. It holds no locks at the top of the loop. For each proc slot it acquires p->lock and checks p->state == RUNNABLE. When found: sets p->state = RUNNING, sets c->proc = p, calls swtch(&c->context, &p->context). This call does NOT return until the process later calls swtch back into the scheduler. The scheduler never directly executes user code — it's always context-switched into a process.",
        "swtch(&c->context, &p->context) restores ra to wherever in the process's kernel code it last called swtch(). That's always one of: (a) yield() → sched() → swtch, which means it returns into sched(), which returns into yield(), which returns into usertrap(), which calls usertrapret() → back to user. Or: (b) sleep() → sched() → swtch, returns into sleep() which checks the condition and possibly loops. Or: (c) first run — allocproc() set context.ra = forkret, so the first swtch into a new process jumps to forkret(), which releases ptable lock then calls usertrapret().",
        "Timer interrupts are how xv6 preempts CPU-bound processes. The machine-mode timer handler (kernel/kernelvec.S) increments a count; when it reaches threshold, it raises a software interrupt (SSIP bit). In usertrap()/kerneltrap(), if which_dev==2 (timer), yield() is called. yield() acquires p->lock, sets p->state=RUNNABLE, calls sched() → swtch() → scheduler. Result: the running process becomes RUNNABLE and the scheduler picks the next one. xv6 uses round-robin among RUNNABLE processes (no priority)."
    ]
    property var swtchCodes: [
        "# kernel/swtch.S — full routine (24 lines)\nswtch:\n    # save old context (a0 = &old)\n    sd ra,  0(a0)\n    sd sp,  8(a0)\n    sd s0, 16(a0)  # ... s1-s11 follow\n    sd s11,96(a0)\n\n    # restore new context (a1 = &new)\n    ld ra,  0(a1)\n    ld sp,  8(a1)\n    ld s0, 16(a1)  # ... s1-s11 follow\n    ld s11,96(a1)\n    ret            # jumps to restored ra",
        "# kernel/proc.h\nstruct context {\n    uint64 ra;        // return address\n    uint64 sp;        // stack pointer\n    // callee-saved registers s0-s11\n    uint64 s0;  uint64 s1;  uint64 s2;\n    uint64 s3;  uint64 s4;  uint64 s5;\n    uint64 s6;  uint64 s7;  uint64 s8;\n    uint64 s9;  uint64 s10; uint64 s11;\n};\n// struct proc also has trapframe (different!)\n// context = kernel-side saved state\n// trapframe = user-side saved state (all regs)",
        "// kernel/proc.c\nvoid sched(void) {\n    struct proc *p = myproc();\n    // must hold p->lock, not other locks\n    if(!holding(&p->lock)) panic(\"sched p->lock\");\n    if(mycpu()->noff != 1) panic(\"sched locks\");\n    if(p->state == RUNNING) panic(\"sched running\");\n    if(intr_get()) panic(\"sched interruptible\");\n    int intena = mycpu()->intena;\n    // SWITCH: process → scheduler\n    swtch(&p->context, &mycpu()->context);\n    mycpu()->intena = intena;  // restored here\n}",
        "// kernel/proc.c\nvoid scheduler(void) {\n    struct cpu *c = mycpu();\n    c->proc = 0;\n    for(;;) {\n        intr_on();  // enable interrupts\n        for(struct proc *p = proc; p < &proc[NPROC]; p++) {\n            acquire(&p->lock);\n            if(p->state == RUNNABLE) {\n                p->state = RUNNING;\n                c->proc  = p;\n                // SWITCH: scheduler → process\n                swtch(&c->context, &p->context);\n                // Returns here after process yields/sleeps/exits\n                c->proc = 0;\n            }\n            release(&p->lock);\n        }\n    }\n}",
        "// kernel/proc.c — allocproc sets up first switch target\nstatic struct proc* allocproc(void) {\n    // ... find free slot, set state=USED ...\n    // Set up kernel stack + trapframe\n    p->context.ra = (uint64)forkret;  // <-- first switch lands here\n    p->context.sp = p->kstack + PGSIZE;\n    return p;\n}\n// forkret() runs after FIRST switch into a new process:\nvoid forkret(void) {\n    static int first = 1;\n    release(&myproc()->lock);    // release lock scheduler held\n    if(first) { first=0; fsinit(ROOTDEV); }\n    usertrapret();  // → back to user space\n}",
        "// kernel/proc.c — yield() called on timer interrupt\nvoid yield(void) {\n    struct proc *p = myproc();\n    acquire(&p->lock);\n    p->state = RUNNABLE;  // give up CPU\n    sched();              // switch to scheduler\n    release(&p->lock);\n}\n\n// kernel/trap.c — in usertrap() and kerneltrap()\nif(which_dev == 2) {  // timer interrupt\n    if(myproc() != 0 && myproc()->state == RUNNING)\n        yield();\n}"
    ]

    // ── sleep/wakeup data ─────────────────────────────────────────────
    property int sleepPanel: 0

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
            border.color: Qt.rgba(244,63,94,0.25); border.width: 1
            layer.enabled: true
            layer.effect: Glow { radius:10; samples:17; color:Qt.rgba(244,63,94,0.12); spread:0.1 }
            Row {
                anchors.fill: parent; anchors.margins: 15; spacing: 16
                Rectangle {
                    width: 52; height: 52; radius: 12
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(244,63,94,0.15); border.color: Qt.rgba(244,63,94,0.4); border.width: 1
                    Column {
                        anchors.centerIn: parent; spacing: 1
                        Text { text:"09"; color:"#f43f5e"; font.bold:true; font.pixelSize:20; font.family:"Consolas"; anchors.horizontalCenter:parent }
                        Text { text:"LESSON"; color:Qt.rgba(244,63,94,0.5); font.pixelSize:7; font.letterSpacing:1; anchors.horizontalCenter:parent }
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 6
                    Text {
                        text: "CONTEXT SWITCH — swtch(), Scheduler, and Process States"
                        color: "#ffffff"; font.family:"Segoe UI"; font.bold:true; font.pixelSize:20; font.letterSpacing:0.5
                    }
                    Text {
                        text: "How xv6 switches between processes: the swtch() assembly routine, scheduler loop, process state machine, yield/sleep/wakeup, and timer-driven preemption."
                        color: Qt.rgba(255,255,255,0.55); font.family:"Segoe UI"; font.pixelSize:12
                    }
                }
            }
        }

        // ── PROCESS STATE MACHINE ────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: stateMachCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(244,63,94,0.15); border.width: 1

            Column {
                id: stateMachCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 14

                Text { text:"PROCESS STATE MACHINE — every xv6 process is always in one of these states"; color:Qt.rgba(244,63,94,0.7); font.bold:true; font.pixelSize:12; font.letterSpacing:0.4 }

                // Process simulator
                Row {
                    width: parent.width; spacing: 10

                    // Left: 4 process tiles
                    Column {
                        width: parent.width * 0.44; spacing: 8

                        Text { text:"SIMULATE — click tiles to change state"; color:Qt.rgba(255,255,255,0.25); font.pixelSize:9; font.letterSpacing:0.5; leftPadding:4 }

                        Repeater {
                            model: 4
                            delegate: Rectangle {
                                property int pState: [scrollRoot.proc0State, scrollRoot.proc1State, scrollRoot.proc2State, scrollRoot.proc3State][index]
                                width: parent.width; height: 48; radius: 9
                                color: Qt.rgba(scrollRoot.stateColors[pState] === "#374151" ? 55/255 : 0,0,0,0)
                                border.color: Qt.rgba(0,0,0,0)
                                Rectangle {
                                    anchors.fill:parent; radius:9
                                    color: {
                                        if(pState===0) return Qt.rgba(55/255,65/255,81/255,0.15)
                                        if(pState===1) return Qt.rgba(107/255,114/255,128/255,0.15)
                                        if(pState===2) return Qt.rgba(59/255,130/255,246/255,0.15)
                                        if(pState===3) return Qt.rgba(16/255,185/255,129/255,0.15)
                                        if(pState===4) return Qt.rgba(139/255,92/255,246/255,0.15)
                                        return Qt.rgba(244/255,63/255,94/255,0.15)
                                    }
                                    border.color: scrollRoot.stateColors[pState]; border.width: 1.5
                                    Behavior on color { ColorAnimation { duration:200 } }
                                }
                                Row {
                                    anchors.left:parent.left;anchors.leftMargin:12
                                    anchors.right:parent.right;anchors.rightMargin:12
                                    anchors.verticalCenter:parent.verticalCenter; spacing:10
                                    Rectangle {
                                        width:8;height:8;radius:4;anchors.verticalCenter:parent.verticalCenter
                                        color:scrollRoot.stateColors[pState]
                                        SequentialAnimation on opacity { running:pState===4; loops:Animation.Infinite
                                            NumberAnimation{to:0.2;duration:500} NumberAnimation{to:1;duration:500}
                                        }
                                    }
                                    Text { text:"P"+index; color:Qt.rgba(255,255,255,0.5); font.family:"Consolas"; font.bold:true; font.pixelSize:13 }
                                    Text { text:scrollRoot.stateNames[pState]; color:scrollRoot.stateColors[pState]; font.bold:true; font.pixelSize:12; font.letterSpacing:0.3 }
                                }
                                MouseArea {
                                    anchors.fill:parent; cursorShape:Qt.PointingHandCursor
                                    onClicked: {
                                        var ns = (pState+1) % 6
                                        if(index===0) scrollRoot.proc0State=ns
                                        else if(index===1) scrollRoot.proc1State=ns
                                        else if(index===2) scrollRoot.proc2State=ns
                                        else scrollRoot.proc3State=ns
                                    }
                                }
                            }
                        }
                    }

                    // Right: state description
                    Rectangle {
                        width: parent.width * 0.56 - 10
                        height: stateDescCol.implicitHeight + 24
                        color: Qt.rgba(0,0,0,0.18); radius: 12
                        border.color: Qt.rgba(244,63,94,0.2); border.width: 1

                        Column {
                            id: stateDescCol
                            anchors.top:parent.top;anchors.topMargin:16
                            anchors.left:parent.left;anchors.leftMargin:16
                            anchors.right:parent.right;anchors.rightMargin:16
                            spacing:10

                            Text{text:"STATE TRANSITIONS";color:Qt.rgba(244,63,94,0.6);font.bold:true;font.pixelSize:10;font.letterSpacing:0.8}

                            Repeater {
                                model: [
                                    ["UNUSED → USED","allocproc() finds a free slot"],
                                    ["USED → RUNNABLE","fork()/userinit() finishes setup, sets state=RUNNABLE"],
                                    ["RUNNABLE → RUNNING","scheduler() picks process, calls swtch()"],
                                    ["RUNNING → RUNNABLE","yield() called (timer interrupt) — gives up CPU voluntarily"],
                                    ["RUNNING → SLEEPING","sleep(chan, lk) — waiting for event, chan = wait address"],
                                    ["SLEEPING → RUNNABLE","wakeup(chan) — event occurred, finds all sleepers on chan"],
                                    ["RUNNING → ZOMBIE","exit() called — sets state=ZOMBIE, wakes parent"],
                                    ["ZOMBIE → UNUSED","wait() in parent frees resources, slot becomes UNUSED"]
                                ]
                                delegate: Row {
                                    spacing:8; width:parent.width
                                    Rectangle{width:6;height:6;radius:3;color:"#f43f5e";anchors.verticalCenter:parent.verticalCenter}
                                    Column{spacing:2
                                        Text{text:modelData[0];color:"#f87171";font.family:"Consolas";font.bold:true;font.pixelSize:10}
                                        Text{text:modelData[1];color:Qt.rgba(255,255,255,0.5);font.pixelSize:10;wrapMode:Text.WordWrap;width:parent.parent.parent.width-20}
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── LIVE SWITCH ANIMATION CANVAS ─────────────────────────────────
        Rectangle {
            width: parent.width; height: 180
            color: Qt.rgba(255,255,255,0.02); radius: 14
            border.color: Qt.rgba(139,92,246,0.18); border.width: 1

            Text {
                text:"LIVE — CPU executes process A → timer fires → scheduler → process B"
                color:Qt.rgba(139,92,246,0.55); font.pixelSize:10; font.bold:true; font.letterSpacing:0.6
                anchors.top:parent.top; anchors.topMargin:9; anchors.horizontalCenter:parent.horizontalCenter
            }

            Canvas {
                id: switchCanvas
                anchors.fill: parent
                property real dot: scrollRoot.switchDot
                property int  phase: scrollRoot.activePhase
                onDotChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d"); ctx.reset()
                    var w=width, h=height
                    var t = dot

                    // boxes: [PROC A kernel stack, yield(), sched(), swtch(), scheduler(), PROC B kernel]
                    var labels = ["Process A\n(running)","yield()","sched()","swtch()","scheduler()","Process B\n(runnable)"]
                    var bW=w*0.11, bH=42, bY=h*0.55
                    var cx=[w*0.08,w*0.24,w*0.38,w*0.52,w*0.68,w*0.88]
                    var bR=[139,249,16,251,59,16]; var bG=[92,115,185,191,130,185]; var bB=[246,22,129,36,246,129]

                    var phaseColors=[[139,92,246],[249,115,22],[16,185,129],[251,191,36],[59,130,246],[16,185,129]]

                    // draw arrows
                    ctx.lineWidth=1.5
                    for(var i=0;i<5;i++){
                        var x1=cx[i]+bW/2+3, x2=cx[i+1]-bW/2-3
                        ctx.strokeStyle="rgba(255,255,255,0.12)"
                        ctx.beginPath(); ctx.moveTo(x1,bY); ctx.lineTo(x2,bY); ctx.stroke()
                        ctx.fillStyle="rgba(255,255,255,0.12)"
                        ctx.beginPath(); ctx.moveTo(x2-6,bY-3); ctx.lineTo(x2,bY); ctx.lineTo(x2-6,bY+3); ctx.fill()
                    }

                    // boxes
                    for(var bi=0;bi<6;bi++){
                        var active=phase===bi
                        var pulse=active?(0.5+0.4*Math.sin(t*Math.PI*14)):0.22
                        ctx.beginPath(); roundRect2(ctx,cx[bi]-bW/2,bY-bH/2,bW,bH,7)
                        ctx.strokeStyle="rgba("+bR[bi]+","+bG[bi]+","+bB[bi]+","+pulse+")"; ctx.lineWidth=active?2:1.2; ctx.stroke()
                        ctx.fillStyle="rgba("+bR[bi]+","+bG[bi]+","+bB[bi]+","+(active?0.18:0.05)+")"; ctx.fill()
                        var lns=labels[bi].split("\n")
                        ctx.fillStyle="rgba("+bR[bi]+","+bG[bi]+","+bB[bi]+","+(active?1:0.55)+")"; ctx.font="bold 8.5px Consolas"; ctx.textAlign="center"
                        ctx.fillText(lns[0],cx[bi],bY-4)
                        ctx.fillStyle="rgba(255,255,255,0.28)"; ctx.font="7.5px Consolas"
                        if(lns[1]) ctx.fillText(lns[1],cx[bi],bY+9)
                    }

                    // animated dot position
                    var dotX, dotY2
                    if(t<0.15){dotX=cx[0];dotY2=bY;}
                    else if(t<0.28){var p=(t-0.15)/0.13;dotX=cx[0]+p*(cx[1]-cx[0]);dotY2=bY;}
                    else if(t<0.42){var p2=(t-0.28)/0.14;dotX=cx[1]+p2*(cx[2]-cx[1]);dotY2=bY;}
                    else if(t<0.60){var p3=(t-0.42)/0.18;dotX=cx[2]+p3*(cx[3]-cx[2]);dotY2=bY;}
                    else if(t<0.78){var p4=(t-0.60)/0.18;dotX=cx[3]+p4*(cx[4]-cx[3]);dotY2=bY;}
                    else{var p5=(t-0.78)/0.22;dotX=cx[4]+p5*(cx[5]-cx[4]);dotY2=bY;}

                    var pC=phaseColors[phase]
                    ctx.beginPath(); ctx.arc(dotX,dotY2,10,0,Math.PI*2)
                    ctx.fillStyle="rgba("+pC[0]+","+pC[1]+","+pC[2]+",0.15)"; ctx.fill()
                    ctx.beginPath(); ctx.arc(dotX,dotY2,5,0,Math.PI*2)
                    ctx.fillStyle="rgba("+pC[0]+","+pC[1]+","+pC[2]+",1)"; ctx.fill()

                    // Phase label
                    var pLabels=["Process A executing user code","timer interrupt → yield() called","sched() — validates, calls swtch()","swtch() saves A's context, loads scheduler's","scheduler() loops, finds Process B RUNNABLE","swtch() into B — B resumes from where it left off"]
                    ctx.fillStyle="rgba("+pC[0]+","+pC[1]+","+pC[2]+",0.85)"; ctx.font="bold 10px Segoe UI"; ctx.textAlign="center"
                    ctx.fillText(pLabels[phase], w/2, h*0.87)
                }
                function roundRect2(c,x,y,w2,h2,r){
                    c.beginPath(); c.moveTo(x+r,y); c.lineTo(x+w2-r,y); c.quadraticCurveTo(x+w2,y,x+w2,y+r);
                    c.lineTo(x+w2,y+h2-r); c.quadraticCurveTo(x+w2,y+h2,x+w2-r,y+h2);
                    c.lineTo(x+r,y+h2); c.quadraticCurveTo(x,y+h2,x,y+h2-r);
                    c.lineTo(x,y+r); c.quadraticCurveTo(x,y,x+r,y); c.closePath();
                }
            }
        }

        // ── swtch() DEEP DIVE STEPPER ─────────────────────────────────────
        Rectangle {
            width: parent.width
            height: swtchCol.implicitHeight + 32
            color: Qt.rgba(255,255,255,0.015); radius: 14
            border.color: Qt.rgba(255,255,255,0.07); border.width: 1

            Column {
                id: swtchCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 16

                Row { spacing:10
                    Text{text:"🔬";font.pixelSize:18;anchors.verticalCenter:parent.verticalCenter}
                    Column{spacing:2
                        Text{text:"swtch() DEEP DIVE — every detail of how the context switch assembly works";color:"#a78bfa";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3}
                        Text{text:"From callee-saved registers to the scheduler loop, forkret, and timer preemption";color:Qt.rgba(255,255,255,0.35);font.pixelSize:11}
                    }
                }

                Row {
                    spacing: 8
                    Repeater {
                        model: 6
                        delegate: Row { spacing:0
                            Rectangle {
                                width:26;height:26;radius:13
                                color:scrollRoot.swtchStep>=index?"#8b5cf6":Qt.rgba(139,92,246,0.1)
                                border.color:"#8b5cf6";border.width:scrollRoot.swtchStep>=index?0:1
                                Behavior on color{ColorAnimation{duration:180}}
                                Text{anchors.centerIn:parent;text:(index+1).toString();color:scrollRoot.swtchStep>=index?"#fff":Qt.rgba(255,255,255,0.3);font.bold:true;font.pixelSize:10;font.family:"Consolas"}
                                MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:scrollRoot.swtchStep=index}
                            }
                            Rectangle{visible:index<5;width:16;height:2;anchors.verticalCenter:parent.verticalCenter;color:scrollRoot.swtchStep>index?"#8b5cf6":Qt.rgba(255,255,255,0.1);Behavior on color{ColorAnimation{duration:180}}}
                        }
                    }
                }

                Text { text:scrollRoot.swtchTitles[scrollRoot.swtchStep]; color:"#c084fc"; font.bold:true; font.pixelSize:14; font.letterSpacing:0.3 }

                Row {
                    width:parent.width; spacing:14
                    Text {
                        width:parent.width*0.38
                        text:scrollRoot.swtchDescs[scrollRoot.swtchStep]
                        color:Qt.rgba(255,255,255,0.75);font.family:"Segoe UI";font.pixelSize:11;wrapMode:Text.WordWrap;lineHeight:1.55
                    }
                    Rectangle {
                        width:parent.width*0.62-14
                        height:swtchCodeText.implicitHeight+32
                        color:Qt.rgba(0,0,0,0.3);radius:10;border.color:Qt.rgba(255,255,255,0.06);border.width:1
                        Rectangle{width:parent.width;height:22;color:Qt.rgba(255,255,255,0.04);radius:10
                            Rectangle{width:parent.width;height:11;anchors.bottom:parent.bottom;color:parent.color}
                            Row{anchors.left:parent.left;anchors.leftMargin:8;anchors.verticalCenter:parent.verticalCenter;spacing:4
                                Repeater{model:3;delegate:Rectangle{width:7;height:7;radius:3.5;color:["#f43f5e","#fbbf24","#10b981"][index];opacity:0.7}}}
                            Text{text:"kernel/swtch.S + proc.c";color:Qt.rgba(255,255,255,0.18);font.pixelSize:9;font.family:"Consolas";anchors.centerIn:parent}
                        }
                        Text {
                            id: swtchCodeText
                            anchors.top:parent.top;anchors.topMargin:28
                            anchors.left:parent.left;anchors.leftMargin:12
                            anchors.right:parent.right;anchors.rightMargin:12
                            text:scrollRoot.swtchCodes[scrollRoot.swtchStep]
                            color:Qt.rgba(255,255,255,0.82);font.family:"Consolas";font.pixelSize:10
                            wrapMode:Text.WrapAtWordBoundaryOrAnywhere;lineHeight:1.5
                        }
                    }
                }

                Row { spacing:10
                    Rectangle{width:90;height:34;radius:9;color:scrollRoot.swtchStep>0?Qt.rgba(139,92,246,0.15):Qt.rgba(255,255,255,0.03);border.color:scrollRoot.swtchStep>0?"#8b5cf6":Qt.rgba(255,255,255,0.1);border.width:1
                        Text{anchors.centerIn:parent;text:"← PREV";color:scrollRoot.swtchStep>0?"#8b5cf6":Qt.rgba(255,255,255,0.2);font.bold:true;font.pixelSize:11}
                        MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:if(scrollRoot.swtchStep>0)scrollRoot.swtchStep--}
                    }
                    Rectangle{width:90;height:34;radius:9;color:scrollRoot.swtchStep<5?Qt.rgba(139,92,246,0.15):Qt.rgba(255,255,255,0.03);border.color:scrollRoot.swtchStep<5?"#8b5cf6":Qt.rgba(255,255,255,0.1);border.width:1
                        Text{anchors.centerIn:parent;text:"NEXT →";color:scrollRoot.swtchStep<5?"#8b5cf6":Qt.rgba(255,255,255,0.2);font.bold:true;font.pixelSize:11}
                        MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:if(scrollRoot.swtchStep<5)scrollRoot.swtchStep++}
                    }
                    Text{anchors.verticalCenter:parent.verticalCenter;text:"Step "+(scrollRoot.swtchStep+1)+" of 6";color:Qt.rgba(255,255,255,0.2);font.pixelSize:11}
                }
            }
        }

        // ── sleep() / wakeup() PANEL ─────────────────────────────────────
        Rectangle {
            width: parent.width
            height: sleepCol.implicitHeight + 32
            color: Qt.rgba(59/255,130/255,246/255,0.05); radius: 14
            border.color: Qt.rgba(59/255,130/255,246/255,0.2); border.width: 1

            Column {
                id: sleepCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing: 14

                Row { spacing:10
                    Text{text:"💤";font.pixelSize:18;anchors.verticalCenter:parent.verticalCenter}
                    Column { spacing:2
                        Text{text:"sleep() & wakeup() — blocking synchronisation primitive";color:"#3b82f6";font.bold:true;font.pixelSize:13;font.letterSpacing:0.3}
                        Text{text:"The channel (chan) is an arbitrary kernel address used as a rendezvous point — no explicit channel object needed";color:Qt.rgba(255,255,255,0.35);font.pixelSize:11}
                    }
                }

                Row { width:parent.width; spacing:14

                    Rectangle {
                        width:(parent.width-14)*0.5; height:sleepCode.implicitHeight+32
                        color:Qt.rgba(0,0,0,0.28); radius:10; border.color:Qt.rgba(255,255,255,0.06); border.width:1
                        Rectangle{width:parent.width;height:22;color:Qt.rgba(255,255,255,0.04);radius:10
                            Rectangle{width:parent.width;height:11;anchors.bottom:parent.bottom;color:parent.color}
                            Row{anchors.left:parent.left;anchors.leftMargin:8;anchors.verticalCenter:parent.verticalCenter;spacing:4
                                Repeater{model:3;delegate:Rectangle{width:7;height:7;radius:3.5;color:["#f43f5e","#fbbf24","#10b981"][index];opacity:0.7}}}
                            Text{text:"kernel/proc.c";color:Qt.rgba(255,255,255,0.18);font.pixelSize:9;font.family:"Consolas";anchors.centerIn:parent}
                        }
                        Text {
                            id: sleepCode
                            anchors.top:parent.top;anchors.topMargin:28
                            anchors.left:parent.left;anchors.leftMargin:12
                            anchors.right:parent.right;anchors.rightMargin:12
                            text:"// sleep: block until wakeup(chan)\nvoid sleep(void *chan, struct spinlock *lk) {\n    struct proc *p = myproc();\n    acquire(&p->lock);\n    release(lk);          // avoid deadlock!\n    p->chan  = chan;\n    p->state = SLEEPING;\n    sched();              // → scheduler\n    // Resumes here after wakeup(chan)\n    p->chan = 0;\n    release(&p->lock);\n    acquire(lk);          // re-acquire caller's lock\n}\n\n// wakeup: wake all sleepers on chan\nvoid wakeup(void *chan) {\n    struct proc *p;\n    for(p=proc; p < &proc[NPROC]; p++) {\n        if(p != myproc()) {\n            acquire(&p->lock);\n            if(p->state==SLEEPING && p->chan==chan)\n                p->state = RUNNABLE;\n            release(&p->lock);\n        }\n    }\n}"
                            color:Qt.rgba(255,255,255,0.82);font.family:"Consolas";font.pixelSize:10
                            wrapMode:Text.WrapAtWordBoundaryOrAnywhere;lineHeight:1.5
                        }
                    }

                    Column {
                        width:(parent.width-14)*0.5; spacing:10

                        Repeater {
                            model: [
                                ["WHY release(lk) before sleep?","If sleep held lk while blocking, no other thread could acquire lk to call wakeup → deadlock. The tricky lock dance: acquire p->lock (to set state=SLEEPING atomically), release lk, call sched. On return: re-acquire lk."],
                                ["LOST WAKEUP problem","If wakeup fires between the condition check and the sleep() call, and sleep() hasn't set state=SLEEPING yet, the wakeup is lost and the process sleeps forever. Solution: always call sleep() inside a loop checking the condition, with lk held around both the check and sleep()."],
                                ["Example usage: pipe read","pipe.c: while(pi->nread == pi->nwrite) sleep(&pi->nread, &pi->lock) — loops checking if data available. The writer calls wakeup(&pi->nread) after writing. The channel is the address of nread — just a unique pointer."],
                                ["wakeup() wakes ALL sleepers","All processes sleeping on the same chan are made RUNNABLE. Usually only one should proceed (thundering herd). They re-check the condition in the while loop and go back to sleep if not satisfied."]
                            ]
                            delegate: Rectangle {
                                width:parent.width; height:bodyTxt.implicitHeight+40; radius:9
                                color:Qt.rgba(59/255,130/255,246/255,0.07)
                                border.color:Qt.rgba(59/255,130/255,246/255,0.2); border.width:1
                                Column {
                                    anchors.left:parent.left;anchors.leftMargin:12
                                    anchors.right:parent.right;anchors.rightMargin:12
                                    anchors.top:parent.top;anchors.topMargin:10; spacing:5
                                    Text{text:modelData[0];color:"#60a5fa";font.bold:true;font.pixelSize:11;font.letterSpacing:0.2}
                                    Text{id:bodyTxt;text:modelData[1];color:Qt.rgba(255,255,255,0.62);font.family:"Segoe UI";font.pixelSize:11;wrapMode:Text.WordWrap;width:parent.width;lineHeight:1.45}
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── FOOTER ──────────────────────────────────────────────────────

        // ── SWTCH() REGISTER VISUALIZER ─────────────────────────────────
        Rectangle {
            id: swtchVisSim
            width:parent.width; height:rvSwtchCol.implicitHeight+32
            color:Qt.rgba(255,255,255,0.015); radius:14
            border.color:Qt.rgba(6,182,212,0.2); border.width:1

            property int step: 0
            property int maxStep: 4

            property var steps: [
                {title:"BEFORE swtch()", desc:"P1 is running. Its callee-saved regs (ra,sp,s0-s11) are live in the CPU. P2 context is saved in its kernel stack from a previous swtch().", highlight:"none"},
                {title:"SAVE P1: sd ra,0(a0)",  desc:"swtch() takes *old=&p1→context, *new=&p2→context. First stores P1's ra onto the context struct at address a0. Each sd saves one 8-byte register.", highlight:"p1"},
                {title:"SAVE P1 sp..s11",       desc:"Continues storing sp, s0, s1, s2, s3, s4, s5 … s11 into P1's context struct. Now P1's full register state is on its kernel stack — safe to abandon.", highlight:"p1"},
                {title:"RESTORE P2: ld ra,0(a1)",desc:"Loads P2's ra from its context struct (address a1=&p2→context). This is the return address swtch() will jump to when it 'returns'.", highlight:"p2"},
                {title:"JUMP: ret (to P2's ra)", desc:"After loading sp,s0-s11 from P2's context, swtch() executes ret — which jumps to P2's ra (scheduler or sched). P2 is now running with its own registers.", highlight:"p2"}
            ]

            function fmtReg(name, val, hl) {
                return val  // just return the value; colour is set by highlight state
            }

            Column {
                id:rvSwtchCol
                anchors.top:parent.top; anchors.topMargin:18
                anchors.left:parent.left; anchors.leftMargin:18
                anchors.right:parent.right; anchors.rightMargin:18
                spacing:14

                Row { spacing:10
                    Text { text:"🔀"; font.pixelSize:18; anchors.verticalCenter:parent.verticalCenter }
                    Column { spacing:2
                        Text { text:"swtch() REGISTER VISUALIZER — step through the context switch"; color:"#06b6d4"; font.bold:true; font.pixelSize:13 }
                        Text { text:"swtch(old,new) saves callee-saved regs to 'old' context, restores from 'new'. 13 registers total (ra+sp+s0-s11). Defined in kernel/swtch.S."; color:Qt.rgba(255,255,255,0.32); font.pixelSize:11 }
                    }
                }

                // Step description
                Rectangle { width:parent.width; height:rvStepBox.implicitHeight+20; radius:10; color:Qt.rgba(0,0,0,0.2)
                    border.color:swtchVisSim.steps[swtchVisSim.step].highlight==="p1"?"#a78bfa":swtchVisSim.steps[swtchVisSim.step].highlight==="p2"?"#06b6d4":Qt.rgba(255,255,255,0.1); border.width:1.5
                    Column { id:rvStepBox; anchors.top:parent.top; anchors.topMargin:12; anchors.left:parent.left; anchors.leftMargin:14; anchors.right:parent.right; anchors.rightMargin:14; spacing:6
                        Text { text:"Step "+(swtchVisSim.step+1)+"/"+swtchVisSim.maxStep+": "+swtchVisSim.steps[swtchVisSim.step].title; color:"#06b6d4"; font.bold:true; font.pixelSize:12 }
                        Text { text:swtchVisSim.steps[swtchVisSim.step].desc; color:Qt.rgba(255,255,255,0.65); wrapMode:Text.WordWrap; width:parent.width; font.pixelSize:11; lineHeight:1.6 }
                    }
                }

                // Register panels side by side
                Row { spacing:12; width:parent.width
                    // P1 context
                    Rectangle { width:(parent.width-12)/2; height:rvP1RegCol.implicitHeight+20; radius:10
                        color:swtchVisSim.steps[swtchVisSim.step].highlight==="p1"?Qt.rgba(139/255,92/255,246/255,0.12):Qt.rgba(255,255,255,0.02)
                        border.color:swtchVisSim.steps[swtchVisSim.step].highlight==="p1"?"#a78bfa":Qt.rgba(255,255,255,0.08); border.width:1.5
                        Behavior on border.color{ColorAnimation{duration:200}}
                        Column { id:rvP1RegCol; anchors.top:parent.top; anchors.topMargin:12; anchors.left:parent.left; anchors.leftMargin:12; anchors.right:parent.right; anchors.rightMargin:12; spacing:5
                            Text { text:"P1 CONTEXT"; color:"#a78bfa"; font.bold:true; font.pixelSize:11 }
                            Repeater { model:[{r:"ra",v:"sched"},{r:"sp",v:"kstack1"},{r:"s0",v:"0xAAA"},{r:"s1",v:"0xBBB"},{r:"s2",v:"0xCCC"},{r:"s3",v:"0xDDD"},{r:"s4",v:"0xEEE"},{r:"s5",v:"0xFFF"}]
                                delegate: Row { spacing:10
                                    property bool saved: swtchVisSim.step >= 2 || (swtchVisSim.step===1 && index===0)
                                    Text { text:modelData.r+":"; color:Qt.rgba(255,255,255,0.3); font.pixelSize:10; font.family:"Consolas"; width:26 }
                                    Text { text:modelData.v; color:parent.saved?"#a78bfa":Qt.rgba(255,255,255,0.45); font.pixelSize:10; font.family:"Consolas"; font.bold:parent.saved }
                                    Text { text:parent.saved?"← saved":""; color:Qt.rgba(139/255,92/255,246/255,0.6); font.pixelSize:9 }
                                }
                            }
                        }
                    }
                    // P2 context
                    Rectangle { width:(parent.width-12)/2; height:rvP2RegCol.implicitHeight+20; radius:10
                        color:swtchVisSim.steps[swtchVisSim.step].highlight==="p2"?Qt.rgba(6/255,182/255,212/255,0.12):Qt.rgba(255,255,255,0.02)
                        border.color:swtchVisSim.steps[swtchVisSim.step].highlight==="p2"?"#06b6d4":Qt.rgba(255,255,255,0.08); border.width:1.5
                        Behavior on border.color{ColorAnimation{duration:200}}
                        Column { id:rvP2RegCol; anchors.top:parent.top; anchors.topMargin:12; anchors.left:parent.left; anchors.leftMargin:12; anchors.right:parent.right; anchors.rightMargin:12; spacing:5
                            Text { text:"P2 CONTEXT"; color:"#06b6d4"; font.bold:true; font.pixelSize:11 }
                            Repeater { model:[{r:"ra",v:"scheduler"},{r:"sp",v:"kstack2"},{r:"s0",v:"0x111"},{r:"s1",v:"0x222"},{r:"s2",v:"0x333"},{r:"s3",v:"0x444"},{r:"s4",v:"0x555"},{r:"s5",v:"0x666"}]
                                delegate: Row { spacing:10
                                    property bool restored: swtchVisSim.step >= 4 || (swtchVisSim.step===3 && index===0)
                                    Text { text:modelData.r+":"; color:Qt.rgba(255,255,255,0.3); font.pixelSize:10; font.family:"Consolas"; width:26 }
                                    Text { text:modelData.v; color:parent.restored?"#06b6d4":Qt.rgba(255,255,255,0.45); font.pixelSize:10; font.family:"Consolas"; font.bold:parent.restored }
                                    Text { text:parent.restored?"← active":""; color:Qt.rgba(6/255,182/255,212/255,0.6); font.pixelSize:9 }
                                }
                            }
                        }
                    }
                }

                // Step controls
                Row { spacing:10; width:parent.width
                    Rectangle { height:34; width:rvPrevBtn.implicitWidth+20; radius:9; opacity:swtchVisSim.step>0?1:0.3
                        color:Qt.rgba(6/255,182/255,212/255,0.1); border.color:"#06b6d4"; border.width:1
                        Text { id:rvPrevBtn; anchors.centerIn:parent; text:"◀ PREV"; color:"#06b6d4"; font.bold:true; font.pixelSize:11 }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:if(swtchVisSim.step>0) swtchVisSim.step-- }
                    }
                    Rectangle { height:34; width:rvNextBtn.implicitWidth+20; radius:9; opacity:swtchVisSim.step<swtchVisSim.maxStep?1:0.3
                        color:Qt.rgba(6/255,182/255,212/255,0.15); border.color:"#06b6d4"; border.width:1
                        Text { id:rvNextBtn; anchors.centerIn:parent; text:"NEXT ▶"; color:"#06b6d4"; font.bold:true; font.pixelSize:11 }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:if(swtchVisSim.step<swtchVisSim.maxStep) swtchVisSim.step++ }
                    }
                    Rectangle { height:34; width:rvRstCs.implicitWidth+20; radius:9
                        color:Qt.rgba(255,255,255,0.04); border.color:Qt.rgba(255,255,255,0.1); border.width:1
                        Text { id:rvRstCs; anchors.centerIn:parent; text:"↺ RESET"; color:Qt.rgba(255,255,255,0.35); font.pixelSize:11 }
                        MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:swtchVisSim.step=0 }
                    }
                    // progress dots
                    Row { spacing:6; anchors.verticalCenter:parent.verticalCenter
                        Repeater { model:swtchVisSim.maxStep+1
                            delegate: Rectangle { width:8; height:8; radius:4; color:index<=swtchVisSim.step?"#06b6d4":Qt.rgba(255,255,255,0.15) }
                        }
                    }
                }
            }
        }

        Rectangle {
            width:parent.width; height:65
            color:Qt.rgba(244/255,63/255,94/255,0.08); radius:14
            border.color:Qt.rgba(244/255,63/255,94/255,0.35); border.width:1
            RowLayout {
                anchors.fill:parent; anchors.margins:15; spacing:15
                Text{text:"🌟";font.pixelSize:22;Layout.alignment:Qt.AlignVCenter}
                Text {
                    Layout.fillWidth:true; Layout.alignment:Qt.AlignVCenter
                    text:"CORE SUMMARY: Context switch in xv6: swtch() saves/restores only callee-saved registers (ra, sp, s0-s11). Switching goes: process→yield()→sched()→swtch()→scheduler()→swtch()→next process. Process states: UNUSED/USED/RUNNABLE/RUNNING/SLEEPING/ZOMBIE. Timer interrupts trigger yield() for preemption. sleep(chan,lk)/wakeup(chan) block/unblock on arbitrary kernel addresses. New processes first land in forkret() via context.ra before calling usertrapret()."
                    color:"#ffffff"; wrapMode:Text.WordWrap; font.family:"Segoe UI"; font.bold:true; font.pixelSize:12; font.letterSpacing:0.2
                }
            }
        }
    }
}
