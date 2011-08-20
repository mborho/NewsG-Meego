/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.meego 1.0
import "js/gnews.js" as Gnews

SelectionDialog {
    id: defaultEditionDialog
    titleText: "Set default edition"
    selectedIndex: 1

    function openDialog() {
        var editions = Gnews.getEditionList();
        var max = editions.length;
        for(var x=0; max > x;x++) {
            if(editions[x].value == appWindow.settings.defaultNed) {
                selectedIndex = x;
            }
            defaultEditionModel.append({name: editions[x].label})
        }
        open();
    }

    function accept() {
        var editions = Gnews.getEditionList();
        var selectedNed = editions[selectedIndex];
        appWindow.saveSettingValue('defaultNed', selectedNed.value)
        appWindow.changeDefaultNedLabel(selectedNed.label)
        close();
    }

    model: ListModel {
        id: defaultEditionModel
    }
}
