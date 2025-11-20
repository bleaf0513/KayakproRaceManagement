import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Window 2.15
import com.kayakpro.print 1.0
ApplicationWindow {

    id:second_window
    x:0
    y:0
    width: Screen.width-15
    height: Screen.height-80
    property int _pixelSize:main_window.height/35
    flags: Qt.Window | Qt.WindowCloseButtonHint
    title: "Racing UI"
    property int first_tab_width:width/16
    property int second_tab_width:width/16
    property int height_spacing:height/11
    property var ranking_number:[1,2,3,4,5,6,7,8,9,10]
    property var player_name:["Jhon","Iris","Tiger","Wolf","Cat","Dog","Fish","House","Codemaster","engineer"]
    property int countdown: 10  // Start counting from 10
    PrintManager{
        id:printManager
    }
    Component.onCompleted: {
        showMaximized()

    }
    Text {
        id:time_counter
        z:10

        anchors.centerIn: parent
        text: countdown===0?"GO!":countdown.toString()  // Display the countdown value
        font.pixelSize: parent.width/2.5
    }

    Timer {
        id: countdownTimer
        interval: 1000  // 1 second interval
        running: true
        repeat: true

        onTriggered: {
            if (countdown > 0) {
                countdown -= 1;  // Decrease the countdown by 1 each time
            } else {
                countdownTimer.stop();  // Stop the timer when it reaches 0
                time_counter.visible =false;
            }
        }
    }

    Shape {
        width:second_window.width
        height: second_window.height/11

        ShapePath {
            strokeWidth: 4
            strokeColor: "red"
            strokeStyle: ShapePath.DashLine
            dashPattern: [ 1, 4 ]
            startX: 0; startY: 0
            PathLine { x: second_window.x+second_window.width; y: 4 }

        }
    }
    Column {
        Repeater {
            model: 10

            Shape {
                width:second_window.width
                height: second_window.height/11

                ShapePath {
                    strokeWidth: 4
                    strokeColor: "red"
                    strokeStyle: ShapePath.DashLine
                    dashPattern: [ 1, 4 ]
                    startX: 0; startY: second_window.height/11
                    PathLine { x: second_window.x+second_window.width; y: second_window.height/11+4 }

                }
                Shape{
                    x:0
                    width:first_tab_width
                    height:second_window.height/11
                    Text {
                        anchors.centerIn: parent
                        font.bold: true
                        font.pixelSize: _pixelSize
                        text: {

                            return player_name[index].toString()
                        }
                    }
                }
                Shape{
                    x:second_window.width-second_tab_width
                    width:second_tab_width
                    height:second_window.height/11
                    Text {
                        anchors.centerIn: parent
                        font.bold: true
                        font.pixelSize: _pixelSize
                        text: {

                            return ranking_number[index].toString()
                        }
                    }
                }
            }

        }
    }

    Shape {
        x:parent.x+first_tab_width-4
        y:0
        width: 4
        height: parent.height
        ShapePath {
            strokeWidth: 4
            strokeColor: "red"
            strokeStyle: ShapePath.DashLine
            dashPattern: [ 1, 4 ]
            startX: parent.x; startY: 0
            PathLine { x: parent.x; y: second_window.height-height_spacing }

        }

    }
    Shape {
        x:parent.x+parent.width-second_tab_width-4
        y:0
        width: 4
        height: parent.height
        ShapePath {
            strokeWidth: 4
            strokeColor: "red"
            strokeStyle: ShapePath.DashLine
            dashPattern: [ 1, 4 ]
            startX: parent.x; startY: 0
            PathLine { x: parent.x; y: second_window.height-height_spacing }
        }
    }
    Button {
        id:print_but
        text: "Print"
        font.pixelSize: _pixelSize
        x:second_window.width*0.7
        y:second_window.height-height_spacing*0.8
        onClicked: {
            printManager.saveCsv();
            printManager.printCsv("race_record.csv");
        }
    }
    Button {
        id:exit_but
        text: "Exit"
        font.pixelSize: _pixelSize
        x:print_but.x+print_but.width*2
        y:second_window.height-height_spacing*0.8
        width:print_but.width

        onClicked: {
            Qt.quit()

        }
    }

}
