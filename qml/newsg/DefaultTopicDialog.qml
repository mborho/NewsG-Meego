/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import "js/gnews.js" as Gnews

SelectionDialog {
    id: defaultTopicDialog
    titleText: "Set default topic"
    selectedIndex: -1
    Component.onCompleted: onStartup()

    function onStartup() {
        var max = Gnews.confTopics.length;
        for(var x=0; max > x;x++) {
            if(Gnews.confTopics[x].value == appWindow.defaultTopic) {
                selectedIndex = x;
            }
        }
    }

    function accept() {
         var selectedTopic = Gnews.confTopics[selectedIndex];
         appWindow.saveSettingValue('defaultTopic', selectedTopic.value)
         appWindow.changeDefaultTopicLabel(selectedTopic.label)
         appWindow.defaultTopic = selectedTopic.value;
         close();
    }

    model: ListModel {
        id: defaultTopicModel
        ListElement {name: "Top Stories"}
        ListElement {name: "World"}
        ListElement {name: "National"}
        ListElement {name: "Business"}
        ListElement {name: "Science/Technology"}
        ListElement {name: "Politics"}
        ListElement {name: "Entertainment"}
        ListElement {name: "Sports"}
        ListElement {name: "Health"}
        ListElement {name: "Spotlight"}
        ListElement {name: "Most Popular"}
    }
}
