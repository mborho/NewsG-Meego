/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import "js/gnews.js" as Gnews

Menu {
    id: topicSelectMenu
    platformStyle: MenuStyle {
        topMargin: 55
    }

    function openMenu() {
        var nedTopics = Gnews.getEditionTopics(appWindow.currentNed);
        var topics = appWindow.getManagedTopics(nedTopics);
        var max = topics.length

        var calc_height = parseInt((parent.height-55)/(max - appWindow.topicsHidden.length))
        var height = (calc_height > 80) ? 80 : ((calc_height < 66) ? 66 : calc_height);

        // eval is evil, i know
        for(var x = 0; max > x; x++) {
            var evil_eval = 'topic_'+x+'.topic = "'+topics[x].value+'";';
            evil_eval += 'topic_'+x+'.text= "'+topics[x].label+'";';
            evil_eval += 'topic_'+x+'.visible = '+topics[x].visibility+';'
            evil_eval += 'topic_'+x+'.height = '+((topics[x].visibility)?height:0)+';'
            eval(evil_eval);
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
        MenuItem { id:topic_0; visible: true; height:65; text: "Top Stories"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_1; visible: true; height:65; text: "World"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_2; visible: true; height:65; text: "U.S."; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_3; visible: true; height:65; text: "Business"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_4; visible: true; height:65; text: "Science/Technology"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_5; visible: true; height:65; text: "Politics"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_6; visible: true; height:65; text: "Entertainment"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_7; visible: true; height:65; text: "Sports"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_8; visible: true; height:65; text: "Health"; property string topic: ''; onClicked: topicSelected(topic)}
        MenuItem { id:topic_9; visible: true; height:65; text: "Spotlight"; property string topic: '';onClicked: topicSelected(topic)}
        MenuItem { id:topic_10; visible: true; height:65; text: "Most Popular"; property string topic: '';onClicked: topicSelected(topic)}
    }
}
