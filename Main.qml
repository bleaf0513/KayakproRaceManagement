import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls 2.5
import QtQuick.Window 2.15
import com.kayakpro.bluetooth 1.0
import shareddataApp 1.0
Page {
    //    x:0
    //    y:0
    //    width: Screen.width-15
    //    height: Screen.height-80
    //        flags: Qt.FramelessWindowHint
    id:main_window
    property StackView stack
    //   title: "Setting..."
    property int _pixelSize:main_window.height/35
    property int _divided_num:6
    property int _activeconsoles:0
    property var name_rect_color:["#297AFF","#EF4444","#20B055","#F59E0B","#8B5CF6","#F14097","#00BBDB","#12B6A4","#FF7311","#6366F1"]
    //    onClosing:
    //    {
    //        console.log("ComponentDestruction:")
    //        Qt.quit()
    //    }
    Timer {
        id:_timer
        interval: 10
        repeat: true
        running: true
        onTriggered: {
            for(var i=0;i<10;i++)
            {
                var item = eachplayerinfo.children[i];
                if(SharedData.isActive(i)===-1)
                {

                    item.failedImg.visible=true;
                    item.connectingImg.visible=false;
                    item.connectedImg.visible = false;
                }
                else if(SharedData.isActive(i)===1)
                {
                    if(item.connectedImg.visible === false)
                        _activeconsoles++;

                    item.failedImg.visible=false;
                    item.connectingImg.visible=false;
                    item.connectedImg.visible = true;
                }
                else
                {
                    if(item.connectedImg.visible === true)
                    {    _activeconsoles--;
                        item.connectingImg.visible=false;
                        item.failedImg.visible=true;
                        item.connectedImg.visible = false;
                    }

                }

            }
        }
    }
    Image {
        //anchors.fill: parent
        width:1920
        height:1080
        source:"images/main_background.png"
    }
    Image {
        //anchors.fill: parent
        x:74
        y:294
        width:47.8
        height:649.8
        source:"images/main_number.svg"
    }
    // Label { x:left_field.width/5;y:left_field.height/30;text: "ActivePlayers:"; color: "blue"; font.pixelSize: _pixelSize }
    // Label {
    //     x:left_field.width/5+_pixelSize*9;
    //     y:left_field.height/30;
    //     text: "0";
    //     color: "black";
    //     font.pixelSize: _pixelSize
    // }
    Row{
        x:1668
        y:60.22
        Text {
            // id:rank_text

            color:"#00FF00"
            font.pixelSize:25
            font.weight: 700
            font.bold: true
            font.family: "Inter"
            text:_activeconsoles+""
        }
        Text {

            // id:rank_text
            color:"#FFFFFF"
            font.pixelSize:25
            font.weight: 700
            font.bold: true
            font.family: "Inter"
            text:"/10"
        }
    }
    Text {
        id:total_distance
        x:1779.71
        y:58.07
        text: group.checkedButton ? group.checkedButton.text : "None"
        font.pixelSize:25
        font.weight: 700
        font.bold: true
        font.family: "Inter"
        color: "white"
    }
    ButtonGroup { id: group1}
    Button {
        x:1772
        y:1016
        width:100
        height:44
        text: "Next"
        checkable: true
        ButtonGroup.group: group1
        checked: true  // default selection

        background: Rectangle {
            color: parent.checked ? Qt.rgba(0.54,1,0.47,0.1) :Qt.rgba(0,0,0,0.3)
            radius: 8
            border.color: parent.checked ? Qt.rgba(0.54,1,0.47,1) :Qt.rgba(1,1,1,0.1)
            border.width: 2
        }
        contentItem: Text {
            text: parent.text
            color: parent.checked?Qt.rgba(0.54,1,0.47,1):"white"
            font.weight: 500
            // <-- WHITE FONT COLOR
            font.family: "Inter"
            font.pixelSize: 16
            //font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onClicked:{

            for (var i = 0; i < 10; i++) {
                var item = eachplayerinfo.children[i];
                if (!item) continue;

                //SharedData.setSharedItem(i,0,item.number);
                SharedData.setSharedItem(i,1,item.firstName);
                SharedData.setSharedItem(i,2,item.surName);
                SharedData.setSharedItem(i,3,item.clubValue);
                SharedData.setSharedItem(i,4,item.sex);
                SharedData.setSharedItem(i,5,item.catValue);
                SharedData.setSharedItem(i,6,item.weight);
                SharedData.setSharedItem(i,7,item.dobValue);
            }
            var totaldist=parseInt(total_distance.text)

            SharedData.setTotalDist(totaldist);
            SharedData.writeProfile();
            if(_activeconsoles<2) return
            if (stack  ) {
                var comp = Qt.createComponent("Racing.qml");
                if (comp.status === Component.Ready) {
                    var page = comp.createObject(stack, {
                        stack: stack
                    });
                    if (page) {
                        stack.push(page);
                    } else {
                        console.error("Failed to create Racing instance");
                    }
                } else if (comp.status === Component.Error) {
                    console.error("Failed to load Racing.qml:", comp.errorString());
                }
            } else {
                console.error("StackView not provided!");
            }
        }

    }
/*
    Button {
        x:1572
        y:1016
        width:100
        height:44
        text: "Test"
        checkable: true
        ButtonGroup.group: group1
        checked: true  // default selection

        background: Rectangle {
            color: parent.checked ? Qt.rgba(0.54,1,0.47,0.1) :Qt.rgba(0,0,0,0.3)
            radius: 8
            border.color: parent.checked ? Qt.rgba(0.54,1,0.47,1) :Qt.rgba(1,1,1,0.1)
            border.width: 2
        }
        contentItem: Text {
            text: parent.text
            color: parent.checked?Qt.rgba(0.54,1,0.47,1):"white"
            font.weight: 500
            // <-- WHITE FONT COLOR
            font.family: "Inter"
            font.pixelSize: 16
            //font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onClicked:{

            for (var i = 0; i < 10; i++) {
                var item = eachplayerinfo.children[i];
                if (!item) continue;

                SharedData.setSharedItem(i,0,item.number);
                SharedData.setSharedItem(i,1,item.firstName);
                SharedData.setSharedItem(i,2,item.surName);
                SharedData.setSharedItem(i,3,item.clubValue);
                SharedData.setSharedItem(i,4,item.sex);
                SharedData.setSharedItem(i,5,item.catValue);
                SharedData.setSharedItem(i,6,item.weight);
                SharedData.setSharedItem(i,7,item.dobValue);
            }
            var totaldist=parseInt(total_distance.text)

            SharedData.setTotalDist(totaldist);
            SharedData.writeProfile();
            //print saveCsvFile
          //  main_window.visible=false;
          //  loader.source="Racing.qml"
        }

    }
*/
    // ----- Button 2 -----
    Button {
        x:48
        y:1016
        width:100
        height:44
        text: "Back"
        checkable: true
        ButtonGroup.group: group1

        background: Rectangle {
            color: parent.checked ? Qt.rgba(0.54,1,0.47,0.1) :Qt.rgba(0,0,0,0.3)
            radius: 8
            border.color: parent.checked ? Qt.rgba(0.54,1,0.47,1) :Qt.rgba(1,1,1,0.1)
            border.width: 2
        }
        contentItem: Text {
            text: parent.text
            color:  parent.checked?Qt.rgba(0.54,1,0.47,1):"white"
            font.weight: 500
            // <-- WHITE FONT COLOR
            font.family: "Inter"
            font.pixelSize: 16
            //font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        onClicked:{
            stack.pop();
            // Hide current window
           // main_window.visible = false
            // Load Main.qml
           // setblueloader.source = "qt/qml/GSMKayakpro/SetBluetoothAddress.qml"
        }

    }
    /*
    Item {
        id:left_field
        width: main_window.width/3
        height: main_window.height
        x:30
        z:10


        Button {
            id:ready_but
            text: "Ready!"
            font.pixelSize: _pixelSize
            x:left_field.width/2.5
            y:left_field.height/1.4
            onClicked: {
                // for (var i = 0; i < 10; i++) {
                //     var item = eachplayerinfo.itemAtIndex(i);
                //     if (!item) continue;
                //     SharedData.setSharedItem(i,0,item.number);
                //     SharedData.setSharedItem(i,1,item.firstName);
                //     SharedData.setSharedItem(i,2,item.surName);
                //     SharedData.setSharedItem(i,3,item.clubValue);
                //     SharedData.setSharedItem(i,4,item.sex);
                //     SharedData.setSharedItem(i,5,item.catValue);
                //     SharedData.setSharedItem(i,6,item.weight);
                //     SharedData.setSharedItem(i,7,item.dobValue);
                // }
                var total_distance=parseInt(group.checkedButton ? group.checkedButton.text : "0")
                console.log("tatal_dist:"+total_distance);
                //   SharedData.setTotalDist(total_distance);
                //   SharedData.writeProfile();
                //print saveCsvFile
                //   main_window.visible=false;
                //   loader.source="Racing.qml"

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

    }*/
    Row {
        x:170
        y:151
        spacing: 12

        ButtonGroup { id: group }

        Repeater {
            model: 5

            Button {
                width:80
                height:36
                text: ((index + 1)*500).toString()+"m"
                checkable: true
                ButtonGroup.group: group
                // First button selected by default
                checked: index === 0

                background: Rectangle {
                    color: checked ? Qt.rgba(0.54,1,0.47,0.1) :Qt.rgba(0,0,0,0.3)
                    radius: 8
                    border.color: checked ? Qt.rgba(0.54,1,0.47,1) :Qt.rgba(1,1,1,0.1)
                    border.width: 2
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.weight: 500
                    // <-- WHITE FONT COLOR
                    font.family: "Inter"
                    font.pixelSize: 16
                    //font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    // Label {
    //     x:left_field.width/5+_pixelSize*9;
    //     y:left_field.height/30;text: "/10";
    //     color: "black";
    //     font.pixelSize: _pixelSize
    // }

    Column{
        id:eachplayerinfo
        spacing:19.12
        x:140.59
        y:294

        Repeater{

            model: SharedData.players

            delegate:
                Row{
                spacing:12.18
                property alias firstName: playerFirstName.text
                property alias surName: playerSurName.text
                property alias weight: playerWeight.text
                property alias sex: playerSex.text
                property alias dobValue: dob.text
                property alias catValue: cat.text
                property alias clubValue: club.text
                property alias connectedImg:connected
                property alias connectingImg:connecting
                property alias failedImg:failed
                TextField {
                    id: playerFirstName
                    placeholderText: "First Name"
                    width:179.23
                    height:47.79
                    text:modelData[1]
                    color: "white"              // text colo
                    font.pixelSize:16
                    font.weight: 400
                    //font.bold: true
                    font.family: "Arial"
                    padding: 10
                    palette {
                        placeholderText: "#4B5563"
                    }
                    background: Rectangle {
                        radius:15
                        color: "#000000"
                        opacity:0.3//"transparent"    // transparent background
                        border.color: Qt.rgba(1,1,1,0.08)
                        border.width:1.19
                    }
                }

                TextField {
                    id: playerSurName
                    placeholderText: "Surname"
                    width:179.23
                    height:47.79
                    color: "white"              // text colo
                    font.pixelSize:16
                    font.weight: 400
                    text:modelData[2]
                    font.family: "Arial"
                    padding: 10
                    palette {
                        placeholderText: "#4B5563"
                    }
                    background: Rectangle {
                        radius:15
                        color: "#000000"
                        opacity:0.3//"transparent"    // transparent background
                        border.color: Qt.rgba(1,1,1,0.08)
                        border.width:1.19
                    }
                }
                TextField {
                    id: playerWeight
                    placeholderText: "kg"
                    width:95.59
                    height:47.79
                    color: "white"
                    text:modelData[6]
                    font.pixelSize:16
                    font.weight: 400
                    padding: 10
                    font.family: "Arial"

                    palette {
                        placeholderText: "#4B5563"
                    }
                    background: Rectangle {
                        radius:15
                        color: "#000000"
                        opacity:0.3//"transparent"    // transparent background
                        border.color: Qt.rgba(1,1,1,0.08)
                        border.width:1.19
                    }
                }
                TextField {
                    id: playerSex
                    placeholderText: "Male"
                    width:95.59
                    height:47.79
                    color: "white"
                    text:modelData[4]
                    font.pixelSize:16
                    font.weight: 400
                    padding: 10
                    font.family: "Arial"
                    palette {
                        placeholderText: "#4B5563"
                    }

                    background: Rectangle {
                        radius:15
                        color: "#000000"
                        opacity:0.3//"transparent"    // transparent background
                        border.color: Qt.rgba(1,1,1,0.08)
                        border.width:1.19
                    }
                }
                TextField {
                    id: dob
                    placeholderText: "YYYY-MM-DD"
                    width:131.43
                    height:47.79
                    color: "white"
                    text:modelData[7]
                    font.pixelSize:16
                    font.weight: 400
                    padding: 10
                    font.family: "Arial"

                    palette {
                        placeholderText: "#4B5563"
                    }
                    background: Rectangle {
                        radius:15
                        color: "#000000"
                        opacity:0.3//"transparent"    // transparent background
                        border.color: Qt.rgba(1,1,1,0.08)
                        border.width:1.19
                    }
                }
                TextField {
                    id: club
                    placeholderText: "Club"
                    width:167.28
                    height:47.79
                    color: "white"              // text colo
                    font.pixelSize:16
                    font.weight: 400
                    padding: 10
                    text:modelData[3]
                    font.family: "Arial"
                    palette {
                        placeholderText: "#4B5563"
                    }

                    background: Rectangle {
                        radius:15
                        color: "#000000"
                        opacity:0.3//"transparent"    // transparent background
                        border.color: Qt.rgba(1,1,1,0.08)
                        border.width:1.19
                    }
                }
                TextField {
                    id: cat
                    placeholderText: "Junior"
                    width:131.43
                    height:47.79
                    color: "white"              // text colo
                    font.pixelSize:16
                    font.weight: 400
                    padding: 10
                    text:modelData[5]
                    font.family: "Arial"
                    palette {
                        placeholderText: "#4B5563"
                    }

                    background: Rectangle {
                        radius:15
                        color: "#000000"
                        opacity:0.3//"transparent"    // transparent background
                        border.color: Qt.rgba(1,1,1,0.08)
                        border.width:1.19
                    }
                }
                Image {
                    id:connected
                    width:181
                    height:48
                    source: "images/CONNECTED.svg"
                    visible:false
                }
                Image {
                    id:connecting
                    width:181
                    height:48
                    source: "images/CONNECTING.svg"
                    visible:true
                    Rectangle {
                        x:24
                        y:15
                        width: 18
                        height: 18
                        color: "transparent"

                        Image {
                            id: spinner
                            anchors.centerIn: parent
                            source: "images/spin.svg"   // your spinner image


                            NumberAnimation on rotation {
                                from: 0
                                to: 360
                                duration: 800
                                loops: Animation.Infinite
                            }
                        }
                    }
                }
                Image {
                    id:failed
                    width:181
                    height:48
                    source: "images/FAILED.svg"
                    visible:false
                }
            }
        }
    }
    BluetoothManager {
        id: bluetoothManager
    }
    // SharedData {
    //     id:sharedData
    //     Component.onCompleted: {
    //     }
    // }
    // Root Layout to split into two sections (left and right)
    Component.onCompleted: {
        showMaximized()
        SharedData.readProfile();
        bluetoothManager.startScan();  // Automatically call startScan when the component is fully loaded
    }
    /*
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
            model: SharedData.players
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
*/
    // Left Field: Combo Boxes

//    Loader{
//        id:loader
//    }
//    Loader{
//        id:setblueloader
//    }

}
