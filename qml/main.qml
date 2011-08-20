/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.meego 1.0
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
        id: commonTools
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

    EditionSelectionDialog {
        id:editionSelectionDialog
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

    TopicsManagerDialog {
        id:topicManager
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
                 msg += 'License: GNU General Public License (GPL) Vers.2<br/>';
                 msg += 'Source: <a href="http://github.com/mborho/NewsG-Meego">http://github.com/mborho/NewsG-Meego</a><br/>';
                 msg += 'Icon from <a href="http://thenounproject.com">The Noun Project</a><br/>'
                 msg += '<div><b>Changelog:</b><br/>'
                 msg += '<div>* 0.2.8 - fullscreen mode, more editions,bugs<br/>fixed, new icon</div>';
                 msg += '<div>* 0.2.2 - search added, minor tweaks</div>';
                 msg += '<div>* 0.1.0 - initial release</div>';
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
        visualParent: pageStack
        MenuLayout {
            MenuItem {
                id:aboutButton
                text: 'About'
                onClicked: aboutDialog.open()
            }
            MenuItem {
                id:fontSizeButton
                text: '<span style="color:grey;font-size:small">Font size </span>  '+ ((appWindow.fontSizeFactor >= 1) ? '+' : '')+((appWindow.fontSizeFactor === 0) ? '+- ' : '') + appWindow.fontSizeFactor
                onClicked: fontSizeDialog.openDialog()
            }
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
