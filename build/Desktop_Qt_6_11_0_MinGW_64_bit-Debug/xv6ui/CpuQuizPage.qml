import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: rootQuiz
    anchors.fill: parent

    // إعدادات الكويز
    property string quizName: "cpu_quiz"
    property int savedScore: -1
    property bool isTakingQuiz: false
    property string currentUser: ""

    Component.onCompleted: {
        // جلب اسم المستخدم من C++
        currentUser = dbManager.getCurrentUser();
        // جلب السكور الخاص بهذا الطالب وهذا الكويز
        savedScore = dbManager.getQuizScore(currentUser, quizName);
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 20
        color: "#1AFFFFFF"
        radius: 16
        border.color: "#33FFFFFF"
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 25

            // شريط الحالة العلوي
            Rectangle {
                width: parent.width; height: 70
                color: "#15FFFFFF"; radius: 12
                RowLayout {
                    anchors.fill: parent; anchors.margins: 15
                    Column {
                        Text { text: "CPU SCHEDULING QUIZ"; color: "white"; font.pixelSize: 22; font.bold: true }
                        Text {
                            text: savedScore === -1 ? "Status: Not Started" : "Your Last Score: " + savedScore + " / 3"
                            color: savedScore === -1 ? "#97969d" : "#4ade80"
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: savedScore === -1 ? "Start Quiz" : "Retake Quiz"
                        visible: !isTakingQuiz
                        onClicked: {
                            isTakingQuiz = true;
                            q1.selectedIndex = -1; q2.selectedIndex = -1; q3.selectedIndex = -1;
                            resultText.text = "";
                        }
                    }
                }
            }

            // منطقة الأسئلة (تظهر فقط عند بدء الاختبار)
            ScrollView {
                width: parent.width; height: parent.height - 180
                clip: true
                visible: isTakingQuiz

                Column {
                    width: parent.width; spacing: 35

                    // سؤال 1
                    Column { id: q1; property int selectedIndex: -1; property int correctIndex: 1; spacing: 10
                        Text { text: "1. What is the default scheduling algorithm in xv6?"; color: "white"; font.pixelSize: 16 }
                        Repeater {
                            model: ["FCFS", "Round Robin", "SJF"]
                            delegate: Rectangle {
                                width: rootQuiz.width * 0.8; height: 40; radius: 8
                                color: q1.selectedIndex === index ? "#4b2ac0" : "#2AFFFFFF"
                                MouseArea { anchors.fill: parent; onClicked: q1.selectedIndex = index }
                                Text { text: modelData; color: "white"; anchors.centerIn: parent }
                            }
                        }
                    }

                    // سؤال 2
                    Column { id: q2; property int selectedIndex: -1; property int correctIndex: 2; spacing: 10
                        Text { text: "2. Which system call creates a new process?"; color: "white"; font.pixelSize: 16 }
                        Repeater {
                            model: ["exec()", "wait()", "fork()"]
                            delegate: Rectangle {
                                width: rootQuiz.width * 0.8; height: 40; radius: 8
                                color: q2.selectedIndex === index ? "#4b2ac0" : "#2AFFFFFF"
                                MouseArea { anchors.fill: parent; onClicked: q2.selectedIndex = index }
                                Text { text: modelData; color: "white"; anchors.centerIn: parent }
                            }
                        }
                    }

                    // سؤال 3
                    Column { id: q3; property int selectedIndex: -1; property int correctIndex: 0; spacing: 10
                        Text { text: "3. What does the exec() function do?"; color: "white"; font.pixelSize: 16 }
                        Repeater {
                            model: ["Replaces memory space", "Ends process", "Creates a copy"]
                            delegate: Rectangle {
                                width: rootQuiz.width * 0.8; height: 40; radius: 8
                                color: q3.selectedIndex === index ? "#4b2ac0" : "#2AFFFFFF"
                                MouseArea { anchors.fill: parent; onClicked: q3.selectedIndex = index }
                                Text { text: modelData; color: "white"; anchors.centerIn: parent }
                            }
                        }
                    }
                }
            }

            // زر الإرسال
            Button {
                text: "Submit Answers"
                visible: isTakingQuiz
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    if (q1.selectedIndex === -1 || q2.selectedIndex === -1 || q3.selectedIndex === -1) {
                        resultText.text = "Please answer all questions!";
                        return;
                    }

                    var score = 0;
                    if (q1.selectedIndex === q1.correctIndex) score++;
                    if (q2.selectedIndex === q2.correctIndex) score++;
                    if (q3.selectedIndex === q3.correctIndex) score++;

                    // حفظ السكور باستخدام اسم الطالب الحالي
                    dbManager.saveQuizScore(currentUser, quizName, score);
                    savedScore = score;
                    isTakingQuiz = false;
                }
            }
            Text { id: resultText; color: "#ff5c5c"; anchors.horizontalCenter: parent.horizontalCenter }
        }
    }
}