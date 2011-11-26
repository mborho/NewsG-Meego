#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());

    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer->setMainQmlFile(QLatin1String("qml/newsg/main.qml"));

    viewer->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer->setAttribute(Qt::WA_NoSystemBackground);
    viewer->viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer->viewport()->setAttribute(Qt::WA_NoSystemBackground);
    viewer->setViewportUpdateMode(QGraphicsView::FullViewportUpdate);

    viewer->showExpanded();

    return app->exec();
}

//#include <QApplication>
//#include <QDeclarativeView>

//int main(int argc, char **argv)
//{
//    QApplication a(argc, argv);
//    QDeclarativeView view;
//    view.setSource(QUrl("/opt/newsg/qml/newsg/main.qml"));
//    view.setAttribute(Qt::WA_OpaquePaintEvent);

//    view.setAttribute(Qt::WA_NoSystemBackground);
//    view.viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
//    view.viewport()->setAttribute(Qt::WA_NoSystemBackground);
//    view.setViewportUpdateMode(QGraphicsView::FullViewportUpdate);

//    view.showFullScreen();
//    return a.exec();
//}

