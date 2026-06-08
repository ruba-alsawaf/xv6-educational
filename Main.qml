import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects // لعمل التأثيرات (Blur)

ApplicationWindow {
    id: adminWindow
    visible: true
    width: 1000
    height: 700
    title: "Admin Dashboard - XV6 OS"

    // ========== 1. Background ==========

    Rectangle {
            anchors.fill: parent
            z: -1 // هذا يجعلها في الطبقة الأخيرة (الخلفية المطلقة)

            Image {
                id: backgroundImage
                source: ":/new/prefix1/test.png"
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                visible: false
            }

            // 2. الـ Blur يأخذ الـ id الخاص بالصورة كمصدر
            FastBlur {
                anchors.fill: parent
                source: backgroundImage // <-- هنا التعديل: نستخدم الـ ID وليس المسار
                radius: 32
            }

            // 3. طبقة التعتيم (الشفافية)
            color: Qt.rgba(0, 0, 0, 0.4)
        }

    property string selectedStudent: ""

    function refreshStudentList() {
        studentListModel.clear()
        var students = dbManager.getAllStudents()
        for (var i = 0; i < students.length; i++) {
            studentListModel.append({ "username": students[i] })
        }
        if (studentListModel.count > 0 && selectedStudent === "") {
            selectStudent(studentListModel.get(0).username)
        }
    }

    function selectStudent(username) {
        selectedStudent = username
        studentScoresModel.clear()
        var scores = dbManager.getStudentScores(username)
        for (var i = 0; i < scores.length; i++) {
            studentScoresModel.append({ "quizName": scores[i].quizName, "score": scores[i].score })
        }
    }

    Component.onCompleted: refreshStudentList()

    ListModel { id: studentListModel }
    ListModel { id: studentScoresModel }

    // ========== 2. Dashboard UI ==========
    RowLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        // Right Section (Student Management)
        Rectangle {
            Layout.preferredWidth: parent.width * 0.4
            Layout.fillHeight: true
            color: Qt.rgba(255, 255, 255, 0.08)
            radius: 20
            border.color: Qt.rgba(255, 255, 255, 0.1)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Text { text: "Student Management"; color: "white"; font.pixelSize: 22; font.bold: true; Layout.alignment: Qt.AlignHCenter }

                // Add Student Form
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    TextField { id: txtUsername; placeholderText: "Username"; Layout.fillWidth: true; color: "white"; background: Rectangle { color: Qt.rgba(0,0,0,0.2); radius: 8 } }
                    TextField { id: txtPassword; placeholderText: "Password"; echoMode: TextInput.Password; Layout.fillWidth: true; color: "white"; background: Rectangle { color: Qt.rgba(0,0,0,0.2); radius: 8 } }
                    Button {
                        text: "Add Student"; Layout.fillWidth: true
                        background: Rectangle { color: "#4f46e5"; radius: 8 }
                        contentItem: Text { text: "Add Student"; color: "white"; horizontalAlignment: Text.AlignHCenter }
                        onClicked: {
                            if (dbManager.addStudent(txtUsername.text, txtPassword.text)) {
                                refreshStudentList();
                                txtUsername.clear();
                                txtPassword.clear();
                                lblStatus.text = "Success!";
                            } else {
                                lblStatus.text = "Error: Username exists";
                            }
                        }
                    }
                    Text { id: lblStatus; color: "#fbbf24"; font.pixelSize: 12; Layout.alignment: Qt.AlignHCenter }
                }

                Text { text: "Registered Students:"; color: "#a1a1aa"; font.pixelSize: 14; font.bold: true }

                ScrollView {
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    ListView {
                        model: studentListModel; spacing: 5
                        delegate: ItemDelegate {
                            width: ListView.view.width; height: 45
                            onClicked: selectStudent(model.username)
                            background: Rectangle { color: (selectedStudent === model.username) ? "#4f46e5" : "transparent"; radius: 8 }
                            contentItem: Text { text: "👤 " + model.username; color: "white"; verticalAlignment: Text.AlignVCenter; anchors.leftMargin: 10 }
                        }
                    }
                }
            }
        }

        // Left Section (Scores)
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Qt.rgba(255, 255, 255, 0.08)
            radius: 20
            border.color: Qt.rgba(255, 255, 255, 0.1)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Text { text: selectedStudent !== "" ? "Scores for: " + selectedStudent : "Select a student"; color: "white"; font.pixelSize: 18; font.bold: true }

                ScrollView {
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    ListView {
                        model: studentScoresModel; spacing: 10
                        delegate: Rectangle {
                            width: ListView.view.width; height: 50; color: Qt.rgba(0,0,0,0.2); radius: 10
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 10
                                Text { text: model.quizName; color: "white"; font.bold: true }
                                Item { Layout.fillWidth: true }
                                Rectangle { width: 60; height: 30; color: "#10b981"; radius: 6; Text { text: model.score; color: "white"; anchors.centerIn: parent } }
                            }
                        }
                    }
                }
            }
        }
    }
}