/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import "js/gnews.js" as Gnews
import FeedHelper 1.0

Rectangle {
    id: newsList
    width: parent.width
    height: parent.height-71
    anchors.bottom: parent.bottom
    property int resultPage: 1
    property string moreLabel: ''
    property variant resultUrls: []
    property string query: ""
    property bool querySort: false
    property bool pullToLoad: false
    property string token: ""
    property string mainColor: appWindow.currentTopicColor
    property string mainBgColor: "#FFFFFF"
    property double startedAt : 0.0
    property string moreIcon: (startedAt < 0.99999) ? "down" : "down_ready"
    property string moreRichText: '<p align="center" style=""><img src="gfx/'+moreIcon+'.png" /></p>'
    property int fontSizeFactor: appWindow.fontSizeFactor

    FeedHelper {
        id:feedHelper
    }

    DescListModel {
        id:test
    }

    function doRequest(queryTerm, querySort) {
        newsList.query = (queryTerm !== undefined) ? queryTerm : "";
        newsList.querySort = (querySort !== undefined) ? querySort : false;
        noNewsResults.visible = false;
        pullToLoad = false;
        token = new Date().getTime();
        prepareModel();
        setColors();
        var gnews = new Gnews.Gnews();
        gnews.page = newsList.resultPage
        gnews.ned = appWindow.currentNed;
        gnews.token = token;
        if(newsList.query !== "") {
            gnews.query = newsList.query;
            if(querySort === true) {
                gnews.sort = "d";
            }
            searchPage.startSpinner();
        } else {
            appWindow.startSpinner();
            gnews.topic = appWindow.currentTopic;
        }
        //gnews.doRequest(renderNewsItems);
        gnews.doRssRequest(feedHelper.parseString, renderNewsItemsRss);
    }

    function setColors() {
        if(newsList.query !== "") {
            if(newsList.mainColor !== searchPage.mainColor) {
                newsList.mainColor = searchPage.mainColor
                newsList.mainBgColor = "#D0E8FF" //#C3DEFF"
            }
        } else {
            if(newsList.mainColor !== appWindow.currentTopicColor) {
                newsList.mainColor = appWindow.currentTopicColor
            }
            if(newsList.mainBgColor !== Gnews.getTopicBgColor(appWindow.currentTopic)) {
                newsList.mainBgColor = Gnews.getTopicBgColor(appWindow.currentTopic)
            }
        }
    }

    function prepareModel() {
        if(newsList.resultPage == 1) {
            clearModel();
            moreLabel = Gnews.getMoreLabel(appWindow.currentNed);
        }
    }

    function clearModel() {
        newsList.resultUrls = []
        newsItemModel.clear();
    }

    function buildItem(data, fromRss) {
        var item = {},
            imgWidth = 140,
            title = data.titleNoFormatting;
        if(data.image === undefined || data.image.url === undefined || appWindow.loadImages === false) {
            item.image  = false;
        } else {        
            item.image = {}
            item.image.url = data.image.url;
            item.image.tbWidth = data.image.tbWidth
            item.image.tbHeight = data.image.tbHeight
            item.image.width = imgWidth;
            item.image.height =parseInt((imgWidth/item.image.tbWidth)*item.image.tbHeight);
        }
        item.header = getHeader(title, data.publisher, data.publishedDate);
        item.link = data.unescapedUrl;
        item.content = buildContentString(data.content, item.image);
        item.shareTitle = data.publisher +": "+title;
        return item;
    }

    function renderNewsItemsRss(items, reqToken) {
        var max = items.length,
            relatedsMax = 0,
            itemList = [];

        for(var x=0;max>x;x++) {        
            var item = buildItem(items[x]["main"])
            if(items[x].relatedStories.length > 0) {
                item.relateds = items[x].relatedStories;
            }
            newsItemModel.append(item);
        }
        if(newsList.query === "") {
            appWindow.stopSpinner();
        } else {
            searchPage.stopSpinner();
        }

    }

    function renderNewsItems(response, reqToken) {
        if(token !== reqToken) {
            return false;
        }
        var currentPage = response["responseData"]["cursor"]["currentPageIndex"]
        var maxPage = (response["responseData"]["cursor"]["pages"] !== undefined) ? response["responseData"]["cursor"]["pages"].length -1 : 1
        var items = response["responseData"]["results"]
        var max = items.length;
        var resultUrls = newsList.resultUrls
        if(max === 0 && newsList.resultPage === 1) {
            console.log('no results')
            noNewsResults.visible = true;
        }
        var itemList = [];
        for(var x=0;max > x;x++) {
            if(resultUrls.indexOf(items[x].unescapedUrl) > -1) {
                // check double cluster
                continue;
            }
            var item = buildItem(items[x])
            item.relateds = items[x].relatedStories;
            newsItemModel.append(item);
            itemList.push(item);
            resultUrls.push(items[x].unescapedUrl)
        }
        newsList.resultUrls =  resultUrls
        if(currentPage < maxPage) {
            itemList.push({image:false,header:'',content: '',relateds:''})
            pullToLoad = true;
        }
        max = itemList.length
        var resultPage = newsList.resultPage;
        var delPos = (resultPage != 1) ? newsItemModel.count-1 : false;
        for(var j=0;max >j;j++) {
            newsItemModel.append(itemList[j])
        }
        if(delPos !== false) {
            newsItemModel.remove(delPos);// remove reload item
        }

        if(newsList.query === "") {
            appWindow.stopSpinner();
        } else {
            searchPage.stopSpinner();
        }
    }

    function getHeader(title, publisher, publishedDate) {
        var date = new Date(publishedDate);
        var dateStr = Qt.formatDate(date, 'ddd MMM d') +' '+String(Qt.formatTime(date,Qt.TextDate)).substring(0,5)
        var h = '<span style="font-size:'+(17+newsList.fontSizeFactor)+'pt;font-weight:bold;">'+title+'</span><br/>'
        h += '<span style="font-size:'+(15+newsList.fontsizeFactor)+'pt;">'+publisher +'</span>  - <span style="font-style:italic;font-size:'+(14+newsList.fontSizeFactor)+'pt">'+dateStr+'</span>'
        return h
    }

    function buildContentString(content, image) {
        var text = '';
        if(image) {
            text += '<table style="float:left;margin: 5px 10px -5px 0px;padding-bottom:0px;"><tr>';
            text += '<td width="'+image.width+' valign="middle"><img src="gfx/dummy.png" style="background-color:#fff;" height="'+image.height+'" width="'+image.width+'" /></td>';
            text += '</tr></table>';
        }
        text += content+''
        return text
    }

    ListModel {
        id: newsItemModel
    }       

    Component {
        id:newsItemDelegate
        Rectangle {
            id: newsItemBox
            width:newsList.width
            height: (header !== "") ? childrenRect.height : 80;
            Behavior on height {
                 NumberAnimation {
                     duration: 600
                     easing {
                         type: Easing.InOutQuint
                     }
                 }
             }
            Text {
                id:newsTitle
                width:parent.width-30
                anchors.top: newsItemBox.top
                anchors.topMargin: (header !== "") ? 20 : 0
                anchors.horizontalCenter: parent.horizontalCenter
                text: header
                textFormat: Text.RichText
                font.pointSize: 15 + newsList.fontSizeFactor
                lineHeight:1.1
                wrapMode: Text.WordWrap
                visible: (header !== "") ? true : false;
                MouseArea {
                    anchors.fill: parent
                    onClicked: entryClicked(link)
                    onPressAndHold: Share.shareLink(link, shareTitle);
                    onPressed:  {parent.color = "#585858";}
                    onReleased:  {parent.color = '#000';}
                    onCanceled:  {parent.color = '#000';}
                }
            }
            Text {
                id:newsContent
                width:parent.width-30
                anchors.top: newsTitle.bottom
                anchors.topMargin: (header !== "") ? 5 : 0
                anchors.horizontalCenter: parent.horizontalCenter
                text: (header === "") ? moreRichText : content;
                textFormat: Text.RichText
                font.pointSize: 15 + newsList.fontSizeFactor
                lineHeight:1.1
                wrapMode: Text.WordWrap
                onLinkActivated: entryClicked(link)
                MouseArea {
                    enabled:  (header === "") ? true : false
                    anchors.fill: parent
                    onClicked: entryClicked('more')                    
                }
            }
            Item {
                id: newsImageContainer
                anchors.top: newsContent.top
                anchors.topMargin: 5
                anchors.left: newsContent.left
                height: image.height
                width: image.width
                visible: (header !== "" && image) ? true : false
                Image {
                    id: newsImage
                    source: (image) ? image.url : "gfx/dummy.png"
                    height: image.height
                    width: image.width
                    sourceSize.width: (image) ? image.tbWidth : image.width
                    sourceSize.height: (image) ? image.tbHeigth : image.height
                    opacity: 0
                    fillMode:Image.PreserveAspectFit
                    smooth: true
                    onStatusChanged: {
                        if (status == Image.Ready) {
                            imageIndicator.running = false;
                            imageIndicator.opacity = 0;
                            opacity = 1
                        }
                    }
                    Behavior on opacity {
                         NumberAnimation {
                             from: 0.0; to: 1.0
                             duration: 500
                             easing {
                                 type: Easing.InOutCubic
                             }
                         }
                     }
                }
                BusyIndicator {
                    id: imageIndicator
                    running: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    platformStyle: BusyIndicatorStyle { size: "small" }
                }
            }

            Rectangle {
                id: newsRelatedToggle
                width:parent.width
                height: (newsRelateds.visible === true) ? childrenRect.height : ((relateds) ? relToggleText.height : 0)
                anchors.top: newsContent.bottom
                anchors.topMargin: 5
                visible: (header !== "" && relateds) ? true : false
                Text {
                    id:relToggleText
                    width: parent.width
                    font.bold: true
                    text:  '<table style="background-color:'+newsList.mainColor+';" cellpadding="0" width="'+parent.width+'"><tr><td width="15%"></td><td width="85%" align="center" style="padding:7px;background-color:#fff;">'+((newsRelateds.visible) ? '▲' : '▼')+'   '+newsList.moreLabel+'   '+((newsRelateds.visible) ? '▲' : '▼')+'</td></tr></table>'
                    font.pointSize: 17 + newsList.fontSizeFactor
                    color: newsList.mainColor
                    height: 55
                    verticalAlignment: Text.AlignBottom
                    textFormat: Text.RichText
                    MouseArea {
                        id: moreMouse
                        anchors.fill: parent
                        onClicked: newsRelatedToggle.showRelateds()
                    }
                }
                Rectangle {
                    id:newsRelateds
                    width:parent.width
                    height:relatedsLoader.height
                    anchors.top: relToggleText.bottom
                    visible:false
                    Loader {
                        id:relatedsLoader
                        width:parent.width
                        anchors.centerIn: parent
                    }
                    function loadRelateds() {
                        relatedsLoader.source = "NewsItemRelateds.qml"
                        relatedsLoader.item.fillRelateds(relateds)
                    }
                 }
                Rectangle {
                    id:newsRelatedBottom
                    height:2
                    color: newsList.mainColor
                    anchors.top: newsRelateds.bottom
                    width: parent.width
                    visible: newsRelateds.visible
                }
                function showRelateds() {
                    if (newsRelateds.visible === true) {
                        newsRelateds.visible = false;
                    } else {
                        newsRelateds.loadRelateds()
                        newsRelateds.visible = true;
                    }
                }
            }
            Rectangle {
                id:newsNoRelatedBottom
                height:2
                color: newsList.mainColor
                anchors.top: newsContent.bottom
                anchors.topMargin: 15
                width: parent.width
                visible: (relateds === undefined && header !== "") ? true : false
            }
            Rectangle {
                height:15
                width:parent.width
            }
        }
    }

    function entryClicked(url) {
        if(url == "more") {            
            newsList.resultPage += 1
            console.log('load page '+newsList.resultPage)
            doRequest(newsList.query, newsList.querySort);
        } else {
            if(appWindow.gMobilizer === true) {
                   url = 'http://google.com/gwt/x?u='+encodeURIComponent(url)
            }
            console.log('Opening '+url);
            Qt.openUrlExternally ( url )
        }
    }

    Flickable {
        id:newsFlickable
        width:parent.width
        height: parent.height
        contentWidth: parent.width
        contentHeight: listContainer.height
        flickableDirection: Flickable.VerticalFlick
        onMovementStarted: {
            startedAt = (visibleArea.yPosition+visibleArea.heightRatio);
        }
        onMovementEnded: {
            if(pullToLoad && startedAt > 0.99999
                    && (visibleArea.yPosition+visibleArea.heightRatio) > 0.99999) {
                startedAt = 0 //reset
                entryClicked('more');
            }
        }
        Column {
            id:listContainer
            width:parent.width
            Repeater {
                id: newsRepeater
                 model: newsItemModel
                 delegate:  newsItemDelegate
                 width: parent.width
             }
        }
    }

    Rectangle {
        id:noNewsResults
        width:parent.width
        height:50
        anchors.top: parent.top
        anchors.topMargin: 60
        visible: false
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "- - - - - - - - - - - - - - - - "
            font.pixelSize: 20
            font.wordSpacing:5
            font.bold: true
            color: newsList.mainColor
        }
    }
}
