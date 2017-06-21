//
//  ViewController.m
//  iOS蓝牙开发-CoreBluetooth
//
//  Created by 高飞 on 17/4/1.
//  Copyright © 2017年 高飞. All rights reserved.
//
/*蓝牙中心模式流程(绝大部分是以这个模式进行开发，将手机作为主机，连接蓝牙外设）
 1. 建立中心角色
 
 2. 扫描外设（discover）
 
 3. 连接外设(connect)
 
 4. 扫描外设中的服务和特征(discover)
 
 - 4.1 获取外设的services
 
 - 4.2 获取外设的Characteristics,获取Characteristics的值，获取Characteristics的Descriptor和Descriptor的值
 
 5. 与外设做数据交互(explore and interact):从外围设备读书数据，给外围设备发送数据
 
 6. 订阅Characteristic的通知
 
 7. 断开连接(disconnect)
 
 **蓝牙设备状态
 
 1. 待机状态（standby）：设备没有传输和发送数据，并且没有连接到任何设
 
 2. 广播状态（Advertiser）：周期性广播状态
 
 3. 扫描状态（Scanner）：主动寻找正在广播的设备
 
 4. 发起链接状态（Initiator）：主动向扫描设备发起连接。
 
 5. 主设备（Master）：作为主设备连接到其他设备。
 
 6. 从设备（Slave）：作为从设备连接到其他设备。
 
 蓝牙设备的五种工作状态
 
 准备（standby）
 
 广播（advertising）
 
 监听扫描（Scanning
 
 发起连接（Initiating）
 
 已连接（Connected）*/
#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>
/*中心管理者**/
@property (nonatomic,strong) CBCentralManager *manager;
/*外围设备**/
@property (nonatomic, strong) CBPeripheral *peripheral;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager.delegate = self;
}

- (CBCentralManager *)manager{
    if (!_manager) {
        _manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        //_manager.delegate = self;
    }return _manager;
}
#pragma mark---------CBCentralManagerDelegate
//更新状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case CBManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"CBCentralManagerStateUnsupported");//不支持蓝牙
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case CBManagerStatePoweredOff:
        {
            NSLog(@"CBCentralManagerStatePoweredOff");//蓝牙未开启
        }
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@"CBCentralManagerStatePoweredOn");//蓝牙已开启
            // 在中心管理者成功开启后再进行一些操作
            // 2.开始扫描外围设备
            [self.manager scanForPeripheralsWithServices:nil options:nil]; // 服务,条件进行帅选
        }
            break;
 
    }
}
//扫描外围设备后会触发：发现外围设备这个方法
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    //可以得到外围设备的信息
    // 需要对连接到的外设进行过滤
    // 1.信号强度(40以上才连接, 80以上连接)
    // 2.通过设备名(设备字符串前缀是 OBand)
    // 在此时我们的过滤规则是:有OBand前缀并且信号强度大于35
    // 通过打印,我们知道RSSI一般是带-的
    
    if ([peripheral.name hasPrefix:@"OBand"]) {
        // 在此处对我们的 advertisementData(外设携带的广播数据) 进行一些处理
        
        // 通常通过过滤,我们会得到一些外设,然后将外设储存到我们的可变数组中,
        // 这里由于附近只有1个运动手环, 所以我们先按1个外设进行处理
        
        // 标记我们的外设,让他的生命周期 = vc
        self.peripheral = peripheral;
        // 3.发现完之后就是进行连接
        [self.manager connectPeripheral:self.peripheral options:nil];
        NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    }
}
//已经连接外围设备
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"%s, line = %d, %@=连接成功", __FUNCTION__, __LINE__, peripheral.name);
    // 连接成功之后,可以进行服务和特征的发现
    
    //  设置外设的代理
    self.peripheral.delegate = self;
    
    // 4.外设发现服务,传nil代表不过滤
    // 这里会触发外设的代理方法 - (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
    [self.peripheral discoverServices:nil];
}

//外围设备连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
     NSLog(@"%s, line = %d, %@=连接失败", __FUNCTION__, __LINE__, peripheral.name);
}
//断开外围设备连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
      NSLog(@"%s, line = %d, %@=断开连接", __FUNCTION__, __LINE__, peripheral.name);
}

#pragma mark----------CBPeripheralDelegate 外围设备代理
//外设发现服务时触发
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
}
// 发现外设服务里的特征的时候调用的代理方法(这个是比较重要的方法，你在这里可以通过事先知道UUID找到你需要的特征，订阅特征，或者这里写入数据给特征也可以)
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    
    for (CBCharacteristic *cha in service.characteristics) {
        NSLog(@"%s, line = %d, char = %@", __FUNCTION__, __LINE__, cha);
        
    }
}

// 更新特征的value的时候会调用 （凡是从蓝牙传过来的数据都要经过这个回调，简单的说这个方法就是你拿数据的唯一方法）读取从外围设备发送过来的数据。
//5.与蓝牙设备进行数据交互
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    if ([characteristic  isEqual: @"你要的特征的UUID或者是你已经找到的特征"]) {
        //characteristic.value就是你要的数据
        //5.给外围设备发送数据（也就是写入数据到蓝牙）
       // 这个方法你可以放在button的响应里面，也可以在找到特征的时候就写入，具体看你业务需求怎么用啦
        //第一个参数是已连接的蓝牙设备 ；第二个参数是要写入到哪个特征； 第三个参数是通过此响应记录是否成功写入
        //[self.peripheral writeValue:_batteryData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
}
//这个还不是很清楚？
- (void)yf_peripheral:(CBPeripheral *)peripheral didWriteData:(NSData *)data forCharacteristic:(nonnull CBCharacteristic *)characteristic
{
    /*
     typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
     CBCharacteristicPropertyBroadcast                                                = 0x01,
     CBCharacteristicPropertyRead                                                    = 0x02,
     CBCharacteristicPropertyWriteWithoutResponse                                    = 0x04,
     CBCharacteristicPropertyWrite                                                    = 0x08,
     CBCharacteristicPropertyNotify                                                    = 0x10,
     CBCharacteristicPropertyIndicate                                                = 0x20,
     CBCharacteristicPropertyAuthenticatedSignedWrites                                = 0x40,
     CBCharacteristicPropertyExtendedProperties                                        = 0x80,
     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)        = 0x100,
     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)    = 0x200
     };
     
     打印出特征的权限(characteristic.properties),可以看到有很多种,这是一个NS_OPTIONS的枚举,可以是多个值
     常见的又read,write,noitfy,indicate.知道这几个基本够用了,前俩是读写权限,后俩都是通知,俩不同的通知方式
     */
    //    NSLog(@"%s, line = %d, char.pro = %d", __FUNCTION__, __LINE__, characteristic.properties);
    // 此时由于枚举属性是NS_OPTIONS,所以一个枚举可能对应多个类型,所以判断不能用 = ,而应该用包含&
}
@end
