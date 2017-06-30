---
title: 【转】Python装饰器
date: 2016-12-05 17:55:45
tags: [Python]
categories: [开发, Python]
---

装饰器本质上是一个Python函数，它可以让其他函数在不需要做任何代码变动的前提下增加额外功能，装饰器的返回值也是一个函数对象。<!-- more -->它经常用于有切面需求的场景，比如：插入日志、性能测试、事务处理、缓存、权限校验等场景。装饰器是解决这类问题的绝佳设计，有了装饰器，我们就可以抽离出大量与函数功能本身无关的雷同代码并继续重用。概括的讲，装饰器的作用就是为已经存在的对象添加额外的功能。

先来看一个简单例子：

```python
def foo():
    print('i am foo')
现在有一个新的需求，希望可以记录下函数的执行日志，于是在代码中添加日志代码：
def foo():
    print('i am foo')
    logging.info("foo is running")
```

bar()、bar2()也有类似的需求，怎么做？再写一个logging在bar函数里？这样就造成大量雷同的代码，为了减少重复写代码，我们可以这样做，重新定义一个函数：专门处理日志 ，日志处理完之后再执行真正的业务代码

```python
def use_logging(func):
    logging.warn("%s is running" % func.__name__)
    func()

def bar():
    print('i am bar')

use_logging(bar)
```
逻辑上不难理解， 但是这样的话，我们每次都要将一个函数作为参数传递给use_logging函数。而且这种方式已经破坏了原有的代码逻辑结构，之前执行业务逻辑时，执行运行bar()，但是现在不得不改成use_logging(bar)。那么有没有更好的方式的呢？当然有，答案就是装饰器。

### 简单装饰器

```python
def use_logging(func):

    def wrapper(*args, **kwargs):
        logging.warn("%s is running" % func.__name__)
        return func(*args, **kwargs)
    return wrapper

def bar():
    print('i am bar')

bar = use_logging(bar)
bar()
```

函数use_logging就是装饰器，它把执行真正业务方法的func包裹在函数里面，看起来像bar被use_logging装饰了。在这个例子中，函数进入和退出时，被称为一个横切面(Aspect)，这种编程方式被称为面向切面的编程(Aspect-Oriented Programming)。@符号是装饰器的语法糖，在定义函数的时候使用，避免再一次赋值操作。

```python
def use_logging(func):

    def wrapper(*args, **kwargs):
        logging.warn("%s is running" % func.__name__)
        return func(*args)
    return wrapper

@use_logging
def foo():
    print("i am foo")

@use_logging
def bar():
    print("i am bar")

bar()
```

如上所示，这样我们就可以省去`bar = use_logging(bar)`这一句了，直接调用bar()即可得到想要的结果。如果我们有其他的类似函数，我们可以继续调用装饰器来修饰函数，而不用重复修改函数或者增加新的封装。这样，我们就提高了程序的可重复利用性，并增加了程序的可读性。

装饰器在Python使用如此方便都要归因于Python的函数能像普通的对象一样能作为参数传递给其他函数，可以被赋值给其他变量，可以作为返回值，可以被定义在另外一个函数内。

### 带参数的装饰器
装饰器还有更大的灵活性，例如带参数的装饰器：在上面的装饰器调用中，比如@use_logging，该装饰器唯一的参数就是执行业务的函数。装饰器的语法允许我们在调用时，提供其它参数，比如@decorator(a)。这样，就为装饰器的编写和使用提供了更大的灵活性。

```python
def use_logging(level):
    def decorator(func):
        def wrapper(*args, **kwargs):
            if level == "warn":
                logging.warn("%s is running" % func.__name__)
            return func(*args)
        return wrapper

    return decorator

@use_logging(level="warn")
def foo(name='foo'):
    print("i am %s" % name)

foo()
```

上面的use_logging是允许带参数的装饰器。它实际上是对原有装饰器的一个函数封装，并返回一个装饰器。我们可以将它理解为一个含有参数的闭包。当我 们使用@use_logging(level="warn")调用的时候，Python能够发现这一层的封装，并把参数传递到装饰器的环境中。

### 类装饰器
再来看看类装饰器，相比函数装饰器，类装饰器具有灵活度大、高内聚、封装性等优点。使用类装饰器还可以依靠类内部的`__call__`方法，当使用 @ 形式将装饰器附加到函数上时，就会调用此方法。
```python
class Foo(object):
    def __init__(self, func):
    self._func = func

def __call__(self):
    print ('class decorator runing')
    self._func()
    print ('class decorator ending')

@Foo
def bar():
    print ('bar')

bar()
```

### functools.wraps
使用装饰器极大地复用了代码，但是他有一个缺点就是原函数的元信息不见了，比如函数的`docstring`、`__name__`、参数列表，先看例子：
装饰器
```python
def logged(func):
    def with_logging(*args, **kwargs):
        print func.__name__ + " was called"
        return func(*args, **kwargs)
    return with_logging
```
函数
```python
@logged
def f(x):
   """does some math"""
   return x + x * x
```
该函数完成等价于：
```python
def f(x):
    """does some math"""
    return x + x * x
f = logged(f)
```

不难发现，函数f被with_logging取代了，当然它的`docstring`，`__name__`就是变成了`with_logging`函数的信息了。
```python
print f.__name__    # prints 'with_logging'
print f.__doc__     # prints None
```

