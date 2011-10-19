/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import "js/gnews.js" as Gnews

SelectionDialog {
    id: defaultTopicDialog
    titleText: "Set font size"
    selectedIndex: 1
    property int maxFont: 4

    function openDialog() {
        selectedIndex = 8-maxFont-appWindow.fontSizeFactor;
        open();
    }

    function accept() {
        var selectedSize = maxFont-selectedIndex
        appWindow.saveSettingValue('fontSizeFactor', selectedSize)
        appWindow.fontSizeFactor = selectedSize
        close();
        mainPage.doRefresh()
    }

    model: ListModel {
        id: fontSizeModel
        ListElement {name: "+4"}
        ListElement {name: "+3"}
        ListElement {name: "+2"}
        ListElement {name: "+1"}
        ListElement {name: "0"}
        ListElement {name: "-1"}
        ListElement {name: "-2"}
        ListElement {name: "-3"}
        ListElement {name: "-4"}
    }
}
