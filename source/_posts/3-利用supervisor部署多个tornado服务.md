---
title: 利用supervisor部署多个tornado服务
date: 2015-12-09 21:01:15
tags: [Supervisor, Tornado, Python]
---

单个Tornado服务由于文件句柄和处理请求数的限制不能够很好得满足实际的工作需求，因此我们搭建多个实例共同服务，但是Tornado自身没有这样的集群管理能力，所以我们需要借助第三方工具——Supervisor。
<!-- more -->
[Supervisor](http://supervisord.org/) 是用Python编写的运行在Linux上的进程控制系统，用于监控和管理批量的服务进程，当前版本3.3.0。

## 安装Supervisor

官网上介绍了多种安装方法，这里使用pip进行安装:

```bash
pip install supervisor
```

安装完毕之后在/usr/bin目录会生成一个echo_supervisord_conf文件，它的作用是打印默认的Supervisor配置。接下来我们执行:

```bash
echo_supervisord_conf > /etc/supervisord.conf
```

这样我们的配置文件就建立好了，最好不要改配置文件的路径和名字，因为Supervisor命令默认读取此路径配置，以后使用起来更方便。

supervisorctl默认通过unix_http_server与supervisor通信，关键的.sock文件默认保存在/tmp目录下，但是在阿里云上似乎会定期清理/tmp下的文件，导致supervisorctl无法与监控主程序进行通信，类似问题需要重新配置你的.sock文件在一个不受干扰的路径，如图所示:

```bash
[unix_http_server]
file=/home/libraco/conf/supervisor.sock   ; (the path to the socket file)
```

针对单独服务的配置可以写在任意地方，只要在主配置文件中包含进来就可以。包含格式在默认配置文件的最后一行：

```ini
; The [include] section can just contain the "files" setting.  This
; setting can list multiple files (separated by whitespace or
; newlines).  It can also contain wildcards.  The filenames are
; interpreted as relative to this file.  Included files *cannot*
; include files themselves.

[include]
files = /etc/supervisor/conf.d/*.conf
```

这里会包含/etc/supervisor/conf.d/下所有以.conf结尾的文件，记得删除行首的分号注释符。

## 针对Tornado的Supervisor配置

Supervisor关于监控对象的详细配置可以参考其官网，这里我们给一个具体例子:

```ini
[group:tornadoes]
programs=tornado-8000,tornado-8001,tornado-8002,tornado-8003

[program:tornado-8000]
command=python /var/www/main.py --port=8000 --log_file_prefix=/var/log/tornado/tornado-8000.log
directory=/var/www
user=www-data
autorestart=true
redirect_stderr=true
loglevel=info

[program:tornado-8001]
command=python /var/www/main.py --port=8001 --log_file_prefix=/var/log/tornado/tornado-8000.log
directory=/var/www
user=www-data
autorestart=true
redirect_stderr=true
loglevel=info

[program:tornado-8002]
command=python /var/www/main.py --port=8002 --log_file_prefix=/var/log/tornado/tornado-8000.log
directory=/var/www
user=www-data
autorestart=true
redirect_stderr=true

loglevel=info

[program:tornado-8003]
command=python /var/www/main.py --port=8003 --log_file_prefix=/var/log/tornado/tornado-8000.log
directory=/var/www
user=www-data
autorestart=true
redirect_stderr=true
loglevel=info
```

这里我们定义了一个名为tornadoes的组，包含四个成员tornado-8000、tornado-8001、tornado-8002、tornado-8003。

program部分定义了Supervisor将要运行的每个命令的参数。

command的值是必须的，通常是带有我们希望监听的带有port参数的Tornado应用。

我们还为每个程序的工作目录、有效用户和日志文件定义了额外的设置。

autorestart=true保证进程在异常情况下会自动重启，而redirect_stderr=true会把标准错误重定向到标准输出。

至此我们的配置工作基本完成。

## 启动Supervisord

直接在Bash中执行supervisord即可，如果需要指定配置文件，使用-c参数。此时四个Tornado服务已经跑起来了。

## 管理服务

管理服务需要用到supervisorctl命令，这个命令必须在Supervisord启动之后执行，它通过发送指令给Supervisord达到管理的目的。

常用的指令有：

- `supervisorctl reload`
   重启Supervisord服务

- `supervisorctl restart <name>|<gname>` 
  重启某个服务或某一组服务

- `supervisorctl status`
  查看服务运行的状态和时间

## 其他

如果Tornado集群部署在Nginx反向代理之后，要获取到远程真实IP，除了必要的Nginx配置之外，Tornado也需要明确指定xheaders=True,官方有说明：

> If xheaders is True, we support the X-Real-Ip/X-Forwarded-For and X-Scheme/X-Forwarded-Proto headers, which override the remote IP and URI scheme/protocol for all requests. These headers are useful when running Tornado behind a reverse proxy or load balancer. The protocol argument can also be set to https if Tornado is run behind an SSL-decoding proxy that does not set one of the supported xheaders.
具体代码示例：

```python
application = tornado.web.Application([
    (r"/", MainHandler),
])
application.listen(options.port, '127.0.0.1', xheaders=True)
```
