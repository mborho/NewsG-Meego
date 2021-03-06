/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import QtMobility.feedback 1.1
import com.nokia.meego 1.0
import "js/gnews.js" as Gnews

/**
 * Big thanks to http://blogofmu.com/2011/04/18/drag-and-drop-reorder-list-in-qml-qt/
 */
Page {
    id: topicManager
    tools: topicManagerTools
    width: parent.width
    height: parent.height
    anchors.bottom: parent.bottom
    anchors.centerIn: parent
    orientationLock: PageOrientation.LockPortrait
    property bool loadingComplete: false

    function loadModel() {
        topicsModel.clear();
        loadingComplete = false;
        var confTopics = Gnews.getConfTopics();
        var topics = appWindow.getManagedTopics(confTopics);
        var max = topics.length;
        for(var x=0; max > x;x++) {
            topicsModel.append(topics[x]);
        }
        loadingComplete = true;
    }

    function handleReordering() {
        var newOrder = [];
        var max = topicsModel.count;
        for(var x=0;max > x;x++) {
            newOrder.push(topicsModel.get(x).value);
        }
        appWindow.saveSettingValue('topicsOrder', JSON.stringify(newOrder))
        appWindow.topicsOrder = newOrder
    }

    function handleTopicVisibility(show, topic) {
        if(appWindow.orientationChangeInProgress === true) {
            return false;
        }

        var newHidden = appWindow.topicsHidden
        if(show) {
            newHidden.splice(newHidden.indexOf(topic),1);
        } else {
            newHidden.push(topic);

        }
        appWindow.topicsHidden = newHidden
        appWindow.saveSettingValue('topicsHidden', JSON.stringify(appWindow.topicsHidden))
    }

    Label {
        id: managerTitle
        text: 'Manage topics'
        width:parent.width
        height:80
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left:  parent.left
        anchors.leftMargin: 40
        platformStyle: LabelStyle {
                 fontPixelSize: 35
             }
    }

    ListModel {
        id: topicsModel
    }

    Component {
        id: topicsDelegate
        Item {
            id: topicsDelegateBorder
            width: topicManager.width
            height: topicNameText.height
            anchors.horizontalCenter: parent.horizontalCenter

            Button  {
                anchors.left:  parent.left
                anchors.leftMargin: 40
                id: topicNameText;
                text: label
            }

            Switch {
                id: topicActiveSwitch
                checked: visibility
                anchors.left: topicNameText.right
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                onCheckedChanged: (loadingComplete && status == PageStatus.Active) ? handleTopicVisibility(checked, value) : false
            }

            MouseArea {
                id: dragArea
                anchors.fill: topicNameText
                property int positionStarted: 0
                property int positionEnded: 0
                property int positionsMoved: Math.floor((positionEnded+(topicNameText.height/2) - positionStarted)/topicNameText.height)
                property int newPosition: index + positionsMoved
                property int lastPosition: index
                property bool held: false
                drag.axis: Drag.YAxis
                onPressAndHold: {
                    topicsDelegateBorder.z = 2,
                    positionStarted = topicsDelegateBorder.y,
                    dragArea.drag.target = topicsDelegateBorder,
                    topicsDelegateBorder.opacity = 0.5,
                    topicsManagerList.interactive = false,
                    held = true
                    drag.maximumY = (topicManager.height - topicNameText.height - 1 + topicsManagerList.contentY),
                    drag.minimumY = 0
                    pressedEffect.start();
                }
                onPositionChanged: {
                    positionEnded = topicsDelegateBorder.y;
                    if (Math.abs(positionsMoved) >= 1) {
                        if(held==true && lastPosition != newPosition) {
                            movedEffect.start();
                        }
                        lastPosition = newPosition
                    }
                }
                onReleased: {
                    if (Math.abs(positionsMoved) < 1 && held == true) {
                        topicsDelegateBorder.y = positionStarted,
                        topicsDelegateBorder.opacity = 1,
                        topicsManagerList.interactive = true,
                        dragArea.drag.target = null,
                        held = false
                        pressedEffect.start();
                    } else {
                        if (held == true) {
                            if (newPosition < 1) {
                                topicsDelegateBorder.z = 1,
                                topicsModel.move(index,0,1),
                                topicsDelegateBorder.opacity = 1,
                                topicsManagerList.interactive = true,
                                dragArea.drag.target = null,
                                held = false
                            } else if (newPosition > topicsManagerList.count - 1) {
                                topicsDelegateBorder.z = 1,
                                topicsModel.move(index,topicsManagerList.count - 1,1),
                                topicsDelegateBorder.opacity = 1,
                                topicsManagerList.interactive = true,
                                dragArea.drag.target = null,
                                held = false
                            }
                            else {
                                topicsDelegateBorder.z = 1,
                                topicsModel.move(index,newPosition,1),
                                topicsDelegateBorder.opacity = 1,
                                topicsManagerList.interactive = true,
                                dragArea.drag.target = null,
                                held = false
                            }
                            pressedEffect.start();
                        }
                        handleReordering();                        
                    }                    
                }
            }
        }
    }
    ListView {
        id: topicsManagerList
        model: topicsModel
        delegate: topicsDelegate
        width: parent.width
        height: parent.height-100
        anchors.top: managerTitle.bottom
        anchors.topMargin: 80
        anchors.centerIn: parent
        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id: managerHelp
        width:parent.width-80
        height:70
        anchors.left:  parent.left
        anchors.leftMargin: 40
        textFormat: Text.RichText
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 25
        text:"<ul><li>Use the switch to hide a topic.</li><li>Press on a topic for 1 second to drag and drop it to a new position.</li></ul>"
        font.pixelSize: 19
        wrapMode: Text.WordWrap
    }

    ToolBarLayout {
        id: topicManagerTools
        visible: true
        ToolIcon { iconId: "toolbar-back"; onClicked: { pageStack.pop(); } }
    }

    HapticsEffect {
         id: movedEffect
         attackIntensity: 0.0
         attackTime: 250
         intensity: 0.2
         duration: 100
         fadeTime: 250
         fadeIntensity: 0.0
     }

    FileEffect {
        id: pressedEffect
        loaded: false
        source: "file:////usr/share/sounds/vibra/tct_warning.ivt"
    }

}
