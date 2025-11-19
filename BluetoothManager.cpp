#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothSocket>
#include <QBluetoothUuid>
#include <QBluetoothDeviceInfo>
#include <QMap>
#include <QDebug>
#include <QObject>
#include "BluetoothManager.h"
BluetoothManager::BluetoothManager(QObject *parent) : QObject(parent)
{
    discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);

    // Connect signals
    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered, this, &BluetoothManager::deviceDiscovered);
    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished, this, &BluetoothManager::scanFinished);
}

Q_INVOKABLE void BluetoothManager::startScan() {
    qWarning() << "Starting Bluetooth device scan from QML...";
    discoveryAgent->start();
}

void BluetoothManager::deviceDiscovered(const QBluetoothDeviceInfo &device) {
    qDebug() << "Discovered device:" << device.name() << device.address().toString();
    // Check if the device name matches the KP3902 or if it's in a list of known console addresses
    if (device.name() == "KP3902") {
        connectToDevice(device.address());
    }
}

void BluetoothManager::scanFinished() {
    qDebug() << "Device scan finished.";
}


void BluetoothManager::connectToDevice(const QBluetoothAddress &address) {
    if (activeSockets.contains(address)) {
        qDebug() << "Already connected to this device.";
        return;  // Skip if already connected
    }

    QBluetoothSocket *socket = new QBluetoothSocket(this);
    QBluetoothUuid sppUuid("00001101-0000-1000-8000-00805F9B34FB");
    socket->connectToService(address, sppUuid);

    connect(socket, &QBluetoothSocket::connected, this, &BluetoothManager::onConnected);
    connect(socket, &QBluetoothSocket::readyRead, this, &BluetoothManager::onDataReceived);
    connect(socket, &QBluetoothSocket::disconnected, this, &BluetoothManager::onDisconnected);

    activeSockets[address] = socket; // Add to active connections map
    qDebug() << "Attempting to connect to device" << address.toString();
}

void BluetoothManager::onConnected() {
    QBluetoothSocket *socket = qobject_cast<QBluetoothSocket *>(sender());
    QBluetoothAddress address = socket->peerAddress();
    qDebug() << "Connected to device" << address.toString();
}

void BluetoothManager::onDataReceived() {
    QBluetoothSocket *socket = qobject_cast<QBluetoothSocket *>(sender());
    QByteArray data = socket->readAll();
    QBluetoothAddress address = socket->peerAddress();
    qDebug() << "Received data from" << address.toString() << ":" << data;

    // Parse and handle data here based on the KP3902 protocol
    parseKP3902Data(data);
}

void BluetoothManager::onDisconnected() {
    QBluetoothSocket *socket = qobject_cast<QBluetoothSocket *>(sender());
    QBluetoothAddress address = socket->peerAddress();
    qDebug() << "Disconnected from" << address.toString();

    activeSockets.remove(address); // Remove the disconnected socket from active connections
    socket->deleteLater(); // Clean up socket object
}

void BluetoothManager::parseKP3902Data(const QByteArray &data) {
    // Implement the protocol-specific data parsing here
    // For example, if data is in JSON format:
    // QJsonDocument doc = QJsonDocument::fromJson(data);
    // Handle data accordingly
}

