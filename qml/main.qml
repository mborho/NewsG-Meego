import QtQuick 1.1
import com.meego 1.0
import "js/storage.js" as Storage
import "js/gnews.js" as Gnews

PageStackWindow {
    id: appWindow

    initialPage: mainPage
    property variant settings:  {}
    property string currentNed: "us"
    property string currentTopic: "h"
    property string currentTopicColor: "#6B90DA"
    property variant topicsOrder: ["h","w","n","b","t","p","e","s","m","ir","po"]
    property variant topicsHidden: []
    property bool loadImages: true
    property bool gMobilizer: false    
    property bool settingsComplete: false
    Component.onCompleted: onStartup()

    MainPage{id: mainPage}

    function onStartup() {
        var defaults = {
            defaultNed:currentNed,
            defaultTopic: currentTopic,
            loadImages: loadImages,
            gMobilizer: gMobilizer,
            topicsOrder: JSON.stringify(topicsOrder),
            topicsHidden: JSON.stringify(topicsHidden),
        }
        Storage.loadSettings(defaults, settingsLoaded);
    }

    function settingsLoaded(dbSettings) {
        settings = dbSettings
        currentNed = settings.defaultNed
        currentTopic = settings.defaultTopic
        currentTopicColor = Gnews.getTopicColor(currentTopic)
        loadImages = settings.loadImages
        gMobilizer = settings.gMobilizer
        topicsOrder = JSON.parse(settings.topicsOrder)
        topicsHidden = JSON.parse(settings.topicsHidden)
        settingsComplete = true
        mainPage.start()
    }

    function saveSettingValue(key, value) {
        console.log('save setting: '+key+' = '+value)
        Storage.insertSetting(key, value);
    }

    function isHiddenTopic(topic) {
        var max = appWindow.topicsHidden.length;
        for(var j=0; max > j;j++) {
            if(topic == appWindow.topicsHidden[j]) {
                return true;
            }
        }
        return false;
    }

    function getManagedTopics(unOrderedTopics) {
        var topics = [];
        var max = appWindow.topicsOrder.length;
        for(var i=0;i< max;i++) {
            var data = unOrderedTopics[appWindow.topicsOrder[i]];
            data.visibility = true;
            if(isHiddenTopic(appWindow.topicsOrder[i])) {
                data.visibility = false;
            }
            topics.push(data);
        }
        return topics;
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

    TopicsManagerDialog {
        id:topicManager
    }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {            
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
            MenuItem {
                text: 'Open links with <br/>Google Mobilizer'
                Switch {
                    id: gMobilizerSwitch
                    checked: appWindow.gMobilizer
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 30
                    onCheckedChanged: (settingsComplete === true) ? gMobilizerChanged() : false

                    function gMobilizerChanged() {
                        appWindow.saveSettingValue('gMobilizer',checked)
                        appWindow.gMobilizer = checked
                    }
                }
            }
            MenuItem {
                text: 'Load images'
                Switch {
                    id: imagesSwitch
                    checked: appWindow.loadImages
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 30
                    onCheckedChanged: (settingsComplete === true) ? loadImagesChanged() : false

                    function loadImagesChanged() {
                        appWindow.saveSettingValue('loadImages', checked)
                        appWindow.loadImages = checked
                    }
                 }
            }
            MenuItem {
                text: "Manage topics"
                onClicked: {
                    topicManager.loadModel();
                    pageStack.push(topicManager);
                }
            }
            MenuItem { text: "Select edition"; onClicked: editionSelectionDialog.openDialog() }
        }
    }
}
