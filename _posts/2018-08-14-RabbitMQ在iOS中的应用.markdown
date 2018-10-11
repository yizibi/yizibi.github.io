---
layout:     post
title:    "RabbitMQ在iOS中的应用"
subtitle:   "RabbitMQ"
date: 2018-08-14 15:32:24.000000000 +09:00
author:     "一之笔"
header-img: "img/home-bg-o.jpg"
tags:
- iOS技术
---

文章原创如需转载，请注明出处"本文首发于[一之笔](https://yizibi.github.io/)";


引言

> 随着公司业务的需要，原来的推送，不能满足现有的要求，比如，有的公司需要局域网部署平台服务，不能访问外网，意味着，通过自带的 APNS远程推送服务，基本上就挂掉了;再比如，公司的某一个业务，需要实时刷新数据，如股票价格，报警实时监测数据等这种场景。这时候，就需要另辟蹊径；当然，我们有很多种选择，比如，RabbitMQ-实现了高级消息队列协议的开源消息代理软件，为啥要用这个呢，因为Android已经用这个做好了，所以，iOS 也没有其他选择了;


在集成客户端的时候，我们有一些概念需要知道，如消息队列，生产者，消费者，交换器，队列,通道等；

## 一.RabbitMQ 的相关概念

### 1.1 简介

