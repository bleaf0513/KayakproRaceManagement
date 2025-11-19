#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothSocket>
#include <QBluetoothUuid>
#include <QBluetoothDeviceInfo>
#include <QMap>
#include <QDebug>
#include <QObject>
class BluetoothManager : public QObject {
    Q_OBJECT
public:

    explicit BluetoothManager(QObject *parent = nullptr);
    Q_INVOKABLE void startScan();
private slots:
    void deviceDiscovered(const QBluetoothDeviceInfo &device);

    void scanFinished();

private:
    QBluetoothDeviceDiscoveryAgent *discoveryAgent;
    QMap<QBluetoothAddress, QBluetoothSocket*> activeSockets; // Map to track multiple connections

    void connectToDevice(const QBluetoothAddress &address) ;

    void onConnected() ;

    void onDataReceived();

    void onDisconnected();
    void parseKP3902Data(const QByteArray &data);
};
