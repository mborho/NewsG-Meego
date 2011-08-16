#include <QtGui/QApplication>
#include <QtDeclarative>

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QDeclarativeView view;
    view.setSource(QUrl("qrc:/qml/main.qml"));
    view.setAttribute(Qt::WA_NoSystemBackground);
    view.showFullScreen();
    return app.exec();
}
