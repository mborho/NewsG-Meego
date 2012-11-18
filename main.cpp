#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"
#include <QDeclarativeContext>
#include "sharehelper.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());

    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer->setMainQmlFile(QLatin1String("qml/newsg/main.qml"));

    QDeclarativeContext *ctxt = viewer->rootContext();

    ShareHelper sh;
    ctxt->setContextProperty("Share", &sh);

    viewer->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer->setAttribute(Qt::WA_NoSystemBackground);
    viewer->viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer->viewport()->setAttribute(Qt::WA_NoSystemBackground);
    viewer->setViewportUpdateMode(QGraphicsView::FullViewportUpdate);

    viewer->showExpanded();

    return app->exec();
}

