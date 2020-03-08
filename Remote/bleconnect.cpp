#include "bleconnect.h"

BLEConnect::BLEConnect(QObject *parent) : QObject(parent)
{
    SendModeSelect=0;   //默认发送模式
    MsgRefresh();
    m_foundHeartRateService=false;
    isconnected=false;

    m_deviceDiscoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);
    m_deviceDiscoveryAgent->setLowEnergyDiscoveryTimeout(20000);
    connect(m_deviceDiscoveryAgent,SIGNAL(deviceDiscovered(QBluetoothDeviceInfo)), this,
            SLOT(addDevice(QBluetoothDeviceInfo)));//
    connect(m_deviceDiscoveryAgent, SIGNAL(finished()), this, SLOT(scanFinished()));
    connect(this, SIGNAL(returnAddress(QBluetoothDeviceInfo)), this, SLOT(createCtl(QBluetoothDeviceInfo)));
}

bool BLEConnect::checkPermission()
{
    QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    if(r == QtAndroid::PermissionResult::Denied)
    {
        QtAndroid::requestPermissionsSync( QStringList() << "android.permission.WRITE_EXTERNAL_STORAGE" );
        r = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
        if(r == QtAndroid::PermissionResult::Denied)
        {
            return false;
        }
    }
    return true;
}

void BLEConnect::MsgRefresh()
{
    if(!checkPermission())
    {
        //        ui->bluemsg->append("安卓写权限获取失败");
        emit fromBle("安卓写权限获取失败");
    }
    else
    {
        //        ui->bluemsg->append("安卓写权限获取成功");
        emit fromBle("安卓写权限获取成功");
    }

    QAndroidJniEnvironment env;
    //    ui->bluemsg->append(QString("SDK版本:%1").arg(QtAndroid::androidSdkVersion()));
    emit fromBle(QString("SDK版本:%1").arg(QtAndroid::androidSdkVersion()));
}

bool BLEConnect::PermissionApply(QString str)
{
    QtAndroid::PermissionResult r = QtAndroid::checkPermission(str);

    if(r == QtAndroid::PermissionResult::Denied)
    {
        QtAndroid::requestPermissionsSync(QStringList() << str);

        r=QtAndroid::checkPermission(str);
        if(r == QtAndroid::PermissionResult::Denied)
        {
            //            ui->bluemsg->append("权限申请失败");
            emit fromBle("权限申请失败");
            return false;
        }
    }
    //    ui->bluemsg->append("权限申请成功");
    emit fromBle("权限申请成功");
    return true;
}

void BLEConnect::addDevice(const QBluetoothDeviceInfo &info)
{
    if (info.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration)
    {//判断是否是BLE设备
        QString label = QString("%1 %2").arg(info.address().toString()).arg(info.name());//按顺序显示地址和设备名称
        //        QList<QListWidgetItem *> items = ui->bluelist->findItems(label, Qt::MatchExactly);//检查设备是否已存在，避免重复添加
        if (existBle.value(label,1))
        {//不存在则添加至设备列表
            //            ui->bluelist->addItem(item);
            existBle[label]=0;
            emit addItems(label);
            m_devices.append(info);
        }
    }
}

void BLEConnect::on_blue_connect_clicked(QString address)
{

    QString bltAddress = address.left(17);//获取选择的地址
    for (int i = 0; i<m_devices.count(); i++)
    {
        if(m_devices.at(i).address().toString().left(17) == bltAddress)//地址对比
        {
            QBluetoothDeviceInfo choosenDevice = m_devices.at(i);
            emit returnAddress(choosenDevice);//发送设备信息
            m_deviceDiscoveryAgent->stop();//停止搜索服务
            break;
        }
    }
}

void BLEConnect::on_blue_search_clicked(bool checked)
{
    existBle.clear();
    m_deviceDiscoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
}

void BLEConnect::scanFinished()
{

}

void BLEConnect::createCtl(QBluetoothDeviceInfo info)
{
    m_control = QLowEnergyController::createCentral(info, this);
    connect(m_control, &QLowEnergyController::serviceDiscovered,
            this,&BLEConnect::serviceDiscovered);

    connect(m_control, &QLowEnergyController::discoveryFinished,
            this, &BLEConnect::serviceScanDone);

    connect(m_control, static_cast<void (QLowEnergyController::*)(QLowEnergyController::Error)>(&QLowEnergyController::error),
            this, [this](QLowEnergyController::Error error) {
        Q_UNUSED(error);
//        ui->bluemsg->append("Cannot connect to remote device.");
        emit fromBle("Cannot connect to remote device.");
    });

    connect(m_control, &QLowEnergyController::connected, this, [this]() {
//        ui->bluemsg->append("Controller connected. Search services...\n");
        emit fromBle("Controller connected. Search services...");
        m_control->discoverServices();
        isconnected=true;
    });

    connect(m_control, &QLowEnergyController::disconnected, this, [this]() {
//        ui->bluemsg->append("LowEnergy controller disconnected");
        emit fromBle("LowEnergy controller disconnected");
    });

    //connect
//    ui->bluemsg->append("start to connect\n");
    emit fromBle("start to connect");

    m_control->connectToDevice();
}

