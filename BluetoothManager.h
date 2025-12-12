#ifndef BLUETOOTHMANAGER_H
#define BLUETOOTHMANAGER_H

#include <QObject>
#include <QLowEnergyController>
#include <QLowEnergyService>
#include <QLowEnergyCharacteristic>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothDeviceInfo>
#include <QVariantMap>

struct KayakConsole {

    QString name;
    QString address;
    QBluetoothDeviceInfo deviceInfo;
    int id;
    QLowEnergyController *controller = nullptr;
    QLowEnergyService *ftmsService = nullptr;
    QLowEnergyCharacteristic metricsChar;
    QLowEnergyCharacteristic resistanceLevelChar;
   int connectionAttempts = 0;   // <-- Not a Qt class, no header
    // KP3902 metrics
    quint16 flags = 0;
    quint8 strokeRate = 0;
    quint16 strokeCount = 0;
    quint32 distance = 0;
    quint16 pace = 0;
    quint16 instPower = 0;
    quint16 energyKJ = 0;
    quint16 kcal = 0;
    quint8 heartRate = 0;
    quint16 elapsedTime = 0;
    QByteArray buffer; // accumulate fragmented packets

    bool updateMetrics(const QByteArray &value) {
        if (value.size() < 20) return false;

        QVector<quint8> uint8Data;
        for (auto b : value) uint8Data.append(static_cast<quint8>(b));

        flags       = uint8Data[0] | (uint8Data[1] << 8);
        strokeRate  = uint8Data[2] / 2;
        strokeCount = uint8Data[3] | (uint8Data[4] << 8);
        distance    = uint8Data[5] | (uint8Data[6] << 8) | (uint8Data[7] << 16);
        pace        = uint8Data[8] | (uint8Data[9] << 8);
        instPower   = uint8Data[10] | (uint8Data[11] << 8);
        energyKJ    = uint8Data[12] | (uint8Data[13] << 8);
        kcal        = static_cast<quint16>(energyKJ * 0.239);
        heartRate   = uint8Data[17];
        elapsedTime = uint8Data[18] | (uint8Data[19] << 8);

        return true;
    }

    QVariantMap getMetrics() const {
        QVariantMap map;
        map["strokeRate"]  = strokeRate;
        map["strokeCount"] = strokeCount;
        map["distance"]    = distance;
        map["pace"]        = pace;
        map["instPower"]   = instPower;
        map["kcal"]        = kcal;
        map["heartRate"]   = heartRate;
        map["elapsedTime"] = elapsedTime;
        return map;
    }
};
extern QList<KayakConsole> consoles;
class BluetoothManager : public QObject
{
    Q_OBJECT
public:
    explicit BluetoothManager(QObject *parent = nullptr);
void rebootBluetoothAdapter();
    Q_INVOKABLE void startScan();
    Q_INVOKABLE void setResistance(int consoleIndex, int level);
    Q_INVOKABLE QVariantMap getMetrics(int consoleIndex);
    void setupFtmsService(KayakConsole *console);
private slots:
    void deviceDiscovered(const QBluetoothDeviceInfo &device);
    void scanFinished();
    void characteristicChanged(const QLowEnergyCharacteristic &c, const QByteArray &value);

private:
    QBluetoothDeviceDiscoveryAgent *discoveryAgent;


    const int maxAttempts = 5;
    void connectConsole(KayakConsole *console);
};

#endif // BLUETOOTHMANAGER_H
