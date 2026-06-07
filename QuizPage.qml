import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: rootQuiz
    anchors.fill: parent

    // المعرف الخاص بكل كويز، سيتم تمريره من الـ Loader أو عند تغيير الصفحة
    property string quizName: "default_quiz"
    property int savedScore: -1
    property bool isTakingQuiz: false

    Component.onCompleted: {
        savedScore = dbManager.getQuizScore(quizName);
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
                        Text { text: "Quiz: " + quizName.toUpperCase(); color: "white"; font.pixelSize: 22; font.bold: true }
                        Text {
                            text: savedScore === -1 ? "Status: Not Started" : "Last Score: " + savedScore + " / 3"
                            color: savedScore === -1 ? "#97969d" : "#4ade80"
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: savedScore === -1 ? "Start Quiz" : "Retake Quiz"
                        visible: !isTakingQuiz
                        onClicked: {
                            isTakingQuiz = true;
                            // تصفير الخيارات
                            q1.selectedIndex = -1; q2.selectedIndex = -1; q3.selectedIndex = -1;
                            resultText.text = "";
                        }
                    }
                }
            }

            ScrollView {
                width: parent.width; height: parent.height - 180
                clip: true; visible: isTakingQuiz

                Column {
                    width: parent.width; spacing: 35
                    // الأسئلة (يمكنك تغيير النصوص هنا لكل صفحة كويز)
                    Column {
                        id: q1; property int selectedIndex: -1; property int correctIndex: 1
                        Text { text: "1. Default scheduling algorithm in xv6?"; color: "white"; font.bold: true }
                        Repeater {
                            model: ["FCFS", "Round Robin", "SJF"]
                            delegate: Rectangle {
                                width: 500; height: 40; radius: 8
                                color: q1.selectedIndex === index ? "#4b2ac0" : "#1AFFFFFF"
                                MouseArea { anchors.fill: parent; onClicked: q1.selectedIndex = index }
                                Text { text: modelData; color: "white"; anchors.centerIn: parent }
                            }
                        }
                    }
                    // (يمكنك إضافة q2 و q3 بنفس الطريقة)
                }
            }

            Button {
                text: "Submit"
                visible: isTakingQuiz
                onClicked: {
                    var score = (q1.selectedIndex === q1.correctIndex ? 1 : 0); // مثال
                    dbManager.saveQuizScore(quizName, score);
                    savedScore = score;
                    isTakingQuiz = false;
                }
            }
        }
    }
}