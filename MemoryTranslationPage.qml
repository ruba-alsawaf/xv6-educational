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
            height: 90
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
                    text: "LESSON 7: RISC-V Sv39 MEMORY TRANSLATION & THE walk() FUNCTION"
                    color: "#ffffff"
                    font { family: "Segoe UI"; bold: true; pixelSize: 18; letterSpacing: 0.5 }
                }
                Text {
                    text: "💡 GOAL: Understand how hardware maps virtual addresses, and how the xv6 kernel emulates this using software page-table walks."
                    color: Qt.rgba(255, 255, 255, 0.6)
                    font { family: "Segoe UI"; pixelSize: 13 }
                    wrapMode: Text.WordWrap
                    width: parent.width - 30
                }
            }
        }

        // ==========================================
        // 2. MAIN LAYOUT: Code Block vs Hardware Mapping Diagram
        // ==========================================
        Row {
            width: parent.width
            spacing: 20

            // 💻 Left Side: Dark Mode Code Block (Software Logic)
            Rectangle {
                width: (parent.width - 20) * 0.46
                height: 540
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
                        Text { text: "  vm.c - xv6 Kernel Source"; color: "#97969d"; font { family: "Consolas"; pixelSize: 11 } anchors.verticalCenter: parent.verticalCenter }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }

                    Flickable {
                        width: parent.width; height: parent.height - 50
                        contentWidth: codeColumn.width; contentHeight: codeColumn.height
                        clip: true

                        Column {
                            id: codeColumn
                            spacing: 4

                            Row { Text { text: "pte_t"; color: "#60a5fa"; font.family: "Consolas" } Text { text: " *walk(pagetable_t pt, uint64 va, "; color: "white"; font.family: "Consolas" } Text { text: "int"; color: "#60a5fa"; font.family: "Consolas" } Text { text: " alloc) {"; color: "white"; font.family: "Consolas" } }
                            Row { Text { text: "  if"; color: "#f43f5e"; font.family: "Consolas" } Text { text: "(va >= MAXVA)"; color: "white"; font.family: "Consolas" } }
                            Text { text: "    panic(\"walk\");"; color: "#a1a1aa"; font.family: "Consolas"; font.italic: true }
                            Text { text: "" }
                            Row { Text { text: "  // Loop 3 levels of Sv39 page tree"; color: "#a1a1aa"; font.family: "Consolas"; font.italic: true } }
                            Row { Text { text: "  for"; color: "#f43f5e"; font.family: "Consolas" } Text { text: " ("; color: "white"; font.family: "Consolas" } Text { text: "int"; color: "#60a5fa"; font.family: "Consolas" } Text { text: " level = 2; level > 0; level--) {"; color: "white"; font.family: "Consolas" } }
                            Row { Text { text: "    pte_t"; color: "#60a5fa"; font.family: "Consolas" } Text { text: " *pte = &pt[PX(level, va)];"; color: "white"; font.family: "Consolas" } }
                            Text { text: "" }
                            Row { Text { text: "    if"; color: "#f43f5e"; font.family: "Consolas" } Text { text: "(*pte & PTE_V) {"; color: "white"; font.family: "Consolas" } }
                            Row { Text { text: "      pt = (pagetable_t)PTE2PA(*pte);"; color: "white"; font.family: "Consolas" } }
                            Row { Text { text: "    } "; color: "white"; font.family: "Consolas" } Text { text: "else"; color: "#f43f5e"; font.family: "Consolas" } Text { text: " {"; color: "white"; font.family: "Consolas" } }
                            Row { Text { text: "      if"; color: "#f43f5e"; font.family: "Consolas" } Text { text: "(!alloc || (pt = (pde_t*)kalloc()) == 0)"; color: "white"; font.family: "Consolas" } }
                            Row { Text { text: "        return"; color: "#f43f5e"; font.family: "Consolas" } Text { text: " 0;"; color: "white"; font.family: "Consolas" } }
                            Row { Text { text: "      memset(pt, 0, PGSIZE);"; color: "white"; font.family: "Consolas" } }
                            Row { Text { text: "      *pte = PA2PTE(pt) | perm | PTE_V;"; color: "white"; font.family: "Consolas" } }
                            Text { text: "    }" }
                            Text { text: "  }" }
                            Row { Text { text: "  return"; color: "#f43f5e"; font.family: "Consolas" } Text { text: " &pt[PX(0, va)];"; color: "white"; font.family: "Consolas" } }
                            Text { text: "}"; color: "white"; font.family: "Consolas" }
                        }
                    }
                }
            }

            // 🗺️ Right Side: Hardware Mapping Diagram (Sv39 Scheme)
            Rectangle {
                width: (parent.width - 20) * 0.54
                height: 540
                color: Qt.rgba(255, 255, 255, 0.02)
                radius: 16
                border.color: Qt.rgba(139, 92, 246, 0.2)
                border.width: 1

                Item {
                    anchors.fill: parent
                    anchors.margins: 20

                    Text { id: vaTitle; text: "VIRTUAL ADDRESS STRUCTURE (39-bit va)"; color: "#c084fc"; font { bold: true; pixelSize: 11; letterSpacing: 0.5 } }

                    Row {
                        id: vaBar
                        anchors.top: vaTitle.bottom
                        anchors.topMargin: 8
                        width: parent.width; height: 38
                        spacing: 2

                        Rectangle { width: parent.width * 0.22; height: parent.height; color: Qt.rgba(139, 92, 246, 0.15); border.color: "#8b5cf6"; radius: 4
                            Column { anchors.centerIn: parent; Text { text: "L2 Index"; color: "white"; font { bold: true; pixelSize: 10 } } Text { text: "9 bits [38:30]"; color: Qt.rgba(255,255,255,0.4); font.pixelSize: 8 } } }
                        Rectangle { width: parent.width * 0.22; height: parent.height; color: Qt.rgba(139, 92, 246, 0.15); border.color: "#8b5cf6"; radius: 4
                            Column { anchors.centerIn: parent; Text { text: "L1 Index"; color: "white"; font { bold: true; pixelSize: 10 } } Text { text: "9 bits [29:21]"; color: Qt.rgba(255,255,255,0.4); font.pixelSize: 8 } } }
                        Rectangle { width: parent.width * 0.22; height: parent.height; color: Qt.rgba(139, 92, 246, 0.15); border.color: "#8b5cf6"; radius: 4
                            Column { anchors.centerIn: parent; Text { text: "L0 Index"; color: "white"; font { bold: true; pixelSize: 10 } } Text { text: "9 bits [20:12]"; color: Qt.rgba(255,255,255,0.4); font.pixelSize: 8 } } }
                        Rectangle { width: parent.width * 0.30; height: parent.height; color: Qt.rgba(16, 185, 129, 0.15); border.color: "#10b981"; radius: 4
                            Column { anchors.centerIn: parent; Text { text: "Offset"; color: "white"; font { bold: true; pixelSize: 10 } } Text { text: "12 bits [11:0]"; color: Qt.rgba(255,255,255,0.4); font.pixelSize: 8 } } }
                    }

                    Text { text: "THREE-LEVEL PAGE TABLE TREE"; color: "#97969d"; font { bold: true; pixelSize: 10 } anchors.top: vaBar.bottom; anchors.topMargin: 25 }

                    Rectangle { id: tblL2; width: 120; height: 40; x: 10; y: 110; radius: 6; color: Qt.rgba(0,0,0,0.4); border.color: "#8b5cf6"
                        Text { text: "Root Table (L2)"; color: "white"; font.pixelSize: 10; anchors.centerIn: parent } }

                    Rectangle { id: tblL1; width: 120; height: 40; x: 145; y: 170; radius: 6; color: Qt.rgba(0,0,0,0.4); border.color: "#8b5cf6"
                        Text { text: "Table Level 1"; color: "white"; font.pixelSize: 10; anchors.centerIn: parent } }

                    Rectangle { id: tblL0; width: 120; height: 40; x: 280; y: 230; radius: 6; color: Qt.rgba(0,0,0,0.4); border.color: "#8b5cf6"
                        Text { text: "Table Level 0\n(PTE Entry)"; color: "white"; font.pixelSize: 9; horizontalAlignment: Text.AlignHCenter; anchors.centerIn: parent } }

                    Rectangle { id: paBlock; width: 230; height: 45; x: 120; y: 320; radius: 8; color: Qt.rgba(16, 185, 129, 0.12); border.color: "#10b981"
                        Row { anchors.centerIn: parent; spacing: 8
                            Text { text: "PPN (44-bit)"; color: "white"; font { bold: true; pixelSize: 11 } }
                            Rectangle { width: 1; height: 15; color: Qt.rgba(255,255,255,0.2) }
                            Text { text: "Offset (12-bit)"; color: "#6ee7b7"; font { bold: true; pixelSize: 11 } } } }

                    Text { text: "PHYSICAL ADDRESS RESULT (56-bit pa)"; color: "#10b981"; font { bold: true; pixelSize: 11 } anchors.top: paBlock.bottom; anchors.topMargin: 6; anchors.horizontalCenter: paBlock.horizontalCenter }

                    Canvas {
                        anchors.fill: parent
                        onAvailableChanged: if(available) requestPaint()
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset();
                            ctx.strokeStyle = "#8b5cf6"; ctx.lineWidth = 1.5; ctx.fillStyle = "#8b5cf6";

                            ctx.beginPath(); ctx.moveTo(45, 65); ctx.lineTo(45, 110); ctx.stroke();
                            ctx.beginPath(); ctx.moveTo(41, 105); ctx.lineTo(45, 110); ctx.lineTo(49, 105); ctx.fill();

                            ctx.beginPath(); ctx.moveTo(130, 130); ctx.lineTo(205, 130); ctx.lineTo(205, 170); ctx.stroke();
                            ctx.beginPath(); ctx.moveTo(201, 165); ctx.lineTo(205, 170); ctx.lineTo(209, 165); ctx.fill();

                            ctx.beginPath(); ctx.moveTo(265, 190); ctx.lineTo(340, 190); ctx.lineTo(340, 230); ctx.stroke();
                            ctx.beginPath(); ctx.moveTo(336, 225); ctx.lineTo(340, 230); ctx.lineTo(344, 225); ctx.fill();

                            ctx.strokeStyle = "#10b981"; ctx.fillStyle = "#10b981";
                            ctx.beginPath(); ctx.moveTo(340, 270); ctx.lineTo(340, 295); ctx.lineTo(175, 295); ctx.lineTo(175, 320); ctx.stroke();
                            ctx.beginPath(); ctx.moveTo(171, 315); ctx.lineTo(175, 320); ctx.lineTo(179, 315); ctx.fill();

                            ctx.beginPath(); ctx.moveTo(320, 65); ctx.lineTo(320, 95); ctx.lineTo(415, 95); ctx.lineTo(415, 305); ctx.lineTo(285, 305); ctx.lineTo(285, 320); ctx.stroke();
                            ctx.beginPath(); ctx.moveTo(281, 315); ctx.lineTo(285, 320); ctx.lineTo(289, 315); ctx.fill();

                            ctx.strokeStyle = Qt.rgba(139, 92, 246, 0.5); ctx.lineWidth = 1.2; ctx.setLineDash([4, 4]);
                            ctx.beginPath();
                            ctx.moveTo(-180, 138);
                            ctx.bezierCurveTo(-100, 138, -50, 48, 10, 48);
                            ctx.stroke();
                        }
                    }
                }
            }
        }

        // ==========================================
        // 3. EXPLANATION SECTION: Core takeaways
        // ==========================================
        Rectangle {
            width: parent.width
            height: 140
            color: Qt.rgba(255, 255, 255, 0.01)
            radius: 12
            border.color: Qt.rgba(255, 255, 255, 0.05)

            Column {
                anchors.fill: parent; anchors.margins: 15; spacing: 10

                Row { spacing: 10
                    Text { text: "📌"; font.pixelSize: 14 }
                    Text { text: "walk() Function Duty: It emulates in software exactly what the MMU Paging Hardware automatically does behind the scenes to look up the Page Table Entry (PTE) for a given virtual address."; color: Qt.rgba(255, 255, 255, 0.85); font.pixelSize: 12 } }

                Row { spacing: 10
                    Text { text: "📌"; font.pixelSize: 14 }
                    Text { text: "The PX Macro: Extracted indexes use 9 bits per tier directly out of the given Virtual Address to reference array positions inside the corresponding page directories."; color: Qt.rgba(255, 255, 255, 0.85); font.pixelSize: 12 } }

                Row { spacing: 10
                    Text { text: "📌"; font.pixelSize: 14 }
                    Text { text: "PTE_V Flag Assertion: Stands for Valid bit. If matching 1, the hardware proceeds safely down. If matching 0 and alloc flag is true, kalloc() initializes a new page tier on the fly."; color: Qt.rgba(255, 255, 255, 0.85); font.pixelSize: 12 } }
            }
        }
    }
}
