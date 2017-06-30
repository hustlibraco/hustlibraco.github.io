---
title: 利用supervisor部署多个tornado服务
date: 2015-12-09 21:01:15
tags: [Supervisor, Tornado, Python]
categories: [运维, Supervisor]
---

单个Tornado服务由于文件句柄和处理请求数的限制不能够很好得满足实际的工作需求，因此我们搭建多个实例共同服务，但是Tornado自身没有这样的集群管理能力，所以我们需要借助第三方工具——Supervisor。
<!-- more -->
[Supervisor](http://supervisord.org/) 是用Python编写的运行在Linux上的进程控制系统，用于监控和管理批量的服务进程，当前版本3.3.0。

## 安装

```bash
$ pip install supervisor
```

## 配置

```bash
$ echo_supervisord_conf > /etc/supervisord.conf
```

### 修改默认配置

编辑`/etc/supervisord.conf`：

```ini
; 修改unix socket文件位置，因为不清楚的原因，默认文件位置工作一段时间之后会不正常
[unix_http_server]
file=/home/libraco/conf/supervisor.sock   ; (the path to the socket file)

[supervisorctl]
serverurl=unix:///home/libraco/conf/supervisor.sock ; use a unix:// URL  for a unix socket

; 取消注释，并修改配置文件目录
[include]
files = etc/supervisor/*.ini
```

### 配置Tornado

在`/etc/supervisor/`下添加`tornado.ini`文件:

```ini
[group:tornadoes]
programs=tornado-8000,tornado-8001,tornado-8002,tornado-8003

[program:tornado-8000]

;*命令路径,如果使用python启动的程序应该为 python /home/test.py, 
;不建议放入/home/user/, 对于非user用户一般情况下是不能访问
command=python /var/www/main.py --port=8000

;执行目录,若有/home/supervisor_test/test1.py
;将directory设置成/home/supervisor_test
;则command只需设置成python test1.py
;否则command必须设置成绝对执行目录
directory=/var/www

;*以www-data用户执行
user=www-data

;如果是true,当supervisor启动时,程序将会自动启动
autostart=true

;*自动重启
autorestart=true

;标准输出重定向到文件，标准错误重定向到标准输出
stdout_logfile= /var/log/tornado-8000.log
redirect_stderr=true

[program:tornado-8001]
command=python /var/www/main.py --port=8001
directory=/var/www
user=www-data
autostart=true
autorestart=true
stdout_logfile= /var/log/tornado-8001.log
redirect_stderr=true

[program:tornado-8002]
command=python /var/www/main.py --port=8002
directory=/var/www
user=www-data
autostart=true
autorestart=true
stdout_logfile= /var/log/tornado-8002.log
redirect_stderr=true

[program:tornado-8003]
command=python /var/www/main.py --port=8003
directory=/var/www
user=www-data
autostart=true
autorestart=true
stdout_logfile= /var/log/tornado-8003.log
redirect_stderr=true
```

这里我们定义了一个名为tornadoes的组，包含四个成员tornado-8000、tornado-8001、tornado-8002、tornado-8003。

program定义进程名，每个program有单独的详细配置。


至此我们的配置工作基本完成。

## 启动

```bash
$ /usr/bin/supervisord -c /etc/supervisord.conf
```


## 开机自启动

```bash
$ sudo vim /lib/systemd/system/supervisor.service  
```

写入如下内容:
```init
[Unit]
Description=supervisor
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/supervisord -c /etc/supervisord.conf
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

```bash
# 启动服务
$ sudo systemctl start supervisor

# 开机自启动
$ sudo systemctl enable supervisor
```

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
