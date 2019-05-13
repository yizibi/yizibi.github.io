---
layout:     post
title:    "如何用Pod集成Flutter"
subtitle:   "放弃用手动集成Flutter吧,太不方便了"
date: 2019-05-11 08:32:24.000000000 +09:00
author:     "一之笔"
header-img: "img/post_flutter_0511.jpg"
header-mask: 0.3
catalog:    true
tags:
- 大前端
- Flutter
- 跨平台
---

![](http://yizhibi.6chemical.com/1557401382.png?imageMogr2/thumbnail/!70p)

要求：
1. Macos 已经配置好flutter开发环境；
2. 支持Cocopods

可用如下命令查看Flutter是否配置成功

> flutter doctor -v

如果终端打印如下，基本就OK了,Android的环境不用管，iOS可以就行；

```Java

[✓] Flutter (Channel stable, v1.2.1, on Mac OS X 10.13.6 17G65, locale
zh-Hans-CN)
• Flutter version 1.2.1 at /Users/lucy/development/flutter
• Framework revision 8661d8aecd (3 months ago), 2019-02-14 19:19:53 -0800
• Engine revision 3757390fa4
• Dart version 2.1.2 (build 2.1.2-dev.0.0 0a7dcf17eb)

[✗] Android toolchain - develop for Android devices
✗ Unable to locate Android SDK.
Install Android Studio from:
https://developer.android.com/studio/index.html
On first launch it will assist you in installing the Android SDK
components.
(or visit https://flutter.io/setup/#android-setup for detailed
instructions).
If Android SDK has been installed to a custom location, set ANDROID_HOME
to that location.
You may also want to add it to your PATH environment variable.


[✓] iOS toolchain - develop for iOS devices (Xcode 10.1)
• Xcode at /Applications/Xcode.app/Contents/Developer
• Xcode 10.1, Build version 10B61
• ios-deploy 1.9.4
• CocoaPods version 1.5.3

[!] Android Studio (not installed)
• Android Studio not found; download from
https://developer.android.com/studio/index.html
(or visit https://flutter.io/setup/#android-setup for detailed
instructions).

[✓] VS Code (version 1.33.1)
• VS Code at /Applications/Visual Studio Code.app/Contents
• Flutter extension version 3.0.0

[!] Connected device
! No devices available

! Doctor found issues in 3 categories.

```

## 问题

很久之前，也不能说很久，大概2个月前吧，公司决定未来要迁移到跨平台开发中，需要拿APP部分功能做一个尝试，看实际效果，然后我就看了下Flutter，按照[Flutter中文网](https://flutterchina.club/setup-macos/)配置了开发环境，并且编译了一个 Hello Word 示例程序，成功运行；

项目组专门有一个同学负责写Flutter功能模块，我只需要集成并且跟Flutter数据交互，完成业务即可；

问题就出在这儿，我把Flutter模块更换成公司私有仓库时，更新代码，执行编译打包，发现Xcode编译通过，但是，Flutter无法渲染界面；我就很崩溃；重新查了下资料，发现网上用Pod集成Flutte的资料很少，很多的是，手动集成；


## 手动集成

手动集成，真是太不方便了，可以看看这个文章:[iOS老项目集成Flutter（iOS混编Flutter)](https://www.jianshu.com/p/eee692736632),t太繁琐了，各种配置，如果你喜欢手动的话，就看那个文章就可以；

现在项目基本都是模块化，Flutter基本也是以Framework的形式引入在项目中，如果Flutter模块更新后，我们只需要执行 pod 更新一下，就可以了，真是太方便了；

## Pod集成

* 在 Podfile 中，引入 Flutter 模块，具体就是下面两行代码

```Java

## Flutter 模块的路径
flutter_application_path = '/Users/ly/Desktop/所有/项目/APP/fighting_flutter_common_user'
eval(File.read(File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')),    binding)

```

加完后，你的Podfile大概就是下面这个样子的：

```Java
target 'fireCommonUser' do
# Uncomment this line if you're using Swift or would like to use dynamic frameworks
# use_frameworks!
# Pods for FireControl
pod 'AFNetworking'
pod 'AMapLocation'
pod 'AMap2DMap'
pod 'AMapSearch'
pod 'MQTTClient'

## Flutter 模块的路径
flutter_application_path = '/Users/ly/Desktop/所有/项目/APP/fighting_flutter_common_user'
eval(File.read(File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')),    binding)

target 'fireCommonUserTests' do
inherit! :search_paths
# Pods for testing
end

target 'fireCommonUserUITests' do
inherit! :search_paths
# Pods for testing
end

end

```
* 可用如下命令更新Pod，会自动生成 flutter.framework

> pod update --verbose --no-repo-update


* 增加编译选项

打开iOS项目，选中项目的**Build Phases**选项，点击左上角**+**号按钮,选择**New Run Script Phase**,将下面的shell脚本添加到输入框中：


```Java
"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" build
"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" embed
```

具体如下：

![](http://yizhibi.6chemical.com/1557403488.png?imageMogr2/thumbnail/!70p)


## 结束

Pod集成到这里就结束了，真的很方便，Flutter 功能更新后，我这边就一个 Pod update 就好了；

如果需在项目中调用Flutter模块，并且跟Flutter进行数据交互，比如，
* Flutter怎么获取通讯录权限；
* 获取到的通讯录以什么样的格式传递呢

后面会专门整理一片文章介绍；

最后有问题欢迎大家留言讨论；


相关文章：

[添加Flutter到现有iOS的项目](http://tryenough.com/flutter03)
