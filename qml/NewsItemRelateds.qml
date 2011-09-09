/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1

Rectangle {
    id:newsItemRelateds
    width:parent.width
    height:childrenRect.height+20
    color: newsList.mainBgColor

    function fillRelateds(relateds) {
        if(relateds === undefined) return '';
        var max = relateds.count
        relatedsModel.clear();
        if(max > 0) {
            for(var x=0;max>x;x++) {
                var rel = relateds.get(x);
                relatedsModel.append({
                     title:rel.titleNoFormatting,
                     url:rel.unescapedUrl,
                     publisher:rel.publisher
                 })
            }
        }
    }

    ListModel {
        id:relatedsModel
     }

    Component {
        id: relatedDelegate
        Text {
            text: '<span style="font-weight:bold;">'+title+'</span> '+publisher
            width:relatedsColumn.width
            color:"#000"
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 16 + newsList.fontSizeFactor
            textFormat: Text.RichText
            lineHeight: 1.1
            wrapMode: Text.WordWrap
            MouseArea {
                anchors.fill: parent
                onClicked: newsList.entryClicked(url)
                onPressed:  {parent.color = "#585858";}
                onReleased:  {parent.color = '#000';}
                onCanceled:  {parent.color = '#000';}
            }
        }
    }

    Column {
        id:relatedsColumn
        width:parent.width-30
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        Repeater {
             model: relatedsModel
             delegate:  relatedDelegate
             width: parent.width
             height: childrenRect.height
         }
    }

}
