#ifndef BLECONNECT_H
#define BLECONNECT_H

#include <QObject>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QList>
#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>
#include <QLowEnergyService>
#include <QFileInfo>
#include <QFile>
#include <QDir>
#include <QStringList>
#include <QtAndroid>
#include <QTime>
#include <QDataStream>
#include <QMap>

#include <QDebug>
#include <qandroidjnienvironment.h>
#include <qandroidjniobject.h>

static const QLatin1String serviceUuid("{0000FFE0-0000-1000-8000-00805F9B34FB}");

class BLEConnect : public QObject
{
    Q_OBJECT
public:
    explicit BLEConnect(QObject *parent = nullptr);

    bool PermissionApply(QString);
    bool checkPermission();
    void MsgRefresh();

signals:
    void fromBle(QString msg);
    void sendRquest(QString msg);
    void returnAddress(QBluetoothDeviceInfo);
    void addItems(QString item);

private:
    bool m_foundHeartRateService;

    QBluetoothDeviceDiscoveryAgent *m_deviceDiscoveryAgent;
    QList<QBluetoothDeviceInfo> m_devices;
    QLowEnergyController  *m_control;
    QLowEnergyService *m_service;

    QLowEnergyCharacteristic m_writeCharacteristic[5]; //写特性
    QLowEnergyService::WriteMode m_writeMode;
    QLowEnergyDescriptor m_notificationDesc;
    QLowEnergyCharacteristic m_readCharacteristic; //读特性
    int SendMaxMode; //发送模式
    int SendModeSelect;//选择发送模式
    bool isconnected;
    QMap<QString,int> existBle;

public slots:
    void addDevice(const QBluetoothDeviceInfo &device);

    void on_blue_connect_clicked(QString address);

    void on_blue_search_clicked(bool checked);
    void scanFinished();
    void createCtl(QBluetoothDeviceInfo);

    void serviceDiscovered(const QBluetoothUuid &gatt);
    void serviceScanDone();
    void serviceStateChanged(QLowEnergyService::ServiceState s);

    void searchCharacteristic();
    void BleServiceCharacteristicChanged(const QLowEnergyCharacteristic &c,const QByteArray &value);
    void BleServiceCharacteristicRead(const QLowEnergyCharacteristic &c,
                                      const QByteArray &value);
    void BleServiceCharacteristicWrite(const QLowEnergyCharacteristic &c,
                                                   const QByteArray &value);
    void sendBleMsg(QString text);
};

#endif // BLECONNECT_H
