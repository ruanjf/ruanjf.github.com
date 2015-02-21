---
layout: post
title: "nodejs与npm安装"
date: 2013-05-12 20:12
comments: true
category: nodejs
tags: ['nodejs']
---

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