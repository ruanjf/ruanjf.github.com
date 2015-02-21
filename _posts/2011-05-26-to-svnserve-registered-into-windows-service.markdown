---
layout: post
title: "把 svnserve 注册成 windows service 的正确命令"
date: 2011-05-26 15:57
comments: true
category: ci
tags: ['windows']
---

Subversion的文档里的那个命令是错误的，错误的地方一个是 binpath 应该是 binPath, displayname 也应该是 DisplayName:

``` bat
sc create svn binPath= "\"C:\Program Files\Subversion\bin\svnserve.exe\" --service -r D:\SVN" DisplayName= "Subversion Server" depend= Tcpip start= auto
```
请注意，

- 如果你的svnserve的path中有空格，那么用 `\"` 是必须的
- `--service` 也是必须的
- `-r D:\SVN` 定义的是你的repository的根目录，也就是包含了`conf`、`dav`、`hooks`等目录的那个目录

其他的命令详见 `sc --help`