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
            defaultNed:currentNed,
            defaultTopic: currentTopic,
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

    ToolBarLayout {
        id:commonTools
        visible: true
        ToolIcon {
             id: searchIcon
             platformIconId: "toolbar-search";
             visible: true
             onClicked: {
                 searchPage.startup();
                 pageStack.push(searchPage);
            }
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

    DefaultEditionDialog {
        id:defaultEditionDialog
    }

    FontSizeDialog {
        id: fontSizeDialog
    }

    DefaultTopicDialog {
        id:defaultTopicDialog
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

    SearchPage {
        id:searchPage
    }

    Dialog {
       id: aboutDialog
       content:Item {
            id: name
            width: parent.width
            height: 300
            Text {
                font.pixelSize:20
                color: "white"
                anchors.centerIn: parent
                text: parent.getAboutMsg()
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                onLinkActivated: Qt.openUrlExternally(link)
            }
            function getAboutMsg() {
                 var msg = '<h1>NewsG for Meego</h1>';
                 msg += '<p>&#169; 2011, Martin Borho <a href="mailto:martin@borho.net">martin@borho.net</a><br/>';
                 msg += 'License: GNU General Public License (GPL) Vers.3<br/>';
                 msg += 'Source: <a href="http://github.com/mborho/NewsG-Meego">http://github.com/mborho/NewsG-Meego</a><br/>';
                 msg += 'Icon from <a href="http://thenounproject.com">The Noun Project</a><br/>'
                 msg += '<div><b>Changelog:</b><br/>'
                 msg += '<div>* 0.9.0 - modifications for PR1.1, bugfixes</div>';
                 msg += '<div>* 0.7.2 - search page modified, scrolling</div>';
                 msg += '<div>* 0.6.1 - ui improvements, editions added</div>';
                 msg += '<div>* 0.4.0 - more editions added, ui tweaks</div>';
                 msg += '<div>* 0.2.9 - fullscreen mode, more editions, new <br/>icon, option for font-size </div>';
                 msg += '</div>';
                 msg += '</p><br/>';
                 msg += '<table><tr><td valign="middle">powered by </td>';
                 msg += '<td valign="middle"> <img src="gfx/glogo.png" height="41" width="114" /></td>';
                 msg += '</tr></table>';
                 return msg
            }
        }
    }

    Menu {
        id: myMenu
        MenuLayout {
            MenuItem {
                id:aboutButton
                text: 'About'
                height:70
                onClicked: aboutDialog.open()
            }
            MenuItem {
                id:fontSizeButton
                height:70
                text: '<span style="color:grey;font-size:small">Font size </span>  '+ ((appWindow.fontSizeFactor >= 1) ? '+' : '')+((appWindow.fontSizeFactor === 0) ? '+- ' : '') + appWindow.fontSizeFactor
                onClicked: fontSizeDialog.openDialog()
            }
            MenuItem {
                id:defaultNedButton
                height:70
                text: '<span style="color:grey;font-size:small">Default edition </span>  '+Gnews.getEditionLabel(appWindow.settings.defaultNed)
                onClicked: defaultEditionDialog.openDialog()
            }
            MenuItem {
                id:defaultTopicButton
                height:70
                text: '<span style="color:grey;font-size:small">Default topic </span>  '+Gnews.getConfTopicLabel(appWindow.settings.defaultTopic);
                onClicked: defaultTopicDialog.openDialog()
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
}
