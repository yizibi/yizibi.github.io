---
layout:     post
title:    "iOS Websocket使用指南"
subtitle:   "Websocket初见"
date: 2019-04-25 10:01:24.000000000 +09:00
author:     "一之笔"
header-img: "img/post-bg-nextgen-web-pwa.jpg"
catalog:    true
tags:
- iOS技术
- TCP/IP
---

文章原创如需转载，请注明出处"本文首发于[一之笔](https://yizibi.github.io/)";


<a name="9k3zok"></a>
## 背景介绍
在消控项目中,实时监测,电气监管未来可能会根据业务,实行主动推送数据,APP接收到WSS的推送数据,实时更新页面;
<a name="2dphph"></a>
## 框架介绍
<a name="0f1nsy"></a>
### [facebook](https://github.com/facebook)/[SocketRocket](https://github.com/facebook/SocketRocket)
Facebook开源的可用于iOS,Mac Os系统的socket库<br />支持自动管理socket的生命周期;<br />支持HTTP,HTTPS;<br />发送 ping,响应 pong 事件;
<a name="5d12um"></a>
## 如何使用
* 需要跟服务端约定心跳,并且约定发送的数据,即需要每隔几秒告诉服务端,客户端在线,并且有新的数据推给客户端;

* 销毁心跳,当页面销毁后,销毁心跳,断开Websocket;

`tips`如果数据量过大,可以采用 Zip 压缩数据;
<a name="dl38ox"></a>
## Pod导入
> 

```powershell
pod 'SocketRocket'
```

<a name="17lgsk"></a>
## 关键代码
```objectivec
<SRWebSocketDelegate>//遵循协议
{
NSTimer * heartBeat;//心跳包
}
@property (nonatomic,strong) SRWebSocket *socket;//socket

#pragma mark - Socket
- (void)setUpMarkertSocket {
self.socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"wss://api.test.com/ws"]]];
NSLog(@"请求的websocket地址：%@",self.socket.url.absoluteString);
self.socket.delegate = self;
[self.socket open];
}
#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
if (webSocket == self.socket) {
//接收到推送的新数据message,可以是json,可以是data等
}
}
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
NSLog(@"socket连接成功");
[self initHeartBeat];//初始化心跳
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
NSLog(@"socket连接失败:%@",error);
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
NSLog(@"socket连接关闭:%@",reason);
}
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
NSData * jsonData = [LFCGzipUtility ungzipData:pongPayload];
id resObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
NSLog(@"socket连接接收pong:%@",resObj);
}
- (void)checkHeartWithPongData:(NSMutableDictionary *)pongData {
[self sendScoketParams:pongData];
}
- (void)sendRequestParams {
//发送心跳 和后台可以约定发送什么内容  一般可以调用ping  我这里根据后台的要求 发送了data给他
//在成功后需要做的操作。。。
NSMutableDictionary* param = @{
@"sub":[NSString stringWithFormat: @"test"],//
@"id": @"id10" //行情
}.mutableCopy;
[self sendScoketParams:param];
}
- (void)sendScoketParams:(NSMutableDictionary *)param {
NSString* dataStr = [ToolUtil dictionaryConvertToJsonData:param];
@weakify(self);
dispatch_queue_t queue =  dispatch_queue_create("zy", NULL);
dispatch_async(queue, ^{
@strongify(self);
if (self.socket != nil) {
// 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
if (self.socket.readyState == SR_OPEN) {
[self.socket send:dataStr];    // 发送数据
} else if (self.socket.readyState == SR_CONNECTING) {
NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
// 每隔2秒检测一次 socket.readyState 状态，检测 10 次左右
// 只要有一次状态是 SR_OPEN 的就调用 [ws.socket send:data] 发送数据
// 如果 10 次都还是没连上的，那这个发送请求就丢失了，这种情况是服务器的问题了，小概率的
// 代码有点长，我就写个逻辑在这里好了
// [self reConnect];
} else if (self.socket.readyState == SR_CLOSING || self.socket.readyState == SR_CLOSED) {
// websocket 断开了，调用 reConnect 方法重连
NSLog(@"重连");
[self setUpMarkertSocket];
}
} else {
NSLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
NSLog(@"其实最好是发送前判断一下网络状态比较好，我写的有点晦涩，socket==nil来表示断网");
}
});
}
```
<a name="k0fysa"></a>
## 心跳管理
```objectivec
//初始化心跳
- (void)initHeartBeat {
dispatch_main_async_safe(^{
[self destoryHeartBeat];
[self sendRequestParams];
//心跳设置为3分钟，NAT超时一般为5分钟
heartBeat = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(sendRequestParams) userInfo:nil repeats:YES];
//和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
[[NSRunLoop currentRunLoop] addTimer:heartBeat forMode:NSRunLoopCommonModes];
})
}
//取消心跳
- (void)destoryHeartBeat {
dispatch_main_async_safe(^{
if (heartBeat) {
if ([heartBeat respondsToSelector:@selector(isValid)]){
if ([heartBeat isValid]){
[heartBeat invalidate];
heartBeat = nil;
}
}
}
})
}
```
使用遇到问题,欢迎留言讨论;
