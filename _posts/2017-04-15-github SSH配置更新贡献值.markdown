---
layout: post
title: github SSH配置更新贡献值
date: 2017-04-15 15:32:24.000000000 +09:00
tag: iOS技术
---


引言

> 一段时间,我发现,GitHub上提交的贡献值没有记录了,没错,就是下图的这个图,官网用户记录个人对开源的贡献值:

![](http://upload-images.jianshu.io/upload_images/1360502-0b80fb6605c84895.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

原来是,更换电脑后,即便是用原来的账号配置,虽然可以提交代码,但是却没有记录;

## GitHub:Mac终端配置

### 查看并生成key

1.查看当前设备是否存在已经生成的公钥;
> ls -al ~/.ssh  

2.生成对应的RSA公钥和私钥;

> ssh-keygen -t rsa -b 4096 -C "你的邮箱"


**[备注:]**

如果生成成功的话,会看到,如下图案:


```
+---[RSA 4096]----+
|     ..          |
|     oo    .   o |
|   .oo .o o   + .|
|    o. o.o + . +o|
|      o.S o + ooE|
|       ..+ . o.+*|
|       .o.o . *.+|
|      o+* oo . = |
|     o.oo*..... .|
+----[SHA256]-----+

```


3.copy当前生成的公钥;

> pbcopy < ~/.ssh/id_rsa.pub 



#### 温馨提示:

copy当前生成的公钥,也可以进入到对应的文件夹下

默认路径为:

> /Users/你的电脑用户名/.ssh 

会看到两个文件:打开并复制.pub的文件所有内容;

![](http://upload-images.jianshu.io/upload_images/1360502-0f5c3c6c167d1194.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


此外,一般情况下,电脑默认系统的一些文件是隐藏的,我们需要通过命令行显示隐藏文件,如果执行命令后,没有显示隐藏的文件,重启电脑试试:

- 显示：

```
defaults write com.apple.finder AppleShowAllFiles -bool true

```
- 隐藏：


```
defaults write com.apple.finder AppleShowAllFiles -bool false 
```


### 添加之前生成的key

![](http://upload-images.jianshu.io/upload_images/1360502-dcedea3cb4c493c8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
