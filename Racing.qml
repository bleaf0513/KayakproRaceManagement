import QtQuick
import QtQuick.Controls
import QtQuick.Window 2.15
import com.kayakpro.print 1.0

ApplicationWindow {
    id: second_window
    width: Screen.width * 0.95
    height: Screen.height * 0.95
    visible: true
    title: "Racing UI"

    property int _rows: 10
    property var player_name: ["Jhon","Iris","Tiger","Wolf","Cat","Dog","Fish","House","Codemaster","Engineer"]
    property var ranking_number: [1,2,3,4,5,6,7,8,9,10]
    property int countdown: 10
    property real fieldHeight: height / (_rows + 3)
    property real tabWidth: width / 12
    property real fontSizeCountdown: width / 3

    PrintManager { id: printManager }

    Component.onCompleted: showMaximized()

    // ------------------------------
    // Background
    // ------------------------------
    Rectangle {
        anchors.fill: parent
        color: "#121212"
    }

    // ------------------------------
    // Countdown (centered)
    // ------------------------------
    Text {
        id: countdownText
        anchors.centerIn: parent
        text: countdown === 0 ? "GO!" : countdown.toString()
        font.pixelSize: fontSizeCountdown
        font.bold: true
        color: "#FFD700"
        z: 100

        // Smooth pulsing animation
        Behavior on font.pixelSize {
            NumberAnimation {
                duration: 1000                  // faster pulse
                from: fontSizeCountdown * 0.6  // start slightly smaller
                to: fontSizeCountdown * 1.2    // grow slightly bigger
                loops: Animation.Infinite
                easing.type: Easing.InOutSine  // smooth in and out
            }
        }
    }

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            if (countdown > 0) countdown--
            else {
                countdownTimer.stop()
                countdownText.visible = false
            }
        }
    }
    // ------------------------------
    // Racing Fields
    // ------------------------------
    Column {
        id: racingFields
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 4
        z: 1 // behind countdown

        Repeater {
            model: _rows
            Rectangle {
                width: parent.width
                height: fieldHeight
                radius: 12
                color: index % 2 === 0 ? "#1E1E2A" : "#252535"

                Row {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    // Player Name
                    Rectangle {
                        width: tabWidth * 2
                        height: parent.height
                        radius: 8
                        color: "#333344"
                        Text {
                            anchors.centerIn: parent
                            text: player_name[index]
                            font.pixelSize: fieldHeight * 0.4
                            color: "#FFFFFF"
                            font.bold: true
                        }
                    }

                    // Spacer
                    Item { width: parent.width - (tabWidth*3 + 16) }

                    // Ranking
                    Rectangle {
                        width: tabWidth
                        height: parent.height
                        radius: 8
                        color: "#333344"
                        Text {
                            anchors.centerIn: parent
                            text: ranking_number[index]
                            font.pixelSize: fieldHeight * 0.4
                            color: "#FFD700"
                            font.bold: true
                        }
                    }
                }
            }
        }
    }

    // ------------------------------
    // Buttons
    // ------------------------------
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        spacing: 20

        Button {
            text: "Print"
            font.pixelSize: fieldHeight * 0.35
            background: Rectangle {
                radius: 12
                color: "#18C77A"
            }
            onClicked: {
                printManager.saveCsv()
                printManager.printCsv("race_record.csv")
            }
        }

        Button {
            text: "Exit"
            font.pixelSize: fieldHeight * 0.35
            background: Rectangle {
                radius: 12
                color: "#E14B4B"
            }
            onClicked: Qt.quit()
        }
    }
}
