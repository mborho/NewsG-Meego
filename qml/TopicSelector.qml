import QtQuick 1.1
import com.meego 1.0
import "js/gnews.js" as Gnews

Rectangle {
    id:topicSelector
    height:71
    width: parent.width
    color: (topicArea.pressed) ? "#000" : appWindow.currentTopicColor
    opacity: (topicArea.pressed) ? 0.5: 1
    z:3
    Label {
        id: topicLabelSelected
        text: ''
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 40
        platformStyle: LabelStyle {
                 textColor: "white"
                 fontPixelSize: 35
             }
    }
    Image {
        source: "gfx/topics_down.png"
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.verticalCenter: parent.verticalCenter
        height: 24
        width: 24
    }

    MouseArea {
        id: topicArea
        anchors.fill: parent
        onClicked: (topicSelectMenu.status == DialogStatus.Closed) ? topicSelectMenu.openMenu() : topicSelectMenu.closeMenu()
    }

    function setTopicLabel() {
        topicLabelSelected.text = Gnews.getTopicLabel(appWindow.currentNed, appWindow.currentTopic);
    }

    function topicSelectorClicked(topicId, topicLabel, topicColor) {
        appWindow.currentTopic = topicId
        mainPage.resultPage = 1
        topicLabelSelected.text = topicLabel;
        topicSelector.color = topicColor;
        appWindow.currentTopicColor = topicColor;
        newsList.doRequest();
    }
}
