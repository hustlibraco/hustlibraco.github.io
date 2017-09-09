---
title: CentOS下安装nanomsg和nnpy
date: 2017-09-09 10:47:21
tags: [Linux, Python, Nanomsg]
categories: [开发,  Python]
---

[nanomsg](http://nanomsg.org/)是ZeroMQ作者用C语言重写的一个Socket库，其用法和模式和ZeroMQ差不多，但是具有[更好的性能和更完善的接口](http://nanomsg.org/documentation-zeromq.html)。

下面我们介绍一下CentOS7下nanomsg的安装，以及如何用Python调用。

# 下载源码

wget https://github.com/nanomsg/nanomsg/archive/1.0.0.tar.gz -O nanomsg-1.0.0.tar.gz

# 准备编译环境

```bash
yum install gcc gcc-c++ python-devel cmake
```

nanomsg要求cmake版本要[CMake](http://cmake.org) 2.8.7以上，如果yum源版本不够，需要手动安装

# 编译安装nanomsg

```bash
tar -zxvf nanomsg-1.0.0.tar.gz
cd nanomsg-1.0.0
mkdir bulid
# 这一步如果出现问题，需要删除CMakeCache.txt重新cmake
cmake ..
cmake --build .
# 执行测试
ctest -C Debug .
# 安装
cmake --build . --target install
# 把libnanomsg.so所在路径写入共享库目录（以/usr/local/lib64为例）
echo "/usr/local/lib64" >> /etc/ld.so.conf
# 加载共享库
ldconfig
```

# 安装Python调用模块

这里有两个选择:[nanomsg-python](https://github.com/tonysimpson/nanomsg-python) 和 [nnpy](https://github.com/nanomsg/nnpy)。
其中nanomsg-python很久没人维护，而nnpy较新推出且已经合并到nanomsg的官方代码库中，推荐使用nnpy。

nnpy是基于cffi的，所以需要安装cffi相关开发库，然后pip安装即可：

```bash
yum install libffi-devel
pip install nnpy
```

nnpy代码示例：

```python
import nnpy

pub = nnpy.Socket(nnpy.AF_SP, nnpy.PUB)
pub.bind('inproc://foo')

sub = nnpy.Socket(nnpy.AF_SP, nnpy.SUB)
sub.connect('inproc://foo')
sub.setsockopt(nnpy.SUB, nnpy.SUB_SUBSCRIBE, '')

pub.send('hello, world')
print(sub.recv())
```

如果运行没有报错，那么就大功告成了。

# 备注

nnpy要求python版本>=2.7/3.4, nanomsg-python支持CPython 2.6+, 3.2+ and Pypy 2.1.0+。
如果你不得不使用nanomsg-python，请把源码拷贝下来使用`python setup.py install`安装而不要直接使用pip，因为这个模块会根据你的系统环境编译特定的模块进行安装。
否则可能每次运行nanomsg都会收到恼人的警告：`"Could not load the default wrapper for your platform: XX, performance may be affected!"`

[nanomsg-python](https://github.com/tonysimpson/nanomsg-python)的api与nnpy不同，请自行查看。
