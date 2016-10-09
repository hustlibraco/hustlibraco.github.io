---
title: 根据php加密算法编写python解密代码
date: 2016-10-09 16:30:18
tags: [Php, Python, CTF]
---

服务器搬家，暂时无法工作，拿起一道[CTF](http://www.shiyanbar.com/ctf/1760)练练手。<!-- more -->

php代码是一张图片:

![ctf](/images/ctf_web200.jpg)

使用了`rot13`、逆序、base64等方法加密，我们将其翻译成python代码：

```python
def rot13(s, offset=13):
    '''
    ROT-13 编码是一种每一个字母被另一个字母代替的方法。
    这个代替字母是由原来的字母向前移动 13 个字母而得到的。数字和非字母字符保持不变。
    '''
    def encodeCh(ch):
        f=lambda x: chr((ord(ch)-x+offset) % 26 + x)
        return f(97) if ch.islower() else (f(65) if ch.isupper() else ch)
    return ''.join(encodeCh(c) for c in s)

def encode(s):
    oo = ''
    o = s[::-1]
    for i in range(0, len(o)):
        c = chr(ord(o[i])+1)
        oo += c
    return rot13(base64.b64encode(oo)[::-1])
```

照着encode函数，很容易可以写出来decode函数:

```python
def decode(s):
    o = ''
    oo = base64.b64decode(rot13(s)[::-1])
    for i in range(0, len(oo)):
        c = chr(ord(oo[i])-1)
        o += c
    return o[::-1]  
```

密文`s=a1zLbgQsCESEIqRLwuQAyMwLyq2L5VwBxqGA3RQAyumZ0tmMvSGM2ZwB4tws`, 我们调用一下decode函数，直接得到结果。

```bash
root@kaliSec:~/文档# python 1.py 
a1zLbgQsCESEIqRLwuQAyMwLyq2L5VwBxqGA3RQAyumZ0tmMvSGM2ZwB4tws flag:{NSCTF_b73d5adfb819c64603d7237fa0d52977}
```

语言都是相通的，熟悉算法和数据结构更为关键。