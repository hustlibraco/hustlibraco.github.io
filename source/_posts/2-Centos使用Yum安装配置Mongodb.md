---
title: Centos使用Yum安装配置Mongodb
date: 2015-12-03 20:46:31
tags: [Linux, Mongodb]
---

## 安装Mongodb
使用Yum，我们可以很方便的安装Mongodb:

```bash
yum install mongodb mongodb-server
```
<!-- more -->

yum会自动帮我们生成Mongodb的配置文件，其中最主要的配置文件/etc/mongod.conf部分内容如下：

```bash
# Comma separated list of ip addresses to listen on (all local ips by default)
bind_ip = 127.0.0.1

# Specify port number (27017 by default)
#port = 27017

# Fork server process (false by default)
fork = true

# Full path to pidfile (if not set, no pidfile is created)
pidfilepath = /var/run/mongodb/mongod.pid

# Log file to send write to instead of stdout - has to be a file, not directory
logpath = /var/log/mongodb/mongod.log

# Alternative directory for UNIX domain sockets (defaults to /tmp)
unixSocketPrefix = /var/run/mongodb

# Directory for datafiles (defaults to /data/db/)
dbpath = /var/lib/mongodb

# Enable/Disable journaling (journaling is on by default for 64 bit)
#journal = true
#nojournal = true
```

默认配置指定了IP、端口、数据文件、日志文件等等，十分详尽，可以根据自己的实际情况进行修改，一般用默认的就行了。

## 配置开机自启动

打开/etc/rc.d/rc.local文件，追加/usr/bin/mongod --config /etc/mongod.conf至行尾，保存即可。

## 尝试启动

```bash
service mongod start
```

结果失败了，提示我使用指令systemctl status mongodb查看原因，指令输出类似这样:

```bash
mongodb.service - High-performance, schema-free document-oriented database
        Loaded: loaded (/usr/lib/systemd/system/mongodb.service; enabled)
        Active: failed (Result: exit-code) since Mi 2013-04-03 15:48:01 EEST; 3min 13s ago
        Process: 1756 ExecStart=/usr/bin/mongod --quiet --config /etc/mongodb.conf (code=exited, status=14)

apr 03 15:48:01 echelon mongod[1756]: /usr/lib/libstdc++.so.6(_ZNSt6localeC1EPKc+0x71b) [0x7f60471c952b]
apr 03 15:48:01 echelon mongod[1756]: /usr/lib/libboost_filesystem.so.1.53.0(_ZN5boost10filesystem4path7codecvtEv+0x4f) [0x7f6047adfb6f]
apr 03 15:48:01 echelon mongod[1756]: /usr/lib/libboost_filesystem.so.1.53.0(_ZNK5boost10filesystem4path14root_directoryEv+0x114) [0x7f6047ae1344]
apr 03 15:48:01 echelon mongod[1756]: /usr/lib/libboost_filesystem.so.1.53.0(_ZN5boost10filesystem8absoluteERKNS0_4pathES3_+0x3e) [0x7f6047add16e]
apr 03 15:48:01 echelon mongod[1756]: /usr/bin/mongod(_ZN5mongo27initializeServerGlobalStateEb+0xf3) [0x94fc73]
apr 03 15:48:01 echelon mongod[1756]: /usr/bin/mongod(main+0x234) [0x7591f4]
apr 03 15:48:01 echelon mongod[1756]: /usr/lib/libc.so.6(__libc_start_main+0xf5) [0x7f60468b7a15]
apr 03 15:48:01 echelon mongod[1756]: /usr/bin/mongod() [0x76bcd5]
apr 03 15:48:01 echelon systemd[1]: mongodb.service: main process exited, code=exited, status=14/n/a
apr 03 15:48:01 echelon systemd[1]: Unit mongodb.service entered failed state
```

仍然看不出哪里有问题，直到google到了这样的字眼sudo chown -R mongodb: /var/{lib,log}/mongodb，恍然大悟。

使用Yum安装Mongodb会默认创建mongo用户,该用户的家目录是/var/lib/mongodb, 但是日志文件/var/log/mongodb/mongod.log和进程ID文件/var/run/mongodb/mongod.pid在其他的目录下面，这些目录属主不是mongodb用户，所以写入的时候会报权限问题。

修改目录/var/log/mongodb和/var/run/mongodb属主为monodb即可。

## 总结

Yum安装软件十分简单，但是由于Mongodb的安装包忽略了权限问题，而且出错日志十分不明显，导致我花费数十分钟才解决。

其实Linux下权限问题十分常见，发生问题不知道原因的时候都可以往这方面尝试一下。

## 更新

后来想了一下，应该不是安装包的问题，这问题未免也太低级了。

极有可能是我安装好的时候使用自己的帐号运行过服务，所以产生的配置文件及目录的属主是我平常用的帐号，因此mongodb这个用户没有写入和执行权限。