import QtQuick 1.1
import com.meego 1.0

Rectangle {
    id: topicManager
    width: 360
    height: 360
    ListModel {
        id: starwarsModel
        ListElement {
            number: "IV"
            title: "A New Hope"
        }
        ListElement {
            number: "V"
            title: "The Empire Strikes Back"
        }
        ListElement {
            number: "VI"
            title: "Return of the Jedi"
        }
        ListElement {
            number: "I"
            title: "The Phantom Menace"
        }
        ListElement {
            number: "II"
            title: "Attack of the Clones"
        }
        ListElement {
            number: "III"
            title: "Revenge of the Sith"
        }
        ListElement {
            number: "VII"
            title: "The Force of the Jedi"
        }
        ListElement {
            number: "VIII"
            title: "The New Republic Challenged"
        }
        ListElement {
            number: "IX"
            title: "The Force Combined"
        }
        ListElement {
            number: "X"
            title: "The Council Rebuilt"
        }
        ListElement {
            number: "XI"
            title: "Jedi Outnumbered"
        }
        ListElement {
            number: "XII"
            title: "The Ultimate Force"
        }
    }
    Component {
        id: starwarsDelegate
        Rectangle {
            id: starwarsDelegateBorder
            border.color: "black"
            width: topicManager.width
            height: starwarsNumberText.height
            Row {
                spacing: 10
                Text { id: starwarsNumberText; text: number }
                Text { text: title }
                Text { text: index }
            }
            MouseArea {
                id: dragArea
                anchors.fill: parent
                property int positionStarted: 0
                property int positionEnded: 0
                property int positionsMoved: Math.floor((positionEnded - positionStarted)/starwarsNumberText.height)
                property int newPosition: index + positionsMoved
                property bool held: false
                drag.axis: Drag.YAxis
                onPressAndHold: {
                    starwarsDelegateBorder.z = 2,
                    positionStarted = starwarsDelegateBorder.y,
                    dragArea.drag.target = starwarsDelegateBorder,
                    starwarsDelegateBorder.opacity = 0.5,
                    starwarsList.interactive = false,
                    held = true
                    drag.maximumY = (topicManager.height - starwarsNumberText.height - 1 + starwarsList.contentY),
                    drag.minimumY = 0
                }
                onPositionChanged: {
                    positionEnded = starwarsDelegateBorder.y;
                }
                onReleased: {
                    if (Math.abs(positionsMoved) < 1 && held == true) {
                        starwarsDelegateBorder.y = positionStarted,
                        starwarsDelegateBorder.opacity = 1,
                        starwarsList.interactive = true,
                        dragArea.drag.target = null,
                        held = false
                    } else {
                        if (held == true) {
                            if (newPosition < 1) {
                                starwarsDelegateBorder.z = 1,
                                starwarsModel.move(index,0,1),
                                starwarsDelegateBorder.opacity = 1,
                                starwarsList.interactive = true,
                                dragArea.drag.target = null,
                                held = false
                            } else if (newPosition > starwarsList.count - 1) {
                                starwarsDelegateBorder.z = 1,
                                starwarsModel.move(index,starwarsList.count - 1,1),
                                starwarsDelegateBorder.opacity = 1,
                                starwarsList.interactive = true,
                                dragArea.drag.target = null,
                                held = false
                            }
                            else {
                                starwarsDelegateBorder.z = 1,
                                starwarsModel.move(index,newPosition,1),
                                starwarsDelegateBorder.opacity = 1,
                                starwarsList.interactive = true,
                                dragArea.drag.target = null,
                                held = false
                            }
                        }
                    }
                }
            }
        }
    }
    ListView {
        id: starwarsList
        anchors.fill: parent
        model: starwarsModel
        delegate: starwarsDelegate
    }
}
