#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "BluetoothManager.h"
#include <QtPrintSupport/QPrinter>
#include <QPainter>
#include "PrintManager.h"
#include "SharedData.h"
#include <QtQuickControls2/QQuickStyle>
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    // Use Fusion or Basic style to allow background customization
    QQuickStyle::setStyle("Fusion");  // or "Basic"

    QQmlApplicationEngine engine;
    qmlRegisterType<BluetoothManager>("com.kayakpro.bluetooth", 1, 0, "BluetoothManager");
    qmlRegisterType<PrintManager>("com.kayakpro.print", 1, 0, "PrintManager");
    qmlRegisterType<SharedData>("com.kayakpro.shareddata", 1, 0, "SharedData");
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("GSMKayakpro", "SetBluetoothAddress");//SetBluetoothAddress");

    return app.exec();
}
