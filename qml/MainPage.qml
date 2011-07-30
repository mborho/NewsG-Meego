import QtQuick 1.1
import com.meego 1.0

Page {
    id: mainPage
    tools: commonTools
    property int resultPage: 1

    function start() {
        setTopicLabel()
        newsList.doRequest();
    }

    function doRefresh() {
        mainPage.resultPage = 1
        newsList.doRequest();
    }

    function setTopicLabel() {
        topicSelector.setTopicLabel();
    }

    TopicSelector {
        id: topicSelector
    }

    NewsList {
        id: newsList
    }

//    NewsListWebView {

//        id: newsList
//    }

    TopicSelectMenu {
        id: topicSelectMenu
    }
}
