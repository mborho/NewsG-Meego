import QtQuick 1.1
import com.meego 1.0
import "js/gnews.js" as Gnews

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
    property string mainColor: appWindow.currentTopicColor
    property string mainBgColor: "#FFFFFF"

    function doRequest(queryTerm, querySort) {
        newsList.query = (queryTerm !== undefined) ? queryTerm : "";
        newsList.querySort = (querySort !== undefined) ? querySort : false;
        prepareModel();
        setColors();
        var gnews = new Gnews.Gnews();
        gnews.page = newsList.resultPage
        gnews.ned = appWindow.currentNed;
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
        gnews.doRequest(renderNewsItems);
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

    function renderNewsItems(response) {
        var currentPage = response["responseData"]["cursor"]["currentPageIndex"]
        var maxPage = (response["responseData"]["cursor"]["pages"] !== undefined) ? response["responseData"]["cursor"]["pages"].length -1 : 1
        var items = response["responseData"]["results"]
        var max = items.length
        var resultUrls = newsList.resultUrls
        var itemList = [];
        for(var x=0;max > x;x++) {
            if(resultUrls.indexOf(items[x].unescapedUrl) > -1) {
                // check double cluster
                console.log('duplicate: '+items[x].unescapedUrl)
                continue;
            }
            var item = {}
            var date = new Date(items[x].publishedDate);
            var title = items[x].titleNoFormatting
            var byline = items[x].publisher + ' / '+Qt.formatDate(date) +' '+String(Qt.formatTime(date)).substring(0,5)
            if(items[x].image === undefined || appWindow.loadImages === false) {
                item.image  = false;
            } else {
                item.image = {}
                item.image.url = items[x].image.url
                item.image.tbWidth = items[x].image.tbWidth
                item.image.tbHeight = items[x].image.tbHeight
                item.image.width = 140;
                item.image.height =parseInt((140/item.image.tbWidth)*item.image.tbHeight);
            }
            item.header = getHeader(title, items[x].unescapedUrl , byline);
            item.content = buildContentString(items[x].content, item.image)
            item.relateds = buildRelatedString(items[x].relatedStories);
            itemList.push(item);
            resultUrls.push(items[x].unescapedUrl)
        }
        newsList.resultUrls =  resultUrls
        if(currentPage < maxPage) {
            itemList.push({image:false,
                          header:'',
                          content:'<p align="center" style=""><img src="gfx/down.png" /></p>',
                          relateds:''})
        }
        max = itemList.length
        var resultPage = newsList.resultPage;//(newsList.query !== "") ? searchPage.resultPage : mainPage.resultPage
        for(var j=0;max >j;j++) {
            if(j == 0 && resultPage != 1) {
                newsItemModel.set(newsItemModel.count-1, itemList[j])
            } else {
                newsItemModel.append(itemList[j])
            }
        }
        if(newsList.query === "") {
            appWindow.stopSpinner();
        } else {
            searchPage.stopSpinner();
        }
    }

    function getHeader(title, url, byline) {
        var h = '<span style="font-size:17pt;"><a style="text-decoration:none;font-weight:bold;color:#000" href="'+url+'">'+title+'</a></span><br/>'
        h += '<span style="font-size:14pt">'+byline+'</span>'
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

    function buildRelatedString(relateds) {
        var text = '';
        if(relateds === undefined) return '';
        var max = relateds.length
        if(max > 0) {
            text += '<p>'
            for(var x=0;max>x;x++) {
                var rel = relateds[x]
                text += '<a style="text-decoration:none;font-weight:bold;color:#000" href="'+rel.unescapedUrl+'" >'+rel.titleNoFormatting+'</a> ';
                text += rel.publisher+'<br/>'
            }
            text += '</p>'
        }
        return text
    }


    ListModel {
        id: newsItemModel
    }       

    Component {
        id:newsItemDelegate
        Item {
            id: newsItemBox
            width:newsList.width
            height: (header !== "") ? childrenRect.height : 80;
            Text {
                id:newsTitle
                width:parent.width-30
                anchors.top: newsItemBox.top
                anchors.topMargin: (header !== "") ? 20 : 0
                anchors.horizontalCenter: parent.horizontalCenter
                text: header
                textFormat: Text.RichText
                font.pointSize: 15
                lineHeight:1.1
                wrapMode: Text.WordWrap
                visible: (header !== "") ? true : false;
                onLinkActivated: entryClicked(link)
            }
            Text {
                id:newsContent
                width:parent.width-30
                anchors.top: newsTitle.bottom
                anchors.topMargin: (header !== "") ? 5 : 0
                anchors.horizontalCenter: parent.horizontalCenter
                text: content
                textFormat: Text.RichText
                font.pointSize: 15
                lineHeight:1.1
                wrapMode: Text.WordWrap
                onLinkActivated: entryClicked(link)
                MouseArea {
                    enabled:  (header === "") ? true : false
                    anchors.fill: parent
                    onClicked: entryClicked('more')
                }
            }
            Image {
                id: newsImage
                source: (image) ? image.url : "gfx/dummy.png"
                anchors.top: newsContent.top
                anchors.topMargin: 5
                anchors.left: newsContent.left
                height: image.height
                width: image.width
                sourceSize.width: (image) ? image.tbWidth : image.width
                sourceSize.height: (image) ? image.tbHeigth : image.height
                opacity: 0
                visible: (header !== "" && image) ? true : false
                fillMode:Image.PreserveAspectCrop
                onStatusChanged: if (status == Image.Ready) opacity = 1
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

            Rectangle {
                id: newsRelatedToggle
                width:parent.width
                height: (newsRelateds.visible === true) ? childrenRect.height : ((relateds !== "") ? relToggleText.height : 0)
                anchors.top: newsContent.bottom
                visible: (header !== "" && relateds !== '') ? true : false
                Text {
                    id:relToggleText
                    width: parent.width
                    font.bold: true
                    text:  '<table style="background-color:'+newsList.mainColor+';" cellpadding="0" width="'+parent.width+'"><tr><td width="15%"></td><td width="85%" align="center" style="padding:7px;background-color:#fff;">'+((newsRelateds.visible) ? '▲' : '▼')+'   '+newsList.moreLabel+'   '+((newsRelateds.visible) ? '▲' : '▼')+'</td></tr></table>'
                    font.pointSize: 17
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
                    height: childrenRect.height+10
                    color: newsList.mainBgColor
                    anchors.top: relToggleText.bottom
                    visible:false
                    Text {
                        id: newsRelatedsText
                        width:parent.width-30
                        anchors.top:  newsRelateds.top
                        anchors.topMargin: 15
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenterOffset: 10
                        verticalAlignment: Text.AlignVCenter
                        text: relateds
                        lineHeight: 1.1
                        textFormat: Text.RichText
                        font.pointSize: 16
                        color:"#000"
                        wrapMode: Text.WordWrap
                        onLinkActivated: entryClicked(link)
                        opacity: 0
                        Behavior on opacity {
                             NumberAnimation {
                                 from: 0.0; to: 1.0
                                 duration: 300
                                 easing {
                                     type: Easing.InOutCubic
                                 }
                             }
                         }
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
                        newsRelatedsText.opacity = 0
                    } else {
                        newsRelateds.visible = true;
                        newsRelatedsText.opacity = 1
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
                visible: (relateds === "" && header !== "") ? true : false
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
        flickDeceleration: 2500
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
}