RabbitMQ 本质上是 MB（Message Broker) 消息代理，可以这么认为，[RabbitMQ](https://www.rabbitmq.com/tutorials/tutorial-one-objectivec.html)就像一个 “邮局”，负责收发存储邮包（消息），唯一与邮局不同的是，它不会处理消息内容

==AMQP==，即Advanced Message Queuing Protocol，高级消息队列协议，是应用层协议的一个开放标准；类似Http,https,STMP这种，我们只需要知道，他是一个协议，实际开发中会遇到，底层实现我们不用管；

### 1.2 MQ的特征

RabbitMQ 是一个由 Erlang 语言开发的 AMQP 的开源实现。

支持多种客户端，如：==Python、Ruby、.NET、Java、JMS、C、PHP、ActionScript、XMPP、STOMP，Object-C, Swift==等，支持AJAX。用于在分布式系统中存储转发消息，在易用性、扩展性、高可用性等方面表现不俗。

* 可靠性（Reliability）

RabbitMQ 使用一些机制来保证可靠性，如持久化、传输确认、发布确认。

* 灵活的路由（Flexible Routing）

在消息进入队列之前，通过 Exchange 来路由消息的。对于典型的路由功能，RabbitMQ 已经提供了一些内置的 Exchange 来实现。针对更复杂的路由功能，可以将多个 Exchange 绑定在一起，也通过插件机制实现自己的 Exchange 。

* 消息集群（Clustering）

多个 RabbitMQ 服务器可以组成一个集群，形成一个逻辑 Broker 。

* 高可用（Highly Available Queues）

队列可以在集群中的机器上进行镜像，使得在部分节点出问题的情况下队列仍然可用。

* 多种协议（Multi-protocol）

RabbitMQ 支持多种消息队列协议，比如 STOMP、MQTT 等等。

* 多语言客户端（Many Clients）

RabbitMQ 几乎支持所有常用语言，比如 Java、.NET、Ruby, Object-C等等。

* 管理界面（Management UI）

RabbitMQ 提供了一个易用的用户界面，使得用户可以监控和管理消息 Broker 的许多方面。

* 跟踪机制（Tracing）

如果消息异常，RabbitMQ 提供了消息跟踪机制，使用者可以找出发生了什么。

* 插件机制（Plugin System）

RabbitMQ 提供了许多插件，来从多方面进行扩展，也可以编写自己的插件。

### 1.3 RabbitMQ的概念模型

所有 MQ 产品从模型抽象上来说都是一样的过程：
消费者（consumer）订阅某个队列。生产者（producer）创建消息，然后发布到队列（queue）中，最后将消息发送到监听的消费者。

![消息模型](http://o9zpq25pv.bkt.clouddn.com/MQ-sendMessage.png)

* AMQP的内部结构

上面介绍RabbitMQ是AMQP的实现，所以其内部也是AMQP的概念

![RabbbitMQ的内部结构](http://o9zpq25pv.bkt.clouddn.com/MQ/AMQP-image.png)


* P(Producer) 生产者，有的也称之为 Publisher,消息的发布者

发送消息的程序或者代码就是生产者，一般是 服务端

![生产者](http://o9zpq25pv.bkt.clouddn.com/MQ-producer.png)

* Exchange(交换器)

交换器，用来接收生产者发送的消息并将这些消息路由给服务器中的队列.生产者把消息发布到 Exchange 上，消息最终到达队列并被消费者接收，而 Binding 决定交换器的消息应该发送到那个队列。

* routing key

生产者在将消息发送给Exchange的时候，一般会指定一个routing key，来指定这个消息的路由规则，而这个routing key需要与Exchange Type及binding key联合使用才能最终生效。
在Exchange Type与binding key固定的情况下（在正常使用时一般这些内容都是固定配置好的），我们的生产者就可以在发送消息给Exchange时，通过指定routing key来决定消息流向哪里。
RabbitMQ为routing key设定的长度限制为255 bytes。
此外，这个 Key 值，一般是服务端跟客户端约定好的，可以是组织ID，也可以用ID

* Binding(绑定)

绑定，用于消息队列和交换器之间的关联。一个绑定就是基于路由键将交换器和消息队列连接起来的路由规则，所以可以将交换器理解成一个由绑定构成的路由表。

* Queue(队列) 

消息队列，用来保存消息直到发送给消费者。它是消息的容器，也是消息的终点。一个消息可投入一个或多个队列。消息一直在队列里面，等待消费者连接到这个队列将其取走。

* Connection(连接) 

网络连接，比如一个TCP连接，RabbitMQ的OC CLient就是封装了 开源的TCP实现[CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket)


* Channel(信道)

信道，多路复用连接中的一条独立的双向数据流通道。信道是建立在真实的TCP连接内地虚拟连接，AMQP 命令都是通过信道发出去的，不管是发布消息、订阅队列还是接收消息，这些动作都是通过信道完成。因为对于操作系统来说建立和销毁 TCP 都是非常昂贵的开销，所以引入了信道的概念，以复用一条 TCP 连接。


* Virtual Host(虚拟主机)
虚拟主机，表示一批交换器、消息队列和相关对象。虚拟主机是共享相同的身份认证和加密环境的独立服务器域。每个 vhost 本质上就是一个 mini 版的 RabbitMQ 服务器，拥有自己的队列、交换器、绑定和权限机制。vhost 是 AMQP 概念的基础，必须在连接时指定，RabbitMQ 默认的 vhost 是 /


* C(Consumer) 消费者

订阅某个队列，消息的接受者

![消费者](http://o9zpq25pv.bkt.clouddn.com/MQ-consumer.png)

### 1.4 RabbitMQ 中的消息路由
生产者把消息发布到 Exchange 上，消息最终到达队列并被消费者接收，而 Binding 决定交换器的消息应该发送到那个队列。

在绑定（Binding）Exchange与Queue的同时，一般会指定一个binding key；生产者将消息发送给Exchange时，一般会指定一个routing key；当binding key与routing key相匹配时，消息将会被路由到对应的Queue中。
在绑定多个Queue到同一个Exchange的时候，这些Binding允许使用相同的binding key。
binding key 并不是在所有情况下都生效，它依赖于Exchange Type，比如fanout类型的Exchange就会无视binding key，而是将消息路由到所有绑定到该Exchange的Queue。


![AMOP的消息路由](http://o9zpq25pv.bkt.clouddn.com/MQ/MQroute.png)

### 1.5 RabbitMQ 的Exchange Types

RabbitMQ常用的Exchange Type有==fanout==、==direct==、==topic==、==headers==这四种（AMQP规范里还提到两种Exchange Type，分别为system与自定义，这里不予以描述），headers 匹配 AMQP 消息的 header 而不是路由键，此外 headers 交换器和 direct 交换器完全一致，但性能差很多，目前几乎用不到了，所以直接看另外三种类型：

* direct

direct类型的Exchange路由规则也很简单，它会把消息路由到那些binding key与routing key完全匹配的Queue中。

相关代码如下：

```
/** 创建信道 */
id<RMQChannel> ch = [_conn createChannel];
/** 创建交换器，direct方法，这个需要跟后台保持一致，包括交换器的名称，也要跟后台约定好，还有配置选项，是否持久化等 */
RMQExchange *x = [ch  direct:@"Mobile_Alarm" options:(RMQExchangeDeclareNoOptions)];
/** 创建队列，如果不指定队列名称，MQ会默认自动创建一个队列，前缀以 `rmq-objc-client.gen-` 开头 */
RMQQueue *q = [ch queue:@"" options:RMQQueueDeclareExclusive | RMQQueueDeclareAutoDelete];
/** 队列绑定交换器，并指定 rountKey，需要跟后台指定相同的规则，可以是用户ID等 */
[q bind:x routingKey:@"5"];

```

![Exchange Direct类型](http://o9zpq25pv.bkt.clouddn.com/MQ-Direct.png)

* fanout
这种类型的Exchange,就是群发，此exchange的路由规则很简单直接将消息路由到所有绑定的队列中，无须对消息的routingkey进行匹配操作。

![Exchange fanout类型](http://o9zpq25pv.bkt.clouddn.com/MQ%20fanout.png)

```
/**  需要注意：<RMQConnectionDelegate> 如果创建连接，指定代理是 当前class,那么当前class需要遵守连接的代理协议，并实现相关代理方法*/

/** 创建连接 */
RMQConnection *conn = [[RMQConnection alloc] initWithUri:url5 delegate:self];
[conn start];
/** 创建信道 */
id<RMQChannel> ch = [conn createChannel];
/** 创建交换器 */
RMQExchange *x = [ch fanout:@"Alarm"];
RMQQueue *q = [ch queue:@"" options:RMQQueueDeclareExclusive];
/** 绑定交换器 */
[q bind:x];
/** 订阅消息 */
[q subscribe:^(RMQMessage * _Nonnull message) {
NSLog(@"Received %@", [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding]);
}];

///socket 连接失败回调，超时或者地址有误
- (void)connection:(RMQConnection *)connection failedToConnectWithError:(NSError *)error;
/// 没有连接成功回调
- (void)connection:(RMQConnection *)connection disconnectedWithError:(NSError *)error;
/// 自动恢复连接调用
- (void)willStartRecoveryWithConnection:(RMQConnection *)connection;
/// 正在开始恢复连接
- (void)startingRecoveryWithConnection:(RMQConnection *)connection;
/// 已经恢复连接的时候，调用
- (void)recoveredConnection:(RMQConnection *)connection;
/// 连接过程中，信道异常调用
- (void)channel:(id<RMQChannel>)channel error:(NSError *)error;
```

* Topic

前面讲到direct类型的Exchange路由规则是完全匹配binding key与routing key，但这种严格的匹配方式在很多情况下不能满足实际业务需求。topic类型的Exchange在匹配规则上进行了扩展，它与direct类型的Exchage相似，也是将消息路由到binding key与routing key相匹配的Queue中，但这里的匹配规则有些不同，它约定：

> routing key为一个句点号“. ”分隔的字符串（我们将被句点号“. ”分隔开的每一段独立的字符串称为一个单词），如“device.userId”、“alarm.type”，
binding key与routing key一样也是句点号“. ”分隔的字符串
binding key中可以存在两种特殊字符“*”与“#”，用于做模糊匹配，其中“*”用于匹配一个单词，“#”用于匹配多个单词（可以是零个）

```
RMQConnection * connection = [[RMQConnection alloc] initWithUri:url delegate:[RMQConnectionDelegateLogger new]];
[connection start];
id<RMQChannel>channel = [connection createChannel];
RMQExchange * exchange = [channel topic:@"topic_logs" options:RMQExchangeDeclarePassive];
[exchange publish:finalData routingKey:[NSString stringWithFormat:@"device.%@",didStr]];
[connection close];

```

![Topic 类型](http://o9zpq25pv.bkt.clouddn.com/MQ%20topic%20Type.png)

以上图中的配置为例，routingKey=”dev.alarm.device”的消息会同时路由到QA与QB，routingKey=”dev.alarm.type”的消息会路由到QA，routingKey=”lazy.brown.fox”的消息会路由到Q2，routingKey=”water.type.ID”的消息会路由到QB；routingKey=”device.user.water”、routingKey=”alarmtype”的消息将会被丢弃，因为它们没有匹配任何bindingKey。

## 二.RabbitMQ 的集成

### 2.1 客户端集成

[RabbitMQ官方Git仓库](https://github.com/rabbitmq/rabbitmq-objc-client)

* 我用的是CocoaPods集成,在 podfile 中添加：

```
pod 'RMQClient'

```

注意：

RabbitMQ pod 内部有 [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket),如果项目中，已经集成了，需要删除多余的

### 2.2 源代码文件

考虑到客户端架构的特殊性，需要将MQ消息订阅封装成一个工具,并配置为 单例 模式。


>导入头文件  #import <RMQClient.h>


LXCustomRabbitMQManger.h
```
//开始订阅消息
- (void)startScribeMessage;
//关闭连接
- (void)closeConnection;
```
LXCustomRabbitMQManger.m
```
@interface LXCustomRabbitMQManger()<RMQConnectionDelegate>

@property (nonatomic,strong) RMQConnection *conn;
@property (nonatomic,strong) LXCustomAlarmModel *alarmModel;

@end


- (void)startScribeMessage {
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)closeConnection {
if (_conn) {
[self.conn close];
self.conn = nil;
}
}

//创建本地推送
- (void)registerNotification:(NSInteger )alerTime {
kweakSelf;
kStrongSelf;
// 使用 UNUserNotificationCenter 来管理通知
if (@available(iOS 10.0, *)) {
// 使用 UNUserNotificationCenter 来管理通知
UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
//需创建一个包含待通知内容的 UNMutableNotificationContent 对象，注意不是 UNNotificationContent ,此对象为不可变对象。
UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
content.title = [NSString localizedUserNotificationStringForKey:self.alarmModel.alarm_type arguments:nil];
content.body = [NSString localizedUserNotificationStringForKey:self.alarmModel.geography
arguments:nil];
content.sound = [UNNotificationSound defaultSound];

// 在 alertTime 后推送本地推送
UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
triggerWithTimeInterval:alerTime repeats:NO];
UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
content:content trigger:trigger];
//添加推送成功后的处理！
[center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
/*
DQAlertView *reservationAlert = [[DQAlertView alloc] initWithTitle:self.alarmModel.alarm_type
message:self.alarmModel.geography
delegate:self cancelButtonTitle:@"取消"
otherButtonTitles:@"确定"];

reservationAlert.shouldDimBackgroundWhenShowInView = YES;
reservationAlert.shouldDismissOnOutsideTapped = YES;
[reservationAlert show];
[reservationAlert actionWithBlocksCancelButtonHandler:^{


} otherButtonHandler:^{
//跳转
LXDeviceAlarmModel *alarmIDModel = [[LXDeviceAlarmModel alloc] init];
alarmIDModel.ID = strongSelf.alarmModel.ID;
LXDeviceDetailController *deviceDetailVC = [[LXDeviceDetailController alloc] init];
deviceDetailVC.deviceDealType = KearlyNoDealType;
deviceDetailVC.deviceAlarm = alarmIDModel;
[[self getCurrentVC].navigationController pushViewController:deviceDetailVC animated:YES];

}];
*/
UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.alarmModel.alarm_type message:self.alarmModel.geography preferredStyle:UIAlertControllerStyleAlert];
UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
LXDeviceAlarmModel *alarmIDModel = [[LXDeviceAlarmModel alloc] init];
alarmIDModel.ID = strongSelf.alarmModel.ID;
LXDeviceDetailController *deviceDetailVC = [[LXDeviceDetailController alloc] init];
deviceDetailVC.deviceDealType = KearlyNoDealType;
deviceDetailVC.deviceAlarm = alarmIDModel;
[[self getCurrentVC].navigationController pushViewController:deviceDetailVC animated:YES];
}];
[alert addAction:cancelAction];
[alert addAction:confirmAction];
[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];

}];
}
else {
UILocalNotification *notification = [[UILocalNotification alloc] init];
// 设置触发通知的时间
NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
NSLog(@"fireDate=%@",fireDate);

notification.fireDate = fireDate;
// 时区
notification.timeZone = [NSTimeZone defaultTimeZone];
// 设置重复的间隔
notification.repeatInterval = kCFCalendarUnitSecond;

// 通知内容
notification.alertBody =  self.alarmModel.alarm_type;
notification.applicationIconBadgeNumber = 1;
// 通知被触发时播放的声音
notification.soundName = UILocalNotificationDefaultSoundName;
// 通知参数
NSDictionary *userDict = [NSDictionary dictionaryWithObject:self.alarmModel.geography forKey:@"key"];
notification.userInfo = userDict;

// ios8后，需要添加这个注册，才能得到授权
if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
categories:nil];
[[UIApplication sharedApplication] registerUserNotificationSettings:settings];
// 通知重复提示的单位，可以是天、周、月
notification.repeatInterval = NSCalendarUnitDay;
} else {
// 通知重复提示的单位，可以是天、周、月
notification.repeatInterval = NSDayCalendarUnit;
}
// 执行通知注册
[[UIApplication sharedApplication] scheduleLocalNotification:notification];

}

}

- (void)receiveRabbitServicerMessage {

//    NSString *url5 = @"amqp://web_user:123@192.178.0.2:5672/device_log_2";
DebugLog(@"MQ服务器地址:%@",url5);
if (_conn == nil) {
_conn = [[RMQConnection alloc] initWithUri:url5 delegate:self];
}
[_conn start];
id<RMQChannel> ch = [_conn createChannel];
RMQExchange *x = [ch  direct:@"Mobile_Electric_Alarm" options:(RMQExchangeDeclareNoOptions)];
RMQQueue *q = [ch queue:@"" options:RMQQueueDeclareExclusive | RMQQueueDeclareAutoDelete];
[q bind:x routingKey:kUserInfo.company_id];
kweakSelf;
[q subscribe:^(RMQMessage * _Nonnull message) {
id result = [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding];
NSDictionary *dict = [self dictionaryWithJsonString:result];
if ([dict isKindOfClass:[NSDictionary class]]) {
weakSelf.alarmModel = [LXCustomAlarmModel mj_objectWithKeyValues:dict];
[weakSelf registerNotification:1];
}
}];
}

- (void)emitLogDirect:(NSString *)msg severity:(NSString *)severity {
//    NSString *url5 = @"amqp://web_user:123@192.178.0.2:5672/device_log_2";
DebugLog(@"MQ发送服务器地址:%@",url5);
RMQConnection *conn = [[RMQConnection alloc] initWithUri:url5 delegate:self];
self.conn = conn;
[conn start];
id<RMQChannel> ch = [conn createChannel];
RMQExchange *x = [ch  direct:@"Mobile_Electric_Alarm" options:(RMQExchangeDeclareNoOptions)];
RMQQueue *q = [ch queue:@"" options:RMQQueueDeclareExclusive | RMQQueueDeclareAutoDelete];
[q bind:x routingKey:kUserInfo.company_id];
[x publish:[msg dataUsingEncoding:NSUTF8StringEncoding] routingKey:severity];
NSLog(@"Sent '%@'", msg);
[conn close];
}

#pragma mark - 系统的通知监听
- (void)activeNotification:(NSNotification *)notification{
if (_conn == nil) {
//登录成功
if ([[LXUserInfoManger shareLXUserInfoManger].currentUserInfo.is_cloud isEqualToString:@"0"]) {
//MQ推送
[self receiveRabbitServicerMessage];
}
}
}
- (void)backgroundNotification:(NSNotification *)notification{
[self closeConnection];
}

- (void)connection:(RMQConnection *)connection failedToConnectWithError:(NSError *)error {
if (error) {
NSLog(@"%@",error);
NSLog(@"连接超时");
[self closeConnection];

}else{

}
}
- (void)connection:(RMQConnection *)connection disconnectedWithError:(NSError *)error {
if (error) {
NSLog(@"%@",error);
}
else{
NSLog(@"连接成功");
}
}
- (void)willStartRecoveryWithConnection:(RMQConnection *)connection {
DebugLog(@"将要开始恢复链接");
}
- (void)startingRecoveryWithConnection:(RMQConnection *)connection {
DebugLog(@"开始恢复链接");

}

- (void)recoveredConnection:(RMQConnection *)connection {
DebugLog(@"恢复链接");

}
- (void)channel:(id<RMQChannel>)channel error:(NSError *)error {
if (error) {
NSLog(@"%@",error);
[self closeConnection];
}
}

//获取当前屏幕显示的viewcontroller，当接收到推送需要跳转VC
- (UIViewController *)getCurrentVC {
UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC {
UIViewController *currentVC;
if ([rootVC presentedViewController]) {
// 视图是被presented出来的
rootVC = [rootVC presentedViewController];
}
if ([rootVC isKindOfClass:[UITabBarController class]]) {
// 根视图为UITabBarController
currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];

} else if ([rootVC isKindOfClass:[UINavigationController class]]){
// 根视图为UINavigationController
currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];

} else {
// 根视图为非导航类
currentVC = rootVC;
}
return currentVC;
}
//接收到推送，json格式字符串转字典：因为MQ推过来的消息是 String 类型的
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {

if (jsonString == nil) {
return nil;
}
NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
NSError *err;
NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
options:NSJSONReadingMutableContainers
error:&err];
if(err) {
NSLog(@"json解析失败：%@",err);
return nil;
}
return dic;

}
```

### 2.3 本地安装启动MQ服务

如果电脑安装 brew 软件包工具的话，执行并启动

```
brew install rabbitmq

sudo ./rabbitmq-server

```
浏览器访问:localhost:15672,默认账号为:guest 密码: guest


## 三.RabbitMQ 遇到的问题

### 3.1 地址不对，connect fail
> Received connection: <RMQConnection: 0x103fa1fc0> disconnectedWithError: Error Domain=GCDAsyncSocketErrorDomain Code=7 "Socket closed by remote peer" UserInfo={NSLocalizedDescription=Socket closed by remote peer}

解决办法：MQ的鉴权，O-C跟Java的格式不太一样，Java是通过Name,Host,Ip等，iOS的是直接设置地址

> amqps://user:pass@hostname:1234/myvhost

**说明：**

* 协议头：如果是Https的话，协议用：amqps，如果是Http，用amqp
* 用户名：userName
* 用户密码：password
* ip地址：182.142.123等
* port端口：5672
* 虚拟主机：由后台定义，可有可无，根据需求，myloghost


### 3.2 服务端与客户端参数配置有误,消息队列持久化

> Error Domain=com.rabbitmq.rabbitmq-objc-client Code=406 "PRECONDITION_FAILED - inequivalent arg 'durable' for queue 'Mobile_Electric_Alarm' in vhost 'device_log_2': received 'false' but current is 'true'" UserInfo={NSLocalizedDescription=PRECONDITION_FAILED - inequivalent arg 'durable' for queue 'Mobile_Electric_Alarm' in vhost 'device_log_2': received 'false' but current is 'true'}

看3.3解决办法

### 3.3 MQ 找不到对应的队列

> Error Domain=com.rabbitmq.rabbitmq-objc-client Code=404 "NOT_FOUND - no queue 'rmq-objc-client.gen-3B6E0E14-06E6-4AFC-B6E1-42A7F8FCD218-46927-00002C8AE36AB350' in vhost 'device_log_2'" UserInfo={NSLocalizedDescription=NOT_FOUND - no queue 'rmq-objc-client.gen-3B6E0E14-06E6-4AFC-B6E1-42A7F8FCD218-46927-00002C8AE36AB350' in vhost 'device_log_2'}

解决办法：

Exchange 交换器的配置参数，跟后台约定的不一致，有时候后台也不知道自己配置的啥，就需要尝试了；

```
/**

typedef NS_OPTIONS(NSUInteger, RMQExchangeDeclareOptions) {
RMQExchangeDeclareNoOptions  = 0,
/// 被动声明
RMQExchangeDeclarePassive    = 1 << 0,
///交换器持久化
RMQExchangeDeclareDurable    = 1 << 1,
/// 自动销毁交换器，当所有的消息队列都被使用
RMQExchangeDeclareAutoDelete = 1 << 2,
/// 配置的交换器内部构造对应用发布者不可见
RMQExchangeDeclareInternal   = 1 << 3,
/// @brief
RMQExchangeDeclareNoWait     = 1 << 4,
};*/
RMQExchange *x = [ch  direct:@"Mobile_Electric_Alarm" options:(RMQExchangeDeclareNoOptions)];
/** 
* 队列的配置可选参数
* 
typedef NS_OPTIONS(NSUInteger, RMQQueueDeclareOptions) {
RMQQueueDeclareNoOptions  = 0,
/// 被动声明
RMQQueueDeclarePassive    = 1 << 0,
/// 队列持久化
RMQQueueDeclareDurable    = 1 << 1,
/// 只能被当前的连接授权访问
RMQQueueDeclareExclusive  = 1 << 2,
/// 自动删除
RMQQueueDeclareAutoDelete = 1 << 3,
///
RMQQueueDeclareNoWait     = 1 << 4,
};
*/
RMQQueue *q = [ch queue:@"" options:RMQQueueDeclareExclusive | RMQQueueDeclareAutoDelete];


```

如果连接成功后，那么在MQ的管理台，就可以看到当前连接的消费者了

![管理台当前连接消费者](http://o9zpq25pv.bkt.clouddn.com/%E5%9B%BE%E7%89%87.png)

[参考文章]

1> [RabbbitMQ官网](https://www.rabbitmq.com/tutorials/tutorial-one-objectivec.html)

2> [RabbitMQ基础概念详细介绍](http://www.diggerplus.org/archives/3110)

3> [消息队列之 RabbitMQ](https://www.jianshu.com/p/79ca08116d57)

4> [RabbitMQ——第一篇：RabbitMQ介绍](https://www.jianshu.com/p/5c2d8af2c78e)

## 交流讨论

RabbitMQ在iOS中的使用资料很少，如果有问题的话，欢迎留言探讨，也可以加我QQ:1093034974

另外，如果你觉得我的文章对你有一定的帮助，非常感谢能够点赞，谢谢！
