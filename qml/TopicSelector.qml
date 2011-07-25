import QtQuick 1.1
import com.meego 1.0
import "js/gnews.js" as Gnews

Rectangle {
    id:topicSelector
    height:71
    width: parent.width
    color: appWindow.currentTopicColor
    z:3
    Label {
        id: topicLabelSelected
        text:  ''
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        platformStyle: LabelStyle {
                 textColor: "white"
                 fontPixelSize: 35
             }
    }
    MouseArea {
        id: topicArea
        anchors.fill: parent
        //onReleased: parent.topicSelectorClicked('test')
        onClicked: (topicSelectMenu.status == DialogStatus.Closed) ? topicSelectMenu.openMenu() : topicSelectMenu.closeMenu()
    }

    function setTopicLabel() {
        topicLabelSelected.text = Gnews.getTopicLabel(appWindow.currentNed, appWindow.currentTopic);
    }

    function topicSelectorClicked(topicId, topicLabel, topicColor) {
        appWindow.currentTopic = topicId
        mainPage.resultPage = 1
        topicLabelSelected.text = qsTr(topicLabel)
        appWindow.currentTopicColor = topicColor
        newsList.doRequest();
    }
}
