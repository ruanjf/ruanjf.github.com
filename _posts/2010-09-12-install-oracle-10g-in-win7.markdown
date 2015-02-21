---
layout: post
title: "win7下安装oracle 10g"
date: 2010-09-12 13:24
comments: true
category: oracle
tags: ['oracle','windows']
---

将oralce 10G的安装镜像解压都硬盘，找到/stage/prereq/db/ 下的refhost.xml文件添加如下内容：

``` xml
<!--Microsoft Windows 7-->
<OPERATING_SYSTEM>
<VERSION VALUE="6.1"/>
</OPERATING_SYSTEM>
```

再到install目录中找到oraparam.ini文件，添加如下内容：

``` ini
[Windows-6.1-required]
#Minimum display colours for OUI to run
MIN_DISPLAY_COLORS=256
#Minimum CPU speed required for OUI
#CPU=300
[Windows-6.1-optional]
```

最重要的是下面这一步： 改兼容
如下图：

<img src="/images/post/201209/0_1284269026TwgZ.gif" alt="windows配置">
