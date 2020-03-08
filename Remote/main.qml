import QtQuick 2.12
import QtQuick.Controls 2.12
import BleConnect.module 1.0

ApplicationWindow {
    id:root;
    visible: true
    width: 640
    height: 480
    title: qsTr("Tabs")

    property var bleconnect:ble;
    property var controlPage:page1;
    property var setPage:page2;
    property var swipeViewDe:swipeView;

    SwipeView {
        id: swipeView
        anchors.fill: parent

        Page1Form {
            id:page1;
        }

        Page2Form {
            id:page2;
        }
    }

//    footer: TabBar {
//        id: tabBar
//        currentIndex: swipeView.currentIndex

//        TabButton {
//            text: qsTr("遥控")
//        }
//        TabButton {
//            text: qsTr("连接和设置")
//        }
//    }

    BLE{
        id:ble;
    }
}
