---
layout: post
title: "在谷歌浏览器(Chrome)中运行安卓应用(APK)"
date: 2015-03-15 20:22
comments: true
category: 浏览器
tags: ['Android', 'Chrome']
---

## 介绍

平常我们的Android APK只能在手机或者Pad上运行。由于谷歌提供了能在[ChromeOS](http://www.chromium.org/chromium-os)下运行APK后，外国一个牛人就把它改造成在Chrome下就可以运行了。考虑下电脑上都跑着APK，逆天了。

## 运行先决条件

### 安装依赖扩展应用
- 下载地址在[这里](http://archon.vf.io/ARChon-v1.2-x86_64.zip)，这个是64版本的。可能有些应用已经默认是64的了（又是苹果开的先河呵呵了）因此大家还是下64位的吧。真想要32位的[这里](http://archon.vf.io/ARChon-v1.2-x86_32.zip)也双手奉上。
- 接下来就是打开谷歌浏览器的[扩展应用](chrome://extensions/)，点击链接或者复制这个`chrome://extensions/`到浏览器的地址栏。快捷键`ctrl + L`，OSX下`cmd + L`。先勾上`开发者模式`在页面顶部的右边
- 然后先下载解压到一个文件夹，再到`扩展应用`中选择刚才解压到的文件夹。就可以看到如下图的界面
<img src="/image/post/2015/2015-03-15-21.28.20.png" alt="安装依赖环境">

### 安卓APK转化为扩展应用
- 到`终端`或者`命令行界面下`下安装打包工具`npm install chromeos-apk -g`。未安装过nodejs环境的，请移步到[nodejs与npm安装](http://www.runjf.com/nodejs/nodejs-install)
- 接下来到`APK`所在的目录下执行命令`chromeos-apk --name duokan DkReader_3.4.1_02112111_Duokan.apk`。运行结果如下

	``` bash
rjf-mba:chrome-apk $ chromeos-apk --name duokan DkReader_3.4.1_02112111_Duokan.apk
Directory " com.duokan.reader.android " created. Copy that directory onto your Chromebook and use "Load unpacked extension" to load the application.
	```
- 执行命令后将产生一个文件夹，最后在扩展应用添加该文件夹
<img src="/image/post/2015/2015-03-15-chrome-apk.png" alt="安装扩展应用">
<img src="/image/post/2015/2015-03-15-run-win.png" alt="安装扩展应用">


## 运行扩展应用

在扩展应用中点击对应应用的`启动`链接（蓝色链接地址）
效果如下：
<img src="/image/post/2015/2015-03-15-run.png" alt="效果图OSX">

## 附加说明
- 在生成的**扩展应用**对应的`manifest.json`中添加`"resize": "scale"`配置即可实现应用窗口大小可变功能
- 转换扩展命令`chromeos-apk`支持参数`--tablet`，以实现作为Pad应用（窗口大）。如，`chromeos-apk --tablet --name duokan DkReader_3.4.1_02112111_Duokan.apk`

参考[chromeos-apk](https://github.com/vladikoff/chromeos-apk/blob/master/archon.md)
