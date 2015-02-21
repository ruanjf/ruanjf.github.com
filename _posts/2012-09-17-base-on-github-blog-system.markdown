---
layout: post
title: "windows下用github搭建静态博客（octopress）全过程"
date: 2012-09-17 21:45
modified: 2012-09-17 21:45
category: web
comments: true
tags: ['git','octopress']
---

## git安装
git windows 下安装主要有两种，这里简单介绍下这两种方法以及要注意的地方

- 安装[windows客户端](http://github-windows.s3.amazonaws.com/GitHubSetup.exe)基本上不会出现什么特殊情况
- 安装[msysgit](http://code.google.com/p/msysgit/downloads/list)现在最新的就好了，不会配置的[看图](https://help.github.com/articles/set-up-git)一步步来。
接下来就是[生成SSH keys](https://help.github.com/articles/generating-ssh-keys)按照其中的步骤做完，至于[ssh](http://zh.wikipedia.org/wiki/SSH)不知是何物的同学要科普了解下就可以了。
这里要注意的就是权限问题，用命令查看下有没有ssh key

``` bash
ssh-add -l 
#没有的话就添加下
ssh-add 
#或者
ssh-add 路径
```
到此git安装就算到一个阶段

----------

## octopress安装
当然也要介绍下这[octopress](http://octopress.org/)，为啥不用[jekyllbootstrap](http://jekyllbootstrap.com/)。个人主要考虑两点：1、方便插件好用 2、更新及时（jekyllbootstrap好几个月都没动静了，作者在另外一个项目可活跃了）。这个安装比较繁琐同学跟着做就好了。

- 安装前提环境，git上面就讲过了剩下的就是基于ruby的应用了。这样有[安装包](http://rubyinstaller.org/downloads/)windows下安装挺方便的（还提供了压缩包的对于喜欢绿色的同学还是不错的）。接下来就是配置下[环境变量](http://baike.baidu.com/view/95930.htm) 新建`RUBY_HOME=F:\ruby\ruby-1.9.3-p194-i386-mingw32` 和 编辑`Path`添加`;%RUBY_HOME%\bin;` 由于octopress对python依赖挺大的，所以也要[安装](http://www.python.org/ftp/python/2.7.3/python-2.7.3.msi)。接下来还是一样的配置环境变量，新建`PYTHON_HOME=F:\python\Python27` 和 编辑`Path`添加`;%PYTHON_HOME%;`
看下安装的是否可用

``` bash
python --version
ruby --version
```

- [安装octopress](http://octopress.org/docs/setup/)安装其中说的做，其中

``` bash
rbenv rehash    # If you use rbenv, rehash to be able to run the bundle command
```
这个出错可以忽然

- [关联github](http://octopress.org/docs/deploying/github/)如果配置http://username.github.com这样的就看(With Github User/Organization pages)部分，如果配置http://username.github.com/project这个的就看（With Github Project pages (gh-pages)）最后有域名的可以加下`CNAME`，注意不用它说的命令加文件在windows会产生编码问题，自己新建下也是挺快的（域名只支持一个不要填多个会无效的）。

----------

## 写博客
主要是以下几个命令

``` bash
rake new_post["title"]
#新建标题为title的文章

rake generate
#生成文章等

rake preview
#预览博客默认htt://localhost:4000地址

rake deploy
#发布博客到github，这样就可以用http://username.github.com访问了
```

生成文章建议用`utf-8`编码原因是html编码是`utf-8`，因此有两个文件要改
ruby安装路径下的

``` ruby
#27行self.content = File.read(File.join(base, name))换成
self.content = File.read(File.join(base, name), :encoding => "utf-8")
#octopress文件夹下的22行highlighted_code = File.read(path)换成
highlighted_code = File.read(path, :encoding => "utf-8")
```

这样生成是就不会报错了，血淋淋的经验啊！