void BLEConnect::serviceDiscovered(const QBluetoothUuid &gatt)
{
//    ui->bluemsg->insertPlainText(QString("%1").arg(gatt.toString()));
    emit fromBle(QString("%1").arg(gatt.toString()));
    m_foundHeartRateService = true;
}

void BLEConnect::serviceScanDone()
{
    //setInfo("Service scan done.");
//    ui->bluemsg->append("Service scan done.");
    emit fromBle("Service scan done.");

    m_service = m_control->createServiceObject(QBluetoothUuid(serviceUuid),
                                               this);
    if(m_service)
    {
//        ui->bluemsg->append("服务建立成功\n");
        emit fromBle("服务建立成功");

        m_service->discoverDetails();
    }
    else
    {
//        ui->bluemsg->append("Service not found");
        emit fromBle("Service not found");
        return;
    }
    connect(m_service, &QLowEnergyService::stateChanged, this,
            &BLEConnect::serviceStateChanged);
    connect(m_service, &QLowEnergyService::characteristicChanged, this,
            &BLEConnect::BleServiceCharacteristicChanged);
    connect(m_service, &QLowEnergyService::characteristicRead, this,
            &BLEConnect::BleServiceCharacteristicRead);
    connect(m_service, SIGNAL(characteristicWritten(QLowEnergyCharacteristic,QByteArray)),
            this, SLOT(BleServiceCharacteristicWrite(QLowEnergyCharacteristic,QByteArray)));

    if(m_service->state()==QLowEnergyService::DiscoveryRequired)
    {
        m_service->discoverDetails();
    }
    else
    {
        searchCharacteristic();
    }
}

void BLEConnect::serviceStateChanged(QLowEnergyService::ServiceState s)
{
    if(s == QLowEnergyService::ServiceDiscovered)
    {
//        ui->bluemsg->append("服务已同步\n");
        emit fromBle("服务已同步");

        searchCharacteristic();
    }
}

void BLEConnect::searchCharacteristic()
{
    if(m_service)
    {
        QList<QLowEnergyCharacteristic> list=m_service->characteristics();
        qDebug()<<"list.count()="<<list.count();
        //characteristics 获取详细特性
        SendMaxMode=list.count();  //设置模式选择上限
        for(int i=0;i<list.count();i++)
        {
            QLowEnergyCharacteristic c=list.at(i);
            /*如果QLowEnergyCharacteristic对象有效，则返回true，否则返回false*/
            if(c.isValid())
            {
                //                返回特征的属性。
                //                这些属性定义了特征的访问权限。
                if(c.properties() & QLowEnergyCharacteristic::WriteNoResponse || c.properties() & QLowEnergyCharacteristic::Write)
                    // if(c.properties() & QLowEnergyCharacteristic::Write)
                {
//                    ui->bluemsg->insertPlainText("具有写权限!\n");
                    emit fromBle("获取蓝牙写权限!");
                    m_writeCharacteristic[i] = c;  //保存写权限特性
                    if(c.properties() & QLowEnergyCharacteristic::WriteNoResponse)
                        //                        如果使用此模式写入特性，则远程外设不应发送写入确认。
                        //                        无法确定操作的成功，并且有效负载不得超过20个字节。
                        //                        一个特性必须设置QLowEnergyCharacteristic :: WriteNoResponse属性来支持这种写模式。
                        //                         它的优点是更快的写入操作，因为它可能发生在其他设备交互之间。
                        m_writeMode = QLowEnergyService::WriteWithoutResponse;
                    else
                        m_writeMode = QLowEnergyService::WriteWithResponse;
                    //如果使用此模式写入特性，则外设应发送写入确认。
                    //如果操作成功，则通过characteristicWritten（）信号发出确认。
                    //否则，发出CharacteristicWriteError。
                    //一个特性必须设置QLowEnergyCharacteristic :: Write属性来支持这种写模式。
                }
                if(c.properties() & QLowEnergyCharacteristic::Read)
                {
                    m_readCharacteristic = c; //保存读权限特性
                }
                //描述符定义特征如何由特定客户端配置。
                m_notificationDesc = c.descriptor(QBluetoothUuid::ClientCharacteristicConfiguration);
                //值为真
                if(m_notificationDesc.isValid())
                {
                    //写描述符
                    m_service->writeDescriptor(m_notificationDesc, QByteArray::fromHex("0100"));
                    //   m_service->writeDescriptor(m_notificationDesc, QByteArray::fromHex("FEE1"));
//                    ui->bluemsg->insertPlainText("写描述符!\n");
                    emit fromBle("获取蓝牙写描述符!");
                }
            }
        }
    }
}

void BLEConnect::BleServiceCharacteristicChanged(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
//    ui->bluemsg->insertPlainText(QString(value));
    emit fromBle(QString(value));
}

void BLEConnect::BleServiceCharacteristicRead(const QLowEnergyCharacteristic &c, const QByteArray &value)
{

}

void BLEConnect::BleServiceCharacteristicWrite(const QLowEnergyCharacteristic &c, const QByteArray &value)
{
//    ui->bluemsg->append(QString("指令%1发送成功").arg(QString(value)));
    emit sendRquest(QString(value));
//    ui->bluemsg->append(QString().number(value.length()));
}

void BLEConnect::sendBleMsg(QString text)
{
    QByteArray array=text.toLocal8Bit();
    m_service->writeCharacteristic(m_writeCharacteristic[SendModeSelect],array, m_writeMode);
}
