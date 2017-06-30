---
title: 使用virtualenvwrapper(Linux + Windows)
date: 2017-01-10 15:03:33
tags: [Python]
categories: [开发, Python]
---

生活的问题在于，你永远不知道下一个到来的是什么问题。开发亦然。之前Python都是用一个运行环境，偶尔用一下virtualenv，直到开始在windows调试python才不得不来学习virtualenvwrapper。<!-- more -->

## 简介

Virtualenvwrapper解决的主要问题是和virtualenv一样的，但是它弥补了virtualenv无法统一管理环境的缺点。

## 安装

virtualenvwrapper安装方式还是比较简单的。

### Linux

1.安装
```
pip install virtualenvwrapper
```

2.设置环境变量
```
export WORKON_HOME=~/Envs
export PROJECT_HOME=$HOME/pyproj
source /usr/bin/virtualenvwrapper.sh
```
建议添加到自启动脚本中`~/.bashrc` 或 `~/.profile`。

### Windows

windows下直接安装virtualenvwrapper似乎不能运行。
我搜索到有独立的安装包，也能通过pip安装。https://github.com/davidmarble/virtualenvwrapper-win。

1.安装
```
# using pip
pip install virtualenvwrapper-win

# using easy_install
easy_install virtualenvwrapper-win

# from source
git clone git://github.com/davidmarble/virtualenvwrapper-win.git
cd virtualenvwrapper-win
python setup.py install
```

2.设置环境变量（可选）
```
Optional: Add an environment variable WORKON_HOME to specify the path to store environments. By default, this is `%USERPROFILE%\Envs`。
```

3.可能出现的错误
```
  File "D:\Python\Python27\Lib\mimetypes.py", line 249, in enum_types
        ctype = ctype.encode(default_encoding) # omit in 3.x!
UnicodeDecodeError: 'ascii' codec can't decode byte 0xb0 in position 1: ordinal not in range(128)
```
原因是某些程序（阿里旺旺）写了一些中文键值到注册表里。具体看http://pcliuyang.blog.51cto.com/8343567/1339637

**解决方法**：打开`Python27/Lib/mimetypes.py`，找到`default_encoding = sys.getdefaultencoding() `一行，在它前面添加如下代码：
```
# begin fix bug
if sys.getdefaultencoding() != 'gbk':
        reload(sys)
        sys.setdefaultencoding('gbk')
# end
```

## 命令

主要命令Linux和windows是一致的，部分有出入。

### 主要命令

``mkvirtualenv <name>``
    Create a new virtualenv environment named *<name>*.  The environment will
    be created in WORKON_HOME.

``lsvirtualenv``
    List all of the enviornments stored in WORKON_HOME.

``rmvirtualenv <name>``
    Remove the environment *<name>*. Uses ``folder_delete.bat``.

``workon [<name>]``
    If *<name>* is specified, activate the environment named *<name>* (change
    the working virtualenv to *<name>*). If a project directory has been
    defined, we will change into it. If no argument is specified, list the
    available environments. One can pass additional option -c after
    virtualenv name to cd to virtualenv directory if no projectdir is set.

``deactivate``
    Deactivate the working virtualenv and switch back to the default system
    Python.

``add2virtualenv <full or relative path>``
    If a virtualenv environment is active, appends *<path>* to
    ``virtualenv_path_extensions.pth`` inside the environment's site-packages,
    which effectively adds *<path>* to the environment's PYTHONPATH.
    If a virtualenv environment is not active, appends *<path>* to
    ``virtualenv_path_extensions.pth`` inside the default Python's
    site-packages. If *<path>* doesn't exist, it will be created.

### 其他命令

``cdproject``
    If a virtualenv environment is active and a projectdir has been defined,
    change the current working directory to active virtualenv's project directory.
    ``cd-`` will return you to the last directory you were in before calling
    ``cdproject``.

``cdsitepackages``
    If a virtualenv environment is active, change the current working
    directory to the active virtualenv's site-packages directory. If
    a virtualenv environment is not active, change the current working
    directory to the default Python's site-packages directory. ``cd-``
    will return you to the last directory you were in before calling
    ``cdsitepackages``.

``cdvirtualenv``
    If a virtualenv environment is active, change the current working
    directory to the active virtualenv base directory. If a virtualenv
    environment is not active, change the current working directory to
    the base directory of the default Python. ``cd-`` will return you
    to the last directory you were in before calling ``cdvirtualenv``.

``lssitepackages``
    If a virtualenv environment is active, list that environment's
    site-packages. If a virtualenv environment is not active, list the
    default Python's site-packages. Output includes a basic listing of
    the site-packages directory, the contents of easy-install.pth,
    and the contents of virtualenv_path_extensions.pth (used by
    ``add2virtualenv``).

``setprojectdir(win)/setvirtualenvproject(Linux)`` 
    这两个命令功能相同，但是格式不同。`setprojectdir`只需要一个参数，指定工程主目录。`setvirtualenvproject`需要两个参数，参数一指定虚拟环境目录，参数二指定工程主目录。参数可省略，省略时使用当前的虚拟环境和当前目录。

```bash
# setvirtualenvproject 用法示例
$ mkproject myproj
New python executable in myproj/bin/python
Installing setuptools.............................................
..................................................................
..................................................................
done.
Creating /Users/dhellmann/Devel/myproj
(myproj)$ mkvirtualenv myproj_new_libs
New python executable in myproj/bin/python
Installing setuptools.............................................
..................................................................
..................................................................
done.
Creating /Users/dhellmann/Devel/myproj
(myproj_new_libs)$ setvirtualenvproject $VIRTUAL_ENV $(pwd)
```
   

``toggleglobalsitepackages``
    If a virtualenv environment is active, toggle between having the
    global site-packages in the PYTHONPATH or just the virtualenv's
    site-packages.

``whereis <file>``
    A script included for convenience. Returns directory locations
    of `file` and `file` with any executable extensions. So you can call
    ``whereis python`` to find all executables starting with ``python`` or
    ``whereis python.exe`` for an exact match.

``mkproject(Only in Linux)``
    项目将创建到PROJECT_HOME目录下，实际上相当于在某个目录下，建了一个环境。
