---
layout: post
title: "Sublime Text 2 文本编辑器介绍"
date: 2013-05-05 10:12
comments: true
category: sublime
tags: ['sublime']
---

## 个人看重的功能：

 - 集成vi操作（释放鼠标）
 - Command Palette（快捷操作）
 - Package Control（化繁为简）
 - 开放配置定制（习惯性操作）
 - 多样布局（只需一个）
 - 文件夹内文件内容查找（实用杠杠的）


如果不想看这个的童鞋可以看[视频](http://www.youku.com/playlist_show/id_19239558.html)不过是英文的


## 安装

这里提供各种口味的下载地址，或者去[官方网站](http://www.sublimetext.com)

[Windows 安装版](http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1%20Setup.exe)、 [Windows 便携版](http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1.zip)、 [Windows 64 bit 安装版](http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1%20x64%20Setup.exe)、 [Windows 64 bit 便携版](http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1%20x64.zip)

[Linux 32 bit](http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1.tar.bz2)、 [Linux 64 bit](http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1%20x64.tar.bz2)

[Mac OS X](http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1.dmg)

对于使用便携版的童鞋这里提供Windows右键菜单关联批处理（bat）需与Sublime Text运行程序放同一目录下

添加右键的`add_right.bat`，请复制代码后自行新建bat文件

``` bat
@echo off
@reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shell\Sublime Text 2" /t REG_EXPAND_SZ /v "Icon" /d "\"%~dp0sublime_text.exe\",0" /f
@reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shell\Sublime Text 2\command" /t REG_EXPAND_SZ /v "" /d "\"%~dp0sublime_text.exe\" \"%%1\"" /f
@reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Folder\shell\Sublime Text 2" /t REG_EXPAND_SZ /v "Icon" /d "\"%~dp0sublime_text.exe\",0" /f
@reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Folder\shell\Sublime Text 2\command" /t REG_EXPAND_SZ /v "" /d "\"%~dp0sublime_text.exe\" \"%%1\"" /f
pause
```

删除右键的`del_right.bat`，请复制代码后自行新建bat文件

``` bat
@echo off
@reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shell\Sublime Text 2" /f
@reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Folder\shell\Sublime Text 2" /f
pause
```

## vi操作
这个以后专文介绍，大家也可以[Google](http://203.208.46.146/)之

## Command Palette
这东西的主要作用是快速查找命令（新建、设置语法高亮、Package Control）在你知道有这功能，但不知道快捷键时这功能就体现出来了。当然呼出它的快捷键可不能忘`Ctrl+Shift+P`就是它

## Package Control
这东西的主要作用是安装管理插件。某人说过好的GOV管的事情很少，大部分都让市场来做。跟这道理是一样一样的

鄙人认为这功能太他妈好用了，插件思想、独立更新类似[Maven](http://maven.apache.org/)、[npm](https://npmjs.org/)等。软件就是主模块加插件系统，插件系统结合[GitHub](https://github.com/)太完美了

Package Control这么用呢？

 - 安装插件
  
	先按`Ctrl+Shift+P`然后输入`ins pake`再按回车（其实就是install package，可以不全输入它会模糊匹配，这功能也很赞），接下来就是输入插件名称过滤然后回车确定等待安装完成就ok了
 - 删除插件

	先按`Ctrl+Shift+P`然后输入`rem pake`再按回车（其实就是remove package）
 - 启用插件

	先按`Ctrl+Shift+P`然后输入`ena pake`再按回车（其实就是enable package
 - 禁用插件

	先按`Ctrl+Shift+P`然后输入`dis pake`再按回车（其实就是disable package）
 - 更新插件

	先按`Ctrl+Shift+P`然后输入`upg pake`再按回车（其实就是upgrade package）

## 开放配置定制
这里包含软件配置、快捷键配置。都可以通过命令打开。修改文件的时候要注意满足[json](http://www.json.org/json-zh.html)格式

 - 软件配置

	先按`Ctrl+Shift+P`然后输入`prefer set`再按回车（其实就是preferences settings default）可以看下那些配置需要修改的，建议修改到用户的配置中（preferences settings user操作如上）方便以后更新（这思想好多地方都适用）。

 - 快捷键配置

	先按`Ctrl+Shift+P`然后输入`prefer key  set`再按回车（其实就是preferences key bindings settings default）。支持命令组合，调用插件Cool。目测Sublime Text 3又加强了
	下面是的一些常用快捷键，与[eclipse](http://eclipse.org/)一致

	``` json
[
	{ "keys": ["f8"], "command": "toggle_setting", "args": {"setting": "word_wrap"} },
	{ "keys": ["ctrl+enter"], "command": "insert", "args": {"characters": "\n"} },
	{ "keys": ["shift+enter"], "command": "run_macro_file", "args": {"file": "Packages/Default/Add Line.sublime-macro"} },
	{ "keys": ["ctrl+shift+enter"], "command": "run_macro_file", "args": {"file": "Packages/Default/Add Line Before.sublime-macro"} },
	{ "keys": ["ctrl+shift+up"], "command": "select_lines", "args": {"forward": false} },
	{ "keys": ["ctrl+shift+down"], "command": "select_lines", "args": {"forward": true} },
	{ "keys": ["ctrl+alt+up"], "command": "run_macro_file", "args": {"file": "Packages/User/Duplicate Line Before.sublime-macro"} },
	{ "keys": ["ctrl+alt+down"], "command": "duplicate_line" },
	{ "keys": ["alt+up"], "command": "swap_line_up" },
	{ "keys": ["alt+down"], "command": "swap_line_down" },
	{ "keys": ["alt+/"], "command": "auto_complete" },
	{ "keys": ["alt+/"], "command": "replace_completion_with_auto_complete", "context":
		[
			{ "key": "last_command", "operator": "equal", "operand": "insert_best_completion" },
			{ "key": "auto_complete_visible", "operator": "equal", "operand": false },
			{ "key": "setting.tab_completion", "operator": "equal", "operand": true }
		]
	}
]

	```

## 多样布局

通过快捷键`Alt+Shift+1`到`Alt+Shift+5`等可以实现分屏的功能

### 文件夹内文件内容查找
右键文件夹（前提你已经添加了我前面说的`add_right.bat`）用Sublime Text打开，左边将出现文件列表（未出现的先按`Ctrl+Shift+P`然后输入`side bar`再按回车即可出现）

右键需要搜索的文件夹，找到`Find in Project...`接下来输入查找内容