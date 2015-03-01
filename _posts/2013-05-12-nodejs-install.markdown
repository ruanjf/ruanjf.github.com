---
layout: post
title: "nodejs与npm安装"
date: 2013-05-12 20:12
modified: 2015-03-01 20:41
comments: true
category: nodejs
tags: ['nodejs']
---
## Mac OS X环境

OSX下使用[nvm](https://github.com/creationix/nvm/)来管理nodejs的版本所有这里就介绍`nvm`的安装和使用配置，以及我个人附加的修改

### 下载

在OSX环境下很方便不需要手动去网站下载软件这步就免了。通过[brew](http://brew.sh/)进行下载安装，顺便说下这货类似于Linux下的`apt-get`、`yum`实在方便，忍不住要吐槽Windows不带这样的。

### 安装

打开终端执行下面的命令，注意`#`井号后面的是注释不要连带复制了。

``` bash
brew install nvm # 安装nvm
source $(brew --prefix nvm)/nvm.sh # 初始化配置
nvm install 0.11 # 安装nodejs的0.11.x版本
nvm use 0.11 # 启用0.11.x版本
npm config set prefix "$NVM_DIR/`nvm current`" # 设置nodejs的安装路径
npm config get prefix # 查看显示的路径是否为你需要安装的nodejs，通常是不会错啦
```

### 配置

在`shell`环境配置中添加下面配置，注本人用的`zsh`对应的文件为`.zshrc`,如果用的是`bash`的话对应的文件就是`.bashrc`。打开`.zshrc`在末尾添加如下内容

``` bash
# 这个是设置了一个别名方便在shell中使用nvm。官方的配置是直接在启动shell的时候执行source，这样导致启动的时候都得执行这个不太有用的命令。本人做的修改是在必要的时候去执行snvm来启用nvm
alias snvm="source $(brew --prefix nvm)/nvm.sh"

# 设置默认的nodejs安装路径
export NODE_HOME="/usr/local/opt/nvm/v0.11.14"
# 帮助文档
export MANPATH="${NODE_HOME}/share/man:$MANPATH"
# 添加到可执行环境变量中
export PATH="$NODE_HOME/bin:$PATH"
＃ 设置别名用于切换nodejs版本后，修改npm中记录的nodejs安装路径
alias snpmp="npm config set prefix $NODE_HOME && npm config get prefix"

#export PATH="${NODE_HOME}/bin:$NODE_HOME/lib/node_modules/npm/bin/node-gyp-bin:$PATH"
```


### 测试

``` bash
rjf-mba:~ $ node -v          
v0.11.13
rjf-mba:~ $ npm -v
1.4.9
rjf-mba:~ $ 

```
安装后进行测试有出现对应的版本说明nodejs安装成功了可以正常使用啦



## Windows环境

### 下载

 - [nodejs](http://nodejs.org/download/) 快捷地址[v0.10.5 32-bit](http://nodejs.org/dist/v0.10.5/node.exe)、[v0.10.5 64-bit](http://nodejs.org/dist/v0.10.5/node.exe)
	
	这里提供的是单一exe的版本，当然也可以下载安装版本的

 - [npm](http://nodejs.org/dist/npm/) 快捷地址[npm-1.2.9](http://nodejs.org/dist/npm/npm-1.2.9.zip)
	
	npm当然要自己动手下载，用`npm install npm`是有问题的这时npm命令还不可用

### 安装
 - 拷贝下载的`node.exe`到你想安装的地方

	建议新建一个`node`文件夹，然后把`node.exe`复制到该文件夹

 - 解压`npm-xxx.zip`的内容到`node.exe`所在的文件夹

### 配置

 - 新建NODE_HOME
	
	在环境变量中添加`NODE_HOME=C:\Program Files\node`其中`C:\Program Files\node`为`node.exe`所在的路径

 - 新建NODE_PATH
	
	在环境变量中添加`NODE_PATH=%NODE_HOME%\node_modules`
	

 - 添加Path的值

	在环境变量`Path`值得末尾中添加`;%NODE_HOME%;`

### 测试
进入`cmd`命令行

``` bat
Microsoft Windows [版本 6.2.9200]
(c) 2012 Microsoft Corporation。保留所有权利。

C:\Users\rjf>node -v
v0.10.5

C:\Users\rjf>npm -v
1.2.19

C:\Users\rjf>
```

如出现`v0.10.5`则表明nodejs安装成功了。如出现`1.2.19`则说明npm安装成功了，这时候就可以使用`npm install xxx`或者`npm install -g xxx`来安装其他包了

## Linux环境
Soon...
