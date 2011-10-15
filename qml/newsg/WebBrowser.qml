/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.meego 1.0
import QtWebKit 1.0

Page {
    id: webBrowser
    tools: browserTools
    property string urlString : ""

    width: parent.width
    height: parent.height

    Flickable {
        id: flickable
         width: parent.width
         height: parent.height
         anchors.fill: webBrowser/*
             top: parent.top;
             left: parent.left;
             right: parent.right;
             bottom: browserTools.top
         }*/
         pressDelay: 200
//         contentWidth: Math.max(parent.width,webView.width)
//         contentHeight: Math.max(parent.height,webView.height)
         contentWidth: webView.width
         contentHeight: webView.height
//         flickableDirection: Flickable.HorizontalAndVerticalFlick//Flickable.VerticalFlick
         onWidthChanged : {
                  // Expand (but not above 1:1) if otherwise would be smaller that available width.
                  if (width > webView.width*webView.contentsScale && webView.contentsScale < 1.0)
                      webView.contentsScale = width / webView.width * webView.contentsScale;
              }

         WebView {
            id: webView
            transformOrigin: Item.TopLeft
            url: webBrowser.urlString
//            width:parent.width
            smooth: false
//            preferredWidth: flickable.width
//            preferredHeight: flickable.height
            contentsScale: 1
            settings.zoomTextOnly : true
//            onContentsSizeChanged: {
//                // zoom out
//                contentsScale = Math.min(1,flickable.width / contentsSize.width)
//            }
            onUrlChanged: {
                 // got to topleft
                 flickable.contentX = 0
                 flickable.contentY = 0
             }
            onLoadFinished: {
                console.log("finished")
                webLoadingSpinner.running = false
                webLoadingSpinner.visible = false
                console.log('pwidth: '+webBrowser.width)
                console.log('pheight: '+webBrowser.height)
                console.log('fwidth: '+flickable.width)
                console.log('fheight: '+flickable.height)
                console.log('wwidth: '+webView.width)
                console.log('wheight: '+webView.height)
                contentsScale = Math.min(1,flickable.width / contentsSize.width)
            }
            onLoadStarted: {
                console.log("started")
                webLoadingSpinner.running = true
                webLoadingSpinner.visible = true
            }

            function doZoom(zoom,centerX,centerY) {
                 if (centerX) {
                     var sc = zoom*contentsScale;
                     scaleAnim.to = sc;
                     flickVX.from = flickable.contentX
                     flickVX.to = Math.max(0,Math.min(centerX-flickable.width/2,webView.width*sc-flickable.width))
                     finalX.value = flickVX.to
                     flickVY.from = flickable.contentY
                     flickVY.to = Math.max(0,Math.min(centerY-flickable.height/2,webView.height*sc-flickable.height))
                     finalY.value = flickVY.to
                     quickZoom.start()
                 }
             }

            onDoubleClick: {
                if (!heuristicZoom(clickX,clickY,2.5)) {
                    console.log("no heuristic")
                    var zf = flickable.width / contentsSize.width
                    if (zf >= contentsScale)
                        zf = 2.0/zf // zoom in (else zooming out)
                    doZoom(zf,clickX*zf,clickY*zf)
                }
            }
            SequentialAnimation {
                id: quickZoom

                PropertyAction {
                    target: webView
                    property: "renderingEnabled"
                    value: false
                }
                ParallelAnimation {
                    NumberAnimation {
                        id: scaleAnim
                        target: webView
                        property: "contentsScale"
                        // the to property is set before calling
                        easing.type: Easing.Linear
                        duration: 200
                    }
                    NumberAnimation {
                        id: flickVX
                        target: flickable
                        property: "contentX"
                        easing.type: Easing.Linear
                        duration: 200
                        from: 0 // set before calling
                        to: 0 // set before calling
                    }
                    NumberAnimation {
                        id: flickVY
                        target: flickable
                        property: "contentY"
                        easing.type: Easing.Linear
                        duration: 200
                        from: 0 // set before calling
                        to: 0 // set before calling
                    }
                }
                // Have to set the contentXY, since the above 2
                // size changes may have started a correction if
                // contentsScale < 1.0.
                PropertyAction {
                    id: finalX
                    target: flickable
                    property: "contentX"
                    value: 0 // set before calling
                }
                PropertyAction {
                    id: finalY
                    target: flickable
                    property: "contentY"
                    value: 0 // set before calling
                }
                PropertyAction {
                    target: webView
                    property: "renderingEnabled"
                    value: true
                }
            }
            onZoomTo: doZoom(zoom,centerX,centerY)
        }
     }

    ToolBarLayout {
        id: browserTools
        visible: true
        ToolIcon { iconId: "toolbar-back"; onClicked: { pageStack.pop(); } }
        BusyIndicator {
            id: webLoadingSpinner
            running: false
            visible: false
            platformStyle: BusyIndicatorStyle { size: "medium" }
            anchors.right: parent.right
            anchors.rightMargin: 25
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
