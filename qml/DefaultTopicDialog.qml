import QtQuick 1.1
import com.meego 1.0
import "js/gnews.js" as Gnews

SelectionDialog {
    id: defaultTopicDialog
    titleText: "Set default topic"
    selectedIndex: 1

    function openDialog() {
        var max = Gnews.confTopics.length;
        for(var x=0; max > x;x++) {
            if(Gnews.confTopics[x].value == appWindow.settings.defaultTopic) {
                selectedIndex = x;
            }
            defaultTopicModel.append({name: Gnews.confTopics[x].label})
        }
        open();
    }

    function accept() {
         var selectedTopic = Gnews.confTopics[selectedIndex];
         appWindow.saveSettingValue('defaultTopic', selectedTopic.value)
         appWindow.changeDefaultTopicLabel(selectedTopic.label)
         close();
    }

    model: ListModel {
        id: defaultTopicModel
    }
}
