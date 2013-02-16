/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import "js/gnews.js" as Gnews

SelectionDialog {
    id: backendDialog
    titleText: "Choose data source"
    selectedIndex: 0
    property int maxFont: 4

    function openDialog() {
        selectedIndex = (appWindow.dataSource === "api") ? 0 : 1;
        open();
    }

    function accept() {
        var dataSource = (selectedIndex === 1) ? "feed" : "api";
        appWindow.saveSettingValue('dataSource', dataSource)
        appWindow.dataSource = dataSource
        close();
        mainPage.doRefresh()
    }

    model: ListModel {
        id: backendModel
        ListElement {name: "API (deprecated)"}
        ListElement {name: "Feed"}
    }
}
