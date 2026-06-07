import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ScrollView {
    id: scrollRoot
    anchors.fill: parent
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    contentWidth: width

    // الشرح العلمي العميق (مستوحى من Chapter 2 في xv6 book)
    property var lessonData: {
        "1": {
            title: "1. USER SPACE (Ring 3)",
            theory: "The process executes in User Mode. It lacks direct access to CPU/RAM/Disk. When a system service is needed, it invokes a library function (e.g., read, write). This maintains system isolation, preventing the application from crashing the entire OS.",
            code: "void cat(int fd) {\n  char buf[512];\n  int n;\n  while((n = read(fd, buf, 512)) > 0)\n    write(1, buf, n);\n}"
        },
        "2": {
            title: "2. VECTOR LOAD",
            theory: "The syscall ID (e.g., SYS_write = 16) is loaded into register 'a7'. In RISC-V xv6, register 'a7' is strictly reserved to communicate the requested system call to the kernel trap handler.",
            code: "#define SYS_fork  1\n#define SYS_read  3\n#define SYS_write 16\n#define SYS_open  15\n\n// Load index into a7"
        },
        "3": {
            title: "3. ECALL TRAP",
            theory: "The 'ecall' instruction triggers a 'Trap'. The CPU switches from User Mode (Ring 3) to Supervisor Mode (Ring 0). Control passes to the kernel's trap handler, which is predefined in the 'stvec' register.",
            code: "ecall  // Hardware Trap\n// Switch to Ring 0\n// Jump to stvec"
        },
        "4": {
            title: "4. KERNEL EXEC",
            theory: "The Kernel, now executing with full privileges, reads 'a7', validates arguments from user-space, and dispatches the request to the syscall table. It executes 'sys_write()' safely, then restores the trapframe and returns to user space.",
            code: "void syscall(void) {\n  struct proc *p = myproc();\n  int num = p->trapframe->a7;\n  if(num > 0) {\n    p->trapframe->a0 = syscalls[num]();\n  }\n}"
        }
    }
    property string activeId: "1"

    ColumnLayout {
        width: scrollRoot.width - 60
        anchors.horizontalCenter: scrollRoot.horizontalCenter
        spacing: 30

        // العنوان التوضيحي
        Column {
            Layout.fillWidth: true
            topPadding: 30
            Text { text: "OS ARCHITECTURE: THE TRAP MECHANISM"; color: "#ffffff"; font { pixelSize: 28; bold: true } }
            Text { text: "The mechanism that prevents user-space processes from corrupting the kernel integrity."; color: "#a0a0a0"; font.pixelSize: 15 }
        }

        // المسار التفاعلي
        RowLayout {
            Layout.fillWidth: true
            spacing: 15
            Repeater {
                model: ["1", "2", "3", "4"]
                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: activeId === modelData ? "#4c1d95" : "#1e1e24"
                    radius: 8
                    border.color: activeId === modelData ? "#c084fc" : "#374151"
                    Column {
                        anchors.centerIn: parent
                        Text { text: lessonData[modelData].title; color: "#fff"; font.bold: true }
                    }
                    MouseArea { anchors.fill: parent; onClicked: activeId = modelData }
                }
            }
        }

        // منطقة العمق العلمي (نظري + كود)
        Rectangle {
            Layout.fillWidth: true
            height: 350
            color: "#0a0a0c"; radius: 10
            border.color: "#374151"

            RowLayout {
                anchors.fill: parent; anchors.margins: 25
                spacing: 40

                ColumnLayout {
                    Layout.fillWidth: true
                    Text { text: "THEORETICAL DEPTH"; color: "#8b5cf6"; font.bold: true; font.pixelSize: 16 }
                    Text {
                        text: lessonData[activeId].theory
                        color: "#e5e7eb"; font.pixelSize: 15; wrapMode: Text.WordWrap; Layout.fillWidth: true
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 300; Layout.fillHeight: true
                    color: "#161616"; radius: 6
                    Column {
                        anchors.fill: parent; anchors.margins: 15
                        Text { text: "SOURCE (syscall.c / trap.c)"; color: "#10b981"; font.bold: true; font.pixelSize: 11 }
                        Text { text: lessonData[activeId].code; color: "#fbbf24"; font.family: "Monospace"; font.pixelSize: 13 }
                    }
                }
            }
        }
    }
}