---
title: pip设置国内源
date: 2016-11-28 13:26:45
tags: [Python]
categories: [开发, Python]
---

{% cq %} 每次学习编程的时候都会遇到许多运维的问题。身为立志成为一名全站工程师的我，只有不断折腾了。{% endcq %}<!--more-->

pip的默认下载源是国外的，所以不是很快，类似yum我们想替换成国内的源，比如：

-  阿里云 http://mirrors.aliyun.com/pypi/simple/  
-  豆瓣 https://pypi.doubanio.com/simple/  

网上搜到的地址很多都是过期的，验证方法是用浏览器打开的能看到包列表的地址。比如`https://pypi.douban.com/simple/`用浏览器打开会跳转至`https://pypi.doubanio.com/simple/`，这才是最终的正确地址。

以豆瓣源为例，在Linux下面，创建/etc/pip.conf，编辑内容如下:

```ini
[global]
timeout = 60
trusted-host=pypi.doubanio.com
index-url=https://pypi.doubanio.com/simple/
```

保存即可生效，甚至包括virtualenv创建出来的pip也会用这个源。

### 临时用法

```bash
pip install xxx -i http://mirrors.aliyun.com/pypi/simple/ 
```

### 更多设置

可以针对不同Linux用户设置不同源，详见 https://pip.pypa.io/en/stable/user_guide/#configuration
