/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.meego 1.0
import QtWebKit 1.0
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
        //newsItemModel.clear();
    }

    function renderNewsItems(response) {
        if(mainPage.resultPage != 1) {
            //newsItemModel.remove(newsItemModel.count-1)
        }
        var html = '';
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
            itemList[x] = item;
        }
        if(currentPage < maxPage) {
            itemList.push({url:"more",content:'<p style="font-size:20pt;line-height:40pt;"><a style="text-decoration:none;font-weight:bold;color:#000" href="more">load more...</a></p>', relateds:''})
        }
        max = itemList.length

        for(var j=0;max >j;j++) {
            html += '<div>'+itemList[j].content+'</div>'
        }
        resultView.html = html
        appWindow.stopSpinner();
    }

    function buildContentString(title, url, byline, content, image) {
        var text = '<div style="clear:both">';
        text += '<div class="headline"><h1><a style="text-decoration:none;font-weight:bold;color:#000" href="" onclick="window.qml.openLink(\''+url+'\');return false;">'+title+'</a></h1></div>'
        text += '<div class="byline" style="color:grey;font-size:15pt">'+byline+'</div>'
        text += '<div class="content">';
        if(image) {
            var width = 130;
            var height =parseInt((130/image.tbWidth)*image.tbHeight);
            text += '<img src="'+image.url+'" style="border-radius: 15px;float:left;background-color:#fff;height:'+height+'px;width:'+width+'px" />';
        }
        text += content+'</div>';
        text += '</div>'
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

    Flickable{
        width: parent.width
        height: parent.height
        contentWidth: parent.width //Math.max(parent.width,resultView.width)
        contentHeight: Math.max(parent.height,resultView.height)
        flickableDirection: Flickable.VerticalFlick

        WebView {
            javaScriptWindowObjects: QtObject {
                     WebView.windowObjectName: "qml"

                     function openLink(url) {
                         entryClicked(url);
                     }
            }
            id: resultView
            html:  ''
            preferredWidth: parent.width
//            preferredHeight: parent.height
            smooth: false
            onUrlChanged: console.log('changed');
            settings.standardFontFamily: QWebSettings.FantasyFont
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
}
