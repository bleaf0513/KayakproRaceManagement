import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import shareddataApp 1.0
import com.kayakpro.bluetooth 1.0
Page  {
    id: root
    width: 1920//Screen.width - 20
    height: 1080//Screen.height - 50
  //  visible: true
   // title: "KP3902 MAC Address Settings"
  //      flags: Qt.FramelessWindowHint
    property StackView stack
    property int consoleCount: 10
    property var blueNames: Array(consoleCount).fill("")
    property var macAddresses: Array(consoleCount).fill("")
    // Colors
    readonly property color bgColor: "#121212"
    readonly property color cardColor: "#1E1E2A"
    readonly property color cardBorder: "#333344"
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: "#BBBBBB"
    readonly property color accentGreen: "#18C77A"
    readonly property color accentHover: "#16B370"
    readonly property color accentNext: "#3388FF"
    readonly property color accentNextHover: "#2277DD"
    readonly property color fieldFocus: "#2D8CFF"
    Image {
        //anchors.fill: parent
        width:1920
        height:1080

        source:"images/device_connect.png"
    }
//    onClosing:
//    {
//        console.log("ComponentDestruction:")
//        Qt.quit()
//    }
    BluetoothManager {
        Component.onCompleted: {

        }
    }

    Component.onCompleted:{
        for(var i=0;i<consoleCount;i++)
        {

            blueNames[i]=SharedData.blueNames(i);
            macAddresses[i]=SharedData.blueMacAddress(i);
        }
        showMaximized()
    }
    // Rectangle {
    //     anchors.fill: parent
    //     color: bgColor
    // }
    GridLayout {
        id: grid
        x:173.73
        y:262.67
        width:1137.29
        height:568.64
        columns: 2
        rows:5
        rowSpacing:79.61
        columnSpacing:227.45
        Repeater{
            model:10
            TextField {
                width:454.92
                height:50.04
                Layout.fillWidth: true
                placeholderText: "XX:XX:XX:XX:XX:XX"
                text: SharedData.blueMacAddress(index)

                color: "#22C55E"
                font.pixelSize:16
                font.weight: 400
                //font.bold: true
                font.family: "Inter"
                padding: 10
                palette {
                    placeholderText: "#4B5563"
                }
                background: Rectangle {
                    radius: 10

                    border.color: "#1E3A5F"
                    border.width: 1
                    color: "#041316"
                }
                onTextChanged: macAddresses[index] = text
            }


        }
    }

    RowLayout {
        spacing: 20
        //  Layout.alignment: Qt.AlignHCenter
        // Layout.fillWidth: true
        y:700//1016//parent.height*0.8
        x:1648//parent.width*0.5
        Rectangle {
            Layout.preferredWidth: 110//root.width / 10
            Layout.preferredHeight: 44//root.height / 25
            radius: 14
            color: accentGreen

            Text {
                anchors.centerIn: parent
                text: "Exit"
                font.pixelSize: 20
                font.bold: true
                color: "#FFFFFF"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: parent.color = accentHover
                onExited: parent.color = accentGreen
                onClicked: Qt.quit()//saveAllMacAddresses()
            }
        }
        // Next Button
        Rectangle {
            Layout.preferredWidth: 110//root.width / 10
            Layout.preferredHeight: 44//root.height / 25
            radius: 14
            color: accentNext

            Text {
                anchors.centerIn: parent
                text: "Confirm"
                font.pixelSize: 20
                font.bold: true
                color: "#FFFFFF"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: parent.color = accentNextHover
                onExited: parent.color = accentNext
                onClicked:{
                    for(var i=0;i<consoleCount;i++)
                    {

                        SharedData.setBlueMacAddress(i,blueNames[i],macAddresses[i]);
                    }
                    stack.pop();
                }
            }
        }
        // Save Button



    }
    Loader{
        id:mainLoader
    }
    // Signal to C++ for saving all MAC addresses
    signal saveAllMacAddresses()
}
