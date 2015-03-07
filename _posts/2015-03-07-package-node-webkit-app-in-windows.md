---
layout: post
title: "Windows环境下node-webkit应用打包"
date: 2015-03-07 20:05
comments: true
category: nodejs
tags: ['windows', 'javascript']
---

## 先介绍下流程
1. 创建两个`bat`文件`package_gateway-nw.bat`和`build_gateway-nw.bat`，文件内容文章下面介绍
2. 将`package_gateway-nw.bat`文件放于node-webkit应用的源码文件夹，用于打包源码
3. 将`build_gateway-nw.bat`文件放于`node-wekbit`运行目录下，运行环境下载[地址](https://github.com/nwjs/nw.js#user-content-downloads)
4. 执行`build_gateway-nw.bat`,进行打包和生成可执行文件。逻辑如下

	- `build_gateway-nw.bat`内部使用call调用`package_gateway-nw.bat`生成文件`xxx.nw`到`build_gateway-nw.bat`文件所在的文件夹
	- 使用系统的`copy`命令进行生成可执行程序以`xxx.exe`
	- 使用`7z`进行压缩生成`xxx.zip`，方便拷贝

## 压缩应用代码

压缩的批处理文件`package_gateway-nw.bat`内容如下：

``` bat
@rem 打包使用zip格式，生成xxx.nw的文件名，
del gateway-nw.nw
"D:\Program Files\7-Zip\7z.exe" a -tzip gateway-nw.nw -x!.git -x!html "%~dp0"\*
```
使用来[7z](http://sparanoid.com/lab/7z/)进行压缩，其中需要提下的是

- `-x!xxx` 这个是7z压缩的附加指令，用于排除需要的`xxx`文件
- `%~dp0` 这个表示当前批处理文件所在目录，这个`bat`文件和源码放一起

## 生成可执行文件

压缩的批处理文件`build_gateway-nw.bat`内容如下：

``` bat
del gateway-nw.nw
del gateway-nw-ia32.exe
del gateway-nw-win-ia32.zip

@rem 打包工程操作 使用call 确保环境
call ..\gateway-nw\package_gateway-nw.bat

@rem 生成exe
copy /b nw.exe+gateway-nw.nw gateway-nw-ia32.exe
del gateway-nw.nw

@rem 打包可用的zip
"D:\Program Files\7-Zip\7z.exe" a -tzip gateway-nw-win-ia32.zip -x!pdf.dll -x!nwsnapshot.exe -x!nw.exe -x!
build_gateway-nw.bat "%~dp0"\*
```
其中需要提下的是

- `call` Windows下系统命令用于调用`build_gateway-nw.bat`，使用独立的运行环境
- `coyp` Windows下的系统命令用于生成执行文件

参考[nwjs](https://github.com/nwjs/nw.js/wiki/How-to-package-and-distribute-your-apps)
