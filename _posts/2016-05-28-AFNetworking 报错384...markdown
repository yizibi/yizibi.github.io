---
layout:     post
title:    "AFNetworking 报错3840..."
subtitle:   "AFN Error"
date: 2016-05-25 15:32:24.000000000 +09:00
author:     "一之笔"
header-img: "img/home-bg-o.jpg"
tags:
- iOS问题
- iOS技术
---

> 之前写过一篇文章,关于AFNetworking 报错415的,最近,又有3840错,整天都被一些莫名其妙的错误纠缠,吃一堑,长一智,废话不多说了,这个3840的错,网上搜了好久,试了好久,终于解决了.

## 报错具体如下


```
Error Domain=NSCocoaErrorDomain Code=3840 "The operation couldn’t be completed. (Cocoa error 3840.)" (JSON text did not start with array or object and option to allow fragments not set.) UserInfo=0x15d7bdd0 {NSDebugDescription=JSON text did not start with array or object and option to allow fragments not set.}

```

* 首先,这个错误是怎么产生的,

我按照之前封装的AFNetworking发送post请求,然后报错了,错误是 AFNetworking 不支持一种类型:`content-type`=`text/plain`;
这种错误好解决,有了之前的文章,这个很快搞定,在AFNetworking中的这个子类`AFURLResponseSerialization.m`文件中,226行,添加不支持的类型即可,详情参考` AFNetworking报错:(415...)`

* 我网络请求是这么写的:

```

SString *url                = @"http://muyan.tunnel.qydev.com/aliPay/getSignDate";
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    AFSecurityPolicy *policy     = [[AFSecurityPolicy alloc] init];
    [policy setAllowInvalidCertificates:YES];
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    [manger setSecurityPolicy:policy];
    manger.requestSerializer = [AFJSONRequestSerializer serializer];
    manger.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *dict = @{
                           @"subject":@"你是大牛",
                           @"total_fee":@0.02,
                           @"body":@"哈哈哈哈哈"
                           };
    [manger POST:url parameters:dict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        LXLog(@"请求成功");
        LXLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        LXLog(@"%@",error);
    }];
    

```

好了,这个解决了,然后又出现了一个难缠的问题,3840,没事,好了,翻墙google,终于找到了问题的答案,其实就是替换掉`manger`的响应序列化设置:

```
manger.responseSerializer=[AFHTTPResponseSerializer serializer];

```

这个就有意思了,请求的时候是`AFJSONRequestSerializer`,然后响应的时候,变成它的父类`AFHTTPResponseSerializer`,问题解决,但是,这样的话,返回来的数据,就是一串数字,NSdate,直接转json或者string,都可以,这个更深一层的意义,有待探索.......

