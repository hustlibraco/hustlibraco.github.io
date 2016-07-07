---
title: python实现rsa的几种方案
date: 2015-12-09 21:26:47
tags: [Python, RSA, 密码学]
---

## [rsa](https://pypi.python.org/pypi/rsa)

这是一个纯python实现的库，不依赖底层文件，优点是部署容易，缺点是速度比较慢，原本是斯坦福大学教学演示用的，现在由Sybren A. Stüvel专人维护。 生产环境不太建议使用此库。

<!-- more -->

** 解密性能: 70ms左右 **

> Python-RSA is a pure-Python RSA implementation. It supports encryption and decryption, signing and verifying signatures, and key generation according to PKCS#1 version 1.5. It can be used as a Python library as well as on the commandline. The code was mostly written by Sybren A. Stüvel.

## [pycrypto](https://pypi.python.org/pypi/pycrypto)

这个库应用的比较多，不局限于rsa，实现了大多数常用的加密算法。底层应该也是自己实现的，因为相比后面一个调用系统模块的库它的rsa算法要慢很多。

** 解密性能: 40ms左右 **

> This is a collection of both secure hash functions (such as SHA256 and RIPEMD160), and various encryption algorithms (AES, DES, RSA, ElGamal, etc.). The package is structured to make adding new modules easy. This section is essentially complete, and the software interface will almost certainly not change in an incompatible way in the future; all that remains to be done is to fix any bugs that show up. If you encounter a bug, please report it in the Launchpad bug tracker at…

## [M2Crypto](https://pypi.python.org/pypi/M2Crypto)

这个库是对Openssl库接口的python封装，实际运算都是调用系统的libssl.so/libcryto.so，不过安装的时候比较麻烦，需要依赖swig等工具 ([demo](https://gitlab.com/m2crypto/m2crypto_demo))。

** 解密性能: 7ms左右 **

## ctypes+openssl

以上列举的几种方法都有一个问题，就是不能利用多核。当我调用解密接口比较集中的时候，接口耗时会成倍增加，即便是最快的M2Crypto，瞬时10个并发的时候最坏情况就会达到70ms左右。

因此我尝试直接使用ctypes调用openssl库突破的GIL的限制，不过ctypes调用so文件有点麻烦的就是看不到so提供的函数名，反复查阅openssl的文档和参考c代码之后，最终调试成功。结果也非常令人满意，达到了1ms级，瞬时100个并发也能维持在毫秒级的性能。

** 解密性能: 1ms左右 **

```python
import ctypes
from ctypes.util import find_library
_libcrypto = find_library('crypto')
sign = 'iYzF0bn6kwUtsqLmTSx8fx...'
cryptor = ctypes.cdll.LoadLibrary(_libcrypto)
RSA_size                    = cryptor.RSA_size
BIO_free                    = cryptor.BIO_free
RSA_free                    = cryptor.RSA_free
RSA_decrypt                 = cryptor.RSA_private_decrypt
PEM_read_bio_RSAPrivateKey  = cryptor.PEM_read_bio_RSAPrivateKey
privkey = '''-----BEGIN RSA PRIVATE KEY-----...-----END RSA PRIVATE KEY-----'''    
bio = cryptor.BIO_new_mem_buf(privkey, -1)
key = PEM_read_bio_RSAPrivateKey(bio, 0, 0, 0)
r = BIO_free(bio)
if r != 1:
    # break here
    print 'BIO_free error'
    return
rsa_size = RSA_size(key)
rsa = ctypes.create_string_buffer(rsa_size)
ret = RSA_decrypt(rsa_size, sign, rsa, key, 1)
```

其中privkey是私钥，sign是我要解密的数据。

## 总结

1. 加解密这一块，Linux下面能用openssl就用openssl，绝对比自己实现快。

2. python+ctypes可以让你享受python便利的同时还能拥有卓越的性能，不过ctypes创建的内存空间记得要自己释放，python垃圾收集机制对其无效。

3. 一般情况下推荐用pycrypto库，文档比较全面。
