import QtQuick 1.0
import com.nokia.meego 1.0

Dialog {
   id: aboutDialog
   content:Item {
        id: name
        width: parent.width
        height: 300
        Text {
            font.pixelSize:20
            color: "white"
            anchors.centerIn: parent
            text: parent.getAboutMsg()
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            onLinkActivated: Qt.openUrlExternally(link)
        }
        function getAboutMsg() {
             var msg = '<h1>NewsG for Meego</h1>';
             msg += '<p>&#169; 2011, Martin Borho <a href="mailto:martin@borho.net">martin@borho.net</a><br/>';
             msg += 'License: GNU General Public License (GPL) Vers.3<br/>';
             msg += 'Source: <a href="http://github.com/mborho/NewsG-Meego">http://github.com/mborho/NewsG-Meego</a><br/>';
             msg += 'Icon from <a href="http://thenounproject.com">The Noun Project</a><br/>'
             msg += '<div><b>Changelog:</b><br/>'
             msg += '<div>* 3.0.0 - alternative feed-based data source added</div>';
             msg += '<div>* 2.3.0 - PressAndHold on headline to share the link</div>';
             msg += '<div>* 2.2.0 - some usability tweaks</div>';
             msg += '<div>* 2.0.0 - new settings menu, fullscreen option</div>';
             msg += '<div>* 1.4.1 - little tweak for PR 1.2</div>';
             msg += '<div>* 1.3.0 - hindi edition added</div>';
             msg += '</div>';
             msg += '</p><br/>';
             msg += '<table><tr><td valign="middle">powered by </td>';
             msg += '<td valign="middle"> <img src="gfx/glogo.png" height="41" width="114" /></td>';
             msg += '</tr></table>';
             return msg
        }
    }
}
