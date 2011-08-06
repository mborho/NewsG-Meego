import QtQuick 1.1
import com.meego 1.0

Page {
    id: searchPage
    tools: searchTools
    property string mainColor: "#4272DB"
    property bool sortByDate: false

    function startup() {
        searchInput.text = '';
        newsList.clearModel();
    }

    function search() {
        if(searchInput.text !== "") {            
            newsList.resultPage = 1
            console.log('Search: '+searchInput.text)
            newsList.doRequest(searchInput.text, searchPage.sortByDate);
        }
    }

    function doRefresh() {
        newsList.resultPage = 1
        newsList.doRequest(searchInput.text);
    }

    function orderChanged() {
        searchPage.sortByDate = !searchPage.sortByDate;
        search();
    }

    function startSpinner() {
        searchLoadingSpinner.running = true;
        searchLoadingSpinner.visible = true;
        searchRefreshIcon.visible = false;
        searchSubmit.opacity = 0.5;
        searchSubmitArea.enabled = true;
    }

    function stopSpinner() {
        searchLoadingSpinner.visible = false
        searchLoadingSpinner.running = false
        searchRefreshIcon.visible = true
        searchSubmit.opacity = 1;
        searchSubmitArea.enabled = true;
    }

    Keys.onPressed: {
        if (event.key == Qt.Key_Return) {
           search();
        }
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
            opacity: 1
            MouseArea {
                id:searchSubmitArea
                anchors.fill: parent
                onClicked: search()
                enabled: true
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
        ToolButton {
            id: searchSortButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: 250
            text: (searchPage.sortByDate) ? "sorted by date" : "sorted by relevance";
            onClicked: searchPage.orderChanged();
            visible: true;
        }
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
