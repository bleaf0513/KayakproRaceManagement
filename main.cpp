#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtQuickControls2/QQuickStyle>
#include <QtPrintSupport/QPrinter>
#include <QPainter>
#include <QQuickWindow>
#include "BluetoothManager.h"
#include "PrintManager.h"
#include "SharedData.h"
 #include <QDirIterator>
int main(int argc, char *argv[])
{
    // 1. Create the application
    QGuiApplication app(argc, argv);

    // 2. Set QML style (Fusion or Basic allows background customization)
    QQuickStyle::setStyle("Fusion"); // or "Basic"

    // 3. Create QML engine
    QQmlApplicationEngine engine;
   static SharedData sharedData;
   engine.addImportPath("qml");
   QDirIterator it(":/qml", QDir::Files);
   while(it.hasNext())
       qWarning() << "Resource found:" << it.next();
    // 4. Register C++ classes to QML
    qmlRegisterType<BluetoothManager>("com.kayakpro.bluetooth", 1, 0, "BluetoothManager");
    qmlRegisterType<PrintManager>("com.kayakpro.print", 1, 0, "PrintManager");
    qmlRegisterSingletonInstance("shareddataApp", 1, 0, "SharedData",&sharedData);
//qmlRegisterSingletonType(QUrl("qml/Main.qml"), "Main", 1, 0, "MainState");
    // 5. Exit if QML object creation fails
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection
    );

    // 6. Load the main QML from resources
    //engine.load(QUrl::fromLocalFile("qml/App.qml"));
    engine.loadFromModule("GSMKayakpro","App");
    // 7. Check if the engine loaded correctly
    if (engine.rootObjects().isEmpty())
        return -1;
    QObject *rootObject = engine.rootObjects().first();

    QQuickWindow *window = qobject_cast<QQuickWindow *>(rootObject);
    if (window) {
        window->setFlags(Qt::Window | Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint);
        window->showFullScreen();
    }

    // 8. Run the application
    return app.exec();
}
