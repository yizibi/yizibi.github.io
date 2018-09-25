---
layout:     post
title:    "Mac APP数据抓包神器 Charles 破解版及使用"
subtitle:   "Charles如何用"
date:  2018-06-10 15:32:24.000000000 +09:00
author:     "一之笔"
header-img: "img/home-bg-o.jpg"
tags:
- 工具
---


![](http://o9zpq25pv.bkt.clouddn.com/lucyBlog/charlesicon@2x.png)

[Charles官网](https://www.charlesproxy.com/)

`备注`:如果不差钱,直接[官网购买](https://www.charlesproxy.com/buy/),一个授权码 30 刀;当然也可以试用版 30 天;

### 一.环境配置

#### 1.1 软件破解版下载

[点我下载](http://xclient.info/s/charles.html?t=a5394ba268ffbedd3c9bb0d9446eb6226ee067a6)

如果点开失败,也可以打开[这个网址](http://xclient.info/),直接搜索破解版即可;里面有详细的破解教程,并且会更新

步骤:
* 将 Charles.app 拖至 应用程序 文件夹
* 复制 charles.jar 至 /Applications/Charles.app/Contents/Java/

#### 1.2 软件激活

打开软件,点击菜单栏 -> help -> Register 打开弹窗,填写信息激活;

直接用以下账号注册激活:

* Registered Name: `https://zhile.io`

* License Key: `48891cf209c6d32bf4`


### 二.使用方法

#### 2.0 准备工作

* 首先,电脑安装 `SSL` 证书

看大图如下:
![安装rootSSL证书](http://o9zpq25pv.bkt.clouddn.com/lucyBlog/charlesSSLRoot.png)

`需要注意`:Mac 默认安装外来的证书是不被信任的,需要完全信任;
* 证书信任

打开钥匙串,找到刚才下载的证书,然后点开,找到信任,修改成 完全信任,如下:
![SSL证书信任设置](http://o9zpq25pv.bkt.clouddn.com/lucyBlog/charlesSSKxinren@2x.png)

至此,基本的软件环境设置完成;

`注意`: 不管是 http 还是 https 都需要配置手机代理,需要保证手机跟电脑连接的是 `同一个` WIFI

#### 2.1 http 抓包

http抓包比较简单,电脑设置好之后,配置手机代理,点开 WIFI 名称,打开WIFI详情,点击 配置代理,选择 手动,设置 服务器 跟 端口,设置好之后,电脑会弹窗,是否允许电脑作为手机http代理,选择 yes即可,不要手快,点击了 deny 了,说了这么多,其实就是下面一个图:

![配置代理](http://o9zpq25pv.bkt.clouddn.com/lucyBlog/charlesdelegateSeting.PNG)

不出意外的话,就可以看到请求的数据了

![](http://o9zpq25pv.bkt.clouddn.com/lucyBlog/charlesResult.png)


#### 2.2 https 抓包

* 手机安装 SSL 证书,打开 safari 浏览器,输入 Charles 软件获取到的地址,按照要求一路 next 操作;

![](http://o9zpq25pv.bkt.clouddn.com/lucyBlog/charleshttpsIphoneSSL.png)

信任证书即可操作;

* 设置软件SSL 端口跟域名白名单

![](http://o9zpq25pv.bkt.clouddn.com/lucyBlog/charlesSetingSSL.png)

### 三.可能遇到的问题

#### 中文乱码

* 解决

应用程序->Charles->显示包内容->info.plis如下:
在VMOptions中加一项：`-Dfile.encoding=UTF-8`
如下图:
![中文乱码设置](http://o9zpq25pv.bkt.clouddn.com/lucyBlog/charleszhongwenluanma.png)


#### https 手机端证书安装了,也信任了,还是无法查看信息

* 解决,iOS 10 +,没有彻底信任证书

需要在一下路径中信任证书

设置→通用→关于本机→证书信任设置,里面启用完全信任Charles证书
