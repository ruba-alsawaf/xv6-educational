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
        // 1. HEADER: Lesson Title & Goal
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
                    text: "LESSON 8: KERNEL ADDRESS SPACE & KVMINIT"
                    color: "#ffffff"
                    font { family: "Segoe UI"; bold: true; pixelSize: 18; letterSpacing: 0.5 }
                }
                Text {
                    text: "💡 GOAL: Master how the xv6 kernel designs its rigid virtual-to-physical mapping during boot up, allocates page tables, and isolates raw peripheral hardware using defensive page table entry flags."
                    color: Qt.rgba(255, 255, 255, 0.6)
                    font { family: "Segoe UI"; pixelSize: 12 }
                    wrapMode: Text.WordWrap
                    width: parent.width - 30
                }
            }
        }

        // ==========================================
        // 2. MAIN LAYOUT: Code Block vs Kernel Memory Map Diagram
        // ==========================================
        Row {
            width: parent.width
            spacing: 20

            // 💻 Left Side: Dark Mode Code Block (Software Logic)
            Rectangle {
                width: (parent.width - 20) * 0.48
                height: 520
                color: Qt.rgba(0, 0, 0, 0.4)
                radius: 16
                border.color: Qt.rgba(255, 255, 255, 0.08)
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    Row {
                        spacing: 6
                        Rectangle { width: 10; height: 10; radius: 5; color: "#ef4444" }
                        Rectangle { width: 10; height: 10; radius: 5; color: "#eab308" }
                        Rectangle { width: 10; height: 10; radius: 5; color: "#10b981" }
                        Text { text: "  vm.c - kvminit() Code Implementation"; color: "#97969d"; font { family: "Consolas"; pixelSize: 11 } anchors.verticalCenter: parent.verticalCenter }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Flickable {
                        width: parent.width; height: parent.height - 50
                        contentWidth: codeColumn.width; contentHeight: codeColumn.height
                        clip: true

                        Column {
                            id: codeColumn
                            spacing: 5

                            Row { Text { text: "void"; color: "#60a5fa"; font.family: "Consolas" } Text { text: " kvminit() {"; color: "white"; font.family: "Consolas" } }
                            Row { Text { text: "  kpagetable = (pagetable_t) kalloc();"; color: "white"; font.family: "Consolas" } }
                            Row { Text { text: "  memset(kpagetable, 0, PGSIZE);"; color: "white"; font.family: "Consolas" } }
                            Text { text: "" }
                            Row { Text { text: "  // 1. Direct map I/O peripherals"; color: "#a1a1aa"; font.family: "Consolas"; font.italic: true } }
                            Row { Text { text: "  kvm_map(kpagetable, UART0, UART0, PGSIZE, "; color: "white"; font.family: "Consolas" } Text { text: "PTE_R | PTE_W"; color: "#34d399"; font.family: "Consolas" } Text { text: ");"; color: "white"; font.family: "Consolas" } }
                            Row { Text { text: "  kvm_map(kpagetable, VIRTIO0, VIRTIO0, PGSIZE, "; color: "white"; font.family: "Consolas" } Text { text: "PTE_R | PTE_W"; color: "#34d399"; font.family: "Consolas" } Text { text: ");"; color: "white"; font.family: "Consolas" } }
                            Text { text: "" }
                            Row { Text { text: "  // 2. Map kernel text (Read & Execute only)"; color: "#a1a1aa"; font.family: "Consolas"; font.italic: true } }
                            Row { Text { text: "  kvm_map(kpagetable, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, "; color: "white"; font.family: "Consolas" } Text { text: "PTE_R | PTE_X"; color: "#f43f5e"; font.family: "Consolas" } Text { text: ");"; color: "white"; font.family: "Consolas" } }
                            Text { text: "" }
                            Row { Text { text: "  // 3. Map kernel data & RAM physical space"; color: "#a1a1aa"; font.family: "Consolas"; font.italic: true } }
                            Row { Text { text: "  kvm_map(kpagetable, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, "; color: "white"; font.family: "Consolas" } Text { text: "PTE_R | PTE_W"; color: "#34d399"; font.family: "Consolas" } Text { text: ");"; color: "white"; font.family: "Consolas" } }
                            Text { text: "}" }
                        }
                    }
                }
            }

            // 🗺️ Right Side: Kernel Memory Map Stack Diagram
            Rectangle {
                width: (parent.width - 20) * 0.52
                height: 520
                color: Qt.rgba(255, 255, 255, 0.02)
                radius: 16
                border.color: Qt.rgba(139, 92, 246, 0.2)
                border.width: 1

                Item {
                    anchors.fill: parent
                    anchors.margins: 20

                    Text { id: mapTitle; text: "KERNEL VIRTUAL ADDRESS SPACE MAP"; color: "#c084fc"; font { bold: true; pixelSize: 11; letterSpacing: 0.5 } }

                    Column {
                        id: memoryStack
                        anchors.top: mapTitle.bottom
                        anchors.topMargin: 15
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width * 0.85
                        spacing: 6

                        // Free Memory RAM Space Block
                        Rectangle {
                            width: parent.width; height: 80; radius: 4; color: Qt.rgba(52, 211, 153, 0.12); border.color: "#10b981"
                            Column { anchors.centerIn: parent; spacing: 2
                                Text { text: "FREE RAM MEMORY"; color: "white"; font { bold: true; pixelSize: 11 } anchors.horizontalCenter: parent }
                                Text { text: "Max Limit: PHYSTOP (0x88000000)"; color: Qt.rgba(255,255,255,0.4); font.pixelSize: 8 }
                                Text { text: "Permissions: PTE_R | PTE_W (Read & Write Allowed)"; color: "#34d399"; font.pixelSize: 8 } }
                        }

                        // Kernel Data Segment Block
                        Rectangle {
                            width: parent.width; height: 65; radius: 4; color: Qt.rgba(52, 211, 153, 0.08); border.color: "#34d399"
                            Column { anchors.centerIn: parent; spacing: 2
                                Text { text: "KERNEL DATA & STACK"; color: "white"; font { bold: true; pixelSize: 11 } }
                                Text { text: "Start Addr: etext (End of Text Segment)"; color: Qt.rgba(255,255,255,0.4); font.pixelSize: 8; anchors.horizontalCenter: parent }
                                Text { text: "Permissions: PTE_R | PTE_W"; color: "#34d399"; font.pixelSize: 8; anchors.horizontalCenter: parent } }
                        }

                        // Kernel Text Segment Block (Code)
                        Rectangle {
                            width: parent.width; height: 65; radius: 4; color: Qt.rgba(244, 63, 94, 0.12); border.color: "#f43f5e"
                            layer.enabled: true; layer.effect: Glow { radius: 5; samples: 9; color: "#f43f5e"; spread: 0.1 }
                            Column { anchors.centerIn: parent; spacing: 2
                                Text { text: "KERNEL TEXT (CODE SEGMENT)"; color: "white"; font { bold: true; pixelSize: 11 } }
                                Text { text: "Start Addr: KERNBASE (0x80000000)"; color: Qt.rgba(255,255,255,0.4); font.pixelSize: 8; anchors.horizontalCenter: parent }
                                Text { text: "Permissions: PTE_R | PTE_X (Read & Execute Only)"; color: "#f43f5e"; font.pixelSize: 8; anchors.horizontalCenter: parent } }
                        }

                        // Peripherals Dev I/O Block
                        Rectangle {
                            id: devBlock
                            width: parent.width; height: 70; radius: 4; color: Qt.rgba(139, 92, 246, 0.15); border.color: "#8b5cf6"
                            Column { anchors.centerIn: parent; spacing: 2
                                Text { text: "I/O PERIPHERALS DEVICES"; color: "white"; font { bold: true; pixelSize: 11 } }
                                Text { text: "Maps: UART0 (Console) & VIRTIO0 (Disk Controllers)"; color: Qt.rgba(255,255,255,0.5); font.pixelSize: 8; anchors.horizontalCenter: parent }
                                Text { text: "Direct Mapping Mode (pa == va)"; color: "#a78bfa"; font.pixelSize: 8; anchors.horizontalCenter: parent } }
                        }
                    }

                    Canvas {
                        anchors.fill: parent
                        onAvailableChanged: if(available) requestPaint()
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset();
                            ctx.strokeStyle = Qt.rgba(139, 92, 246, 0.45); ctx.lineWidth = 1.2; ctx.setLineDash([4, 4]);
                            ctx.beginPath();
                            ctx.moveTo(-150, 168);
                            ctx.bezierCurveTo(-60, 168, -30, 335, 30, 335);
                            ctx.stroke();
                        }
                    }
                }
            }
        }

        // ==========================================
        // 3. EXPLANATION SECTION
        // ==========================================
        Rectangle {
            width: parent.width
            height: 220
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
                    Text { text: "📌 Kernel Direct Mapping Strategy:"; color: "#c084fc"; font { bold: true; pixelSize: 12 } }
                    Text {
                        text: "During early boot, kvminit() maps critical hardware device registers (UART0, VIRTIO0) identically into virtual memory spaces. This ensures that the Virtual Address (VA) equals exactly the Physical Address (PA), allowing the kernel to fetch and stream bytes to disk controllers safely without complex translation layers.";
                        color: Qt.rgba(255, 255, 255, 0.75); font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width
                    }
                }

                Column {
                    width: parent.width
                    spacing: 3
                    Text { text: "📌 Defensive Page Level Security:"; color: "#f43f5e"; font { bold: true; pixelSize: 12 } }
                    Text {
                        text: "The kernel code (text segment) starting from 0x80000000 is compiled as Read and Execute only (PTE_R | PTE_X). Omitting the PTE_W (Write) flag prevents the running operating system from being modified or overwritten by software glitches, effectively establishing a hardware-enforced shield around kernel operations.";
                        color: Qt.rgba(255, 255, 255, 0.75); font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width
                    }
                }

                Column {
                    width: parent.width
                    spacing: 3
                    Text { text: "📌 The Core Mapping Registry:"; color: "#34d399"; font { bold: true; pixelSize: 12 } }
                    Text {
                        text: "Every call to kvm_map() calls the walk() helper under the hood to safely descend the page directory layers. If a path branch is missing, it dynamically invokes kalloc() to construct new page nodes and populates the permissions flags securely.";
                        color: Qt.rgba(255, 255, 255, 0.75); font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width
                    }
                }
            }
        }
    }
}
