
---
layout: post
title: "配置Tocmat成window的服务"
date: 2015-11-22 16:21
comments: true
category: java
tags: ['Web']

---


## 缘由

1. 由于机子存在断电的情况，重启后对应的因为又未重启如`Tomcat`。因此需要进行自启动配置
2. 在配合Jenkins进行项目部署时需要先停止tomcat，再进行启动

## 添加启动方式

有两种方式可以实现自启动

1. Windows任务计划
2. 注册成服务

### 使用Windows任务计划的方式

打开`cmd`命令行窗口，可以通过快捷键`Win + r`再输入`cmd`按回车即可。在开的界面中输入如下内容：

```
SCHTASKS /Create /RU SYSTEM /SC ONSTART /TN Tomcat9180Gateway /TR "D:\apache-tomcat-6.0.36-gateway\bin\start.bat"
```

其中`Tomcat9180Gateway`是任务计划的名称，`"D:\apache-tomcat-6.0.36-gateway\bin\start.bat"`是应用的启动地址


### 使用注册Windows服务的方式

1. 首先还是要打开`cmd`命令行窗口，然后进入到`Tocmat`所在目录。也可以进入到所在文件夹按住`Shift`后右键可以看到一个命令行的选项，点击即可
2. 进入到`bin`目录中，输入`service.bat install gateway`其中`gateway`是服务名称。注册成功后命令行窗口会提示`The service 'gateway' has been installed`。

> 需要注意的问题是，如果发现`bin`目录中没有`service.bat`，这大概就是你的Tomcat包下的不对了，apache官网提供了多种方式的包。需要选择有包含附加命令的
