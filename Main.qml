import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls 2.5
import QtQuick.Window 2.15
import com.kayakpro.bluetooth 1.0
ApplicationWindow {
    x:0
    y:0
    width: Screen.width-15
    height: Screen.height-80
    flags: Qt.Window | Qt.WindowCloseButtonHint
    // maximumWidth: width
    // maximumHeight: height
    // minimumWidth: width
    // minimumHeight: height
    id:main_window
    title: "Setting..."
    property int _pixelSize:main_window.height/35
    BluetoothManager {
        id: bluetoothManager
    }
    // Root Layout to split into two sections (left and right)
    Component.onCompleted: {
        showMaximized()

        bluetoothManager.startScan();  // Automatically call startScan when the component is fully loaded
    }
    GridLayout {
        columns: 2
        rows: 5
        x:main_window.width/3
        y:0
        z:19
        rowSpacing: 0
        columnSpacing: 0
        width:main_window.width*2/3
        height:main_window.height*5/5.1
        // Repeater to create 10 player sections

        Repeater {
            model: 10
            Rectangle {
                id:player_setting_dlg
                width: main_window.width/3
                height: main_window.height/5.1
                color: "transparent"
                border.color: "blue"
                border.width: 3
                layer.enabled: true
                layer.smooth: true
                z:20


                Image {
                    width:56
                    height:56
                    source: "images/bluetooth.png"

                }
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins:8
                    //leftMargin:  player_setting_dlg.width/3
                    spacing: 6

                    // ------------------
                    // Player Image & Name
                    // ------------------
                    RowLayout {
                        spacing: 8
                        Item{width:player_setting_dlg.width/4}
                        Label { text: "Player" + (index + 1)+":"; color: "blue"; font.pixelSize: _pixelSize }
                        TextField {
                            id: playerName
                            placeholderText: "Name"
                            text: ""
                            width: player_setting_dlg.width/3
                            font.pixelSize: _pixelSize
                        }
                    }

                    // ------------------
                    // Weight Input
                    // ------------------
                    RowLayout {
                        spacing: 8
                        Item{width:player_setting_dlg.width/4}
                        Label { text: "Weight:"; color: "blue"; font.pixelSize: _pixelSize }
                        TextField {
                            id: playerWeight
                            placeholderText: "Kg"
                            font.pixelSize: _pixelSize
                            width: player_setting_dlg.width/4
                            height:playerName.height
                            inputMethodHints: Qt.ImhDigitsOnly
                            validator: IntValidator { bottom: 30; top: 200 }  // realistic range
                        }
                    }

                    // ------------------
                    // Sex Input
                    // ------------------
                    RowLayout {
                        spacing: 8
                        Item{width:player_setting_dlg.width/4}
                        Label { text: "Sex:      "; color: "blue"; font.pixelSize: _pixelSize }
                        ComboBox {
                            id: playerSex
                            font.pixelSize: _pixelSize
                            width: player_setting_dlg.width/4
                            model: ["Male", "Female", "Other"]
                        }
                    }


                }
            }
        }
    }

    // Left Field: Combo Boxes
    Item {
        id:left_field
        width: main_window.width/3
        height: main_window.height
        x:30
        z:10
        // ColumnLayout for stacking the combo boxes

        // Combo Box 1
        ComboBox {
            x:left_field.width/5
            width:left_field.width/5
            y:left_field.height/3
            currentIndex: 3
            id: select_meter_combo
            font.pixelSize: _pixelSize
            model: ["select","250m","500m", "1000m", "2000m","3000m", "5000m", "7500m","10000m"]
            onActivated: {
                // Disable the second combo box when one is selected
                select_time_combo.currentIndex=0;
            }

        }
        Label { x:left_field.width*2.3/5;y:left_field.height/3;text: "OR"; color: "blue"; font.pixelSize: _pixelSize }
        // Combo Box 2
        ComboBox {
            id: select_time_combo
            x:left_field.width*3/5
            y:left_field.height/3
            width:left_field.width/5
            model: ["select","5min", "10min", "15min"]
            enabled: true  // Initially disabled until comboBox1 is selected
            font.pixelSize: _pixelSize
            onActivated: {
                // Disable the first combo box when one is selected
                select_meter_combo.currentIndex=0;
            }
        }

        Label { x:left_field.width/5;y:left_field.height/30;text: "ActivePlayers:"; color: "blue"; font.pixelSize: _pixelSize }
        Label { x:left_field.width/5+_pixelSize*9;y:left_field.height/30;text: "10"; color: "black"; font.pixelSize: _pixelSize }

        // A button to show what has been entered


        Button {
            id:ready_but
            text: "Ready!"
            font.pixelSize: _pixelSize
            x:left_field.width/2.5
            y:left_field.height/1.4
            onClicked: {

               main_window.visible=false;
                loader.source="Racing.qml"

            }
        }

        Button {
            id:exit_but
            text: "Exit"
            font.pixelSize: _pixelSize
            x:left_field.width/2.5
            y:ready_but.y+ready_but.height*2
            width:ready_but.width

            onClicked: {
                Qt.quit()
            }
        }

    }
    Loader{
        id:loader
    }


}
