/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import "js/gnews.js" as Gnews

Rectangle {
    id:topicSelector
    height:71
    width: parent.width
    color: appWindow.currentTopicColor
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
        onClicked: topicSelectMenuLoader.toggle()
        onPressed:  {
            parent.color = "#585858"
        }
        onReleased: {
            parent.color = appWindow.currentTopicColor
        }
    }

    function setTopicLabel() {
        topicLabelSelected.text = Gnews.getTopicLabel(appWindow.currentNed, appWindow.currentTopic);
    }

    function topicSelectorClicked(topicId, topicLabel, topicColor) {
        appWindow.currentTopic = topicId
        newsList.resultPage = 1
        topicLabelSelected.text = topicLabel;
        topicSelector.color = topicColor;
        appWindow.currentTopicColor = topicColor;
        newsList.doRequest();
    }
}
