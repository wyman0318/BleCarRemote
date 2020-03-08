import QtQuick 2.12
import QtQuick.Controls 2.12

Page {
    id: page
    width: 600
    height: 400

    property alias blue_msg:sendMsg.text

    header: Label {
        text: qsTr("遥控模式(请确保在设置界面连接蓝牙）")
        font.pixelSize: Qt.application.font.pixelSize * 2
        padding: 10
    }

    Button {
        id: buttonLeft
        x: 380
        y: 78
        width: 100
        height: 73
        visible: !controlSwitch.checked;
        text: qsTr("左转")
        autoRepeat: root.setPage.isChecked;
        autoRepeatDelay:  root.setPage.getRepeatFront;
        autoRepeatInterval: root.setPage.getRepeatTime;
    }

    Button {
        id: buttonRight
        y: 78
        width: 100
        height: 73
        text: qsTr("右转")
        visible: !controlSwitch.checked;
        autoRepeat: root.setPage.isChecked;
        autoRepeatDelay: root.setPage.getRepeatFront;
        autoRepeatInterval: root.setPage.getRepeatTime;
        anchors.left: buttonLeft.right
        anchors.leftMargin: 11
    }

    Button {
        id: buttonAhead
        x: 37
        y: 60
        width: 100
        height: 73
        text: qsTr("前进")
        visible: !controlSwitch.checked;
        autoRepeat: root.setPage.isChecked;
        autoRepeatDelay: root.setPage.getRepeatFront;
        autoRepeatInterval: root.setPage.getRepeatTime;
    }


    Connections{
        target: root.bleconnect;
        onSendRquest:{
            sendMsg.append(msg+"\n");
        }
    }

    TextInput {
        id: textLeft
        visible: setBtn.checked
        x: 395
        y: 44
        width: 100
        height: 35
        text: qsTr("l")
        font.pointSize: 12
    }

    TextInput {
        id: textAhead
        visible: setBtn.checked
        x: 144
        y: 63
        width: 61
        height: 35
        text: qsTr("a")
        font.pointSize: 12
    }

    TextInput {
        id: textRight
        visible: setBtn.checked
        x: 486
        y: 44
        width: 100
        height: 35
        text: qsTr("r")
        font.pointSize: 12
    }

    TextInput {
        id: textBack
        visible: setBtn.checked
        x: 144
        y: 161
        width: 100
        height: 35
        text: qsTr("b")
        font.pointSize: 12
    }

    Connections {
        target: buttonLeft
        onPressed:{
            root.bleconnect.sendBleMsg(textLeft.text);
        }
        onReleased:{
            root.bleconnect.sendBleMsg(stopText.text);
        }
    }

    Connections {
        target: buttonRight
        onPressed: {
            root.bleconnect.sendBleMsg(textRight.text);
        }
        onReleased:{
            root.bleconnect.sendBleMsg(stopText.text);
        }
    }

    Connections {
        target: buttonAhead
        onPressed: {
            root.bleconnect.sendBleMsg(textAhead.text);
        }
        onReleased:{
            root.bleconnect.sendBleMsg(stopText.text);
        }
    }

    Connections {
        target: buttonBack
        onPressed: {
            root.bleconnect.sendBleMsg(textBack.text);
        }
        onReleased:{
            root.bleconnect.sendBleMsg(stopText.text);
        }
    }

    ScrollView {
        id: scrollView
        x: 24
        y: 141
        width: 100
        height: 160

        TextArea {
            id: sendMsg
            anchors.fill: parent
            font.pointSize: 11
        }
    }

    Switch {
        id: controlSwitch;
        x: 132
        y: 0
        width: 99
        height: 51
        text: checked?"摇杆":"按键";
        checked: false
        checkable: true
    }

    Text {
        id: element
        x: 144
        y: 207
        width: 76
        height: 29
        color: "#ebe5e5"
        text: qsTr("占空比：")
        font.pixelSize: 20

        Text {
            id: element1
            y: -3
            width: 87
            height: 24
            color: "#f2efef"
            font.pixelSize: 20
           // text: (slider.valueInt*10).toString();
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.leftMargin: 69
        }

        Slider {
            id: slider
            x: 0
            y: 28
            width: 352
            height: 48
            to: 10
            value: 5
            property int valueInt:Math.round(value);
            property int old;
        }
    }

    Connections {
        target: slider
        onMoved: {
            if(slider.old!=slider.valueInt)
            {
                slider.old=slider.valueInt;
                if(slider.valueInt!=10)
                {
                    root.bleconnect.sendBleMsg(slider.valueInt.toString());
                }
                else{
                    root.bleconnect.sendBleMsg("t");
                }
            }
        }
    }

    Switch {
        id: setBtn
        x: 25
        y: 0
        width: 99
        height: 51
        text: checked?"ON":"OFF"
        checkable: true
        font.pointSize: 12
        checked: false
    }

    Rectangle {
        id: rectangle
        x: 400
        y: 29
        width: 180
        height: 180
        color: "#693d3d"
        radius: 90
        visible: controlSwitch.checked;

        Rectangle {
            id: circleControl
            x: 80
            y: 0
            width: 20
            height: 180
            color: "#2d0e0e"
            radius: 20
            rotation: 0;
            property int recX;
            property int recY;
            property int actullyR;
            property int old:5;
            property bool isRun;
        }
        MouseArea{
            id:mouse;
            anchors.fill: parent;
            hoverEnabled: true;
        }
    }

    Connections {
        target: mouse

        onPositionChanged:{
            circleControl.recX=mouse.x-rectangle.width/2;
            circleControl.recY=rectangle.height/2-mouse.y;
            circleControl.actullyR=Math.atan(circleControl.recY/circleControl.recX)/(Math.PI/180);
            circleControl.rotation=450-circleControl.actullyR;
            console.debug(circleControl.actullyR);
            if(((circleControl.actullyR>45&&circleControl.actullyR<90)||(circleControl.actullyR<-45&&circleControl.actullyR>-90))&&circleControl.recY>0&&circleControl.old!=0&&circleControl.isRun)
            {
                circleControl.old=0;
                root.bleconnect.sendBleMsg(textAhead.text);
            }
            else if(((circleControl.actullyR>45&&circleControl.actullyR<90)||(circleControl.actullyR<-45&&circleControl.actullyR>-90))&&circleControl.recY<0&&circleControl.old!=1&&circleControl.isRun)
            {
                circleControl.old=1;
                root.bleconnect.sendBleMsg(textBack.text);
            }
            else if(((circleControl.actullyR<=45&&circleControl.actullyR>=0)||(circleControl.actullyR>=-45&&circleControl.actullyR<=0))&&circleControl.recX<0&&circleControl.old!=2&&circleControl.isRun)
            {
                circleControl.old=2;
                root.bleconnect.sendBleMsg(textLeft.text);
            }
            else if(((circleControl.actullyR<=45&&circleControl.actullyR>=0)||(circleControl.actullyR>=-45&&circleControl.actullyR<=0))&&circleControl.recX>0&&circleControl.old!=3&&circleControl.isRun)
            {
                circleControl.old=3;
                root.bleconnect.sendBleMsg(textRight.text);
            }
        }
        onPressed:{
            circleControl.isRun=true;
            root.swipeViewDe.interactive=false;
        }
        onReleased:{
            circleControl.isRun=false;
            root.swipeViewDe.interactive=true;
            root.bleconnect.sendBleMsg(stopText.text);
        }

    }

    Text {
        id: element2
        x: 491
        y: 6
        width: 89
        height: 66
      //  text: circleControl.rotation.toString();
        font.pixelSize: 20
        visible: controlSwitch.checked;
    }

    Text {
        id: element3
        x: 308
        y: 201
        width: 73
        height: 29
        text: "停止："
        font.pixelSize: 20
        visible: setBtn.checked

        TextEdit {
            id: stopText
            x: 52
            y: 0
            width: 64
            height: 29
            font.pixelSize: 20
            text:"s"
        }
    }

    Button {
        id: buttonavoid
        x: 215
        y: 104
        width: 84
        height: 59
        text: qsTr("自动避障")
        autoRepeat: root.setPage.isChecked
        //visible: !controlSwitch.checked
        visible:true;
        autoRepeatInterval: root.setPage.getRepeatTime
        autoRepeatDelay: root.setPage.getRepeatFront
    }

    TextInput {
        id: textZ
        x: 215
        y: 63
        width: 61
        height: 35
        text: qsTr("z")
        font.pointSize: 12
        visible: setBtn.checked
    }

    Connections {
        target: buttonavoid
        onPressed: root.bleconnect.sendBleMsg(textZ.text);
    }
    Button {
        id: buttonBack
        x: 37
        y: 149
        width: 100
        height: 73
        text: qsTr("后退")
        visible: !controlSwitch.checked;
        autoRepeat: root.setPage.isChecked;
        autoRepeatDelay: root.setPage.getRepeatFront;
        autoRepeatInterval: root.setPage.getRepeatTime;
    }
}


