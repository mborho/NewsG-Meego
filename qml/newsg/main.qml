/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import "js/storage.js" as Storage
import "js/gnews.js" as Gnews

PageStackWindow {
    id: appWindow
    showStatusBar: false
    initialPage: mainPage
    property variant settings:  {}
    property string defaultNed: "us"
    property string defaultTopic: "h"
    property string currentNed: "us"
    property string currentTopic: "h"
    property string currentTopicColor: "#6B90DA"
    property variant topicsOrder: ["h","w","n","b","t","p","e","s","m","ir","po"]
    property variant topicsHidden: []
    property bool loadImages: true
    property bool gMobilizer: false
    property int fontSizeFactor: 0
    property bool settingsComplete: false
    property bool orientationChangeInProgress: false
    Component.onCompleted: onStartup()

    MainPage{id: mainPage}

    function onStartup() {
        var defaults = {
            defaultNed: defaultNed,
            defaultTopic: defaultTopic,
            loadImages: loadImages,
            gMobilizer: gMobilizer,
            fontSizeFactor: fontSizeFactor,
            topicsOrder: JSON.stringify(topicsOrder),
            topicsHidden: JSON.stringify(topicsHidden),
        }
        Storage.loadSettings(defaults, settingsLoaded);
    }

    function orientationChangeFinished () {
        orientationChangeInProgress = false
    }

    function orientationChangeStarted () {
        orientationChangeInProgress = true
    }

    function settingsLoaded(dbSettings) {
        settings = dbSettings
        defaultNed = settings.defaultNed
        defaultTopic = settings.defaultTopic
        currentNed = settings.defaultNed
        currentTopic = settings.defaultTopic
        currentTopicColor = Gnews.getTopicColor(currentTopic)
        loadImages = settings.loadImages
        gMobilizer = settings.gMobilizer
        fontSizeFactor = parseInt(settings.fontSizeFactor)
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

    /* Toolbar */
    ToolBarLayout {
        id:commonTools
        visible: true
        ToolIcon {
             id: searchIcon
             platformIconId: "toolbar-search";
             visible: true
             onClicked: searchPage.show();
        }
        BusyIndicator {
            id: loadingSpinner
            running: false
            visible: false
            platformStyle: BusyIndicatorStyle { size: "medium" }
            anchors.verticalCenter: parent.verticalCenter
        }
        ToolIcon {
             id: refreshIcon
             platformIconId: "toolbar-refresh";
             visible: true
             onClicked: (refreshIcon.visible == true) ? mainPage.doRefresh() : false
        }
        ToolIcon {
             id: settingsIcon
             platformIconId: "toolbar-view-menu";
             onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    Loader {
        id:searchPage
        onStatusChanged: {
            if (searchPage.status == Loader.Ready) {
                show();
            }
        }
        function show() {
            if (searchPage.status == Loader.Ready) {
                pageStack.push(searchPage.item);
                searchPage.item.startup();
            } else {
                searchPage.source = "SearchPage.qml"
            }
        }
    }

    /* Menu with loaders following */
    Menu {
        id: myMenu
        MenuLayout {
            MenuItem {
                id:aboutButton
                text: 'About'
                height:70
                onClicked: {
                    aboutLoader.source = "AboutDialog.qml";
                    aboutLoader.item.open();
                }

            }
            MenuItem {
                id:fontSizeButton
                height:70
                text: '<span style="color:grey;font-size:small">Font size </span>  '+ ((appWindow.fontSizeFactor >= 1) ? '+' : '')+((appWindow.fontSizeFactor === 0) ? '+- ' : '') + appWindow.fontSizeFactor
                onClicked: fontSizeDialog.show();
            }
            MenuItem {
                id:defaultNedButton
                height:70
                text: '<span style="color:grey;font-size:small">Default edition </span>  '+Gnews.getEditionLabel(appWindow.settings.defaultNed)
                onClicked: defaultEditionDialog.show();
            }
            MenuItem {
                id:defaultTopicButton
                height:70
                text: '<span style="color:grey;font-size:small">Default topic </span>  '+Gnews.getConfTopicLabel(appWindow.settings.defaultTopic);
                onClicked: defaultTopicDialog.show();
            }
            MenuItem {
                text: 'Open links with <br/>Google Mobilizer'
                height:70
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
                height:70
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
                height:70
                text: "Manage topics"
                onClicked: topicManager.show();
            }
            MenuItem {
                height:70
                text: "Select edition"
                onClicked: editionSelection.show()
            }
        }
    }

    Loader {
        id: aboutLoader
        anchors.fill: parent
    }

    Loader {
        id:editionSelection
        width: parent.width
        height: parent.height
        onStatusChanged: {
            if (editionSelection.status == Loader.Ready) {
                show()
            }
        }
        function show() {
            if (editionSelection.status == Loader.Ready) {
                editionSelection.item.openDialog();
            } else {
                editionSelection.source = "EditionSelectionDialog.qml"
            }
        }
    }

    Loader {
        id:fontSizeDialog
        width: parent.width
        height: parent.height
        onStatusChanged: {
            if (fontSizeDialog.status == Loader.Ready) {
                show()
            }
        }
        function show() {
            if (fontSizeDialog.status == Loader.Ready) {
                fontSizeDialog.item.openDialog();
            } else {
                fontSizeDialog.source = "FontSizeDialog.qml"
            }
        }
    }

    Loader {
        id:defaultEditionDialog
        width: parent.width
        height: parent.height
        onStatusChanged: {
            if (defaultEditionDialog.status == Loader.Ready) {
                show()
            }
        }
        function show() {
            if (defaultEditionDialog.status == Loader.Ready) {
                defaultEditionDialog.item.open();
            } else {
                defaultEditionDialog.source = "DefaultEditionDialog.qml"
            }
        }
    }

    Loader {
        id:defaultTopicDialog
        width: parent.width
        height: parent.height
        onStatusChanged: {
            if (defaultTopicDialog.status == Loader.Ready) {
                show()
            }
        }
        function show() {
            if (defaultTopicDialog.status == Loader.Ready) {
                defaultTopicDialog.item.open();
            } else {
                defaultTopicDialog.source = "DefaultTopicDialog.qml"
            }
        }
    }

    Loader {
        id:topicManager
        onStatusChanged: {
            if (topicManager.status == Loader.Ready) {
                show();//showTopicManager()
            }
        }
        function show() {
            if (topicManager.status == Loader.Ready) {
                topicManager.item.loadModel();
                pageStack.push(topicManager.item);
            } else {
                topicManager.source = "TopicsManagerDialog.qml"
            }
        }
    }
}
