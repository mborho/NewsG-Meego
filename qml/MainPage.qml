import QtQuick 1.1
import com.meego 1.0

Page {
    id: mainPage
    tools: commonTools

    function start() {
        setTopicLabel()
        newsList.doRequest();
    }

    function doRefresh() {
       newsList.resultPage = 1
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
