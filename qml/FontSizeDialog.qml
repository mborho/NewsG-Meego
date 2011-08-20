/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.meego 1.0
import "js/gnews.js" as Gnews

SelectionDialog {
    id: defaultTopicDialog
    titleText: "Set font size"
    selectedIndex: 1
    property int maxFont: 4

    function openDialog() {
        fontSizeModel.clear();
        for(var x=0; 9 > x; x++) {
            var val = 8-maxFont-x;
            if(val === appWindow.fontSizeFactor) {
                selectedIndex = x;
            }
            fontSizeModel.append({name: (val > 0) ? '+'+val :val })
        }
        open();
    }

    function accept() {
        var selectedSize = maxFont-selectedIndex
        appWindow.saveSettingValue('fontSizeFactor', selectedSize)
        appWindow.fontSizeFactor = selectedSize
        close();
        mainPage.doRefresh()
    }

    model: ListModel {
        id: fontSizeModel
    }
}
