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
    QLowEnergyController *controller = nullptr;
    QLowEnergyService *ftmsService = nullptr;
    QLowEnergyCharacteristic metricsChar;
    QLowEnergyCharacteristic resistanceLevelChar;

    // Rower Metrics
    int strokeRate = 0;
    int strokeCount = 0;
    int avgStrokeRate = 0;
    double totalDistance = 0.0;
    double instantPace = 0.0;
    int elapsedTime = 0;
    int remainingTime = 0;
    int energyPerHour = 0;
    int power = 0;
};

class BluetoothManager : public QObject
{
    Q_OBJECT
public:
    explicit BluetoothManager(QObject *parent = nullptr);

    Q_INVOKABLE void startScan();
    Q_INVOKABLE void setResistance(int consoleIndex, int level);
    Q_INVOKABLE QVariantMap getMetrics(int consoleIndex);

private slots:
    void deviceDiscovered(const QBluetoothDeviceInfo &device);
    void scanFinished();
    void characteristicChanged(const QLowEnergyCharacteristic &c, const QByteArray &value);

private:
    QBluetoothDeviceDiscoveryAgent *discoveryAgent;
    QList<KayakConsole> consoles;

    void connectConsole(KayakConsole *console);
};

#endif // BLUETOOTHMANAGER_H
