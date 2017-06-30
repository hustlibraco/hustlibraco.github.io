---
title: Kali Linux 2016.1 安装 Chrome
date: 2016-09-18 14:04:39
tags: [Kali, Linux]
categories: [安全, Kali]
---

Kali Linux 2016.1 Rolling Edtion 预装的是iceweasel浏览器，如果要使用chrome需要自己下载安装包并需要额外的设置。<!-- more -->

## 1. 下载地址

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
实测不用翻墙，速度还挺快。

## 2. 安装命令

```bash
dpkg -i google-chrome-stable_current_amd64.deb
```
如果缺少依赖：

```bash
apt-get install -f
```

## 3. 运行设置

安装完chrome之后我们发现并不能正常打开它，需要在`/usr/share/application`里找到chrome的快捷方式，在原先的运行命令添加`--no-sandbox`和`--user-dir-data`。

- `--no-sandbox` 解决点击图片无响应问题
- `--user-dir-data` 解决Chrome不能在root用户下运行的问题

![chrome-setting](/images/chrome-setting.png)
