import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ScrollView {
    id: scrollRoot
    anchors.fill: parent
    contentWidth: width
    contentHeight: mainCol.implicitHeight + 40
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    signal requestNavigate(string pageSource)
    property string quizName:    "round_robin_quiz"
    property string lessonSource:"RoundRobinPage.qml"
    property int    savedScore:  -1
    property bool   showResults: false
    property string currentUser: ""

    Component.onCompleted: {
        currentUser = dbManager.getCurrentUser()
        savedScore  = dbManager.getQuizScore(currentUser, quizName)
    }

    Column {
        id: mainCol
        width: scrollRoot.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top; anchors.topMargin: 20
        spacing: 16

        Rectangle {
            width: parent.width; height: 82; radius: 14
            color: Qt.rgba(255,255,255,0.03); border.color: "#14b8a6"; border.width: 1
            Column { anchors.centerIn: parent; spacing: 5
                Text { text: "ROUND-ROBIN  QUIZ"; color: "#14b8a6"
                    font.bold: true; font.pixelSize: 18; font.family: "Segoe UI"; font.letterSpacing: 0.5
                    anchors.horizontalCenter: parent.horizontalCenter }
                Text {
                    text: scrollRoot.savedScore===-1?"Not taken yet"
                          :scrollRoot.savedScore+" / 5   —   "+(scrollRoot.savedScore>=4?"Excellent!":scrollRoot.savedScore>=3?"Good":"Keep studying")
                    color: scrollRoot.savedScore===-1?Qt.rgba(255,255,255,0.4):scrollRoot.savedScore>=4?"#10b981":scrollRoot.savedScore>=3?"#fbbf24":"#f43f5e"
                    font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter }
            }
        }

            Column { id: q1
                property int selectedIndex: -1; property int correctIndex: 1
                property bool submitted: scrollRoot.showResults
                property bool isCorrect: selectedIndex === correctIndex
                property bool answered:  selectedIndex !== -1
                width: parent.width; spacing: 8
                Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.07) }
                Text { text: "1.  xv6 gives scheduling priority to processes that have been waiting longer."; color: "white"; font.pixelSize: 13
                    font.family: "Segoe UI"; width: parent.width; wrapMode: Text.WordWrap; lineHeight: 1.45 }
                Row { spacing: 14; width: parent.width
                    Repeater { model: ["True","False"]
                        delegate: Rectangle {
                            width: (q1.width-14)/2; height: 54; radius: 10
                            color: { if(!q1.submitted)return q1.selectedIndex===index?Qt.rgba(75,42,192,0.35):Qt.rgba(255,255,255,0.05)
                                if(index===q1.correctIndex)return Qt.rgba(16,185,129,0.25)
                                if(index===q1.selectedIndex)return Qt.rgba(239,68,68,0.20)
                                return Qt.rgba(255,255,255,0.03) }
                            border.color: { if(!q1.submitted)return q1.selectedIndex===index?"#8b5cf6":Qt.rgba(255,255,255,0.10)
                                if(index===q1.correctIndex)return"#10b981"
                                if(index===q1.selectedIndex)return"#ef4444"
                                return Qt.rgba(255,255,255,0.06) }
                            border.width: 1
                            Text { anchors.centerIn: parent; text: index===0?"TRUE":"FALSE"
                                color: { if(!q1.submitted)return q1.selectedIndex===index?"white":Qt.rgba(255,255,255,0.55)
                                    if(index===q1.correctIndex)return"#10b981"
                                    if(index===q1.selectedIndex)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.22) }
                                font.pixelSize: 15; font.bold: true; font.family: "Segoe UI" }
                            MouseArea { anchors.fill: parent; enabled: !q1.submitted; cursorShape: Qt.PointingHandCursor
                                onClicked: q1.selectedIndex = index } } } }
            Column{id:q2
                property int m0:-1;property int m1:-1;property int m2:-1;property int m3:-1
                property bool submitted:scrollRoot.showResults
                property bool isCorrect:m0===3 && m1===2 && m2===0 && m3===1
                property bool answered:m0!==-1&&m1!==-1&&m2!==-1&&m3!==-1
                width:parent.width;spacing:8
                Rectangle{width:parent.width;height:1;color:Qt.rgba(255,255,255,0.07)}
                Text{text:"2.  Match each process state to its meaning:";color:"white";font.pixelSize:13;font.family:"Segoe UI"
                    width:parent.width;wrapMode:Text.WordWrap;lineHeight:1.45}
                Rectangle{width:q2.width;radius:10
                    color:Qt.rgba(255,255,255,0.04);border.color:Qt.rgba(255,255,255,0.09);border.width:1
                    height:dc2.implicitHeight+18
                    Column{id:dc2;anchors.top:parent.top;anchors.left:parent.left
                        anchors.right:parent.right;anchors.margins:10;spacing:5
                        Text{text:"A.  Exited but parent has not called wait()";color:Qt.rgba(255,255,255,0.68);font.pixelSize:11;font.family:"Segoe UI";width:parent.width;wrapMode:Text.WordWrap}
                        Text{text:"B.  Currently on the CPU";color:Qt.rgba(255,255,255,0.68);font.pixelSize:11;font.family:"Segoe UI";width:parent.width;wrapMode:Text.WordWrap}
                        Text{text:"C.  Waiting on a channel (e.g. I/O)";color:Qt.rgba(255,255,255,0.68);font.pixelSize:11;font.family:"Segoe UI";width:parent.width;wrapMode:Text.WordWrap}
                        Text{text:"D.  Ready to run, waiting for CPU";color:Qt.rgba(255,255,255,0.68);font.pixelSize:11;font.family:"Segoe UI";width:parent.width;wrapMode:Text.WordWrap}
                    }}
                Column{width:q2.width;spacing:6

                    Rectangle{width:q2.width;height:48;radius:8
                        color:{if(!q2.submitted)return Qt.rgba(255,255,255,0.04)
                            if(q2.m0===3)return Qt.rgba(16,185,129,0.10)
                            return Qt.rgba(239,68,68,0.08)}
                        border.color:Qt.rgba(255,255,255,0.08);border.width:1
                        Text{anchors.left:parent.left;anchors.leftMargin:12;anchors.verticalCenter:parent.verticalCenter
                            width:100;text:"RUNNABLE";color:"white";font.pixelSize:12;font.bold:true
                            font.family:"Segoe UI";elide:Text.ElideRight}
                        Row{anchors.right:parent.right;anchors.rightMargin:10;anchors.verticalCenter:parent.verticalCenter
                            spacing:8

                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m0===0?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(0===3)return Qt.rgba(16,185,129,0.28)
                                if(q2.m0===0)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m0===0?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(0===3)return"#10b981"
                                if(q2.m0===0)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"A"
                                color:{if(!q2.submitted)return q2.m0===0?"white":Qt.rgba(255,255,255,0.45)
                                    if(0===3)return"#10b981"
                                    if(q2.m0===0)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m0=0}}
                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m0===1?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(1===3)return Qt.rgba(16,185,129,0.28)
                                if(q2.m0===1)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m0===1?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(1===3)return"#10b981"
                                if(q2.m0===1)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"B"
                                color:{if(!q2.submitted)return q2.m0===1?"white":Qt.rgba(255,255,255,0.45)
                                    if(1===3)return"#10b981"
                                    if(q2.m0===1)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m0=1}}
                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m0===2?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(2===3)return Qt.rgba(16,185,129,0.28)
                                if(q2.m0===2)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m0===2?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(2===3)return"#10b981"
                                if(q2.m0===2)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"C"
                                color:{if(!q2.submitted)return q2.m0===2?"white":Qt.rgba(255,255,255,0.45)
                                    if(2===3)return"#10b981"
                                    if(q2.m0===2)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m0=2}}
                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m0===3?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(3===3)return Qt.rgba(16,185,129,0.28)
                                if(q2.m0===3)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m0===3?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(3===3)return"#10b981"
                                if(q2.m0===3)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"D"
                                color:{if(!q2.submitted)return q2.m0===3?"white":Qt.rgba(255,255,255,0.45)
                                    if(3===3)return"#10b981"
                                    if(q2.m0===3)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m0=3}}
                        }}
                    Rectangle{width:q2.width;height:48;radius:8
                        color:{if(!q2.submitted)return Qt.rgba(255,255,255,0.04)
                            if(q2.m1===2)return Qt.rgba(16,185,129,0.10)
                            return Qt.rgba(239,68,68,0.08)}
                        border.color:Qt.rgba(255,255,255,0.08);border.width:1
                        Text{anchors.left:parent.left;anchors.leftMargin:12;anchors.verticalCenter:parent.verticalCenter
                            width:100;text:"SLEEPING";color:"white";font.pixelSize:12;font.bold:true
                            font.family:"Segoe UI";elide:Text.ElideRight}
                        Row{anchors.right:parent.right;anchors.rightMargin:10;anchors.verticalCenter:parent.verticalCenter
                            spacing:8

                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m1===0?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(0===2)return Qt.rgba(16,185,129,0.28)
                                if(q2.m1===0)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m1===0?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(0===2)return"#10b981"
                                if(q2.m1===0)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"A"
                                color:{if(!q2.submitted)return q2.m1===0?"white":Qt.rgba(255,255,255,0.45)
                                    if(0===2)return"#10b981"
                                    if(q2.m1===0)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m1=0}}
                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m1===1?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(1===2)return Qt.rgba(16,185,129,0.28)
                                if(q2.m1===1)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m1===1?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(1===2)return"#10b981"
                                if(q2.m1===1)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"B"
                                color:{if(!q2.submitted)return q2.m1===1?"white":Qt.rgba(255,255,255,0.45)
                                    if(1===2)return"#10b981"
                                    if(q2.m1===1)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m1=1}}
                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m1===2?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(2===2)return Qt.rgba(16,185,129,0.28)
                                if(q2.m1===2)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m1===2?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(2===2)return"#10b981"
                                if(q2.m1===2)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"C"
                                color:{if(!q2.submitted)return q2.m1===2?"white":Qt.rgba(255,255,255,0.45)
                                    if(2===2)return"#10b981"
                                    if(q2.m1===2)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m1=2}}
                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m1===3?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(3===2)return Qt.rgba(16,185,129,0.28)
                                if(q2.m1===3)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m1===3?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(3===2)return"#10b981"
                                if(q2.m1===3)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"D"
                                color:{if(!q2.submitted)return q2.m1===3?"white":Qt.rgba(255,255,255,0.45)
                                    if(3===2)return"#10b981"
                                    if(q2.m1===3)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m1=3}}
                        }}
                    Rectangle{width:q2.width;height:48;radius:8
                        color:{if(!q2.submitted)return Qt.rgba(255,255,255,0.04)
                            if(q2.m2===0)return Qt.rgba(16,185,129,0.10)
                            return Qt.rgba(239,68,68,0.08)}
                        border.color:Qt.rgba(255,255,255,0.08);border.width:1
                        Text{anchors.left:parent.left;anchors.leftMargin:12;anchors.verticalCenter:parent.verticalCenter
                            width:100;text:"ZOMBIE";color:"white";font.pixelSize:12;font.bold:true
                            font.family:"Segoe UI";elide:Text.ElideRight}
                        Row{anchors.right:parent.right;anchors.rightMargin:10;anchors.verticalCenter:parent.verticalCenter
                            spacing:8

                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m2===0?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(0===0)return Qt.rgba(16,185,129,0.28)
                                if(q2.m2===0)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m2===0?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(0===0)return"#10b981"
                                if(q2.m2===0)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"A"
                                color:{if(!q2.submitted)return q2.m2===0?"white":Qt.rgba(255,255,255,0.45)
                                    if(0===0)return"#10b981"
                                    if(q2.m2===0)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m2=0}}
                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m2===1?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(1===0)return Qt.rgba(16,185,129,0.28)
                                if(q2.m2===1)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m2===1?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(1===0)return"#10b981"
                                if(q2.m2===1)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"B"
                                color:{if(!q2.submitted)return q2.m2===1?"white":Qt.rgba(255,255,255,0.45)
                                    if(1===0)return"#10b981"
                                    if(q2.m2===1)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m2=1}}
                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m2===2?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(2===0)return Qt.rgba(16,185,129,0.28)
                                if(q2.m2===2)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m2===2?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(2===0)return"#10b981"
                                if(q2.m2===2)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"C"
                                color:{if(!q2.submitted)return q2.m2===2?"white":Qt.rgba(255,255,255,0.45)
                                    if(2===0)return"#10b981"
                                    if(q2.m2===2)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m2=2}}
                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m2===3?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(3===0)return Qt.rgba(16,185,129,0.28)
                                if(q2.m2===3)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m2===3?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(3===0)return"#10b981"
                                if(q2.m2===3)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"D"
                                color:{if(!q2.submitted)return q2.m2===3?"white":Qt.rgba(255,255,255,0.45)
                                    if(3===0)return"#10b981"
                                    if(q2.m2===3)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m2=3}}
                        }}
                    Rectangle{width:q2.width;height:48;radius:8
                        color:{if(!q2.submitted)return Qt.rgba(255,255,255,0.04)
                            if(q2.m3===1)return Qt.rgba(16,185,129,0.10)
                            return Qt.rgba(239,68,68,0.08)}
                        border.color:Qt.rgba(255,255,255,0.08);border.width:1
                        Text{anchors.left:parent.left;anchors.leftMargin:12;anchors.verticalCenter:parent.verticalCenter
                            width:100;text:"RUNNING";color:"white";font.pixelSize:12;font.bold:true
                            font.family:"Segoe UI";elide:Text.ElideRight}
                        Row{anchors.right:parent.right;anchors.rightMargin:10;anchors.verticalCenter:parent.verticalCenter
                            spacing:8

                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m3===0?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(0===1)return Qt.rgba(16,185,129,0.28)
                                if(q2.m3===0)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m3===0?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(0===1)return"#10b981"
                                if(q2.m3===0)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"A"
                                color:{if(!q2.submitted)return q2.m3===0?"white":Qt.rgba(255,255,255,0.45)
                                    if(0===1)return"#10b981"
                                    if(q2.m3===0)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m3=0}}
                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m3===1?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(1===1)return Qt.rgba(16,185,129,0.28)
                                if(q2.m3===1)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m3===1?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(1===1)return"#10b981"
                                if(q2.m3===1)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"B"
                                color:{if(!q2.submitted)return q2.m3===1?"white":Qt.rgba(255,255,255,0.45)
                                    if(1===1)return"#10b981"
                                    if(q2.m3===1)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m3=1}}
                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m3===2?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(2===1)return Qt.rgba(16,185,129,0.28)
                                if(q2.m3===2)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m3===2?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(2===1)return"#10b981"
                                if(q2.m3===2)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"C"
                                color:{if(!q2.submitted)return q2.m3===2?"white":Qt.rgba(255,255,255,0.45)
                                    if(2===1)return"#10b981"
                                    if(q2.m3===2)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m3=2}}
                        Rectangle{width:38;height:38;radius:8
                            color:{if(!q2.submitted)return q2.m3===3?Qt.rgba(75,42,192,0.45):Qt.rgba(255,255,255,0.07)
                                if(3===1)return Qt.rgba(16,185,129,0.28)
                                if(q2.m3===3)return Qt.rgba(239,68,68,0.22)
                                return Qt.rgba(255,255,255,0.04)}
                            border.color:{if(!q2.submitted)return q2.m3===3?"#8b5cf6":Qt.rgba(255,255,255,0.12)
                                if(3===1)return"#10b981"
                                if(q2.m3===3)return"#ef4444"
                                return Qt.rgba(255,255,255,0.07)}
                            border.width:1
                            Text{anchors.centerIn:parent;text:"D"
                                color:{if(!q2.submitted)return q2.m3===3?"white":Qt.rgba(255,255,255,0.45)
                                    if(3===1)return"#10b981"
                                    if(q2.m3===3)return"#ef4444"
                                    return Qt.rgba(255,255,255,0.20)}
                                font.pixelSize:13;font.bold:true}
                            MouseArea{anchors.fill:parent;enabled:!q2.submitted;cursorShape:Qt.PointingHandCursor
                                onClicked:q2.m3=3}}
                        }}
                }}
            Column { id: q3
                property int selectedIndex: -1; property int correctIndex: 1
                property bool submitted: scrollRoot.showResults
                property bool isCorrect: selectedIndex === correctIndex
                property bool answered:  selectedIndex !== -1
                width: parent.width; spacing: 8
                Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.07) }
                Text { text: "3.  An infinite-loop process with no syscalls gets preempted by ___."; color: "white"; font.pixelSize: 13
                    font.family: "Segoe UI"; width: parent.width; wrapMode: Text.WordWrap; lineHeight: 1.45 }
                Repeater { model: ["Kernel polls for others", "CLINT timer interrupt → yield()", "Another process signals it", "Watchdog resets CPU"]
                    delegate: Rectangle {
                        width: q3.width; height: 44; radius: 10
                        color: { if (!q3.submitted) return q3.selectedIndex===index?Qt.rgba(75,42,192,0.35):Qt.rgba(255,255,255,0.05)
                            if(index===q3.correctIndex)return Qt.rgba(16,185,129,0.25)
                            if(index===q3.selectedIndex)return Qt.rgba(239,68,68,0.20)
                            return Qt.rgba(255,255,255,0.03) }
                        border.color: { if(!q3.submitted)return q3.selectedIndex===index?"#8b5cf6":Qt.rgba(255,255,255,0.10)
                            if(index===q3.correctIndex)return"#10b981"
                            if(index===q3.selectedIndex)return"#ef4444"
                            return Qt.rgba(255,255,255,0.06) }
                        border.width: 1
                        Text { anchors.centerIn: parent
                            text: ["A","B","C","D"][index]+".  "+modelData
                            color: { if(!q3.submitted)return"white"
                                if(index===q3.correctIndex)return"#10b981"
                                if(index===q3.selectedIndex)return"#ef4444"
                                return Qt.rgba(255,255,255,0.35) }
                            font.pixelSize: 12; font.family: "Segoe UI"
                            font.bold: q3.submitted&&(index===q3.correctIndex||index===q3.selectedIndex)
                            width: parent.width-28; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter }
                        MouseArea { anchors.fill: parent; enabled: !q3.submitted; cursorShape: Qt.PointingHandCursor
                            onClicked: q3.selectedIndex = index } } } }
            Column { id: q4
                property int r0: 0; property int r1: 0; property int r2: 0; property int r3: 0
                property int nextClick: 1
                property bool submitted: scrollRoot.showResults
                property bool isCorrect: r0===3 && r1===1 && r2===4 && r3===2
                property bool answered: r0>0 && r1>0 && r2>0 && r3>0
                width: parent.width; spacing: 8
                Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.07) }
                Text { text: "4.  Click the timer-preemption steps in order (first → last):"; color: "white"; font.pixelSize: 13
                    font.family: "Segoe UI"; width: parent.width; wrapMode: Text.WordWrap; lineHeight: 1.45 }
                Text { text: q4.submitted?"":"Tap items in order 1→4.  Tap any numbered item to reset all."
                    color: Qt.rgba(255,255,255,0.28); font.pixelSize: 10; font.italic: true }

                Rectangle { width: q4.width; height: 52; radius: 10
                    color: { if(!q4.submitted)return q4.r0>0?Qt.rgba(75,42,192,0.28):Qt.rgba(255,255,255,0.05)
                        if(q4.r0===3)return Qt.rgba(16,185,129,0.22)
                        return q4.r0>0?Qt.rgba(239,68,68,0.18):Qt.rgba(255,255,255,0.03) }
                    border.color: { if(!q4.submitted)return q4.r0>0?"#8b5cf6":Qt.rgba(255,255,255,0.10)
                        if(q4.r0===3)return"#10b981"
                        return q4.r0>0?"#ef4444":Qt.rgba(255,255,255,0.07) }
                    border.width: 1
                    Rectangle { anchors.left: parent.left; anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28; height: 28; radius: 6
                        color: q4.r0>0?"#8b5cf6":Qt.rgba(255,255,255,0.10)
                        Text { anchors.centerIn: parent; text: q4.r0>0?q4.r0.toString():"?"
                            color: "white"; font.pixelSize: 12; font.bold: true } }
                    Text { anchors.left: parent.left; anchors.leftMargin: 50
                        anchors.right: ht40.left; anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Scheduler selects next RUNNABLE process"; color: "white"; font.pixelSize: 12; font.family: "Segoe UI"; wrapMode: Text.WordWrap }
                    Text { id: ht40; anchors.right: parent.right; anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        visible: q4.submitted && q4.r0 !== 3
                        text: "✓3"; color: "#10b981"; font.pixelSize: 11; font.bold: true }
                    MouseArea { anchors.fill: parent; enabled: !q4.submitted; cursorShape: Qt.PointingHandCursor
                        onClicked: { if(q4.r0>0){q4.r0=0;q4.r1=0;q4.r2=0;q4.r3=0;q4.nextClick=1}
                            else{q4.r0=q4.nextClick;q4.nextClick++} } } }
                Rectangle { width: q4.width; height: 52; radius: 10
                    color: { if(!q4.submitted)return q4.r1>0?Qt.rgba(75,42,192,0.28):Qt.rgba(255,255,255,0.05)
                        if(q4.r1===1)return Qt.rgba(16,185,129,0.22)
                        return q4.r1>0?Qt.rgba(239,68,68,0.18):Qt.rgba(255,255,255,0.03) }
                    border.color: { if(!q4.submitted)return q4.r1>0?"#8b5cf6":Qt.rgba(255,255,255,0.10)
                        if(q4.r1===1)return"#10b981"
                        return q4.r1>0?"#ef4444":Qt.rgba(255,255,255,0.07) }
                    border.width: 1
                    Rectangle { anchors.left: parent.left; anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28; height: 28; radius: 6
                        color: q4.r1>0?"#8b5cf6":Qt.rgba(255,255,255,0.10)
                        Text { anchors.centerIn: parent; text: q4.r1>0?q4.r1.toString():"?"
                            color: "white"; font.pixelSize: 12; font.bold: true } }
                    Text { anchors.left: parent.left; anchors.leftMargin: 50
                        anchors.right: ht41.left; anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: "CLINT timer interrupt fires"; color: "white"; font.pixelSize: 12; font.family: "Segoe UI"; wrapMode: Text.WordWrap }
                    Text { id: ht41; anchors.right: parent.right; anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        visible: q4.submitted && q4.r1 !== 1
                        text: "✓1"; color: "#10b981"; font.pixelSize: 11; font.bold: true }
                    MouseArea { anchors.fill: parent; enabled: !q4.submitted; cursorShape: Qt.PointingHandCursor
                        onClicked: { if(q4.r1>0){q4.r0=0;q4.r1=0;q4.r2=0;q4.r3=0;q4.nextClick=1}
                            else{q4.r1=q4.nextClick;q4.nextClick++} } } }
                Rectangle { width: q4.width; height: 52; radius: 10
                    color: { if(!q4.submitted)return q4.r2>0?Qt.rgba(75,42,192,0.28):Qt.rgba(255,255,255,0.05)
                        if(q4.r2===4)return Qt.rgba(16,185,129,0.22)
                        return q4.r2>0?Qt.rgba(239,68,68,0.18):Qt.rgba(255,255,255,0.03) }
                    border.color: { if(!q4.submitted)return q4.r2>0?"#8b5cf6":Qt.rgba(255,255,255,0.10)
                        if(q4.r2===4)return"#10b981"
                        return q4.r2>0?"#ef4444":Qt.rgba(255,255,255,0.07) }
                    border.width: 1
                    Rectangle { anchors.left: parent.left; anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28; height: 28; radius: 6
                        color: q4.r2>0?"#8b5cf6":Qt.rgba(255,255,255,0.10)
                        Text { anchors.centerIn: parent; text: q4.r2>0?q4.r2.toString():"?"
                            color: "white"; font.pixelSize: 12; font.bold: true } }
                    Text { anchors.left: parent.left; anchors.leftMargin: 50
                        anchors.right: ht42.left; anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: "New process resumes running"; color: "white"; font.pixelSize: 12; font.family: "Segoe UI"; wrapMode: Text.WordWrap }
                    Text { id: ht42; anchors.right: parent.right; anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        visible: q4.submitted && q4.r2 !== 4
                        text: "✓4"; color: "#10b981"; font.pixelSize: 11; font.bold: true }
                    MouseArea { anchors.fill: parent; enabled: !q4.submitted; cursorShape: Qt.PointingHandCursor
                        onClicked: { if(q4.r2>0){q4.r0=0;q4.r1=0;q4.r2=0;q4.r3=0;q4.nextClick=1}
                            else{q4.r2=q4.nextClick;q4.nextClick++} } } }
                Rectangle { width: q4.width; height: 52; radius: 10
                    color: { if(!q4.submitted)return q4.r3>0?Qt.rgba(75,42,192,0.28):Qt.rgba(255,255,255,0.05)
                        if(q4.r3===2)return Qt.rgba(16,185,129,0.22)
                        return q4.r3>0?Qt.rgba(239,68,68,0.18):Qt.rgba(255,255,255,0.03) }
                    border.color: { if(!q4.submitted)return q4.r3>0?"#8b5cf6":Qt.rgba(255,255,255,0.10)
                        if(q4.r3===2)return"#10b981"
                        return q4.r3>0?"#ef4444":Qt.rgba(255,255,255,0.07) }
                    border.width: 1
                    Rectangle { anchors.left: parent.left; anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28; height: 28; radius: 6
                        color: q4.r3>0?"#8b5cf6":Qt.rgba(255,255,255,0.10)
                        Text { anchors.centerIn: parent; text: q4.r3>0?q4.r3.toString():"?"
                            color: "white"; font.pixelSize: 12; font.bold: true } }
                    Text { anchors.left: parent.left; anchors.leftMargin: 50
                        anchors.right: ht43.left; anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: "yield() changes state to RUNNABLE"; color: "white"; font.pixelSize: 12; font.family: "Segoe UI"; wrapMode: Text.WordWrap }
                    Text { id: ht43; anchors.right: parent.right; anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        visible: q4.submitted && q4.r3 !== 2
                        text: "✓2"; color: "#10b981"; font.pixelSize: 11; font.bold: true }
                    MouseArea { anchors.fill: parent; enabled: !q4.submitted; cursorShape: Qt.PointingHandCursor
                        onClicked: { if(q4.r3>0){q4.r0=0;q4.r1=0;q4.r2=0;q4.r3=0;q4.nextClick=1}
                            else{q4.r3=q4.nextClick;q4.nextClick++} } } }            }
            Column { id: q5
                property int selectedIndex: -1; property int correctIndex: 2
                property bool submitted: scrollRoot.showResults
                property bool isCorrect: selectedIndex === correctIndex
                property bool answered:  selectedIndex !== -1
                width: parent.width; spacing: 8
                Rectangle { width: parent.width; height: 1; color: Qt.rgba(255,255,255,0.07) }
                Text { text: "5.  Compared to FCFS, Round-Robin is better for ___ workloads."; color: "white"; font.pixelSize: 13
                    font.family: "Segoe UI"; width: parent.width; wrapMode: Text.WordWrap; lineHeight: 1.45 }
                Repeater { model: ["Long batch jobs", "Single-process systems", "Interactive and short tasks", "Disk-heavy processes"]
                    delegate: Rectangle {
                        width: q5.width; height: 44; radius: 10
                        color: { if (!q5.submitted) return q5.selectedIndex===index?Qt.rgba(75,42,192,0.35):Qt.rgba(255,255,255,0.05)
                            if(index===q5.correctIndex)return Qt.rgba(16,185,129,0.25)
                            if(index===q5.selectedIndex)return Qt.rgba(239,68,68,0.20)
                            return Qt.rgba(255,255,255,0.03) }
                        border.color: { if(!q5.submitted)return q5.selectedIndex===index?"#8b5cf6":Qt.rgba(255,255,255,0.10)
                            if(index===q5.correctIndex)return"#10b981"
                            if(index===q5.selectedIndex)return"#ef4444"
                            return Qt.rgba(255,255,255,0.06) }
                        border.width: 1
                        Text { anchors.centerIn: parent
                            text: ["A","B","C","D"][index]+".  "+modelData
                            color: { if(!q5.submitted)return"white"
                                if(index===q5.correctIndex)return"#10b981"
                                if(index===q5.selectedIndex)return"#ef4444"
                                return Qt.rgba(255,255,255,0.35) }
                            font.pixelSize: 12; font.family: "Segoe UI"
                            font.bold: q5.submitted&&(index===q5.correctIndex||index===q5.selectedIndex)
                            width: parent.width-28; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter }
                        MouseArea { anchors.fill: parent; enabled: !q5.submitted; cursorShape: Qt.PointingHandCursor
                            onClicked: q5.selectedIndex = index } } } }
        Rectangle {
            width: parent.width; height: 50; radius: 12; visible: !scrollRoot.showResults
            color: subMa.containsMouse?Qt.rgba(139,92,246,0.35):Qt.rgba(139,92,246,0.15)
            border.color: "#8b5cf6"; border.width: 1
            Behavior on color { ColorAnimation { duration: 150 } }
            Text { anchors.centerIn: parent; text: "Submit Answers"
                color: "#a78bfa"; font.bold: true; font.pixelSize: 14; font.family: "Segoe UI" }
            MouseArea { id: subMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if(!q1.answered||!q2.answered||!q3.answered||!q4.answered||!q5.answered){warnTxt.visible=true;return}
                    warnTxt.visible=false
                    var sc=0
                    if(q1.isCorrect)sc++;if(q2.isCorrect)sc++;if(q3.isCorrect)sc++
                    if(q4.isCorrect)sc++;if(q5.isCorrect)sc++
                    dbManager.saveQuizScore(scrollRoot.currentUser,scrollRoot.quizName,sc)
                    scrollRoot.savedScore=sc; scrollRoot.showResults=true } } }
        Text { id: warnTxt; visible: false; text: "Answer all questions before submitting."
            color: "#f43f5e"; font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter }

        Rectangle {
            width: parent.width; height: 80; radius: 14; visible: scrollRoot.showResults
            color: scrollRoot.savedScore>=4?Qt.rgba(16,185,129,0.12):scrollRoot.savedScore>=3?Qt.rgba(251,191,36,0.12):Qt.rgba(239,68,68,0.12)
            border.color: scrollRoot.savedScore>=4?"#10b981":scrollRoot.savedScore>=3?"#fbbf24":"#ef4444"; border.width: 1
            Column { anchors.centerIn: parent; spacing: 4
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: scrollRoot.savedScore+" / 5"
                    color: scrollRoot.savedScore>=4?"#10b981":scrollRoot.savedScore>=3?"#fbbf24":"#ef4444"
                    font.pixelSize: 30; font.bold: true }
                Text { anchors.horizontalCenter: parent.horizontalCenter
                    text: scrollRoot.savedScore>=4?"Excellent work!":scrollRoot.savedScore>=3?"Good job!":"Review the lesson and retry"
                    color: Qt.rgba(255,255,255,0.55); font.pixelSize: 11 } } }

        Rectangle {
            width: parent.width; height: 44; radius: 12; visible: scrollRoot.showResults
            color: retMa.containsMouse?Qt.rgba(255,255,255,0.10):Qt.rgba(255,255,255,0.04)
            border.color: Qt.rgba(255,255,255,0.15); border.width: 1
            Text { anchors.centerIn: parent; text: "Retake Quiz"
                color: Qt.rgba(255,255,255,0.6); font.pixelSize: 13; font.bold: true }
            MouseArea { id: retMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: { q1.selectedIndex=-1
                    q2.m0=-1;q2.m1=-1;q2.m2=-1;q2.m3=-1
                    q3.selectedIndex=-1
                    q4.r0=0;q4.r1=0;q4.r2=0;q4.r3=0;q4.nextClick=1
                    q5.selectedIndex=-1
                    scrollRoot.showResults=false } } }

        Rectangle {
            width: parent.width; height: 52; radius: 14
            color: backMa.containsMouse?Qt.rgba(139,92,246,0.22):Qt.rgba(139,92,246,0.10)
            border.color: "#14b8a6"; border.width: 1
            Behavior on color { ColorAnimation { duration: 180 } }
            Text { anchors.centerIn: parent
                text: "←   ROUND-ROBIN  (Back to Lesson)"
                color: "#14b8a6"; font.bold: true; font.pixelSize: 13; font.family: "Segoe UI" }
            MouseArea { id: backMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: scrollRoot.requestNavigate(scrollRoot.lessonSource) } }
        Item { height: 10; width: 1 }
    }
}
}