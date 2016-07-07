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

## 同步Hexo

如果你只在一台电脑上写博客，你就不需要看这一部分。但是如果你有在多机上写博客的需求，那么解决Hexo同步的问题就很必要了。

Hexo的部署命令针对public里的静态文件，对于文章源文件和配置等没有同步功能，除非你每次写完博客都把源文件存储在一个公共的地方，要不然你没有办法接下来承接之前的文章继续写作。

我在网路上搜索了一下，一般有这么几个解决方法：

- 用DropBox同步源文件
- 把源文件存放在服务器上
- 使用[hexo-git-backup](https://github.com/coneycode/hexo-git-backup)
- 使用git保存源代码(建议)

我本身的源文件就是存放在服务器上，所以不方便使用云来存储代码，hexo-git-backup这个插件对于太新的node也不支持，所以我选择使用git保存源代码。

使用git不仅能够解决同步问题，也可以解决回滚问题，而且也是作者建议的方式——如果你发现了目录里的.gitignore——你应该也会这么认为。

### 备份

假设你把网站搭建在github上面，那么master分支保存静态文件，可以新建hexo分支保存源文件。

首先把本地代码提交到远端，确保远端仓库不存在hexo分支或者hexo分支为空。
```bash
$ cd blog
# 新建本地仓库
$ git init
# 新建并切换到hexo分支
$ git checkout -b hexo
# 本地提交
$ git add .
$ git commit -m 'init'
# 配置远端仓库地址
$ git remote add git@github.com:xxxx/xxxx.github.io.git
# 远端提交
$ git push origin hexo
```

然后进入远端仓库`https://github.com/xxxx/xxxx.github.io`，进入`Settings` --> `Branches`，选择hexo为默认分支。

至此同步配置已经结束，之后每次修改或者新增文件我们需要在本地（确保在hexo分支）提交源文件至远端hexo分支，然后运行`hexo g -d`即可。

### 恢复

如果重装了电脑或者换了电脑，安装git、node、npm、hexo之后，依次执行以下命令即可:
```bash
# 配置新电脑的sshkey到github，或者选择https方式clone
$ git clone git@github.com:xxxx/xxxx.github.io.git -b hexo blog
$ cd blog
# 安装hexo依赖，确保之前安装hexo模块时没有漏掉--save选项
# eg. npm install hexo-deployer-git --save
$ npm install
```
无须执行`hexo init`。

### 弊端

因为github上面repo是公开的，而源文件中会有一些不宜公开的数据配置，所以更保险的做法是使用私人的代码仓库保存源代码，比如收费的github private，或者[码云](http://git.oschina.net/)。