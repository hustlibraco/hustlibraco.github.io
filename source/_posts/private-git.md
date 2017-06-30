---
title: 搭建使用个人Git服务器
date: 2016-12-16 00:59:43
tags: [Linux, Git]
categories: [开发, Git]
---

一直一来都不用IDE，直接用SFTPDriver把Linux服务器文件直接映射到Windows本次操作。可惜Win10已经用不了SftpDriver，替代品稳定性捉急，因此在Linux上搭建个人Git服务器成为了必然。<!--more-->

## Git服务器搭建

以CentOS7为例，有以下几个步骤。

### 安装git
```bash
sudo yum install git
```

### 创建git用户，创建authorized_keys文件
一定要设置好权限，否则无法起作用或者不安全
```bash
adduser git 
su - git
mkdir .ssh && chmod 700 .ssh
touch .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
```

### 创建一个空仓库
```
cd /home/git
git init --bare sample.git
```

### 禁止git用户登录服务器
```bash
# 修改 /bin/bash 为 git-shell
vim /etc/passwd
git:x:1001:1002::/home/git:/usr/bin/git-shell
```

### 退出git用户


## TortoiseGit客户端使用

### 使用Puttygen生成密钥对
![select-tag](/images/private-git-1.png)
公钥复制粘贴到服务器的`/home/git/.ssh/authorized_keys`文件中。
私钥保存在本地。
> TortoiseGit默认不是OpenSSH

### 克隆仓库
右键 git clone，加载Putty密钥选择刚刚生成的私钥。
![select-tag](/images/private-git-2.png)


## 错误帮助

### 如果提示网络无法链接，那么服务器的ssh端口很可能不是22！
如果服务器ssh端口不是22，则要求如下格式：
> ssh://git@115.28.137.182:23456/home/git/sample.git

- `ssh://` 前缀必不可少
- ip和端口之间一个冒号，端口和项目地址没有冒号！

### 如果要求你输入git的密码，那么很有可能authorized_keys有问题
- 格式错误
- 权限不对

具体可以在 **systemctl status sshd** 里看到错误日志！
