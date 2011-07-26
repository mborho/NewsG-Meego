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
        if(mainPage.resultPage != 1) {
            newsItemModel.remove(newsItemModel.count-1)
        }
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
            if(items[x].image == "undefined") items[x].image = false;
            item.image = items[x].image
            if(item.image) {
                item.image.width = 130;
                item.image.height =parseInt((130/item.image.tbWidth)*item.image.tbHeight);
            }
            item.header = getHeader(title, items[x].unescapedUrl , byline);
            item.content = buildContentString(items[x].content, items[x].image)
            item.relateds = buildRelatedString(items[x].relatedStories);
            console.log('Item '+x)
            itemList[x] = item;
        }
        if(currentPage < maxPage) {
            itemList.push({image:{url:'false',height:0,width:0},
                          header:'',
                          content:'<p style="text-align:center;width:100%;font-size:20pt;line-height:40pt;"><a style="text-decoration:none;font-weight:bold;color:#000" href="more">load more...</a></p>',
                          relateds:''})
        }
        max = itemList.length
        for(var j=0;max >j;j++) {
           newsItemModel.append(itemList[j])
        }
        appWindow.stopSpinner();
    }

    function getHeader(title, url, byline) {
        var h = '<span style="font-size:17pt;"><a style="text-decoration:none;font-weight:bold;color:#000" href="'+url+'">'+title+'</a></span><br/>'
        h += '<span style="color:grey;font-size:14pt">'+byline+'</span>'
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
            text += '<p>';
            for(var x=0;max>x;x++) {
                var rel = relateds[x]
                text += '<a style="text-decoration:none;font-weight:bold;color:grey" href="'+rel.unescapedUrl+'" >'+rel.titleNoFormatting+'</a> ';
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
            height: childrenRect.height
            Text {
                id:newsTitle
                width:parent.width-30
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                text: header
                textFormat: Text.RichText
                font.pointSize: 15
                wrapMode: Text.WordWrap
                onLinkActivated: entryClicked(link)
            }
            Text {
                id:newsContent
                width:parent.width-30
                anchors.top: newsTitle.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                text: content
                textFormat: Text.RichText
                font.pointSize: 15
                wrapMode: Text.WordWrap
                onLinkActivated: entryClicked(link)
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
//                anchors.topMargin: 10
                visible: (header !== "") ? true : false
                Text {
                    id:relToggleText
                    width: parent.width
                    font.bold: true
                    text:  '<table style="background-color:'+appWindow.currentTopicColor+';" width="'+parent.width+'"><tr><td width="15%"></td><td width="85%" align="center" style="padding:5px;background-color:#fff;">more sources</td></tr></table>'
                    font.pointSize: 16
                    color: appWindow.currentTopicColor
                    height: 60
                    verticalAlignment: Text.AlignVCenter
                    textFormat: Text.RichText
                    MouseArea {
                        id: moreMouse
                        anchors.fill: parent
                        onClicked: newsRelatedToggle.showRelateds()
                    }
                }
                Text {
                    id:newsRelateds
                    width:parent.width-30
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible:false
                    anchors.top: relToggleText.bottom
                    text: relateds
                    textFormat: Text.RichText
                    font.pointSize: 16
                    wrapMode: Text.WordWrap
                    onLinkActivated: entryClicked(link)
                }
                function showRelateds() {
                    if (newsRelateds.visible === true) {
                        newsRelateds.visible = false;
                    } else {
                        newsRelateds.visible = true;
                    }
                }
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
        width:parent.width
        height: parent.height
        contentWidth: parent.width //Math.max(parent.width,resultView.width)
        contentHeight: listContainer.height
        flickableDirection: Flickable.VerticalFlick
        Column {
            id:listContainer
            width:parent.width
//            height: childrenRect.height
            Repeater {
                     model: newsItemModel
                     delegate:  newsItemDelegate
                     width: parent.width
                     anchors.centerIn: parent
                 }
        }
    }
}
