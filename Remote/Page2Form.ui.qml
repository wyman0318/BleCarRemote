import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    width: 600
    height: 400

    property int getRepeatTime:100;
    property int getRepeatFront:500;
    property alias isChecked : repeatSwitch.checked;

    header: Label {
        text: qsTr("设置界面")
        font.pixelSize: Qt.application.font.pixelSize * 2
        padding: 10
    }

    Rectangle {
        id: rectangle
        x: 0
        y: 11
        width: 600
        height: 59
        color: "#352828"

        ListView {
            id: listView
            highlightMoveDuration: 10
            clip: true
            contentHeight: 160
            anchors.rightMargin: 0
            anchors.bottomMargin: 0
            anchors.leftMargin: 0
            anchors.topMargin: 0
            anchors.fill: parent
            highlightRangeMode: ListView.StrictlyEnforceRange
            delegate: Item {
                id:warrap;
                x: 5
                width: 80
                height: 20

                Row {
                    id: row1

                    Text {
                        text: name
                        width: 80
                        anchors.verticalCenter: parent.verticalCenter
                        font.bold: true
                        font.pointSize: 15;
                        color: "white"
                    }

                }
            }
            model: ListModel {
            }
            highlight: Rectangle{
                width: 600
                color: "grey";
            }
        }
    }

    Button {
        id: button
        x: 13
        y: 76
        width: 137
        height: 48
        text: qsTr("连接蓝牙")
    }

    Text {
        id: repeatFront
        x: 13
        y: 122
        width: 103
        height: 32
        color: "#e2bfbf"
        text: qsTr("周期前延时")
        font.pointSize: 15
    }

    Text {
        id: repeatTime
        x: 13
        y: 149
        width: 110
        height: 26
        color: "#e4c1c1"
        text: qsTr("周期间隔")
        font.pointSize: 15
    }

    Rectangle {
        id: rectangle1
        x: 122
        y: 122
        width: 195
        height: 22
        color: "#ffffff"

        TextInput {
            id: element2
            text: "500"
            readOnly: !repeatSwitch.checked;
            font.pointSize: 12
            anchors.fill: parent
        }
    }

    Rectangle {
        id: rectangle2
        x: 122
        y: 154
        width: 195
        height: 21
        color: "#ffffff"

        TextInput {
            id: element3
            height: 22
            text: "100"
            readOnly: !repeatSwitch.checked;
            anchors.bottomMargin: 0
            font.pointSize: 12
            anchors.fill: parent
        }
    }

    Connections{
        target: root.bleconnect;
        onFromBle:{
            ble_msg.append(msg+"\n");

        }
    }

    Button {
        id: ble_search
        x: 170
        y: 76
        width: 137
        text: qsTr("重新搜索")
    }

    Connections{
        target: root.bleconnect;
        onAddItems:{
            listView.model.append({"name":item});
//            listView.model.append({"name":item});
        }
    }

    Connections {
        target: ble_search
        onClicked:{
            listView.model.clear();
            root.bleconnect.on_blue_search_clicked(true);
        }
    }

    Connections {
        target: button
        onClicked: {
            var data=listView.model.get(listView.currentIndex);
            root.bleconnect.on_blue_connect_clicked(data.name);
        }
    }

    ScrollView {
        id: scrollView
        x: 341
        y: 78
        width: 219
        height: 97

        TextArea {
            id: ble_msg
            anchors.fill: parent
            wrapMode: Text.WrapAnywhere
            readOnly: true;
        }
    }

    Connections {
        target: element2
        onEditingFinished: {
            getRepeatFront=parseInt(element2.text);
            console.debug(repeatFront.text)
        }
    }

    Connections {
        target: element3
        onEditingFinished: {
            getRepeatTime=parseInt(element3.text);
            console.debug(repeatTime.text)
        }
    }

    Switch {
        id: repeatSwitch
        x: 13
        y: 181
        width: 195
        height: 48
        text: checked?"周期发送（开）":"周期发送（关）";
        font.pointSize: 12
    }

}


