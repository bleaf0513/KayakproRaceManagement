import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls 2.5
import QtQuick.Window 2.15
import com.kayakpro.bluetooth 1.0
import com.kayakpro.shareddata 1.0
ApplicationWindow {
    x:0
    y:0
    width: Screen.width-15
    height: Screen.height-80
    flags: Qt.Window | Qt.WindowCloseButtonHint
    id:main_window
    title: "Setting..."
    property int _pixelSize:main_window.height/35
    property int _divided_num:6

    BluetoothManager {
        id: bluetoothManager
    }
    SharedData {
        id:sharedData
        Component.onCompleted: {
        }
    }
    // Root Layout to split into two sections (left and right)
    Component.onCompleted: {
        showMaximized()
        sharedData.readProfile();
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
        height:main_window.height*5/5.35
        // Repeater to create 10 player sections
        GridView {
            id:eachplayerinfo
            width: parent.width
            height: parent.height
            cellWidth: width / 2                  // 2 columns
            cellHeight: main_window.height / 5.35
            model: sharedData.players
            // Repeater {
            //     id:eachplayerinfo
            //     model: 10
            delegate: Rectangle {
                id:playersettingdlg
                width: main_window.width/3
                height: main_window.height/5.35
                color: "transparent"
                border.color: "blue"
                border.width: 3
                layer.enabled: true
                layer.smooth: true
                enabled:true
                z:20
                property alias firstName: playerFirstName.text
                property alias surName: playerSurName.text
                property alias weight: playerWeight.text
                property alias sex: playerSex.currentText
                property alias dobValue: dob.text
                property alias catValue: cat.text
                property alias clubValue: club.text
                property alias number: noindex.currentIndex

                Image {
                    width:56
                    height:56
                    source: "images/bluetooth.png"

                }
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins:8
                    spacing: 8
                    RowLayout {
                        spacing: 8
                        Item{width:playersettingdlg.width/12}
                        Label { text: "First Name:"; color: "blue"; font.pixelSize: _pixelSize*0.8 }
                        TextField {
                            id: playerFirstName
                            placeholderText: "FirstName"
                            text: modelData[1]
                            width: playersettingdlg.width/3
                            font.pixelSize: _pixelSize*0.8
                        }

                        Label { text: "Surname:"; color: "blue"; font.pixelSize: _pixelSize*0.8 }
                        TextField {
                            id: playerSurName
                            placeholderText: "Surname"
                            text: modelData[2]
                            width: playersettingdlg.width/3
                            font.pixelSize: _pixelSize*0.8
                        }
                    }
                    RowLayout {
                        spacing: 8
                        Item{width:playersettingdlg.width/12}
                        Label { text: "Weight:      "; color: "blue"; font.pixelSize: _pixelSize*0.8 }
                        TextField {
                            id: playerWeight
                            placeholderText: "Kg"
                            text:modelData[6]
                            font.pixelSize: _pixelSize*0.8
                            width: playersettingdlg.width/4
                            height:playerFirstName.height
                            inputMethodHints: Qt.ImhDigitsOnly
                            validator: IntValidator { bottom: 30; top: 200 }  // realistic range
                        }
                        Item{width:playersettingdlg.width/12}
                        Label { text: "M/F:"; color: "blue"; font.pixelSize: _pixelSize*0.8 }
                        ComboBox {
                            id: playerSex
                            font.pixelSize: _pixelSize*0.8
                            width: playersettingdlg.width/4
                            model: ["Male", "Female"]
                            Component.onCompleted: {
                                const value = modelData[4];
                                const idx = model.indexOf(value);
                                if (idx >= 0)
                                    currentIndex = idx;
                            }
                        }
                    }
                    RowLayout {
                        spacing: 8
                        Item{width:playersettingdlg.width/12}
                        Label { text: "DOB:          "; color: "blue"; font.pixelSize: _pixelSize*0.8 }
                        TextField {
                            id: dob
                            placeholderText: "2000/3/5"
                            text: modelData[7]
                            width: playersettingdlg.width*2.85/3
                            font.pixelSize: _pixelSize*0.8
                        }
                        Item{width:playersettingdlg.width/12}
                        Label { text: "Cat: "; color: "blue"; font.pixelSize: _pixelSize*0.8 }
                        TextField {
                            id: cat
                            placeholderText: "U12"
                            text: modelData[5]
                            width: playersettingdlg.width*2.85/3
                            font.pixelSize: _pixelSize*0.8
                        }

                    }
                    RowLayout {
                        spacing: 8
                        Item{width:playersettingdlg.width/12}
                        Label { text: "Club:          "; color: "blue"; font.pixelSize: _pixelSize*0.8 }
                        TextField {
                            id: club
                            placeholderText: "Wey Kayak Club"
                            text: modelData[3]
                            width: 500//playersettingdlg.width*2.85/3
                            font.pixelSize: _pixelSize*0.8
                        }
                        Item{width:playersettingdlg.width/12}
                        Label { text: "Lane: "; color: "blue"; font.pixelSize: _pixelSize*0.8 }
                        ComboBox {
                            id: noindex
                            font.pixelSize: _pixelSize*0.8
                            width: playersettingdlg.width/4
                            currentIndex: index
                            model: [1,2,3,4,5,6,7,8,9,10]
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
                for (var i = 0; i < 10; i++) {
                    var item = eachplayerinfo.itemAtIndex(i);
                    if (!item) continue;
                    sharedData.setSharedItem(i,0,item.number);
                    sharedData.setSharedItem(i,1,item.firstName);
                    sharedData.setSharedItem(i,2,item.surName);
                    sharedData.setSharedItem(i,3,item.clubValue);
                    sharedData.setSharedItem(i,4,item.sex);
                    sharedData.setSharedItem(i,5,item.catValue);
                    sharedData.setSharedItem(i,6,item.weight);
                    sharedData.setSharedItem(i,7,item.dobValue);
                }
                sharedData.writeProfile();
                //print saveCsvFile
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
