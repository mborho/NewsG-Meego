import QtQuick 1.1
import com.meego 1.0

Page {
    id: searchPage
    tools: searchTools
    property int resultPage: 1
    property string mainColor: "#4272DB"

    function search() {
        if(searchInput.text !== "") {
            searchPage.resultPage = 1
            console.log('Search: '+searchInput.text)
            newsList.doSearchRequest(searchInput.text);
        }
    }

    function doRefresh() {
        searchPage.resultPage = 1
        newsList.doSearchRequest(searchInput.text);
    }

    function clear() {
        newsList.clearList();
    }

    function startSpinner() {
        searchLoadingSpinner.running = true
        searchLoadingSpinner.visible = true
        searchRefreshIcon.visible = false
    }

    function stopSpinner() {
        searchLoadingSpinner.visible = false
        searchLoadingSpinner.running = false
        searchRefreshIcon.visible = true
    }

    Rectangle {
        id:searchHeader
        height:71
        width: parent.width
        color: searchPage.mainColor
        z:3
        TextField {
            id: searchInput
            placeholderText:  "Search"
             anchors.verticalCenter: parent.verticalCenter
             anchors.left: parent.left
             anchors.leftMargin: 20
             width: parent.width-searchSubmit.width-50
         }
        Image {
            id: searchSubmit
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            source: "gfx/search.png"
            MouseArea {
                anchors.fill: parent
                onClicked: search()
            }
         }
    }

    NewsList {
        id: newsList
    }

    ToolBarLayout {
        id: searchTools
        visible: true
        ToolIcon { iconId: "toolbar-back"; onClicked: { pageStack.pop();newsList.query=""; } }
        BusyIndicator {
            id: searchLoadingSpinner
            running: false
            visible: false
            platformStyle: BusyIndicatorStyle { size: "medium" }
            anchors.right: parent.right
            anchors.rightMargin: 25
            anchors.verticalCenter: parent.verticalCenter
        }
        ToolIcon {
             id: searchRefreshIcon
             platformIconId: "toolbar-refresh";
             visible: true
             anchors.right: parent.right
             onClicked: (searchRefreshIcon.visible == true) ? searchPage.doRefresh() : false
        }
    }
}
