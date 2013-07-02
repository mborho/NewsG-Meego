#include "feedhelper.h"

#include <QString>
#include <QVariant>
#include <QDebug>
#include <QDomDocument>
#include <QDomElement>
#include <QDomNode>


FeedHelper::FeedHelper(QObject *parent) : QObject(parent) { }

QVariant FeedHelper::parseString (const QString &xmlString) {
//       qDebug() << "Make data URI from"
//                 << xmlString;
    QDomDocument doc;
    doc.setContent(xmlString);

    QDomElement docElem = doc.documentElement();

    // get the node's interested in, this time only caring about person's
    QDomNodeList nodeList = docElem.elementsByTagName("td");

    // result var
    QVariantMap resultMap;

    if(nodeList.count() == 2) {
        // define data structure for result
        QVariantMap mainImage;
        QVariantList relatedArticles;
        QDomElement imgNodeElem = nodeList.at(0).toElement();
        QDomNodeList imgList = imgNodeElem.elementsByTagName("img");
        if(imgList.count() > 0) {
            QDomElement imgNode = imgList.at(0).toElement();
            QDomAttr imgLinkAttr = imgNode.attributeNode("src");
            QDomAttr imgWidthAttr = imgNode.attributeNode("width");
            QDomAttr imgHeightAttr = imgNode.attributeNode("height");
            mainImage["tbUrl"] = "http:"+imgLinkAttr.value();
            mainImage["tbWidth"] = imgWidthAttr.value();
            mainImage["tbHeight"] = imgHeightAttr.value();
        }

        QDomElement contentNode = nodeList.at(1).toElement();
        QDomNodeList dataNodes = contentNode.firstChild().childNodes().item(2).childNodes();
        for(int x = 0;x < dataNodes.count(); x++)
        {

            QDomElement el = dataNodes.at(x).toElement();
            QString tagName = el.tagName();
            if(tagName == "br") {
                continue;
            }

            if(x == 0 && tagName == "a") {
                QDomElement aLink = el.toElement();
                QDomAttr mainArticleLinkAttr = aLink.attributeNode("href");
                resultMap["unescapedUrl"] = mainArticleLinkAttr.value();
                resultMap["titleNoFormatting"] = el.text();
//                qDebug()  << resultMap["titleNoFormatting"];
//                qDebug()  << resultMap["unescapedUrl"];
            } else if(tagName == "font") {
                if(x == 2) {
                    resultMap["publisher"] = el.firstChild().firstChild().toElement().text();
                } else if(x == 4) {
                    resultMap["content"] = el.text();
                } else if(el.childNodes().item(1).toElement().tagName() == "font") {
                    QVariantMap relatedArticle;
                    QDomElement relElement = el.firstChild().toElement();
                    QDomAttr relLinkAttr = relElement.attributeNode("href");
                    relatedArticle["unescapedUrl"] = relLinkAttr.value();
                    relatedArticle["titleNoFormatting"] = relElement.text();
                    relatedArticle["publisher"] = el.childNodes().item(1).toElement().text();
                    relatedArticle["related"] = "1";
                    relatedArticles.append(relatedArticle);
//                } else { //if(node.childNodes[1].tagName == "A") {
//                    relatedsShort = extractShortRelated(node);
//                }
                }
            }
            resultMap["image"] = mainImage;
            resultMap["relatedStories"] = relatedArticles;
        }
    }
    return resultMap;
}