这个问题就比较严重的，好在我们有`functools.wraps`，wraps本身也是一个装饰器，它能把原函数的元信息拷贝到装饰器函数中，这使得装饰器函数也有和原函数一样的元信息了。

```python
from functools import wraps
def logged(func):
    @wraps(func)
    def with_logging(*args, **kwargs):
        print func.__name__ + " was called"
        return func(*args, **kwargs)
    return with_logging

@logged
def f(x):
    """does some math"""
    return x + x * x

print f.__name__  # prints 'f'
print f.__doc__   # prints 'does some math'
```

### 内置装饰器
`@staticmathod`、`@classmethod`、`@property`

### 装饰器的顺序
```python
@a
@b
@c
def f ():
    pass
```
等效于
```python
f = a(b(c(f)))
```

<br/>
> 作者：zhijun liu
> 链接：https://www.zhihu.com/question/26930016/answer/99243411
> 来源：知乎
> 著作权归作者所有，转载请联系作者获得授权。


### 个人练习

```python
#coding=utf-8
#!/usr/bin/env python
from functools import wraps
from hashlib import md5
from random import randint
import os
import redis
import time, datetime

class Decorator(object):
    """装饰器类"""
    func_cache_dict = {}
    func_cache_key = 'func_cache'
    rds = redis.StrictRedis()

    @classmethod
    def func_cache(cls, func):
        @wraps(func)
        def wrapper(*args, **kargs):
            argstr = '{0}+{1}+{2}'.format(func.__name__,
                '+'.join(str(i) for i in args),
                '+'.join('{0}={1}'.format(k,v) for k,v in kargs.iteritems()))
            uniqid = md5(argstr).hexdigest()
            if uniqid not in cls.func_cache_dict:
                try:
                    res = func(*args, **kargs)
                except Exception as e:
                    logging.error(e, exc_info=True)
                    return None
                else:
                    cls.func_cache_dict[uniqid] = res
            return cls.func_cache_dict[uniqid]
        return wrapper

    @classmethod
    def fun_cache_expire(cls, expire_time):
        assert isinstance(expire_time, int), 'expire_time must be a integer.'
        def decorator(func):
            @wraps(func)
            def wrapper(*args, **kargs):
                argstr = '{0}+{1}+{2}'.format(func.__name__,
                    '+'.join(str(i) for i in args),
                    '+'.join('{0}={1}'.format(k,v) for k,v in kargs.iteritems()))
                uniqid = md5(argstr).hexdigest()
                expire_at = float(cls.rds.get(cls.func_cache_key + uniqid) or 0)
                cond1 = (uniqid not in cls.func_cache_dict)
                cond2 = (time.time() > expire_at)
                # print 'cond1:{0}, cond2:{1}'.format(cond1, cond2)
                if cond1 or cond2:
                    try:
                        res = func(*args, **kargs)
                    except Exception as e:
                        logging.error(e, exc_info=True)
                        return None
                    else:
                        cls.func_cache_dict[uniqid] = res
                        cls.rds.setex(cls.func_cache_key + uniqid, 
                            datetime.timedelta(seconds=expire_time), 
                            time.time() + expire_time)
                return cls.func_cache_dict[uniqid]
            return wrapper
        return decorator


def randomstr1():
    return os.urandom(8).encode('hex')

@Decorator.func_cache
def randomstr2():
    return os.urandom(8).encode('hex')

@Decorator.fun_cache_expire(3)
# 结果缓存三秒
def randomstr3():
    return os.urandom(8).encode('hex')

@Decorator.fun_cache_expire(1)
# 带参数的函数
def randomstr4(*args):
    s = '_'.join(str(i) for i in args)
    return md5(s).hexdigest()

for i in range(8):
    args = [randint(1,100) for i in range(3)]
    print randomstr1(), randomstr2(), randomstr3(), randomstr4(*args)
    time.sleep(1)

print randomstr1(), randomstr2(), randomstr3(), randomstr4(*args)
```

运行结果：
```bash
302e93d809adda2f 828719ab1a357f0a 9e9a3d8e26d8b101 71078cd8bf589b0a82a4d64867a4fca9
8ff79b5be99afab7 828719ab1a357f0a 9e9a3d8e26d8b101 2642897d9d2e5d403790f5efcb51c9de
284014dc432de190 828719ab1a357f0a 9e9a3d8e26d8b101 79c3b2f9cee061069dc95f27ec93893b
# randomstr3 函数结果缓存3秒，所以3秒变换一次结果
8d6201c551e12e08 828719ab1a357f0a bae42a9245254d39 840d506ee9004882b3b8537c722cc917
8038c2c75f0e2584 828719ab1a357f0a bae42a9245254d39 454715c6f86330eebf9a79d65c4c519d
1ad603c8b1c0f862 828719ab1a357f0a bae42a9245254d39 0c69a374754d0c546fe588ff638c4376
f3a35c418c35084c 828719ab1a357f0a 6997bc4c1a5c6acf 71a735b4c528d6eb7bc49375f2e031a7
d42fcb94450a61aa 828719ab1a357f0a 6997bc4c1a5c6acf 4d309f93de6bcb766ca623d9270cf422
# randomstr4 函数最后一次执行的入参与上次相同，所以结果与上一次相同
90e416f4a6177b8d 828719ab1a357f0a 6997bc4c1a5c6acf 4d309f93de6bcb766ca623d9270cf422
```
