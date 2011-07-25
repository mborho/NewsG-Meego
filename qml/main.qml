import QtQuick 1.1
import com.meego 1.0
import "js/storage.js" as Storage
import "js/gnews.js" as Gnews

PageStackWindow {
    id: appWindow

    initialPage: mainPage
    property variant settings:  false
    property string currentNed: "us"
    property string currentTopic: "h"
    property string currentTopicColor: "#6B90DA"
    Component.onCompleted: onStartup()

    MainPage{id: mainPage}

    function onStartup() {
        console.log('startup main')
        var defaults = {
            defaultNed:currentNed,
            defaultTopic: currentTopic
        }
        Storage.loadSettings(defaults, settingsLoaded);
    }

    function settingsLoaded(dbSettings) {
        settings = dbSettings
        currentNed = settings.defaultNed
        currentTopic = settings.defaultTopic
        currentTopicColor = Gnews.getTopicColor(currentTopic)
        mainPage.start()
    }

    function saveSettingValue(key, value) {
        console.log('save setting: '+key+' = '+value)
        appWindow.settings[key] = value;
        Storage.insertSetting(key, value);
    }

    function changeDefaultNedLabel(newLabel) {
        defaultNedButton.text = '<span style="color:grey;font-size:small">Default edition </span>  '+newLabel
    }

    function changeDefaultTopicLabel(newLabel) {
        defaultTopicButton.text = '<span style="color:grey;font-size:small">Default topic </span>  '+newLabel
    }

    function startSpinner() {
        loadingSpinner.running = true
        loadingSpinner.visible = true
        refreshIcon.visible = false
    }

    function stopSpinner() {
        loadingSpinner.visible = false
        loadingSpinner.running = false
        refreshIcon.visible = true
    }

    ToolBarLayout {
        id: commonTools
        visible: true
//        ToolIcon { iconId: "toolbar-back"; onClicked: { myMenu.close(); pageStack.pop(); } }
        BusyIndicator {
            id: loadingSpinner
            running: false
            visible: false
            platformStyle: BusyIndicatorStyle { size: "medium" }
            anchors.right: settingsIcon.left
            anchors.rightMargin: 25
        }
        ToolIcon {
             id: refreshIcon
             platformIconId: "toolbar-refresh";
             visible: true
             anchors.right: settingsIcon.left
             onClicked: (refreshIcon.visible == true) ? mainPage.doRefresh() : false
        }
        ToolIcon {
             id: settingsIcon
             platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    EditionSelectionDialog {
        id:editionSelectionDialog
    }

    DefaultEditionDialog {
        id:defaultEditionDialog
    }

    DefaultTopicDialog {
        id:defaultTopicDialog
    }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: "Select edition"; onClicked: editionSelectionDialog.openDialog() }
            MenuItem {
                id:defaultNedButton
                text: '<span style="color:grey;font-size:small">Default edition </span>  '+Gnews.getEditionLabel(appWindow.settings.defaultNed)
                onClicked: defaultEditionDialog.openDialog()
            }
            MenuItem {
                id:defaultTopicButton
                text: '<span style="color:grey;font-size:small">Default topic </span>  '+Gnews.getConfTopicLabel(appWindow.settings.defaultTopic);
                onClicked: defaultTopicDialog.openDialog()
            }
        }
    }
}
