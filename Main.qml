import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls 2.5
import com.kayakpro.bluetooth 1.0
ApplicationWindow {
    visible: true
    width: 1280
    height: 760
    id:main_window
    title: "Setting..."
    BluetoothManager {
        id: bluetoothManager
    }
    // Root Layout to split into two sections (left and right)
    Component.onCompleted: {
        bluetoothManager.startScan();  // Automatically call startScan when the component is fully loaded
    }
    // Left Field: Combo Boxes
    Item {
        width: 250
        height: parent.height
        x:parent.x+30
        // ColumnLayout for stacking the combo boxes
        ColumnLayout {
            anchors.left: parent.left

            width:parent.width/3
            y:parent.height/2
            spacing: 10

            // Combo Box 1
            ComboBox {
                id: comboBox1
                width: parent.width
                model: ["select","250m","500m", "1000m", "2000m","3000m", "5000m", "7500m","10000m"]
                onActivated: {
                    // Disable the second combo box when one is selected
                    comboBox2.currentIndex=0;
                }

            }

            // Combo Box 2
            ComboBox {
                id: comboBox2
                anchors.left: parent.left

                width:parent.width/3
                model: ["select","5min", "10min", "15min"]
                enabled: true  // Initially disabled until comboBox1 is selected
                onActivated: {
                    // Disable the first combo box when one is selected
                    comboBox1.currentIndex=0;
                }
            }
            RowLayout {
                //anchors.centerIn: parent
                spacing: 20
                anchors.left: parent.left
                // Static Text
                Text {
                    text: "Player Number:"
                    font.pointSize: 8
                    font.bold: true
                    color: "black"
                    Layout.alignment: Qt.AlignVCenter // Align vertically in the center
                }

                // Text Input (for user input)
                TextInput {
                    id: nameInput
                    width: parent.width - 20
                    height: parent.height
                    font.pointSize: 14
                    color: "#333333"
                    padding: 10
                    //placeholderText: "Type your name"
                    //placeholderTextColor: "#888888"
                    // border.color: "transparent"  // Border is handled by Rectangle
                    anchors.centerIn: parent

                    // Focus Effect
                    // onFocusedChanged: {
                    //     if (nameInput.focus) {
                    //         nameInput.border.color = "#007BFF";  // Focused color (blue)
                    //     } else {
                    //         nameInput.border.color = "transparent";
                    //     }
                    // }

                    // Icon inside the text input
                    Text {
                        text: "🖊"
                        font.pointSize: 18
                        color: "#007BFF"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                    }

                    // Handling Text Changed event
                    onTextChanged: {
                        console.log("Entered Text: " + nameInput.text)
                    }
                }

                // A button to show what has been entered

            }
            Button {
                text: "Ready?"
                onClicked: {

                    loader.source="play.qml"
                    main_window.visible = false;

                }
            }
        }

    }

    // Right Field: 10 Players (5 Rows, 2 Columns)
    GridLayout {
        columns: 2
        rows: 5
        //spacing: 10
        x:parent.x+parent.width/3
        y:parent.y
        width:parent.width*2/3
        height:parent.height
        // Repeater to create 10 player sections
        Repeater {
            model: 10
            Rectangle {
                width: parent.width
                height: main_window.height/5
                color: "lightblue"
                border.color: "black"
                radius: 5

                Text {
                    text: "Player " + (index + 1)
                    font.bold: true
                    font.pointSize: 14
                    anchors.centerIn: parent
                }
                Image {
                    width:56
                    height:56
                    source: "images/bluetooth.png"

                }

            }
        }
    }
    Loader {
        id: loader
        anchors.centerIn: parent
    }
}
