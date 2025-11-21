#include "BluetoothManager.h"
#include <QLowEnergyDescriptor>
#include <QDebug>
#include <QFile>
#include <QTextStream>
const QBluetoothUuid FTMS_SERVICE_UUID("00001826-0000-1000-8000-00805f9b34fb");
const QBluetoothUuid ROWER_DATA_CHAR_UUID("00002AD3-0000-1000-8000-00805f9b34fb");
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
    qWarning()<<device.name();

    if (device.name() == "KP3902" ) {
        if (consoles.size() >= 10)
            return;

        KayakConsole console;
        console.name = device.name();
        console.address = device.address().toString();
        consoles.append(console);
        qDebug() << "Added KP3902 console:" << console.address;
    }
}

void BluetoothManager::scanFinished()
{
    qDebug() << "Scan finished. Connecting to consoles...";
    for (int i = 0; i < consoles.size(); ++i)
        connectConsole(&consoles[i]);
}

void BluetoothManager::connectConsole(KayakConsole *console)
{
    logWarningToFile("temp1");
    QBluetoothAddress addr(console->address);
    console->controller = QLowEnergyController::createCentral(QBluetoothDeviceInfo(addr,console->name,1), this);

    connect(console->controller, &QLowEnergyController::connected, [console]() {
        qDebug() << console->name << "connected. Discovering services...";
        console->controller->discoverServices();
    });

    connect(console->controller, &QLowEnergyController::disconnected, [console]() {
        qDebug() << console->name << "disconnected.";
    });
    logWarningToFile("temp2");
    connect(console->controller, &QLowEnergyController::serviceDiscovered,
            [this, console](const QBluetoothUuid &uuid) {
                if (uuid == FTMS_SERVICE_UUID) {
                    console->ftmsService = console->controller->createServiceObject(uuid, this);
                    if (!console->ftmsService)
                        return;
                    logWarningToFile(uuid.toString());
                    connect(console->ftmsService, &QLowEnergyService::stateChanged,
                            [this, console](QLowEnergyService::ServiceState s) {
                        logWarningToFile("temp4.1");
                              //  if (s == QLowEnergyService::ServiceDiscovered) {
                                    // Assign characteristics
                                    console->metricsChar = console->ftmsService->characteristic(ROWER_DATA_CHAR_UUID);
                                    console->resistanceLevelChar = console->ftmsService->characteristic(RESISTANCE_LEVEL_CHAR_UUID);

                                    if (!console->resistanceLevelChar.isValid()) {
                                        qDebug() << "Resistance characteristic not found! Listing all characteristics:";
                                        for (const QLowEnergyCharacteristic &c : console->ftmsService->characteristics())
                                            qDebug() << c.uuid().toString();
                                    }
                                    logWarningToFile("temp4.2");
                                    // Enable notifications for metrics
                                    if (console->metricsChar.isValid()) {
                                        QLowEnergyDescriptor desc = console->metricsChar.descriptor(
                                            QBluetoothUuid(QLatin1String("00001826-0000-1000-8000-00805f9b34fb")));
                                        if (desc.isValid())
                                        {    console->ftmsService->writeDescriptor(desc, QByteArray::fromHex("0100"));
                                            logWarningToFile("temp4.3");
                                        }
                                    }

                                    connect(console->ftmsService, &QLowEnergyService::characteristicChanged,
                                            this, &BluetoothManager::characteristicChanged);

                                    qDebug() << console->name << "service setup complete.";

                             //   }
                              //  else
                             //   {
                              //      logWarningToFile("temp4.3");
                             //   }
                            });

                    console->ftmsService->discoverDetails();
                }
            });

    console->controller->connectToDevice();
}

void BluetoothManager::characteristicChanged(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
    logWarningToFile("temp5");
    for (auto &console : consoles) {
        // if (c.uuid() == console.metricsChar.uuid() && value.size() >= 18) {
        const quint8 *data = reinterpret_cast<const quint8*>(value.constData());

        console.strokeRate    = data[3] | (data[4] << 8);
        console.strokeCount   = data[13] | (data[14] << 8);
        console.avgStrokeRate = data[15] | (data[16] << 8);
        console.totalDistance = (data[5] | (data[6] << 8)) / 10.0;
        console.instantPace   = (data[1] | (data[2] << 8)) / 100.0;
        console.elapsedTime   = data[9] | (data[10] << 8);
        console.remainingTime = data[11] | (data[12] << 8);
        console.energyPerHour = data[17] | (data[18] << 8);
        console.power         = data[7] | (data[8] << 8);

        QString temp="StrokeRate:"+QString::number(console.strokeRate)+"\n";
        temp+="StrokeCount:"+QString::number(console.strokeCount)+"\n";
        temp+="AvgStrokeRate:"+QString::number(console.avgStrokeRate)+"\n";
        temp+="Distance:"+QString::number(console.totalDistance)+"\n";
        temp+="Elapsed:"+QString::number(console.elapsedTime)+"\n";
        temp+="Power:"+QString::number(console.power)+"\n";
        logWarningToFile(temp);
        //        }
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

    auto &c = consoles[consoleIndex];
    map["strokeRate"] = c.strokeRate;
    map["strokeCount"] = c.strokeCount;
    map["avgStrokeRate"] = c.avgStrokeRate;
    map["distance"] = c.totalDistance;
    map["instantPace"] = c.instantPace;
    map["elapsedTime"] = c.elapsedTime;
    map["remainingTime"] = c.remainingTime;
    map["energyPerHour"] = c.energyPerHour;
    map["power"] = c.power;

    return map;
}
