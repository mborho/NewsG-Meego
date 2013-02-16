/*
Copyright 2013 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.0
import com.nokia.meego 1.0

Dialog {
   id: deprecationDialog
   width: parent.width

   content:Item {
        id: noticeContent
        width: parent.width
        Text {
            id: noticeText
            font.pixelSize:21
            width:parent.width-10
            color: "white"
            anchors.centerIn: parent
            text: parent.getMsg()
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
        }
        ButtonRow {
            anchors.top: noticeText.bottom
            style: ButtonStyle { }
            anchors.horizontalCenter: parent.horizontalCenter
            Button {
                text: "OK, noted."
                onClicked: deprecationDialog.accept()
            }
        }
        function getMsg() {
             var msg = '<h1>Important notice!</h1>';
             msg += '<p><b>In 2013 Google will switch of their API for Google News.</b> This means, that this little application won\'t work anymore in its current way.</p>'
                 + '<p><b>But to keep NewsG still working after the Google News API will be finally switched off, '
                 + 'an alternative data backend was added</b>!</p>'
                 + '<p>You can switch in settings between the current API data source and the newly added feed-based data source.</p>'
                 + '<p>Unfortunately the feeds for Google News only delivering 10 items per topic for your reading pleasure.'
                 + '<b> But at least, this is something!</b></p><p>&#160;</p>'
             return msg
        }
    }
    function accepted() {
        appWindow.saveSettingValue('deprecationWarning', false);
        mainPage.start()
    }
    function rejected() {
        mainPage.start()
    }
}
