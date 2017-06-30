---
title: Python中try/except/else/finally的执行机制
date: 2016-07-26 10:50:40
tags: [Python]
categories: [开发, Python]
---

最近经常使用到try/except/else/finally全部子句，对于执行顺序不是很熟悉，这里作一下记录。<!-- more -->

## 不含return的情况

### 一般情况

```python
try:
    print 'try'
except:
    print 'except'
else:
    print 'else'
finally:
    print 'finally'
```

output:
```python
try
else
finally
```

### try子句异常

```python
try:
    print 'try'/0
except:
    print 'except'
else:
    print 'else'
finally:
    print 'finally'
```

output:
```python
except
finally
```


### try/except子句同时异常

```python
try:
    print 'try'/0
except:
    print 'except'/0
else:
    print 'else'
finally:
    print 'finally'
```

output:

```python
finally

Traceback (most recent call last):
  File "E:\tmp\test.py", line 4, in <module>
    print 'except'/0
TypeError: unsupported operand type(s) for /: 'str' and 'int'
```

### else子句异常

```python
try:
    print 'try'
except:
    print 'except'
else:
    print 'else'/0
finally:
    print 'finally'
```

output:

```
try
finally

Traceback (most recent call last):
  File "E:\tmp\test.py", line 12, in <module>
    t()
  File "E:\tmp\test.py", line 7, in t
    print 'else'/0
TypeError: unsupported operand type(s) for /: 'str' and 'int'
```

### finally子句异常

```python
try:
    print 'try'
except:
    print 'except'
else:
    print 'else'
finally:
    print 'finally'/0
```

output:
```python
try
else

Traceback (most recent call last):
  File "E:\tmp\test.py", line 11, in <module>
    t()
  File "E:\tmp\test.py", line 9, in t
    print 'finally'/0
TypeError: unsupported operand type(s) for /: 'str' and 'int'
```

### 总结

1. finally子句总会执行
2. 除了try子句，其他子句中的异常都会抛出

## 包含return的情况

众所周知，return会直接跳出函数，那么它和异常机制的优先级如何呢？

### try子句return

```python
def t():
    try:
        print 'try'
        return
    except:
        print 'except'
    else:
        print 'else'
    finally:
        print 'finally'

t()
```

output:

```
try
finally
```

else子句没有执行！finally子句仍然执行！ 

### finally子句return

```python
def t():
    try:
        print 'try'/0
        return 0
    except:
        print 'except'/0
        return 1
    else:
        print 'else'
        return 2
    finally:
        print 'finally'
        return 3

print t()
```


output:

```python
finally
3
```

函数的返回值是3，而不是try子句中设置的0，而且except子句的异常不见了。但是如果注释掉finally子句的return，就可以看见except中抛出的异常。

```python
def t():
    try:
        print 'try'/0
        return 0
    except:
        print 'except'/0
        return 1
    else:
        print 'else'
        return 2
    finally:
        print 'finally'
        # return 3

print t()
```

output:

```python
finally

Traceback (most recent call last):
  File "E:\tmp\test.py", line 15, in <module>
    print t()
  File "E:\tmp\test.py", line 6, in t
    print 'except'/0
TypeError: unsupported operand type(s) for /: 'str' and 'int'
```

这是为什么呢？其实官方文档里有讲：

>A finally clause is always executed before leaving the try statement, whether an exception has occurred or not. When an exception has occurred in the try clause and has not been handled by an except clause (or it has occurred in a except or else clause), it is **re-raised after the finally clause has been executed**. The finally clause is also executed “on the way out” when any other clause of the try statement is left via a break, continue or return statement.

也就是说except、esle子句中的异常在finally子句执行之后才会抛出，但是finally直接return了，所以我们就看不到异常了，而且会覆盖本身的return值。这种用法显然是不符合初衷的，所以不建议在finally语句中使用`return`、`break`、`continue`这些跳出的语句，应仅用作资源释放操作，否则会出现意想不到的结果。

### 总结

1. 执行顺序 finally > return > else
2. finally的return会抑制其他子句异常抛出，不建议使用

## 一个例子

```python
def example(id):
    db = get_db()
    try:
        with db.cursor() as cursor:
            sql = '''update xxxx
                        set yyyy = yyyy + 1
                      where id = %s'''
            cursor.execute(sql, (id,))
        db.commit()
    except Exception, e:
        app.logger.error(e, exc_info=True)
        db.rollback()
    else:
        # do sth else
        return True
    finally:
        db.close()
```


注意`return`的位置和`finally`子句的用法。
