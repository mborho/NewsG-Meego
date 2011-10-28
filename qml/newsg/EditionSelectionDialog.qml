/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import "js/gnews.js" as Gnews

SelectionDialog {
    id: editionSelectionDialog
    titleText: "Select edition"
    selectedIndex: -1
    Component.onCompleted: onStartup();

    function onStartup() {
        var editions = Gnews.getEditionList();
        var max = editions.length;
        for(var x=0; max > x;x++) {
            if(editions[x].value == appWindow.currentNed) {
                selectedIndex = x;
            }
        }        
    }

    function accept() {
        var editions = Gnews.getEditionList();
        var selectedNed = editions[selectedIndex];
        appWindow.currentNed = selectedNed.value
        close();
        mainPage.setTopicLabel()
        mainPage.doRefresh();
    }

    EditionsModel {
        id:editionsModel;
    }

    model: editionsModel

}
