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
             msg += '<div>* 0.9.0 - modifications for PR1.1, bugfixes</div>';
             msg += '<div>* 0.7.2 - search page modified, scrolling</div>';
             msg += '<div>* 0.6.1 - ui improvements, editions added</div>';
             msg += '<div>* 0.4.0 - more editions added, ui tweaks</div>';
             msg += '<div>* 0.2.9 - fullscreen mode, more editions, new <br/>icon, option for font-size </div>';
             msg += '</div>';
             msg += '</p><br/>';
             msg += '<table><tr><td valign="middle">powered by </td>';
             msg += '<td valign="middle"> <img src="gfx/glogo.png" height="41" width="114" /></td>';
             msg += '</tr></table>';
             return msg
        }
    }
}
