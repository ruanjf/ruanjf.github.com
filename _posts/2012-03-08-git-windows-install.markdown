---
layout: post
title: "git windows 下搭建全过程"
date: 2012-03-08 00:56
comments: true
category: ci
tags: ['git']
---

1、 Git，Windows下的Git，地址：`http://msysgit.googlecode.com/files/Git-1.7.9-preview20120201.exe`（方便下载）

2 、SSH，可以用CopSSH，地址：`http://sqmcc2.newhua.com/down/Copssh_4.1.0_Installer.zip`（方便下载）

3、git、CopSSH安装可以参照（注意：看图片就好了其它的无视）：`http://www.codeproject.com/Articles/296398/Step-by-Step-Setup-Git-Server-on-Windows-with-CopS`

强调下：在安装CopSSH是需要创建用户，这里创建的用户是git，所以下面的地址才可能是`git@127.0.0.1`

4、配置（windows系统的）git环境变量，在Path后面追加（复制下面代码改下git的安装路径就可以了）

``` bat
;D:\Program Files\Git\bin;D:\Program Files\Git\libexec\git-core;
```

5、配置copssh的（文件在安装目录下的etc文件夹里）profile（复制下面代码改下git的安装路径就可以了）

``` bash
gitpath=`/bin/cygpath  D:/Program\ Files/Git/bin`  #这里不是引号，路径是Git下的cmd，斜杠也要用Unix的习惯
gitlibpath=`/bin/cygpath  D:/Program\ Files/Git/libexec/git-core`
export PATH="$PATH:$gitpath:$gitlibpath"
```

6、测试

打开git bash 登陆`ssh git@127.0.0.1`

例如创建一个测试库（按顺序输入）：

``` bash
mkdir test
cd test
git init
touch a b c d
git add .
git commit -m "init"
```
然后，就可以在远程clone这个库（test）了。clone命令如下：
`git clone git@192.168.1.103:testgit aa`
到此git windows下搭建环境完成。