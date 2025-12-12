#include "BluetoothManager.h"
#include <QLowEnergyDescriptor>
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QTimer>
#include <QEventLoop>
#include <QBluetoothLocalDevice>
#include <QThread>
#include <functional>
#include <memory>
#include <QBluetoothDeviceInfo>
#include <QProcess>
#include <QCoreApplication>
QList<KayakConsole> consoles;
extern int global_playernum;
extern QList<QStringList> global_data;
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


void BluetoothManager::rebootBluetoothAdapter()
{
    qDebug() << "Stopping Bluetooth service...";
    QProcess::execute("sudo systemctl stop bluetooth");

    qDebug() << "Turning Bluetooth adapter off...";
    QProcess::execute("sudo hciconfig hci0 down");

    // Small delay to ensure adapter is fully down
    QThread::msleep(200);

    qDebug() << "Turning Bluetooth adapter on...";
    QProcess::execute("sudo hciconfig hci0 up");

    qDebug() << "Starting Bluetooth service...";
    QProcess::execute("sudo systemctl start bluetooth");

    qDebug() << "Bluetooth reboot complete!";
        QProcess::execute("sudo btmgmt power off");
            QProcess::execute("sudo btmgmt le on");
                QProcess::execute("sudo btmgmt bredr off");
                    QProcess::execute("sudo btmgmt advertising off");
                        QProcess::execute("sudo systemctl start bluetooth");
                QProcess::execute("sudo btmgmt privacy off");
                    QProcess::execute("sudo btmgmt power on");








}
BluetoothManager::BluetoothManager(QObject *parent) : QObject(parent)
{
    static bool done = false;
    if (done) return;
    done = true;
    rebootBluetoothAdapter();
    qWarning()<<"constructer call";


}

void BluetoothManager::startScan()
{

    static bool done = false;
    if (done) return;
    done = true;
/*
            KayakConsole console;
consoles.clear();
           // qWarning()<<"DONG_DEVINFO"<<console.deviceInfo.deviceUuid()<<console.deviceInfo.serviceUuids().at(0);
            int index=0;
            //for(int i=1;i<=10;i++)
            int i=1;
            {
               // qDebug() << "global_data:" <<i<<":"<< global_data[i].at(8);
                if(global_data[i].at(8)!="" && global_data[i].at(10)!="")
                {
                    QBluetoothAddress add(global_data[i].at(8));
                    QBluetoothDeviceInfo devinfo(add,global_data[i].at(10),0);

                    console.id=i-1;
                    console.name = global_data[i].at(10);
                    console.address = global_data[i].at(8);
                    console.deviceInfo = devinfo;     // IMPORTANT!!!
                    consoles.append(console);
                    qDebug() << "Found:" << global_data[i].at(10) << global_data[i].at(8);
                    connectConsole(&consoles[index]);
   // QTimer::singleShot(index*450, [this,index]() { connectConsole(&consoles[index]); });
    index++;
                }
            }


    */
    for(int i=0;i<10;i++)
    {
        if(global_data[i+1].at(8)=="")
            global_data[i+1].replace(9,"-1");
    }

    discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);

    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
            this, &BluetoothManager::deviceDiscovered);
    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
            this, &BluetoothManager::scanFinished);
    consoles.clear();
    qDebug() << "Starting Bluetooth scan for KP3902 consoles...";
    discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
}

void BluetoothManager::deviceDiscovered(const QBluetoothDeviceInfo &device)
{
    //if(device.name().contains("KP") || device.name().contains("Kayak"))//serviceUuids().size()>0)
    if(device.serviceIds().size()>0)
    {
qWarning()<<"DONG_DEVINFO"<<device.address().toString()<<"   "<<device.name();
        if (device.serviceIds().at(0).toString() =="{00001826-0000-1000-8000-00805f9b34fb}")
        {

            KayakConsole console;
            console.name = device.name();
            console.address = device.address().toString();
            console.deviceInfo = device;     // IMPORTANT!!!
           // qWarning()<<"DONG_DEVINFO"<<console.deviceInfo.deviceUuid()<<console.deviceInfo.serviceUuids().at(0);
            for(int i=1;i<=10;i++)
            {
               // qDebug() << "global_data:" <<i<<":"<< global_data[i].at(8);
                if(global_data[i].at(8)==console.address)
                {

                    console.id=i-1;
                    consoles.append(console);
                    qDebug() << "Found:" << console.name << console.address<<console.id;

                }
            }
        }
    }
}

