#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "codes.h"
//#include "Colors.h"
#include "jsonmodel.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qmlRegisterUncreatableMetaObject(
      Codes::staticMetaObject,       // static meta object
      "codes.namespace",             // import statement (can be any string)
      1, 0,                          // major and minor version of the import
      "Codes",                       // name in QML (does not have to match C++ name)
      "Error: only enums"            // error in case someone tries to create a MyNamespace object
    );

    qmlRegisterType<JsonModel>("mymodel.Books",1,0,"ModelBooks");
    qmlRegisterUncreatableType<Book>("mymodel.Books",1,0,"MyBook", "interface");

    auto input = QGuiApplication::inputMethod();
    input->setVisible(false);


    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
