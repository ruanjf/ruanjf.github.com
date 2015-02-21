---
layout: post
title: "Linux下监控进程状态"
date: 2013-07-17 21:03
comments: true
category: linux
tags: ['linux']
---

写什么脚本都是有原因的，由于在写的时候没找到好用的监控工具，不过后面发现了[nmon](http://nmon.sourceforge.net/)，脚本中有些东西还是可以记下来的，这边就大概介绍下

## 用法

``` bash
# 进入到脚本所在目录
cd /root/monitoring/
# 运行脚本
nohup monitoring.sh &
# 当然也可以一步合成
cd /root/monitoring/ && nohup monitoring.sh &
```
其中有几个文件需要注意：

 - `config.ini`记录了一些配置信息，原始是用来监控java的情况的（ps：本人从事j2ee的开发因此才监控与web容器相关的信息）
 - `monitoring.sh`监控程序主体

单次监控记录结果如下：

``` bash
[2012-10-01 00:02:20] cpu=0 mem=8.6 netstat_p=13 netstat_t=41 netstat_a=450 lsof_p=436 lsof_a=6346
# 这里详细介绍下各项的含义（注：记录的信息都是针对监控进程当时的瞬间信息，下面就不在重复）
# cpu cpu的使用情况
# mem 内存的使用情况
# netstat_p 进程相关的网络连接数(相对于WEB应用这个还是挺重要的指标)
# netstat_t [TCP](http://zh.wikipedia.org/zh/TCP)相关的网络连接数
# netstat_a 总的网络连接数
# lsof_p 进程的文件打开数（被这货坑过一次，程序的各项指标正常但是无法访问，这个下次发文细讲）
# lsof_a 系统总的文件打开数
```

## 配置说明
这边列出几点可能需要修改的配置，配置文件修改后自动识别，并将在下次执行监控是生效，无需重新启动

``` bash
# 监控程序(默认监听init)
p_name=java

# 监控时间间隔（单位秒）
s_time=900

# 监控cpu上限（cpu使用率参考top）
max_cpu=49

# 监控内存上限（mem使用百分比参考top）
max_mem=40

# 监控连接数（程序的）
max_netstat=400

# 文件打开最大数
max_lsof=10000
``` 

## 有价值的地方

 - `$(cd "$(dirname "$0")"; pwd)`获得脚步所在的目录
 - `${#runs[@]}`获取数组`runs`的长度，可用于累加赋值`runs[${#runs[@]}]=$value`
 - `for i in $(seq ${#runs[@]})`执行命令并返回结果给for

## 源代码如下：（or [这里](https://gist.github.com/ruanjf/6000151)）
<script src="https://gist.github.com/ruanjf/6000151.js"></script>
