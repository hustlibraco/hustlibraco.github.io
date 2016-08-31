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

4.如果你的服务在启动和结束之前还要执行其他操作，目前我不知道Gunicorn如何实现，官方给了自定义Gunicorn的写法，但是我遇到了无法结束的bug。参见：http://docs.gunicorn.org/en/stable/custom.html

```python
from __future__ import unicode_literals
import multiprocessing
import gunicorn.app.base
from gunicorn.six import iteritems

def number_of_workers():
    return (multiprocessing.cpu_count() * 2) + 1

def handler_app(environ, start_response):
    response_body = b'Works fine'
    status = '200 OK'
    response_headers = [
        ('Content-Type', 'text/plain'),
    ]
    start_response(status, response_headers)
    return [response_body]

class StandaloneApplication(gunicorn.app.base.BaseApplication):
    def __init__(self, app, options=None):
        self.options = options or {}
        self.application = app
        super(StandaloneApplication, self).__init__()
    def load_config(self):
        config = dict([(key, value) for key, value in iteritems(self.options)
                       if key in self.cfg.settings and value is not None])
        for key, value in iteritems(config):
            self.cfg.set(key.lower(), value)
    def load(self):
        return self.application

if __name__ == '__main__':
    options = {
        'bind': '%s:%s' % ('127.0.0.1', '8080'),
        'workers': number_of_workers(),
    }
    StandaloneApplication(handler_app, options).run()

```


## 后记

原来喜欢用 python 不喜欢 php 写 web 最大的原因之一就是 php 必须假设在一个web服务器上，配置麻烦。现在发现python web框架自带的服务器就是个玩具而已，生产配置是一样的麻烦。

我还是太年轻了。也许可以花时间学下php，在适合的场景用适合的语言。