void BluetoothManager::scanFinished()
{

    qDebug() << "Scan finished.  consoles..."<<consoles.count();
    if(consoles.size()==0) return;
    for (int i=0; i<10; ++i)
    {
        global_data[i+1].replace(9,"-1");
    }
    for (int i=0; i<consoles.size(); ++i)
    {
global_data[consoles[i].id+1].replace(9,"0");
        QTimer::singleShot(i*50, [this,i]() { connectConsole(&consoles[i]); });
    }
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
    qWarning()<<"FTMS!OK!";
    connect(console->ftmsService, &QLowEnergyService::characteristicChanged,
            this, &BluetoothManager::characteristicChanged);
}
int maxRetries = 900;      // max retry attempts per console




void BluetoothManager::connectConsole(KayakConsole* console)
{
    static QMap<QString, int> retryCount; // Track retries per console

    qDebug() << "Connecting to" << console->name << console->address;

    if (console->controller) {
        console->controller->disconnectFromDevice();
        console->controller->deleteLater();
        console->controller = nullptr;
        QCoreApplication::processEvents();
    }
    console->controller = QLowEnergyController::createCentral(console->deviceInfo,this);//console->deviceInfo, this);

    //if(retryCount[console->address]%2==0)
    console->controller->setRemoteAddressType(QLowEnergyController::PublicAddress);
    //else
    //      console->controller->setRemoteAddressType(QLowEnergyController::RandomAddress);
    QBluetoothLocalDevice *localDevice = new QBluetoothLocalDevice();
    localDevice->setHostMode(QBluetoothLocalDevice::HostConnectable);
    delete localDevice;
    // Connected
    connect(console->controller, &QLowEnergyController::connected, this, [=]() {
        qDebug() << console->name << "Connected!";
        console->controller->discoverServices();
        retryCount[console->address] = 0; // reset retry counter
    });

    // Error handling with retry
    connect(console->controller, &QLowEnergyController::errorOccurred,
            this, [=](QLowEnergyController::Error e) mutable {
        qWarning() << console->name << "Controller error:" << e;

        // Increment retry count
        retryCount[console->address] += 1;

        if (retryCount[console->address] <= maxRetries) {
            qWarning() << "Retrying connection (" << retryCount[console->address] << "/" << maxRetries << ")...";

            // Clean up old controller
            console->controller->disconnectFromDevice();
            console->controller->deleteLater();
            console->controller = nullptr;

            // Retry after 500ms
            QTimer::singleShot(30, [console, this]() {
                this->connectConsole(console);
            });
        } else {
            qWarning() << console->name << "Failed to connect after" << maxRetries << "attempts.";
        }
    });
    // When services found
    connect(console->controller, &QLowEnergyController::serviceDiscovered,
            this, [console](const QBluetoothUuid &uuid) {
        if (uuid == FTMS_SERVICE_UUID)
            qDebug() << console->name << "FTMS service found:";
    });

    // FTMS ready
    connect(console->controller, &QLowEnergyController::discoveryFinished,
            this, [this, console]() {

        console->ftmsService =
                console->controller->createServiceObject(FTMS_SERVICE_UUID, this);

        if (!console->ftmsService) {
            qWarning() << "Could not create FTMS service!";
            return;
        }

        connect(console->ftmsService, &QLowEnergyService::stateChanged,
                this, [this, console](QLowEnergyService::ServiceState state) {
            if (state == QLowEnergyService::RemoteServiceDiscovered) {
                setupFtmsService(console);
                if(global_data[console->id+1].at(9)!="1")
                {global_data[console->id+1].replace(9,"1");
                global_playernum++;
                qDebug() << console->name <<console->id<< "FTMS Ready!";
                }
            }
        });

        console->ftmsService->discoverDetails();
    });

    // Start connection
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
        //qWarning()<<value;
        QByteArray packet = console->buffer.left(20);
        console->buffer.remove(0, 20); // remove parsed bytes

        if (console->updateMetrics(packet)) {

            //qDebug().noquote() << "Console:" << console->name
            //                   << "\n" << console->getMetrics();
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
