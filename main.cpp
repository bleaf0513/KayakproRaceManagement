#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "BluetoothManager.h"
#include <QtPrintSupport/QPrinter>
#include <QPainter>
#include "PrintManager.h"
#include "SharedData.h"
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

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

    engine.loadFromModule("GSMKayakpro", "Main");

    return app.exec();
}
