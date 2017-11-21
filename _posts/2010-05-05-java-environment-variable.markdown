---
layout: post
title: "java 环境变量配置"
date: 2010-05-05 13:55
comments: true
category: java
tags: ['java']
---
## windows
右键我的电脑-属性-高级-环境变量
在系统变量里新建(jdk的安装路径)

```
JAVA_HOME=F:\Java\jdk1.6.0_12
Path=;%JAVA_HOME%\bin;%JAVA_HOME%\jre\bin;
```

注意，这个要添加到系统原来的PATH前面，要像有些人说的加后面可能会不能编译。

``` 
Classpath=.;%JAVA_HOME%\lib\tools.jar;%JAVA_HOME%\lib\dt.jar;%JAVA_HOME%\jre\lib\rt.jar
```
然后就是试下看是否配置成功了 
关于设置`JAVA HOME`的必要性：你若装TOMCAT或ORACLE等都会改变你的环境设置，总是改`path`，`classpath`容易出错也不方便，
所以JAVA HOME就有了统一指向性，方便不易出错。
开始-运行-CMD然后`java`、`javac`会出现很多操作说明，也可以`java -version`查看版本信息。
再就是自己编个简单的JAVA文件试下了。

## linux
在文件/etc/profile末尾添加如下内容(你的jdk所在位置)

``` bash
JAVA_HOME=/usr/java/jdk1.6.0_25
PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/jre/lib/rt.jar
export JAVA_HOME
export PATH
export CLASSPATH
```

source /etc/profile

 
注意：linux下面用冒号分割
解决`java/lang/NoClassDefFoundError: java/lang/Object` 错误
`$JAVA_HOME/lib/ tools.pack`转为`tools.jar` 
`$JAVA_HOME/jre/lib/rt.pack`转为`rt.jar`

``` bash
$ unpack200 rt.pack rt.jar
```

