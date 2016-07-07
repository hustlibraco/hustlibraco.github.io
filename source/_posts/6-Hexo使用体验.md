---
title: Hexo使用体验
date: 2016-07-01 19:07:07
tags: [Hexo, Next, Blog]
---


最早开始搭建个人博客的时候使用WordPress，光安装环境就折腾了许久，而且很多静态资源默认都是国外的，加载缓慢，替换起来也很麻烦。

于是后来就开始体验一些静态博客，从最知名的jekyll，到python开发的pelican，然后是go语言写的hugo，使用过程都不太满意，直到我遇见了Hexo & Next。
<!-- more -->
## Why Hexo

其实我很早知道hexo，在github上面stars的数量也很高，但是年少的我对NodeJS带有偏见，以至于一路过来都没有尝试她。
下面是我选择她的一些理由:

| 工具      | 文章生成速度  | 配置部署 | 主题 | 开发者 |
| :------: | :---: | :---: | :---: | :---:|
| Ruby/Pelican  | 慢 |  简单    | 多 | 外国人 |
| Hugo    | 快   |  麻烦(go的很多代码被墙了) | 较少| 外国人|
| Hexo     | 快   |  简单  | 很多很好看（js毕竟是前端程序员的主力武器）| 台湾

所以我放弃Pelican的理由是太慢了，放弃Hugo的理由是因为找不到我想要的主题，而且本地化支持不是很好。
Hexo部署简单，性能也还不错，但是仅仅如此是不够。最重要的是因为**Next**。

## Why Next

Next是Github上面starts数最多的Hexo主题，最重要的是她是国人开发的，有着对本地化最完美的支持。

比如我们使用多说评论框，在Hugo上要去改写测试layouts文件，很容易出错，但是在Next里你只需要把你的duoshuoID配置在\_config.yaml文件里就可以了。  

此外她有丰富的国人编写的插件及简洁优美的外观，配合Nginx和国内JS、CSS的CDN，性能表现近乎完美。  
具体的介绍可以参考[Next主页](http://theme-next.iissnan.com/)。

## 安装 Hexo

Hexo是用Node开发的，所以我们需要先安装Node。  

安装方式有：

1. `yum install nodejs`  
2. nvm安装
3. [官网](https://nodejs.org/en/download/) 安装

推荐第一种，因为hexo对node没有特殊要求，采用最方便的方式安装即可。

node的包管理工具叫做npm，hexo就是用它安装，但是默认配置的npm是国外的，速度不稳定，所以建议修改为国内源:

```bash
$ vim ~/.profile
```

添加

```bash
export NVM_NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node
```

到文件尾，然后执行`source ~/.profile`使配置生效。

然后安装hexo，一行搞定:
```bash
$ npm install hexo-cli -g
```

## 部署Hexo

设置你的博客
```bash
$ hexo init blog
$ cd blog
```

安装Next
```bash
$ git clone https://github.com/iissnan/hexo-theme-next themes/next
```

启用主题，打开blog/\_config.yaml， 找到 theme 字段，并将其值更改为 next
```bash
theme: next
```

开启服务
```bash
$ hexo server
# 默认监听localhost:4000，可以通过-i参数指定ip(不能写0.0.0.0)
$ hexo server -i `yourip or domain`
```
这个时候访问localhost:4000就能看到博客默认的样子了，**不过建议实际部署的时候不要用hexo直接作为web服务器，而用分发好的静态文件直接部署在nginx上比较好，因为Nginx作为服务器性能比Hexo强，资源占用少。hexo server只是在我们预览效果的时候使用。**

其他命令：

- 创建文章
```bash
$ hexo new "Hello Hexo"
```

- 生成静态文件
```bash
$ hexo generate
```

- 分发静态文件
```bash
$ hexo deploy
```

静态文件还可以通过git直接部署在github上面，利用github搭建自己的静态博客。具体方法就不多说了。  
当然，本博客就是用Hexo & Next搭建在Nginx之上 ^\_^
