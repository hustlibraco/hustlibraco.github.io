---
title: Burpsuite初探
date: 2016-08-05 16:52:04
tags: [Burpsuite, Web安全, 渗透测试]
---

## 简介

Burp Suite是响当当的web应用程序渗透测试集成平台。从应用程序攻击表面的最初映射和分析，到寻找和利用安全漏洞等过程，所有工具为支持整体测试程序而无缝地在一起工作。
<!-- more -->

## 安装

版本：Burp suite pro v1.6.34（破解版本）
下载地址：[http://download.csdn.net/download/luckchoudog/9451559](http://download.csdn.net/download/luckchoudog/9451559)
安装JDK:

- [百度下载](https://www.baidu.com/link?url=mbk3bkGorHt1Q21233i1-7PFkVyPYx_C17XzCf2Ussr1p7M-05bC4rNpOrK6vZwuJj4rywaUYTCDJiuUvIOnbvSdA_6sYILjE-Lo7o2auSi&wd=&eqid=881f494f000c50500000000557a45eb9)
- [官方下载](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

## 启动

解压`Burp suite pro v1.6.34.rar`，执行`BurpLoader.jar`即可。

![burpsuite1](/images/burpsuite1.png)

## HTTPS代理抓包设置

1.访问代理服务器WEB界面`http://127.0.0.1:8080`，如果访问不了，更改为下图设置中的地址：

![burpsuite2](/images/burpsuite2.png)

2.下载证书

![burpsuite3](/images/burpsuite3.png)

3.双击文件安装到 **受信任的根证书颁发机构**

![burpsuite4](/images/burpsuite4.png)

4.导出为`cer`格式证书

![burpsuite5](/images/burpsuite5.png)

5.安装`cer`证书到 **受信任的根证书颁发机构**

同步骤3

## HTTPS代理抓包效果

![burpsuite6](/images/burpsuite6.png)

如果代理失败，可能是Burpsuite版本太低，ssl默认为RC4算法，百度https不支持。


Burpsuite的功能非常强大，以后慢慢学习。






