import QtQuick 1.1
import com.meego 1.0
import "js/gnews.js" as Gnews

Menu {
    id: topicSelectMenu
    platformStyle: MenuStyle {
        topMargin: 55
    }

    function openMenu() {
        var topics = Gnews.getEditionTopics(appWindow.currentNed);
        var max = topics.length
        // eval is evil, i know
        for(var x = 0; max > x; x++) {
            eval('topic_'+x+'.topic = "'+topics[x].value+'";topic_'+x+'.text= "'+topics[x].label+'"');
        }
        open();
    }

    function closeMenu() {}

    function topicSelected(topicId) {
        var topicLabel = Gnews.getTopicLabel(appWindow.currentNed, topicId);
        var topicColor = Gnews.getTopicColor(topicId);
        topicSelector.topicSelectorClicked(topicId, topicLabel, topicColor)
    }

    MenuLayout {
        id: menuLayout
        MenuItem { id:topic_0; height:65; text: "Top Stories"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_1; height:65; text: "World"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_2; height:65; text: "U.S."; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_3; height:65; text: "Business"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_4; height:65; text: "Science/Technology"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_5; height:65; text: "Politics"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_6; height:65; text: "Entertainment"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_7; height:65; text: "Sports"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_8; height:65; text: "Health"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_9; height:65; text: "Spotlight"; property string topic: '';onClicked: topicSelected(topic)}
        MenuItem { id:topic_10; height:65; text: "Most Popular"; property string topic: '';onClicked: topicSelected(topic)}
    }
}
