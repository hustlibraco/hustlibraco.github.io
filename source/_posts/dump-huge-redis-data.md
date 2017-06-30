---
title: 安全快速地导出Redis集合大数据
date: 2017-04-05 17:59:44
tags: [Redis]
categories: [开发, Redis]
---

最近利用redis的集合做数据去重，共存储3e条记录到一个键。
现在需要把这3e数据导出到文本文件里面来。
<!-- more -->
首先我们不能用`smembers`方法，这个方法会阻塞Redis进程，由于数据量太多，可能会阻塞几十秒，排除这个方法。

然后我们想到mysql导出大数据的时候会利用cursor来迭代处理，查阅redis文档，我们发现有类似的方法`sscan`, 可以一次取出指定数量的数据，并且迭代集合。这样不会阻塞redis服务，而且速度很快（40min处理了3e条数据）。

>SCAN cursor [MATCH pattern] [COUNT count]

>Available since 2.8.0.
Time complexity: O(1) for every call. O(N) for a complete iteration, including enough command calls for the cursor to return back to 0. N is the number of elements inside the collection.

代码片段如下：

```python
def main():
    with open(to, 'wb') as f:
        cursor = '0'
        while cursor != 0:
            cursor, data = r.sscan(key, cursor=cursor, count=count)
            data = ['{0}\n'.format(i) for i in data]
            # 批量写入减少IO操作
            f.writelines(data)
            print('cursor:{0}'.format(cursor))
```

迭代开始的时候我们用0初始化cursor的值，每次迭代的时候都传入上一轮返回cursor值，直到cursor再次等于0的时候遍历结束。

`sscan`方法有几个特别的地方：

1. 返回的cursor值并不是递增的，而且随机变化的，也就是说你不能通过cursor判断当前集合遍历的进度。
    ![redis_sscan_cursor](/images/redis_sscan_cursor.png)

2. 某些元素可能会被返回**多次**。

    >A given element may be returned multiple times. It is up to the application to handle the case of duplicated elements, for example only using the returned elements in order to perform operations that are safe when re-applied multiple times.

3. 当集合在迭代的时候发生变化，某些元素可能不会被返回。

    >Elements that were not constantly present in the collection during a full iteration, may be returned or not: it is undefined.

4. 迭代返回元素的数量可能和count指定的不一致

    >While SCAN does not provide guarantees about the number of elements returned at every iteration, it is possible to empirically adjust the behavior of SCAN using the COUNT option. Basically with COUNT the user specified the amount of work that should be done at every call in order to retrieve elements from the collection. This is just an hint for the implementation, however generally speaking this is what you could expect most of the times from the implementation.
    The default COUNT value is 10.
    When iterating the key space, or a Set, Hash or Sorted Set that is big enough to be represented by a hash table, assuming no MATCH option is used, the server will usually return count or a bit more than count elements per call.
    When iterating Sets encoded as intsets (small sets composed of just integers), or Hashes and Sorted Sets encoded as ziplists (small hashes and sets composed of small individual values), usually all the elements are returned in the first SCAN call regardless of the COUNT value.
    Important: there is no need to use the same COUNT value for every iteration. The caller is free to change the count from one iteration to the other as required, as long as the cursor passed in the next call is the one obtained in the previous call to the command.


因此不建议在集合可能会发生变动的情况下使用这个方法。

参考链接：
1. [redis官方文档](https://redis.io/commands/scan)
2. [如何优雅地删除Redis大键](https://zhuoroger.github.io/2016/08/13/redis-delete-large-keys/)

 
