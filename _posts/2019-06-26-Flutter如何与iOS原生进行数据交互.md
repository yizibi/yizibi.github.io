---
layout:     post
title:    "Flutter如何与iOS原生进行数据交互"
subtitle:   "优雅的交互,Flutter"
date: 2019-06-26 08:32:24.000000000 +09:00
author:     "一之笔"
header-img: "img/post_flutter_0511.jpg"
header-mask: 0.3
catalog:    true
tags:
- 大前端
- Flutter
- 跨平台
---

文章首发整理个人博客,转载参考注明来源[一之笔](https://yizibi.github.io/);

![](http://yizhibi.6chemical.com/lucyBlog/Flutter%E4%BA%A4%E4%BA%92.png)

上节主要整理了→[如何用Pod集成Flutter](https://yizibi.github.io/2019/05/10/%E5%A6%82%E4%BD%95%E7%94%A8Pod%E9%9B%86%E6%88%90Flutter/)，真是很方便；本节内容是上节内容的补充；

关于如何与Flutter进行数据交互，且往下看：

## 要求：

* Flutter环境OK；
* Flutter模块已经开发好

## 交互前的改造

### AppDelegate 改造

> 导入头文件 #import <Flutter/Flutter.h>

改造 .h 文件，直接继承 FlutterAppDelegate 即可

```Java

@interface AppDelegate : FlutterAppDelegate


@end

```

.m 暂时不需要改动，也有的修改调用 super 的，FlutterAppDelegate 其实就是继承自 UIResponder 的；

## iOS 跟 Flutter 数据交互

可以这么想，Flutter就是一个容器，在这个容器里，可以有多个不同的View,每次切换，底层引擎绘制当前需要显示的内容；

不像原生，A push B，需要两个不同的VC，在Flutter只有一个，哪怕你整个模块都是Flutter，也只有一个VC，这个VC在Flutter里面叫做 “==FlutterViewController==”；如果你想从原生进入Flutter，就创建==FlutterViewController==就可以，而创建==FlutterViewController==，跟我们原生的VC是一样的，直接 [alloc init],就行；跳转到FlutterVC的哪个页面，这个是路由决定的；

### 路由Route

我们可以通过设置 Route,来跳转不同的FLutter业务VC；像下面的示例的代码，很简单；

```Object-C
FlutterViewController *flutterVC = [[FlutterViewController alloc] init];
//设置路由
[flutterVC setInitialRoute:@"my_friends"];
//push 或者 present
[self.navigationController presentViewController:flutterVC animated:YES completion:nil];
```

那如何给Flutter传参数，或者处理Flutter给我们的响应，比如，在Flutter中，网络接口返回 session 失效，会话过期，需要弹窗，返回登录页面；

这个FLutter提供了，==FlutterMethodChannel== 这个类，用于数据交互

### MethodChannel

FlutterMethodChannel，这个类主要负责Flutter要啥数据，或者以什么样的数据格式给他，都是这个类负责的，而在Flutter内部就需要定义好需要的格式；

```Object-C
FlutterMethodChannel *methodChannel = [FlutterMethodChannel methodChannelWithName:@"methodName" binaryMessenger:messenger];
[methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
if ([call.method isEqualToString:@"userId"]) {
NSString *userId = kUserInfo.user.userId;
result(userId);
}
}];
```

来看上面这个示例:

第一行初始化一个方法信道，这个方法由 Flutter定义好，可以这么 理解，就是方法的集合，为什么是个集合？

因为在它的回调中，还有一个 FlutterMethodCall，这里面是具体的方法名跟参数；

第一行的代码的第二个参数，本质是一个代理，遵循FlutterBinaryMessenger协议的对象就可以，而FlutterViewController刚好就遵循了这个协议，参数就传 FlutterViewController 对象；

### FlutterMethodCall 与 FlutterResult

第二行代码：

> - (void)setMethodCallHandler:(FlutterMethodCallHandler _Nullable)handler;

这个很熟悉吧，是一个Block的回调，而这个Block里面，除了FlutterMethodCall，还有一个FlutterResult，这个也是个BLock，并且接收 id 类型的参数，这两个很重要，基本就是 FlutterVC 跟原生交互的主角了；

需要注意的是，每次result回调只能使用一次；

这个两者数据交互，可以自行封装下，统一调用，以下是我封装的一个示例：

```Object-C
- (void)flutterChennelMethodWithName:(NSString *)methodName binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
FlutterMethodChannel *methodChannel = [FlutterMethodChannel methodChannelWithName:methodName binaryMessenger:messenger];
[methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
if ([call.method isEqualToString:@"userId"]) {
NSString *userId = kUserInfo.user.userId;
result(userId);
}
if ([call.method isEqualToString:@"cookie"]) {
NSString *cookie = [kUserDefault objectForKey:@"Cookie"];
result(cookie);
}
if ([call.method isEqualToString:@"exit"]) {
[self pressLogoutButton];
}
CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
// method和WKWebView里面JS交互很像
if ([call.method isEqualToString:@"checkReadContactPermission"]) {
//获取通讯录权限
if (status == CNAuthorizationStatusNotDetermined) {
CNContactStore *store = [CNContactStore new];
[store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
if (granted)
{
NSNumber *number = [NSNumber numberWithBool:YES];
result(number);
}
else
{
NSNumber *number = [NSNumber numberWithBool:NO];
result(number);
}
}];
}
else {
NSNumber *number = [NSNumber numberWithBool:NO];
result(number);
}
}
if ([call.method isEqualToString:@"getReadContactPermission"]) {
//获取通讯录权限
if (status != CNAuthorizationStatusAuthorized) {
NSNumber *number = [NSNumber numberWithBool:NO];
result(number);
}
else {
NSNumber *number = [NSNumber numberWithBool:YES];
result(number);
}
}
// iOS传参给flutter
if ([call.method isEqualToString:@"getContactList"]) {
[[LJContactManager sharedInstance] accessSectionContactsComplection:^(BOOL succeed, NSArray<LJSectionPerson *> *contacts, NSArray<NSString *> *keys) {
NSMutableArray *contactArray = [NSMutableArray array];
for (LJSectionPerson *sectionPerson in contacts) {
for (LJPerson *person in sectionPerson.persons) {
NSString *fullString = [NSString stringWithFormat:@"%@/",person.fullName];
for (int i = 0; i < person.phones.count; i++) {
LJPhone *phone = person.phones[i];
fullString = [fullString stringByAppendingFormat:@"%@/%@/",phone.label,phone.phone];
}
NSLog(@"拼接后的字符串:%@",fullString);
fullString = [fullString substringToIndex:fullString.length-1];
[contactArray addObject:fullString];
}
}
result(contactArray);
}];
}
}];
}


```

