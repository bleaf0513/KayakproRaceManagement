#include "BluetoothManager.h"
#include <QLowEnergyDescriptor>
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QTimer>
const QBluetoothUuid FTMS_SERVICE_UUID("00001826-0000-1000-8000-00805f9b34fb");
const QBluetoothUuid ROWER_DATA_CHAR_UUID("00002AD1-0000-1000-8000-00805f9b34fb");
const QBluetoothUuid RESISTANCE_LEVEL_CHAR_UUID("00002AD6-0000-1000-8000-00805f9b34fb");
static void logWarningToFile(const QString &message)
{
    QFile file("bluetooth_warnings.log"); // log file in working directory
    if (file.open(QIODevice::Append | QIODevice::Text)) {
        QTextStream out(&file);
        out << message<< "\n";
        file.close();
    }

}
BluetoothManager::BluetoothManager(QObject *parent) : QObject(parent)
{
    discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);

    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
            this, &BluetoothManager::deviceDiscovered);
    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
            this, &BluetoothManager::scanFinished);

}

void BluetoothManager::startScan()
{
    consoles.clear();
    qDebug() << "Starting Bluetooth scan for KP3902 consoles...";
    discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
}

void BluetoothManager::deviceDiscovered(const QBluetoothDeviceInfo &device)
{
    if (device.name() == "KP3902") {
        KayakConsole console;
        console.name = device.name();
        console.address = device.address().toString();
        console.deviceInfo = device;     // IMPORTANT!!!
        consoles.append(console);
        qDebug() << "Found:" << console.name << console.address;
    }
}

void BluetoothManager::scanFinished()
{
    qDebug() << "Scan finished. Connecting to consoles...";
    for (int i = 0; i < consoles.size(); ++i)
        connectConsole(&consoles[i]);
}
void BluetoothManager::setupFtmsService(KayakConsole *console)
{
    qWarning() << console->name << "FTMS details discovered.";

    console->metricsChar =
        console->ftmsService->characteristic(ROWER_DATA_CHAR_UUID);

    console->resistanceLevelChar =
        console->ftmsService->characteristic(RESISTANCE_LEVEL_CHAR_UUID);

    if (!console->metricsChar.isValid()) {
        qWarning() << "Metrics characteristic not found!";
        return;
    }

    // Enable notifications
    QLowEnergyDescriptor cccd =
        console->metricsChar.descriptor(
            QBluetoothUuid("00002902-0000-1000-8000-00805f9b34fb"));

    if (cccd.isValid()) {
        console->ftmsService->writeDescriptor(cccd, QByteArray::fromHex("0100"));
        qWarning() << "Notifications enabled.";
    } else {
        qWarning() << "CCCD (2902) not found!";
    }

    connect(console->ftmsService, &QLowEnergyService::characteristicChanged,
            this, &BluetoothManager::characteristicChanged);
}

void BluetoothManager::connectConsole(KayakConsole *console)
{
    console->controller = QLowEnergyController::createCentral(console->deviceInfo, nullptr);
    console->controller->moveToThread(this->thread()); // Thread-safe
    qWarning()<<"Next Step";
    connect(console->controller, &QLowEnergyController::connected, [console]() {
        qDebug() << console->name << "connected. Discovering services in 150ms...";
        QTimer::singleShot(150, [console]() { console->controller->discoverServices(); });
    });

    connect(console->controller, &QLowEnergyController::serviceDiscovered, this,
            [this, console](const QBluetoothUuid &uuid) {
                if (uuid != FTMS_SERVICE_UUID) return;
                console->ftmsService = console->controller->createServiceObject(FTMS_SERVICE_UUID, nullptr);
                if (!console->ftmsService) {
                    qWarning() << console->name << "Unable to create FTMS service!";
                    return;
                }

                console->ftmsService->moveToThread(this->thread());

                connect(console->ftmsService, &QLowEnergyService::stateChanged, this,
                        [this, console](QLowEnergyService::ServiceState s) {
                            if (s == QLowEnergyService::ServiceDiscovered) {
                                setupFtmsService(console);
                                qDebug() << console->name << "FTMS service ready.";
                            }
                        });

                QTimer::singleShot(50, [console]() { console->ftmsService->discoverDetails(); });
            });

    connect(console->controller, &QLowEnergyController::errorOccurred, [](QLowEnergyController::Error e){
        qWarning() << "Controller error:" << e;
    });

    console->controller->connectToDevice();
}
quint16 readUInt16(const quint8* data, int lowIndex)
{
    return static_cast<quint16>(data[lowIndex]) | (static_cast<quint16>(data[lowIndex + 1]) << 8);
}
void BluetoothManager::characteristicChanged(const QLowEnergyCharacteristic &c, const QByteArray &value)
{

    // Find console whose metricsChar matches
    KayakConsole *console = nullptr;
    for (auto &csl : consoles) {
        if (csl.metricsChar.isValid() && csl.metricsChar == c) {
            console = &csl;
            break;
        }
    }
    if (!console) {
        qWarning() << "Unknown console characteristic changed!";
        return;
    }

    // Append new bytes to buffer
    console->buffer.append(value);

    // Parse full 20-byte packets from buffer
    while (console->buffer.size() >= 20) {
        qWarning()<<value;
        QByteArray packet = console->buffer.left(20);
        console->buffer.remove(0, 20); // remove parsed bytes

        if (console->updateMetrics(packet)) {
            qDebug() << "Console:" << console->name
                               << "\n" << console->getMetrics();
        } else {
            qWarning() << "Failed to parse KP3902 packet from" << console->name;
        }
    }
}

void BluetoothManager::setResistance(int consoleIndex, int level)
{
    if (consoleIndex < 0 || consoleIndex >= consoles.size())
        return;

    KayakConsole *console = &consoles[consoleIndex];
    if (!console->resistanceLevelChar.isValid()) {
        qWarning() << "Cannot write resistance: invalid characteristic for" << console->name;
        return;
    }

    QByteArray data;
    data.append(static_cast<char>(level & 0xFF));
    console->ftmsService->writeCharacteristic(console->resistanceLevelChar,
                                              data,
                                              QLowEnergyService::WriteWithoutResponse);
}

QVariantMap BluetoothManager::getMetrics(int consoleIndex)
{
    QVariantMap map;
    if (consoleIndex < 0 || consoleIndex >= consoles.size())
        return map;

    const auto &c = consoles[consoleIndex];

    map["strokeRate"]      = c.strokeRate;        // strokes/min
    map["strokeCount"]     = c.strokeCount;       // total strokes
    // map["avgStrokeRate"]   = c.avgStrokeRate;     // average strokes/min
    // map["totalDistance"]   = c.totalDistance;     // meters
    // map["instantPace"]     = c.instantPace;       // m/s
    // map["avgPace"]         = c.avgPace;           // m/s
    // map["power"]           = c.power;             // watts
    // map["avgPower"]        = c.avgPower;          // watts
    // map["resistanceLevel"] = c.resistanceLevel;   // 0-?? scale
    // map["elapsedTime"]     = c.elapsedTime;       // seconds
    // map["remainingTime"]   = c.remainingTime;     // seconds
    // map["heartRate"]       = c.heartRate;         // bpm
    // //map["expendedEnergy"]  = c.expendedEnergy;    // kcal or joules (check device)

    return map;
}
