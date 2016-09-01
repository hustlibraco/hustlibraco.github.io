---
title: 使用Gunicorn部署Flask Web服务
date: 2016-08-31 15:07:45
tags: [Python, Gunicorn, Flask]
---

## Flask

Flask 虽然自带 Web 服务器，但是该服务器性能较低，是单进程单线程模型，原本是供开发测试使用。所以我们在生产环境中需要使用 Gunicorn 这样高性能服务器部署Flask服务。<!--more-->

## Gunicorn

Gunicorn 'Green Unicorn' 是一个 UNIX 下的 WSGI HTTP 服务器，它是一个移植自 Ruby 的 Unicorn 项目的 pre-fork worker 模型。它既支持 eventlet，也支持 greenlet。在 Gunicorn 上运行 Flask 应用非常简单:

```bash
gunicorn myproject:app
```

Gunicorn 提供许多命令行参数，可以使用 gunicorn -h 来获得帮助。下面的例子 使用 4 worker 进程（ -w 4 ）来运行 Flask 应用，绑定到 localhost 的 4000 端口（ -b 127.0.0.1:4000 ）:

```bash
gunicorn -w 4 -b 127.0.0.1:4000 myproject:app
```

## 几点注意的地方

1.Gunicorn 日志分为 accesslog 和 errorlog，但是如果你没有配置这两个选项，它们不会被打印出来。

2.被 Gunicorn 包裹的web服务日志，可以改写输出到 Gunicorn errorlog 上，记得设置 errorlog 的 loglevel ，要不然你可能看不到日志。

3.如果 Gunicorn 开启了多进程，原来服务的日志系统也需要兼容多进程，或者仅输出到 Gunicorn 的 errorlog 上，写法如：

```python
app.logger.setLevel(logging.INFO)
app.logger.handlers.extend(logging.getLogger("gunicorn.error").handlers)
```

我猜测这样是多进程安全的，仅仅是**猜测**!

4.~~如果你的服务在启动和结束之前还要执行其他操作，目前我不知道Gunicorn如何实现，官方给了自定义Gunicorn的写法，但是我遇到了无法结束的bug。参见：http://docs.gunicorn.org/en/stable/custom.html~~

`gunicorn server-hooks` 提供这样的功能, 只需要在配置文件中添加对应的函数:

```python
import os
import sys
sys.path.append(os.path.abspath(os.path.dirname(__file__)))
from spectre import crons
bind = ':5000'
loglevel = 'info'
access_log_format = '%(h)s %(l)s %(u)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'
accesslog = "/dev/null"
errorlog = "/dev/null"

def on_starting(server):
    # gunicorn 主进程启动之前的操作
    crons.start()

def on_exit(server):
    # gunicorn 退出之后的操作
    crons.stop()
```

还有其他的钩子函数，参考：http://docs.gunicorn.org/en/latest/settings.html#server-hooks

## 后记

原来喜欢用 python 不喜欢 php 写 web 最大的原因之一就是 php 必须假设在一个web服务器上，配置麻烦。现在发现python web框架自带的服务器就是个玩具而已，生产配置是一样的麻烦。

我还是太年轻了。也许可以花时间学下php，在适合的场景用适合的语言。