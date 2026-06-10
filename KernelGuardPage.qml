import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

ScrollView {
    id: scrollRoot
    anchors.fill: parent
    contentWidth: parent.width
    contentHeight: mainColumn.implicitHeight + 60
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    // 💡 الحفاظ على مصفوفة الشرح العلمي العميق التفاعلي الخاص بكِ (Chapter 2 xv6)
    property var lessonData: {
        "1": {
            title: "1. USER SPACE (Ring 3)",
            theory: "The process executes in User Mode. It lacks direct access to CPU/RAM/Disk. When a system service is needed, it invokes a library function (e.g., read, write). This maintains system isolation, preventing the application from crashing the entire OS.",
            code: "void cat(int fd) {\n  char buf[512];\n  int n;\n  while((n = read(fd, buf, 512)) > 0)\n    write(1, buf, n);\n}"
        },
        "2": {
            title: "2. VECTOR LOAD",
            theory: "The syscall ID (e.g., SYS_write = 16) is loaded into register 'a7'. In RISC-V xv6, register 'a7' is strictly reserved to communicate the requested system call to the kernel trap handler.",
            code: "#define SYS_fork   1\n#define SYS_read   3\n#define SYS_write 16\n#define SYS_open  15\n\n// Load index into a7"
        },
        "3": {
            title: "3. ECALL TRAP",
            theory: "The 'ecall' instruction triggers a 'Hardware Trap'. The CPU switches from User Mode (Ring 3) to Supervisor Mode (Ring 0). Control passes to the kernel's trap handler, which is predefined in the 'stvec' register.",
            code: "ecall  // Hardware Trap\n// Switch to Ring 0\n// Jump to stvec"
        },
        "4": {
            title: "4. KERNEL EXEC",
            theory: "The Kernel, now executing with full privileges, reads 'a7', validates arguments from user-space, and dispatches the request to the syscall table. It executes 'sys_write()' safely, then restores the trapframe and returns to user space.",
            code: "void syscall(void) {\n  struct proc *p = myproc();\n  int num = p->trapframe->a7;\n  if(num > 0) {\n    p->trapframe->a0 = syscalls[num]();\n  }\n}"
        }
    }
    property string activeId: "1"

    Column {
        id: mainColumn
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        spacing: 25

        // ==========================================
        // 1. HEADER: Lesson Title
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
                    text: "LESSON 1: THE OS KERNEL AS A GUARD & SYSTEM CALL ARCHITECTURE"
                    color: "#ffffff"
                    font { family: "Segoe UI"; bold: true; pixelSize: 18; letterSpacing: 0.5 }
                }
                Text {
                    text: "💡 CORE CONCEPT: Master the defensive shielding mechanisms of the xv6 kernel, exploring why user apps are denied raw access, and how system calls bridge the privilege boundary."
                    color: Qt.rgba(255, 255, 255, 0.6)
                    font { family: "Segoe UI"; pixelSize: 12 }
                    wrapMode: Text.WordWrap
                    width: parent.width - 30
                }
            }
        }

        // ==========================================
        // 2. SECTION I: THE INTERACTIVE PATHWAY (الدمج الإبداعي)
        // ==========================================
        Rectangle {
            width: parent.width
            height: 480
            color: Qt.rgba(255, 255, 255, 0.02)
            radius: 16
            border.color: Qt.rgba(139, 92, 246, 0.15)
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                Text {
                    text: "I. INTERACTIVE SYSTEM CALL LIFECYCLE: THE TRAPPING PATHWAY"
                    color: "#c084fc"
                    font { bold: true; pixelSize: 13; letterSpacing: 0.5 }
                }

                // شريط المراحل التفاعلي الأصلي الخاص بكِ معاد صياغته بـ Layouts
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    Repeater {
                        model: ["1", "2", "3", "4"]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 75
                            color: activeId === modelData ? Qt.rgba(76 / 255, 29 / 255, 149 / 255, 0.4) : Qt.rgba(255, 255, 255, 0.03)
                            radius: 10
                            border.color: activeId === modelData ? "#c084fc" : Qt.rgba(255, 255, 255, 0.1)
                            border.width: activeId === modelData ? 1.5 : 1

                            layer.enabled: activeId === modelData
                            layer.effect: Glow { radius: 6; samples: 11; color: "#8b5cf6"; spread: 0.2 }

                            Column {
                                anchors.centerIn: parent
                                Text { text: lessonData[modelData].title; color: "#ffffff"; font { family: "Segoe UI"; bold: true; pixelSize: 12 } }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: activeId = modelData
                            }
                        }
                    }
                }

                // منطقة العرض الديناميكي (نظري + كود حسي متفاعل)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 12
                    border.color: Qt.rgba(255, 255, 255, 0.06)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 30

                        // الجانب النظري المحدث
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Text { text: "THEORETICAL DEPTH"; color: "#8b5cf6"; font { family: "Segoe UI"; bold: true; pixelSize: 14 } }
                            Text {
                                text: lessonData[activeId].theory
                                color: "#e5e7eb"; font { family: "Segoe UI"; pixelSize: 13 }; wrapMode: Text.WordWrap; Layout.fillWidth: true
                            }
                        }

                        // الصندوق البرميجي الأنيق
                        Rectangle {
                            Layout.preferredWidth: parent.width * 0.45
                            Layout.fillHeight: true
                            color: "#121214"; radius: 8
                            border.color: Qt.rgba(255, 255, 255, 0.04)

                            Column {
                                anchors.fill: parent; anchors.margins: 15; spacing: 8
                                Text { text: "SOURCE IMPLEMENTATION (xv6 Kernel)"; color: "#10b981"; font { family: "Consolas"; bold: true; pixelSize: 11 } }
                                Rectangle { width: parent.width; height: 1; color: Qt.rgba(255, 255, 255, 0.08) }
                                Text {
                                    text: lessonData[activeId].code
                                    color: "#fbbf24"; font { family: "Consolas"; pixelSize: 12 }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // 3. SECTION II: EXPANDED DETAILED TAKEAWAYS (بطاقات المعلومات النظيفة)
        // ==========================================
        Rectangle {
            width: parent.width
            height: 250
            color: Qt.rgba(255, 255, 255, 0.01)
            radius: 12
            border.color: Qt.rgba(255, 255, 255, 0.05)

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Column {
                    width: parent.width
                    spacing: 3
                    Text { text: "📌 The Core Necessity of Kernel Guarding:"; color: "#c084fc"; font { bold: true; pixelSize: 12 } }
                    Text {
                        text: "Operating systems must employ defensive design. If user applications were allowed to directly write to disk blocks or read unisolated memory registries, a malicious or crashing application would instantly destroy data integrity or pull down the whole hardware machine. Isolation guarantees that user bugs remain confined inside their own process boundaries.";
                        color: Qt.rgba(255, 255, 255, 0.75); font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width
                    }
                }

                Column {
                    width: parent.width
                    spacing: 3
                    Text { text: "📌 Hardware Boundaries Enforcement:"; color: "#10b981"; font { bold: true; pixelSize: 12 } }
                    Text {
                        text: "The separation is not just a software trick; it is strictly controlled by the central processing unit hardware flags. User space processes execute inside unprivileged user rings. They cannot modify system configurations or jump arbitrarily to random kernel code lines. The hardware locks access down until a controlled transaction gateway is invoked.";
                        color: Qt.rgba(255, 255, 255, 0.75); font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width
                    }
                }

                Column {
                    width: parent.width
                    spacing: 3
                    Text { text: "📌 The Controlled Gateway (System Call Traps):"; color: "#ef4444"; font { bold: true; pixelSize: 12 } }
                    Text {
                        text: "The 'ecall' assembly instruction acts as an intentional structural escape tunnel. It drops the unprivileged execution line instantly and hands total control over to a single, hardcoded entry coordinate defined by the kernel inside the supervisor trap vectors. The kernel acts as an elite security guard, inspects user arguments carefully, performs the hardware transaction, and lowers privileges back.";
                        color: Qt.rgba(255, 255, 255, 0.75); font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width
                    }
                }
            }
        }
    }
}
