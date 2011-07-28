import QtQuick 1.1
import com.meego 1.0
import "js/gnews.js" as Gnews

Rectangle {
    id: newsList
    width: parent.width
    height: parent.height-71
    anchors.bottom: parent.bottom
    Component.onCompleted: onStartup()
    function onStartup() {
        console.log('startup newslist')
    }

    function doRequest() {
        if(mainPage.resultPage == 1) {
            clearList();
        }
        appWindow.startSpinner();
        var gnews = new Gnews.Gnews();
        gnews.page = mainPage.resultPage
        gnews.ned = appWindow.currentNed;
        gnews.topic = appWindow.currentTopic;
        gnews.doRequest(renderNewsItems, newsList.page);
    }

    function clearList() {
        newsItemModel.clear();
    }

    function renderNewsItems(response) {
        var currentPage = response["responseData"]["cursor"]["currentPageIndex"]
        var maxPage = (response["responseData"]["cursor"]["pages"] !== undefined) ? response["responseData"]["cursor"]["pages"].length -1 : 1
        console.log('max: '+maxPage)
        var items = response["responseData"]["results"]
        var max = items.length

        var itemList = [];
        for(var x=0;max > x;x++) {
            var item = {}
            var date = new Date(items[x].publishedDate);
            var title = items[x].titleNoFormatting
            var byline = items[x].publisher + ' / '+Qt.formatDate(date) +' '+String(Qt.formatTime(date)).substring(0,5)
            if(items[x].image === undefined) items[x].image = false;
            item.image = items[x].image
            if(item.image) {
                item.image.width = 130;
                item.image.height =parseInt((130/item.image.tbWidth)*item.image.tbHeight);
            }
            item.header = getHeader(title, items[x].unescapedUrl , byline);
            item.content = buildContentString(items[x].content, items[x].image)
            item.relateds = buildRelatedString(items[x].relatedStories);
            itemList[x] = item;
        }
        if(currentPage < maxPage) {
            itemList.push({image:{url:'false',height:0,width:0},
                          header:'',
                          content:'<p align="center" style=""><img src="gfx/down.png" /></p>',
                          relateds:''})
        }
        max = itemList.length
        console.log(newsRepeater.count)
        for(var j=0;max >j;j++) {
            if(j == 0 && mainPage.resultPage != 1) {
                newsItemModel.set(newsItemModel.count-1, itemList[j])
            } else {
                newsItemModel.append(itemList[j])
            }
        }
        appWindow.stopSpinner();
    }

    function getHeader(title, url, byline) {
        var h = '<span style="font-size:17pt;"><a style="text-decoration:none;font-weight:bold;color:#000" href="'+url+'">'+title+'</a></span><br/>'
        h += '<span style="font-size:14pt">'+byline+'</span>'
        return h
    }

    function buildContentString(content, image) {
        var text = '';
        if(image) {            
            text += '<table style="float:left;margin: 10px 15px -20px 0px;padding-bottom:0px;"><tr>';
            text += '<td width="'+image.width+' valign="middle"><img src="gfx/dummy.png" style="background-color:#fff;" height="'+image.height+'" width="'+image.width+'" /></td>';
            text += '<tr/></table>';
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
                source: image.url
                anchors.top: newsContent.top
                anchors.topMargin: 5
                anchors.left: newsContent.left
                height: image.height
                width: image.width
                visible: (header !== "") ? true : false
                fillMode:Image.PreserveAspectFit
            }

            Rectangle {
                id: newsRelatedToggle
                width:parent.width
                height: (newsRelateds.visible ===true) ? childrenRect.height : relToggleText.height
                anchors.top: newsContent.bottom
                visible: (header !== "") ? true : false
                Text {
                    id:relToggleText
                    width: parent.width
                    font.bold: true
                    text:  '<table style="background-color:'+appWindow.currentTopicColor+';" cellpadding="0" width="'+parent.width+'"><tr><td width="15%"></td><td width="85%" align="center" style="padding:7px;background-color:#fff;">'+((newsRelateds.visible) ? '▲' : '▼')+'   more sources   '+((newsRelateds.visible) ? '▲' : '▼')+'</td></tr></table>'
                    font.pointSize: 17
                    color: appWindow.currentTopicColor
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
                    color:Gnews.getTopicBgColor(appWindow.currentTopic)
                    anchors.top: relToggleText.bottom
                    visible:false
                    Text {
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
                    }
                }
                Rectangle {
                    id:newsRelatedBottom
                    height:2
                    color: appWindow.currentTopicColor
                    anchors.top: newsRelateds.bottom
                    width: parent.width
                    visible: newsRelateds.visible
                }
                function showRelateds() {
                    if (newsRelateds.visible === true) {
                        newsRelateds.visible = false;
                    } else {
                        newsRelateds.visible = true;
                    }
                }
            }
            Rectangle {
                height:15
                width:parent.width                
            }
        }
    }

    function entryClicked(url) {
        if(url == "more") {
            mainPage.resultPage += 1
            console.log('load page '+mainPage.resultPage)
            doRequest()
        } else {
            Qt.openUrlExternally ( url )
        }
        console.log(url);
    }

    Flickable {
        id:newsFlickable
        width:parent.width
        height: parent.height
        contentWidth: parent.width
        contentHeight: listContainer.height
        flickableDirection: Flickable.VerticalFlick
        Column {
            id:listContainer
            width:parent.width
            Repeater {
                id: newsRepeater
                 model: newsItemModel
                 delegate:  newsItemDelegate
                 width: parent.width
                 anchors.centerIn: parent
             }
        }
    }
}
