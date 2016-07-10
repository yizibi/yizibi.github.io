---
layout: post
title: AFNetworking报错:(415...)
date: 2016-05-16 15:32:24.000000000 +09:00
---

#### question

> [摘要] 最近在使用AFNetworking的时候,遇到如下报错:AFNetworking报错:(415 Domain=com.alamofire.error.serialization.response Code=-1011 "Request failed: unsupported media type (415)")

报错具体如下:

```
Error Domain=com.alamofire.error.serialization.response Code=-1011 "Request failed: unsupported media type (415)" UserInfo={com.alamofire.serialization.response.error.response=<NSHTTPURLResponse: 0x7f84d1409fa0> { URL: http://api.mutualtalk.net/api/common/123456 } { status code: 415, headers {

    "Content-Language" = en;

    "Content-Length" = 1048;

    "Content-Type" = "text/html;charset=utf-8";

    Date = "Tue, 05 Jul 2016 00:24:35 GMT";

    Server = "nginx/1.10.1";

} },--------一些二进制数据,此处省略n行字,

NSLocalizedDescription=Request failed: unsupported media type (415)

```
#### ?为什么会出现这种报错呢?
关于网络请求的接口,通常的做法是,利用第三方AFNetworking,这个强大的网络请求库,再此基础上,将项目中每个模块所用到的接口,进行一次简单的封装,这样,每个模块中的接口都是一类,便于调用,管理,维护...

先说一下我的做法,由于之前后台是php写的,但是我们的后台是java写的,都是搞server的,但是我不知道两个语言对数据格式的处理,有什么特殊的处理,反正套用之前的处理,报错,跟后台联调,后台根本接收不到请求,然后直接就报错,见这阵势,立马度娘神马,谷歌神马?stockoverflow什么的,各种答案,试了半天,然并卵,

以下为尝试的解决方法:
	
> 1>修改AFNetworking内部,这个文件AFURLResponseSerialization.m中修改代码就能解决：第223行,初始化时,将如下代码:

	```
	 self.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil nil]; 
	修改为:
     self.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil nil];  
	```
	
 结果,运行,然并卵,我不否认,可能可以解决某些人遇到的问题,说是AFNetworking不支持以"text/html"格式的"content-type",反正我是添加了,没啥用;
 
 > 2> 在创建请求管理者(manger)是,做一些设置,其实本质上同第一种的解决方法是一样的,给AFNetworking添加一种支持的"text/html"格式,没什么用,还是报错,要不报400错;
 
  ```
  1.创建一个请求管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
      //初始化响应者
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
     //添加一种支持的类型
   manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json", nil];
    //2.发送请求
    NSDictionary *dict = @{
                           @"mobile":@"1111111",
                           @"type":@5,
                           @"Code":@"86",
                           @"key":@"eeqwerqwerqwerqwerqwe3af"
                   };
    NSString *url = @"http://api/asdfasd.com/334234";
     url = [url stringByRemovingPercentEncoding];  
    [manager POST:url parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {  
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"%@",error);
        }
    }];
    
 ```
 > 3>为了解决这个问题,单开一个项目,专门解决这个报错,由于java后台支持json数据格式传输,支持"application/json"格式的"content-type",后来在对请求数据格式和响应数据格式初始化的时候,将之前的父类换成了它的子类(AFJSONRequestSerializer);x-code7.3不提示(AFJSONRequestSerializer这个类),只有copy了,如下:
 
 ```
 
 //初始化响应者
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
      manager.requestSerializer = [AFJSONRequestSerializer serializer];
      manager.responseSerializer = [AFJSONResponseSerializer serializer];

/***************    请忽略我---  *****************/
/**
 `AFJSONRequestSerializer` is a subclass of `AFHTTPRequestSerializer` that encodes parameters as JSON using `NSJSONSerialization`, setting the `Content-Type` of the encoded request to `application/json`.
 */
@interface AFJSONRequestSerializer : AFHTTPRequestSerializer
备注:
AFJSONRequestSerializer 继承自AFHTTPRequestSerializer,不过参数的编码形式,进行了设置,也就是设置 `Content-Type` 为 `application/json`,具体调到头文件,就是如下:
+ (instancetype)serializer {
    return [self serializerWithWritingOptions:(NSJSONWritingOptions)0];
}

+ (instancetype)serializerWithWritingOptions:(NSJSONWritingOptions)writingOptions
{
    AFJSONRequestSerializer *serializer = [[self alloc] init];
    serializer.writingOptions = writingOptions;

    return serializer;
}

```
> 至此,问题终于解决,到此,也只能怪自己学艺不精,吃一堑,长一智,慢慢积累吧,写给自己吧~~~
	
