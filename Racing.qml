import QtQuick
import QtQuick.Controls
import QtQuick.Window 2.15
import com.kayakpro.print 1.0
import shareddataApp 1.0
Page {
    id: second_window
    width: 1920//Screen.width * 0.95
    height: 1080//Screen.height * 0.95
        property StackView stack
  //  visible: true
  //  title: "Racing UI"
 //   flags: Qt.FramelessWindowHint
    property int _rows: SharedData.getPlayerNum()
    //property var player_name: ["Jhon","Iris","Tiger","Wolf","Cat","Dog","Fish","House","Codemaster","Engineer"]
    //property var ranking_number: [1,2,3,4,5,6,7,8,9,10]
    property int countdown: 10
    property real fieldHeight: height / (_rows + 3)
    property real tabWidth: width / 12
    property real fontSizeCountdown: width / 3
    ///////////////////////////////////////////////
    property var race_distance:[0,0,0,0,0,0,0,0,0,0];
    property var race_strokerate:[0,0,0,0,0,0,0,0,0,0];
    property var race_strokecount:[0,0,0,0,0,0,0,0,0,0];
    property var name_rect_color:["#297AFF","#EF4444","#20B055","#F59E0B","#8B5CF6","#F14097","#00BBDB","#12B6A4","#FF7311","#6366F1"]
    property var race_end_time:["00:00","00:00","00:00","00:00","00:00","00:00","00:00","00:00","00:00","00:00"];
    property var start_dist:[0,0,0,0,0,0,0,0,0,0];
    ///////////////////////////////////////////////
    // property int race_label_num:0//seperated count
    PrintManager { id: printManager }
    property var distanceTextRefs: []
    property var laneRefs: []
    property int total_dist:0
    property int race_total_time:0
    property var ranking:[0,1,2,3,4,5,6,7,8,9]
    property var passed_dist:[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
    property var device_dist:[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
    Component.onCompleted:{

        showMaximized()
        total_dist = SharedData.getTotalDist();
        //race_label_num=total_dist/5;
    }
//    onClosing:
//    {
//        console.log("ComponentDestruction:")
//        Qt.quit()
//    }
    Button {
        x:248
        y:47
        z:20
        width:100
        height:44
        text: "Print"

        background: Rectangle {
            color: parent.checked ? Qt.rgba(0.54,1,0.47,0.1) :Qt.rgba(0,0,0,0.3)
            radius: 8
            border.color: parent.checked ? Qt.rgba(0.54,1,0.47,1) :Qt.rgba(1,1,1,0.1)
            border.width: 2
        }
        contentItem: Text {
            text: parent.text
            color:  Qt.rgba(0.54,1,0.47,1)
            font.weight: 500
            // <-- WHITE FONT COLOR
            font.family: "Inter"
            font.pixelSize: 16
            //font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        onClicked:{
            printManager.saveCsv()
            printManager.printCsv("race_record.csv")
        }

    }
    Button {
        x:348
        y:47
        z:20
        width:100
        height:44
        text: "Exit"

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
            Qt.quit()
        }

    }
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        spacing: 20
    }
    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            if (countdown > 0)
            {

                countdown--
            }
            else {
                countdownText.visible = false
                if(race_total_time==0)
                {    for(var i=0;i<_rows;i++)
                    {
                        start_dist[i]= SharedData.getDistance(i);

                    }

                    var p1 = second_window.laneRefs[i].mapToItem(null, 0, 0)
                    console.log("p1_x:"+p1+",p1_xx:"+second_window.laneRefs[i].x);
                }
                race_total_time++;
                race_time.text=formatTime(race_total_time);
                race_timer1.start()
            }
        }
    }
    Text {
        id: countdownText
        anchors.centerIn: parent
        text: countdown === 0 ? "GO!" : countdown.toString()
        font.pixelSize: fontSizeCountdown
        font.bold: true

        font.weight: 700
        font.family: "Inter"
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
    // ------------------------------
    // Background
    // ------------------------------
    Image {
        //anchors.fill: parent
        width:1920
        height:1080
        source:"qrc:/images/race_background.png"
    }
    Image {
        x:1568
        y:109

        source:"qrc:/images/race_result.png"
        Column{
            x:12
            y:46
            spacing:5
            Repeater{
                model: _rows

                Rectangle {
                    width:308
                    height:54
                    radius: 10
                    color: index===0?Qt.rgba(0.98,0.8,0.08,0.25):Qt.rgba(1,1,1,0)
                    //ranking
                    Rectangle {

                        z:3
                        y:parent.height/2-height/2
                        x:12.82
                        width: 30
                        height: 30
                        radius: width / 2
                        color: index===0?"#FACC15":index===1?"#D1D5DB":index===2?"#D97706":Qt.rgba(1,1,1,0.2)
                        Text {
                            id:rank_text
                            x:parent.width/2-width/2
                            y:parent.height/2-height/2
                            color:index<2?"#000000":"#FFFFFF"
                            font.pixelSize:14
                            font.weight: 700
                            font.bold: true
                            font.family: "Inter"
                            text:(index+1)+""
                        }

                    }
                    Rectangle {
                        id:ranking_color
                        z:3
                        y:parent.height/2-height/2
                        x:50
                        width: 12.82
                        height: 12.82
                        radius: width / 2
                        color: name_rect_color[ranking[index]]

                    }
                    Text{
                        id:ply_name
                        x:79.52
                        y:3
                        color:Qt.rgba(1,1,1,1)
                        font.pixelSize:16
                        font.weight: 400
                        font.bold: true
                        font.family: "Inter"
                        text:SharedData.playerName(ranking[index])
                    }
                    Text{
                        id:palyer_pass_dist
                        width:100
                        x:200
                        y:3
                        horizontalAlignment: Text.AlignRight
                        color:Qt.rgba(1,1,1,1)
                        font.pixelSize:16
                        font.weight: 400
                        font.bold: true
                        font.family: "Inter"
                        text:passed_dist[ranking[index]]<total_dist?passed_dist[ranking[index]]+"m":race_end_time[index]//(end_line.x-first_line.x)*500.0/
                        Component.onCompleted:
                        {
                            race_end_time[index]=palyer_pass_dist;
                        }
                    }
                    Text{
                        width:100
                        x:200
                        y:29.5
                        horizontalAlignment: Text.AlignRight
                        color:"#F87171"
                        font.pixelSize:12
                        font.weight: 400
                        font.bold: true
                        font.family: "Inter"
                        text:passed_dist[ranking[index]]<total_dist?"+"+Math.round(10.0*(total_dist-parseFloat(palyer_pass_dist.text)))/10+"m":"+0m"
                    }
                    Text {
                        // y:-height/2
                        // x:-60
                        x:79.52
                        y:29.5
                        color:Qt.rgba(1,1,1,0.4)
                        font.pixelSize:12
                        font.weight: 400
                        font.bold: true
                        font.family: "Inter"
                        text:SharedData.playerCat(ranking[index])//index<2?"Pro":index<4?"Elite":index<6?"Masters":index<8?"Open":"Junior"
                    }
                }
            }
        }
    }
    Image {
        id:end_line
        x:1427
        y:110
        width:6
        height:740
        source:"qrc:/images/end_line.svg"
    }
    Image {
        id:first_line
        x:93
        y:110
        width:6
        height:740
        source:"qrc:/images/end_line.svg"
    }
    Column{
        x:91
        y:115
        z:3
        Repeater {
            model: _rows+1



            Image {
                z:4
                width:1920
                height:740/_rows
                source:index<_rows? "qrc:/images/each_lane_rect.svg":""
            }
        }
    }
    //lane_label
    Row{
        x:first_line.x
        y:916
        z:3
        spacing:(end_line.x-first_line.x-750)/5//-x//(end_line.x-x)/5+x
        Repeater {
            model: 9
            Column{

                Image {
                    z:4
                    source: "qrc:/images/race_label.svg"
                    Rectangle{
                        anchors.fill: parent
                        color:index===5?"#EF4444":index===3?"#FACC15":Qt.rgba(1,1,1,1)
                    }
                }

                Text {
                    x:-75
                    width: 150
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.NoWrap
                    color:index===5?"#EF4444":index===3?"#FACC15":Qt.rgba(1,1,1,1)
                    font.pixelSize:18
                    font.weight: 500
                    font.bold: true
                    font.family: "Inter"
                    text:total_dist*index/5+"m"//index<_rows?(index+1)+"":""
                }
            }

        }
    }
    Text{
        x:862
        y:887
        color:Qt.rgba(1,1,1,1)
        font.pixelSize:16
        font.weight: 500
        font.bold: true
        font.family: "Inter"
        text:"Race Overview-"+total_dist+"m"
    }
    Text{
        x:1800
        y:35
        color:Qt.rgba(1,1,1,0.6)
        font.pixelSize:12
        font.weight: 400
        font.bold: true
        font.family: "Inter"
        text:"RACE"
    }
    Text{
        x:1800
        y:52
        color:Qt.rgba(1,1,1,1)
        font.pixelSize:25
        font.weight: 700
        font.bold: true
        font.family: "Inter"
        text:total_dist+"m"
    }
    Text{
        id:race_time
        x:1645
        y:55
        color:Qt.rgba(1,1,1,1)
        font.pixelSize:25
        font.weight: 500
        font.bold: true
        font.family: "Inter"
        text:"00:00"
    }
    function formatTime(sec) {
        var m = Math.floor(sec / 60);
        var s = sec % 60;

        // Add leading zeros
        var mm = (m < 10 ? "0" : "") + m;
        var ss = (s < 10 ? "0" : "") + s;

        return mm + ":" + ss;
    }
    function randomInt(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min
    }

    function bubbleSortIndexes(values,rows_num) {
        // Create an array of indexes [0,1,2,...]
        var indexes = []
        for (var i = 0; i < rows_num; i++)
            indexes.push(i)

        var n = indexes.length
        for (i = 0; i < n - 1; i++) {
            for (var j = 0; j < n - i - 1; j++) {
                // Compare values using the indexes
                if (values[indexes[j]] < values[indexes[j + 1]]) {
                    var temp = indexes[j]
                    indexes[j] = indexes[j + 1]
                    indexes[j + 1] = temp
                }
            }
        }
        return indexes
    }
    Timer {
        id: race_timer1
        interval: 500
        repeat: true
        running: false

        property var temp:[0,0,0,0,0,0,0,0,0,0]
        property var temp1:[_rows,_rows,_rows,_rows,_rows,_rows,_rows,_rows,_rows,_rows]
        property int race_end_state:0
        property int race_end_count:0
        onTriggered: {
            for(var i=0;i<_rows;i++)
            {
                device_dist[i]= start_dist[i]-SharedData.getDistance(i);
            }

            race_end_state=0;
            for( i=0;i<_rows;i++)
            {
                //console.log("conosle1_distance:"+SharedData.getDistance(i));
                //console.log(second_window.laneRefs[i].x );
                var p0 = first_line.mapToItem(null, 0, 0)
                var p = end_line.mapToItem(null, 0, 0)
                var p1 = second_window.laneRefs[i].mapToItem(null, 0, 0)
                var tmp_val;
                //console.log(p1+":"+p );
                if(p1.x+second_window.laneRefs[i].width<=p.x )
                {
                    race_end_state=1;
                    var temp_val=device_dist[i]*(end_line.x-first_line.x)/(total_dist*1.0)+p0.x-second_window.laneRefs[i].width;//total_dist*(p1.x-p0.x+second_window.laneRefs[i].width)/(1.0*(end_line.x-first_line.x))
                    second_window.laneRefs[i].x=temp_val-96;
                    //second_window.laneRefs[i].x+=randomInt(2,16);
                    temp[i]=second_window.laneRefs[i].x;

                }
                else
                {
                    //temp[i]=1000000+10000*race_end_count+second_window.laneRefs[i].x
                    second_window.laneRefs[i].running=false;
                    passed_dist[i]=total_dist;
                    if(temp1[i]===_rows)
                    {
                        console.log("ranking:::"+i);
                        tmp_val=formatTime(race_total_time);
                        race_end_time[i].text=tmp_val;
                        temp1[i]=race_end_count;
                        race_end_count++;
                    }
                    temp[i]+=1000000*(_rows-temp1[i]);
                }
                passed_dist[i]=device_dist[i];//total_dist*(p1.x-p0.x+second_window.laneRefs[i].width)/(1.0*(end_line.x-first_line.x))
                passed_dist[i]=Math.round(passed_dist[i]*10)/10
                ranking=bubbleSortIndexes(temp,_rows);
                //  console.log(ranking);
                //dist[i]+=randomInt(5,150);

            }
            if(race_end_state==0)
            {

                countdownTimer.stop();
                stop();
            }

        }

    }

    Column{
        x:91
        y:105
        z:2
        spacing:740/_rows-10
        Repeater {
            model: _rows+1

            Image {
                id:race_line
                source:"qrc:/images/race_line.png"
                z:10

                Image {
                    x:5
                    y:41*10/_rows
                    z:4
                    source:index<_rows? "qrc:/images/race_vector_line.svg":""

                    Image {
                        id:player_distance_img
                        z:5
                        x:4
                        width:index<_rows?seq.x:0////////////////////player racing distance
                        source:index<_rows? "qrc:/images/race_vector_passed.svg":""
                        // Behavior on width {
                        //     NumberAnimation { duration: 1 } // almost instant but forces refresh
                        // }
                    }
                    Text {
                        y:-height/2
                        x:-60
                        color:Qt.rgba(1,1,1,0.25)
                        font.pixelSize:48
                        font.weight: 700
                        font.bold: true
                        font.family: "Inter"
                        text:index<_rows?(index+1)+"":""
                    }

                    // property var scenePos : seq.mapToItem(null, 0, 0)
                    SpriteSequence {
                        id: seq
                        z:25
                        y:-height/2
                        x:first_line.x-width-91-race_line.x-5//index<_rows?player_distance_img.width:player_distance_img.width
                        width:75*467/242
                        height: 75
                        running: race_timer1.running?true:false
                        interpolate: false
                        // Behavior on width {
                        //     NumberAnimation { duration: 1 } // almost instant but forces refresh
                        // }
                        Sprite {
                            name: "paddle"

                            source: index<_rows? "qrc:/images/player_sprite.png":""
                            frameCount: 12
                            frameWidth: 467
                            frameHeight: 242

                            frameRate: 12   // or adjust

                        }
                        Component.onCompleted: {
                            second_window.laneRefs[index]=seq;

                            //second_window.player_sprite[index]=seq;
                        }
                    }
                    Rectangle {
                        z:5
                        y:-height/2
                        x:seq.width+seq.mapToItem(null,0,0).x<end_line.mapToItem(null, 0, 0).x-300?seq.width+seq.x+3:seq.x-width-40
                        width:seq.width
                        height:52
                        color: index<_rows?name_rect_color[index] :Qt.rgba(0,0,0,0)
                        visible:index>=_rows?false:true
                        radius: 10
                        Text{
                            anchors.fill:parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color:Qt.rgba(1,1,1,1)
                            font.pixelSize:16
                            font.weight: 700
                            font.bold: true
                            font.family: "Inter"
                            text:SharedData.playerName(index)
                        }

                    }
                    // Image {
                    //     z:5
                    //     y:-height/2
                    //     x:seq.width+seq.x-20
                    //     source:index<_rows? "qrc:/images/player_name_rect.svg":""
                    // }
                }

            }


        }

    }


}
