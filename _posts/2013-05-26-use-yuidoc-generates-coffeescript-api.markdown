---
layout: post
title: "使用YUIDoc生成CoffeeScript的API文档"
date: 2013-05-26 20:29
comments: true
category: javascript
tags: ['nodejs', 'CoffeeScript']
---

## 前提环境
生成api文档的程序是基于nodejs编写的，因此需安装nodejs参看[这里](http://www.runjf.com/posts/nodejs-install)

## 安装

``` bash
npm -g install yuidocjs
```

## 使用

``` js
/**
* This is the description for my class.
*
* @class MyClass
* @constructor
*/
```

上面注释为yuidoc提供的文档格式，下面为coffeescript的文档格式。
按照下面的格式即可使用yuidoc生产帮助文档

``` coffeescript
###*
# This is the description for my class.
#
# @class MyClass
# @constructor
###
```

## 生成

``` bash
# 先进入coffeescript源码所在的文件夹
yuidoc --syntaxtype coffee -e .coffee .
```
生成的文档类似于[yuidoc api](http://yui.github.io/yuidoc/api/)