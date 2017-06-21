# iOS-CoreBluetooth-Demo
CoreBluetooth Demo
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
