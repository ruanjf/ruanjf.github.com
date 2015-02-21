---
layout: post
title: "maven 环境变量设置"
date: 2012-02-12 18:24
comments: true
category: ci
tags: ['maven']
---

## windows
右键我的电脑->属性->高级->环境变量
在系统变量里新建：

```
M2_HOME=D:\Program Files\apache-maven-3.0.4（新建）
```

```
Path=;%M2_HOME%\bin;（追加到原有的系统变量下）
```

在cmd中输入：

``` bat
echo %M2_HOME% #测试环境变量是否生效
mvn -v #测试是否配置正确
```