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
        // 1. HEADER: Title & Educational Goal
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
                    text: "LESSON 10: MEMORY CONTEXT SWITCHING & HARDWARE SATP CONTROL"
                    color: "#ffffff"
                    font { family: "Segoe UI"; bold: true; pixelSize: 18; letterSpacing: 0.5 }
                }
                Text {
                    text: "💡 CONCEPTUAL FOCUS: Deep dive into how the RISC-V MMU instantly flips memory perspectives using the satp register, and the critical necessity of cache invalidation via sfence.vma."
                    color: Qt.rgba(255, 255, 255, 0.6)
                    font { family: "Segoe UI"; pixelSize: 12 }
                    wrapMode: Text.WordWrap
                    width: parent.width - 30
                }
            }
        }

        // ==========================================
        // 2. SECTION A: THE ARCHITECTURAL SWITCH VIEW
        // ==========================================
        Rectangle {
            width: parent.width
            height: 240
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 16
            border.color: Qt.rgba(139, 92, 246, 0.15)
            border.width: 1

            Item {
                anchors.fill: parent
                anchors.margins: 20

                Text {
                    id: sectionATitle
                    text: "I. HARDWARE ROOT POINTER CONTROL: FLIPPING THE CPU MEMORY VIEW"
                    color: "#c084fc"
                    font { bold: true; pixelSize: 13; letterSpacing: 0.5 }
                }

                Row {
                    anchors.top: sectionATitle.bottom
                    anchors.topMargin: 20
                    width: parent.width
                    spacing: 20

                    // اليسار: جدول صفحات عملية المستخدم
                    Rectangle {
                        id: ptA
                        width: (parent.width - 180) / 2; height: 130; radius: 10
                        color: Qt.rgba(255, 255, 255, 0.03); border.color: Qt.rgba(255, 255, 255, 0.15)
                        Column { anchors.centerIn: parent; spacing: 5; Text { text: "📂 USER PROCESS PAGE TABLE"; color: "white"; font.bold: true; font.pixelSize: 11 }
                                 Text { text: "• Virtual Space starts from 0x0\n• Trapped inside isolated sandbox"; color: Qt.rgba(255,255,255,0.4); font.pixelSize: 10 } }
                    }

                    // المنتصف: مسجل المعالج satp الحاكم
                    Rectangle {
                        id: satpCoreCard
                        width: 140; height: 130; radius: 12
                        color: Qt.rgba(139, 92, 246, 0.15); border.color: "#8b5cf6"; border.width: 1.5
                        layer.enabled: true; layer.effect: Glow { radius: 8; samples: 13; color: "#8b5cf6"; spread: 0.15 }
                        Column { anchors.centerIn: parent; spacing: 8; Text { text: "📟 REGISTER"; color: "#c084fc"; font { bold: true; pixelSize: 10; letterSpacing: 1 } }
                                 Text { text: "satp"; color: "white"; font { family: "Consolas"; bold: true; pixelSize: 24 } }
                                 Text { text: "Switches Root Pointer"; color: Qt.rgba(255,255,255,0.5); font.pixelSize: 9 } }
                    }

                    // اليمين: جدول صفحات النواة
                    Rectangle {
                        id: ptB
                        width: (parent.width - 180) / 2; height: 130; radius: 10
                        color: Qt.rgba(16, 185, 129, 0.08); border.color: "#10b981"
                        Column { anchors.centerIn: parent; spacing: 5; Text { text: "🛡️ KERNEL PROCESS PAGE TABLE"; color: "white"; font.bold: true; font.pixelSize: 11 }
                                 Text { text: "• Direct map mapping (pa == va)\n• High privilege text protection block"; color: "#6ee7b7"; font.pixelSize: 10 } }
                    }
                }

                Canvas {
                    anchors.fill: parent
                    anchors.top: sectionATitle.bottom
                    anchors.topMargin: 20
                    height: 130
                    onPaint: {
                        var ctx = getContext("2d"); ctx.reset();

                        ctx.strokeStyle = Qt.rgba(139, 92, 246, 0.5); ctx.lineWidth = 1.5; ctx.setLineDash([4, 4]);
                        ctx.beginPath();
                        ctx.moveTo(ptA.x + ptA.width, 65);
                        ctx.lineTo(satpCoreCard.x, 65);
                        ctx.stroke();

                        ctx.strokeStyle = "#10b981"; ctx.lineWidth = 1.5; ctx.setLineDash([4, 4]);
                        ctx.beginPath();
                        ctx.moveTo(satpCoreCard.x + satpCoreCard.width, 65);
                        ctx.lineTo(ptB.x, 65);
                        ctx.stroke();
                    }
                }
            }
        }

        // ==========================================
        // 3. SECTION B: THE TLB FLUSH MECHANISM (Fixed Height to Prevent Overlap)
        // ==========================================
        Rectangle {
            width: parent.width
            height: 175 // تم زيادة وتثبيت الحجم هنا ليتسع للنص الأحمر بالكامل دون أي تداخل
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 16
            border.color: Qt.rgba(244, 63, 94, 0.2)
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 12

                Text {
                    text: "II. HARDWARE PURGE ACTION: THE DYNAMIC OF TLB INVALIDATION"
                    color: "#f43f5e"
                    font { bold: true; pixelSize: 13; letterSpacing: 0.5 }
                }

                Rectangle {
                    width: parent.width
                    height: 110 // زيادة الارتفاع الداخلي للبطاقة الحمراء
                    radius: 10
                    color: Qt.rgba(244, 63, 94, 0.08); border.color: "#f43f5e"; border.width: 1.5
                    layer.enabled: true; layer.effect: Glow { radius: 6; samples: 11; color: "#f43f5e"; spread: 0.1 }

                    Item {
                        anchors.fill: parent
                        anchors.margins: 12

                        Text {
                            id: purgeIcon
                            text: "🧼 🛑"
                            font.pixelSize: 22
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.left: purgeIcon.right
                            anchors.leftMargin: 15
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Text {
                                text: "sfence.vma zero, zero (MANDATORY ASSEMBLER FENCE)"
                                color: "white"
                                font { bold: true; family: "Consolas"; pixelSize: 12 }
                            }
                            Text {
                                text: "Crucial Command: Wipes out the Translation Lookaside Buffer (TLB Cache) instantly. Lacking this instruction causes the hardware pipeline to read stale cached addresses, triggering chaotic overlaps and security drops.";
                                color: "#fca5a5"
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                                width: parent.width // ضبط الالتفاف لأسفل بدقة تامة
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // 4. SECTION C: COMPREHENSIVE TEXTUAL LESSON TAKEAWAYS
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
                    Text { text: "📌 The Supervisor Address Translation Register (satp):"; color: "#c084fc"; font { bold: true; pixelSize: 12 } }
                    Text {
                        text: "The satp register is the master steering wheel for memory maps in RISC-V architectures. It doesn't just hold any reference; it contains the direct physical address pointer of the root page table directory. When the kernel switches execution from Process A to Process B, it loads the new root table token using the macro MAKE_SATP, completely reshaping the processor's active runtime coordinates.";
                        color: Qt.rgba(255, 255, 255, 0.75); font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width
                    }
                }

                Column {
                    width: parent.width
                    spacing: 3
                    Text { text: "📌 The Hidden Hazard (Translation Lookaside Buffer Cache):"; color: "#10b981"; font { bold: true; pixelSize: 12 } }
                    Text {
                        text: "Page table walks require reaching out to physical RAM three consecutive times, which slows down CPU execution speeds. To counter this, hardware caching components implement the TLB (Translation Lookaside Buffer) to save the latest successful virtual-to-physical address conversions. This cache represents a critical trap during table context swaps, as stale records will lead to mapping corruption.";
                        color: Qt.rgba(255, 255, 255, 0.75); font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width
                    }
                }

                Column {
                    width: parent.width
                    spacing: 3
                    Text { text: "📌 TLB Cache Flushing Necessity (sfence.vma):"; color: "#f43f5e"; font { bold: true; pixelSize: 12 } }
                    Text {
                        text: "Executing the assembly line command sfence.vma is non-negotiable right after changing the satp register. This hardware fence instruction orders the core pipeline to empty out all internal cache translation buffers. This guarantees that every following assembly fetch drops deep into the newly activated page tables rather than reading outdated shortcuts.";
                        color: Qt.rgba(255, 255, 255, 0.75); font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width
                    }
                }
            }
        }
    }
}