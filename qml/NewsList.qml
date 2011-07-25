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
        var maxPage = response["responseData"]["cursor"]["pages"].length -1
        var items = response["responseData"]["results"]
        var max = items.length

        var itemList = [];
        for(var x=0;max > x;x++) {
            var item = {}
            var date = new Date(items[x].publishedDate);
            item.title = items[x].titleNoFormatting
            item.url = items[x].unescapedUrl
            item.byline = items[x].publisher + ' / '+Qt.formatDate(date) +' '+String(Qt.formatTime(date)).substring(0,5)
            if(items[x].image == "undefined") items[x].image = false;
            item.content = buildContentString(item.title, item.url, item.byline, items[x].content, items[x].image)
            item.relateds = buildRelatedString(items[x].relatedStories);
            console.log('Item '+x)
            itemList[x] = item;
        }
        if(currentPage < maxPage) {
            itemList.push({url:"more",content:'<p style="font-size:20pt;line-height:40pt;"><a style="text-decoration:none;font-weight:bold;color:#000" href="more">load more...</a></p>', relateds:''})
        }
        max = itemList.length
        for(var j=0;max >j;j++) {
           newsItemModel.append(itemList[j])
        }
        appWindow.stopSpinner();
    }

    function buildContentString(title, url, byline, content, image) {
        var text = '<p style="font-size:20pt;"><a style="text-decoration:none;font-weight:bold;color:#000" href="'+url+'">'+title+'</a></p>'
        text += '<p style="color:grey;font-size:15pt">'+byline+'</p>'
        text += '<p>';
        if(image) {
            var width = 130;
            var height =parseInt((130/image.tbWidth)*image.tbHeight);
            text += '<table style="float:left;margin: 10px 15px -20px 0px;padding-bottom:0px"><tr><td width="'+width+' valign="middle"><img src="'+image.url+'" style="background-color:#fff;" height="'+height+'" width="'+width+'" /></td><tr/></table>';
        }
        text += content+'</p>'
        console.log('content string')
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
            width:parent.width
            height: childrenRect.height
            Text {
                id:newsContent
                width:parent.width
                text: content
                textFormat: Text.RichText
                font.pointSize: 16
                wrapMode: Text.WordWrap
                onLinkActivated: entryClicked(link)
            }
            Rectangle {
                id: newsRelatedToggle
                width:parent.width
                height: (newsRelateds.visible ===true) ? childrenRect.height : 25
                anchors.top: newsContent.bottom
                visible: (url != "more") ? true : false
                Text {
                    id:relToggleText
                    width: parent.width
                    font.bold: true
                    text:  "more sources"
                    font.pointSize: 16
                    height: 25
                    horizontalAlignment: Text.AlignHCenter
                    MouseArea {
                        id: moreMouse
                        anchors.fill: parent
                        onClicked: newsRelatedToggle.test()
                    }
                }
                Text {
                    id:newsRelateds
                    width:parent.width
                    visible:false
                    anchors.top: relToggleText.bottom
                    text: relateds
                    textFormat: Text.RichText
                    font.pointSize: 16
                    wrapMode: Text.WordWrap
                    onLinkActivated: entryClicked(link)
                }
//                states: [
//                        State {
//                            name: 'expanded'
//                            when: newsRelateds.visible
//                            PropertyChanges { target: newsRelatedToggle; height:childrenRect.height }
//                        }
//                ]
//                PropertyAnimation {
//                    id: animation
//                    target: newsRelatedToggle
//                    easing.type: Easing.InCubic
//                    properties: "height"
//                    duration: 2000
//                }
                function test() {
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

    ListView {
        cacheBuffer: 1000
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        model: newsItemModel
        delegate: newsItemDelegate        
        flickDeceleration:2000
    }
}
