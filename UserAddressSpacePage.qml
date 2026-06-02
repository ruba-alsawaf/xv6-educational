import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

ScrollView {
    id: scrollRoot
    anchors.fill: parent
    contentWidth: parent.width
    contentHeight: mainColumn.implicitHeight + 40
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    Column {
        id: mainColumn
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        spacing: 25

        // ==========================================
        // 1. HEADER: Comprehensive Title & Educational Goal
        // ==========================================
        Rectangle {
            width: parent.width
            height: 95
            color: Qt.rgba(255, 255, 255, 0.03)
            radius: 14
            border.color: Qt.rgba(139, 92, 246, 0.25)
            border.width: 1

            layer.enabled: true
            layer.effect: Glow {
                radius: 10; samples: 17; color: Qt.rgba(139, 92, 246, 0.1); spread: 0.1
            }

            Column {
                anchors.fill: parent
                anchors.margins: 15
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    text: "LESSON 9: USER ADDRESS SPACE ISOLATION & DYNAMIC sbrk() GROWTH"
                    color: "#ffffff"
                    font { family: "Segoe UI"; bold: true; pixelSize: 18; letterSpacing: 0.5 }
                }
                Text {
                    text: "💡 CONCEPTUAL FOCUS: Deep dive into the scientific layout of an isolated user application memory stack, hardware-enforced isolation, and the structural lifecycle of memory expansion."
                    color: Qt.rgba(255, 255, 255, 0.6)
                    font { family: "Segoe UI"; pixelSize: 12 }
                    wrapMode: Text.WordWrap
                    width: parent.width - 30
                }
            }
        }

        // ==========================================
        // 2. SECTION A: THE SCIENTIFIC MEMORY LAYOUT (Full Width Diagram)
        // ==========================================
        Rectangle {
            width: parent.width
            height: 380
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 16
            border.color: Qt.rgba(139, 92, 246, 0.15)
            border.width: 1

            Item {
                anchors.fill: parent
                anchors.margins: 20

                Text {
                    id: layoutTitle
                    text: "I. RISC-V Sv39 USER MEMORY STACK LAYOUT (FROM VA 0 TO MAXVA)"
                    color: "#c084fc"
                    font { bold: true; pixelSize: 13; letterSpacing: 0.5 }
                }

                // الترتيب الهندسي والعلمي الصحيح من الأعلى للأسفل
                Column {
                    id: userStackLayout
                    anchors.top: layoutTitle.bottom
                    anchors.topMargin: 15
                    width: parent.width * 0.65
                    spacing: 5

                    // 1. القمة القصوى المحمية
                    Rectangle {
                        width: parent.width; height: 50; radius: 4; color: Qt.rgba(244, 63, 94, 0.12); border.color: "#f43f5e"
                        Column { anchors.centerIn: parent; Text { text: "TRAMPOLINE & TRAPFRAME (High Memory Ceiling)"; color: "white"; font { bold: true; pixelSize: 11 } }
                                 Text { text: "Address Scope: MAXVA (0x3fffffffff) | Lacks PTE_U flag for user execution safety"; color: "#fca5a5"; font.pixelSize: 8 } }
                    }

                    // 2. الفضاء الفارغ المصلح بـ Canvas آمن لمنع الانهيار
                    Rectangle {
                        width: parent.width; height: 40; radius: 4; color: "transparent"
                        Text { text: "UNMAPPED / FREE SPACE AREA (Vast Unused Virtual Range)"; color: Qt.rgba(255,255,255,0.2); font.pixelSize: 10; anchors.centerIn: parent }
                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d"); ctx.strokeStyle = Qt.rgba(255,255,255,0.1); ctx.lineWidth = 1; ctx.setLineDash([4, 4]);
                                ctx.strokeRect(0, 0, width, height);
                            }
                        }
                    }

                    // 3. الـ Heap النامي لأعلى
                    Rectangle {
                        id: dynamicHeapBlock
                        width: parent.width; height: 65; radius: 4; color: Qt.rgba(234, 179, 8, 0.12); border.color: "#eab308"
                        layer.enabled: true; layer.effect: Glow { radius: 6; samples: 11; color: "#eab308"; spread: 0.1 }
                        Column { anchors.centerIn: parent; spacing: 2
                            Text { text: "📈 THE HEAP SEGMENT (DYNAMIC GROWTH ZONE)"; color: "white"; font { bold: true; pixelSize: 11 } }
                            Text { text: "Grows UPWARDS dynamically. Upper bound tracked by proc->sz pointer via sbrk()"; color: Qt.rgba(255,255,255,0.5); font.pixelSize: 8 }
                            Text { text: "Permissions: PTE_U | PTE_W | PTE_R (Full Read/Write User Access)"; color: "#eab308"; font.pixelSize: 8 } }
                    }

                    // 4. الـ User Stack
                    Rectangle {
                        width: parent.width; height: 50; radius: 4; color: Qt.rgba(16, 185, 129, 0.1); border.color: "#10b981"
                        Column { anchors.centerIn: parent; Text { text: "USER EXECUTION STACK (Single 4096-Byte Page)"; color: "white"; font { bold: true; pixelSize: 10 } }
                                 Text { text: "Contains local runtime variables & arguments stack records"; color: Qt.rgba(255,255,255,0.5); font.pixelSize: 8 } }
                    }

                    // 5. الـ Text & Data في الأسفل تماماً تبدأ من الصفر
                    Rectangle {
                        width: parent.width; height: 50; radius: 4; color: Qt.rgba(139, 92, 246, 0.15); border.color: "#8b5cf6"
                        Column { anchors.centerIn: parent; Text { text: "USER TEXT & DATA (Compiled Application Binary)"; color: "white"; font { bold: true; pixelSize: 11 } }
                                 Text { text: "Starts exactly at Virtual Address Base: 0x00000000"; color: "#a78bfa"; font.pixelSize: 8 } }
                    }
                }

                // لوحة الشرح الجانبية المرافقة
                Column {
                    anchors.left: userStackLayout.right
                    anchors.leftMargin: 20
                    anchors.top: layoutTitle.bottom
                    anchors.topMargin: 15
                    width: parent.width * 0.3
                    spacing: 15

                    Text {
                        text: "<b>The Scientific Hierarchy:</b><br>In xv6, user processes are injected at virtual address 0. As the application requests variables dynamically, the Heap expands its ceiling towards the unmapped free space. The high memory area remains reserved for trapping protocols."
                        color: Qt.rgba(255,255,255,0.7)
                        font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.3
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.1) }

                    Text {
                        text: "🚨 <b>Scientific Rule:</b><br>The Heap and Stack are strictly segregated. The Heap grows upwards, while the Stack remains fixed, insulated by an unmapped page below it."
                        color: "#fca5a5"; font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.3
                    }
                }
            }
        }

        // ==========================================
        // 3. SECTION B: THE sbrk() GROWTH LIFECYCLE (Horizontal Flow Card)
        // ==========================================
        Rectangle {
            width: parent.width
            height: 160
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 16
            border.color: Qt.rgba(234, 179, 8, 0.2)
            border.width: 1

            Item {
                anchors.fill: parent
                anchors.margins: 18

                Text {
                    id: flowTitle
                    text: "II. LIFECYCLE FLOW: HOW THE HEAP EXPANDS STEP-BY-STEP VIA sbrk()"
                    color: "#eab308"
                    font { bold: true; pixelSize: 13; letterSpacing: 0.5 }
                }

                Row {
                    anchors.top: flowTitle.bottom
                    anchors.topMargin: 15
                    width: parent.width
                    spacing: 15

                    Rectangle { width: (parent.width - 45) / 4; height: 75; radius: 8; color: Qt.rgba(255,255,255,0.03); border.color: Qt.rgba(255,255,255,0.1)
                        Column { anchors.centerIn: parent; spacing: 4; Text { text: "1. User Request"; color: "white"; font.bold: true; font.pixelSize: 11 } Text { text: "App calls sbrk(n)\nasking for 'n' bytes."; color: Qt.rgba(255,255,255,0.5); font.pixelSize: 9; horizontalAlignment: Text.AlignHCenter } } }

                    Rectangle { width: (parent.width - 45) / 4; height: 75; radius: 8; color: Qt.rgba(255,255,255,0.03); border.color: Qt.rgba(255,255,255,0.1)
                        Column { anchors.centerIn: parent; spacing: 4; Text { text: "2. growproc() Trigger"; color: "white"; font.bold: true; font.pixelSize: 11 } Text { text: "Kernel fetches current\nprocess size index (sz)."; color: Qt.rgba(255,255,255,0.5); font.pixelSize: 9; horizontalAlignment: Text.AlignHCenter } } }

                    Rectangle { width: (parent.width - 45) / 4; height: 75; radius: 8; color: Qt.rgba(234, 179, 8, 0.08); border.color: "#eab308"
                        Column { anchors.centerIn: parent; spacing: 4; Text { text: "3. uvmalloc() Allocation"; color: "white"; font.bold: true; font.pixelSize: 11 } Text { text: "Allocates physical RAM\n& maps pages with PTE_U."; color: "#fef08a"; font.pixelSize: 9; horizontalAlignment: Text.AlignHCenter } } }

                    Rectangle { width: (parent.width - 45) / 4; height: 75; radius: 8; color: Qt.rgba(16, 185, 129, 0.08); border.color: "#10b981"
                        Column { anchors.centerIn: parent; spacing: 4; Text { text: "4. Ceiling Extended"; color: "white"; font.bold: true; font.pixelSize: 11 } Text { text: "proc->sz is updated\nHeap safely expanded."; color: "#a7f3d0"; font.pixelSize: 9; horizontalAlignment: Text.AlignHCenter } } }
                }
            }
        }

        // ==========================================
        // 4. SECTION C: EXPANDED CONCEPTUAL TAKEAWAYS (Info Cards)
        // ==========================================
        Rectangle {
            width: parent.width
            height: 240
            color: Qt.rgba(255, 255, 255, 0.01)
            radius: 12
            border.color: Qt.rgba(255, 255, 255, 0.05)

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 14

                Column {
                    width: parent.width
                    spacing: 3
                    Text { text: "📌 Hardware Page Isolation (The PTE_U Boundary):"; color: "#c084fc"; font { bold: true; pixelSize: 12 } }
                    Text {
                        text: "Hardware isolation is heavily enforced by the RISC-V MMU using the PTE_U (User) bit flag. If an application running in User Mode attempts to read or execute a memory page where PTE_U is 0 (such as the kernel space pages or top trampoline fields), the hardware instantly faults, interrupts the pipeline, and kills the compromised user app immediately.";
                        color: Qt.rgba(255, 255, 255, 0.75); font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width
                    }
                }

                Column {
                    width: parent.width
                    spacing: 3
                    Text { text: "📌 Stack Guard Protection Strategy:"; color: "#10b981"; font { bold: true; pixelSize: 12 } }
                    Text {
                        text: "Right below the User Execution Stack, xv6 deliberately leaves an unmapped guard page (Valid bit PTE_V is set to 0). If the application stack experiences massive nested function calling recursion and overflows its single-page buffer, it hits this unmapped guard zone. The CPU catches this fault instantly, avoiding memory corruption into the code base.";
                        color: Qt.rgba(255, 255, 255, 0.75); font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width
                    }
                }

                Column {
                    width: parent.width
                    spacing: 3
                    Text { text: "📌 Dynamic Process Scaling via growproc():"; color: "#eab308"; font { bold: true; pixelSize: 12 } }
                    Text {
                        text: "The sbrk() system call acts as the application's portal to physical resource growth. By invoking growproc(), the system tracks the existing upper memory boundary index, fires up uvmalloc() to register and loop the allocation counters, zeroes out the new memory block for privacy, and shifts the process size ceiling securely.";
                        color: Qt.rgba(255, 255, 255, 0.75); font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width
                    }
                }
            }
        }
    }
}