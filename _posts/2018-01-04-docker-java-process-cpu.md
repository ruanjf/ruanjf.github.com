---
layout: post
title: "在Docker内定位使用CPU过高的Java进程"
date: 2018-01-04 14:33
comments: true
category: linux
tags: ['java', 'jvm', 'linux' , 'docker']
---

当访问应用需要很长时间才响应时可以登录到系统上使用`top`命令查看CPU使用情况，如果发现CPU使用过高则可以通过下面所讲的方法定位问题。本文将介绍如何定位Docker内使用CPU过高的Java进程

首先，通过`top`命令找到CPU使用过高的进程（如：`7152`），如下信息已忽略top的头信息

```
 PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
7152 root      20   0 1668880 308248   4640 S  1.3 16.4   8:14.01 java
1390 root      20   0  129848   7080   1708 S  0.3  0.4 153:43.35 AliYunDun
2451 root      20   0  166704   4548    440 S  0.3  0.2  30:11.21 ilogtail
2509 root      20   0  134896   2788      0 S  0.3  0.1   1:16.78 docker-containe
```


## 确定进程信息

判断该进程是否在Docker容器中（如果有在则找出对于的容器）有两种方式

- 使用`cat /proc/7152/cgroup`查看打印内容是否包含`:/docker/`。原理是Docker使用了Linux [cgroups](https://zh.wikipedia.org/wiki/Cgroups)
    
    ```
    11:memory:/docker/b7a84996139a834966df09d10b8a50082b5043153f633f5f5fd2638de0ebc206
    10:hugetlb:/docker/b7a84996139a834966df09d10b8a50082b5043153f633f5f5fd2638de0ebc206
    9:cpuset:/docker/b7a84996139a834966df09d10b8a50082b5043153f633f5f5fd2638de0ebc206
    8:cpuacct,cpu:/docker/b7a84996139a834966df09d10b8a50082b5043153f633f5f5fd2638de0ebc206
    7:perf_event:/docker/b7a84996139a834966df09d10b8a50082b5043153f633f5f5fd2638de0ebc206
    6:freezer:/docker/b7a84996139a834966df09d10b8a50082b5043153f633f5f5fd2638de0ebc206
    5:devices:/docker/b7a84996139a834966df09d10b8a50082b5043153f633f5f5fd2638de0ebc206
    4:net_prio,net_cls:/docker/b7a84996139a834966df09d10b8a50082b5043153f633f5f5fd2638de0ebc206
    3:blkio:/docker/b7a84996139a834966df09d10b8a50082b5043153f633f5f5fd2638de0ebc206
    2:pids:/docker/b7a84996139a834966df09d10b8a50082b5043153f633f5f5fd2638de0ebc206
    1:name=systemd:/docker/b7a84996139a834966df09d10b8a50082b5043153f633f5f5fd2638de0ebc206
    ```
    如果有打印docker信息则可以通过`docker inspect --format '{{ .Name }} b7a849961`查询到容器的名称，其中`b7a849961`为容器id的前几个字符

- 使用`pstree -s 7152`查看打印的进程树是否包含`docker-containe`，显示信息如下：

    ```
    systemd(1)───docker(1101)───docker-containe(1447)───docker-containe(7088)───entrypoint.sh(7099)───java(7152)─┬─{java}(7177)
    ```
    其中只显示了第一行，后面包含多个线程未显示出来
    如果有包含`docker-containe`则可以通过`docker ps -q | xargs docker inspect --format '{{ .State.Pid }} {{ .Name}}' |grep 7099`显示出容器名称，其中`7099`为容器进程ID

如果是非Docker容器进程则可以通过`ps -ef |grep 7152`查看进程启动信息，以确定具体的应用。

## 确定进程中的线程CPU使用情况

通过`top -H -p 7152`，如下信息已忽略top的头信息

```
  PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
27603 root      20   0 1669908 308540   4580 S  4.7 16.4   0:00.43 java
 7182 root      20   0 1669908 308540   4580 S  0.3 16.4   0:16.46 java
27602 root      20   0 1669908 308540   4580 S  0.3 16.4   0:13.82 java
 7152 root      20   0 1669908 308540   4580 S  0.0 16.4   0:00.01 java
 7177 root      20   0 1669908 308540   4580 S  0.0 16.4   0:16.04 java
```

或者`ps -To pcpu,tid,pid,user 7152 |sort -r -k1 |more`

```
%CPU   TID   PID USER
 6.3  7234  7152 root
 0.0  8715  7152 root
 0.0  8650  7152 root
 0.0  8563  7152 root
 0.0  8558  7152 root
```

找出CPU使用过高的线程ID（如：`7234`）。

注意，如果是在Docker中的容器的话需要进入到对应的容器中否则执行出来的线程ID将不对应，无法匹配后续的信息。可以通过`docker exec -it b7a849961 ps -ef`列出容器内部的进程列表（由于容器基本上是单进程或者少数几个进程可以很方便的辨认出对于的需要查看的进程），打印信息如下：

```
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 Mar02 ?        00:00:00 /bin/sh /sbin/entrypoint.sh
root         5     1  0 Mar02 ?        00:08:44 /usr/lib/jvm/java-7-openjdk-amd6
root        90     0  0 16:16 ?        00:00:00 ps -ef
```

通过观察发现进程号为`5`因此修改上面的命令为`docker exec -it b7a849961 top -H -p 5`或者`docker exec -it b7a849961 ps -To pcpu,tid,pid,user 5 |sort -r -k1 |more`这时可打印类似上面的结果

```
%CPU   TID   PID USER
 9.3    26     5 root
 0.0    66     5 root
 0.0    65     5 root
 0.0    63     5 root
 0.0    62     5 root
 0.0    56     5 root
 0.0     5     5 root
 0.0    54     5 root
```

这时可找出CPU使用过高的线程ID（如：`26`）。

## 进行Jvm线程Dump

通过Jvm线程Dump可以查出线程对应的Class，从而达到定位Java代码的作用

这里介绍两种进行线程Dump的方法

- 通过`jstack`命令，使用`jstack -l <pid>`将结果输出到控制台，如果想将内容保存到文件中请使用`jstack -l <pid>  > jstack_$(date "+%Y%m%d%H%M%S").txt`，其中`<pid>`为进程ID。如果机器只安装了jre可能不存在`jstack`命令，那你可以通过下面的方式。
    
- 通过`kill`命令，使用`kill -3 <pid>`将结果输出到默认的日志文件中，如果在Docker容器内日志可能被接管了，这时可以通过`docker logs b7a849961`查看如果想输出到文件中可以使用`docker logs b7a849961 >& b7a849961_$(date "+%Y%m%d%H%M%S").log`

打印的日志信息如下：

```
"org.springframework.jms.listener.DefaultMessageListenerContainer#0-1" prio=10 tid=0x00007f0ad4baa800 nid=0x1a runnable [0x00007f0aae3e8000]
   java.lang.Thread.State: RUNNABLE
	at org.apache.qpid.amqp_1_0.client.Receiver.receive(Receiver.java:264)
	at org.apache.qpid.amqp_1_0.jms.impl.MessageConsumerImpl.receive0(MessageConsumerImpl.java:306)
	at org.apache.qpid.amqp_1_0.jms.impl.MessageConsumerImpl.receiveImpl(MessageConsumerImpl.java:275)
	at org.apache.qpid.amqp_1_0.jms.impl.MessageConsumerImpl.receive(MessageConsumerImpl.java:258)
	at org.apache.qpid.amqp_1_0.jms.impl.MessageConsumerImpl.receive(MessageConsumerImpl.java:58)
	at org.springframework.jms.listener.AbstractPollingMessageListenerContainer.receiveMessage(AbstractPollingMessageListenerContainer.java:413)
	at org.springframework.jms.listener.AbstractPollingMessageListenerContainer.doReceiveAndExecute(AbstractPollingMessageListenerContainer.java:293)
	at org.springframework.jms.listener.AbstractPollingMessageListenerContainer.receiveAndExecute(AbstractPollingMessageListenerContainer.java:246)
	at org.springframework.jms.listener.DefaultMessageListenerContainer$AsyncMessageListenerInvoker.invokeListener(DefaultMessageListenerContainer.java:1142)
	at org.springframework.jms.listener.DefaultMessageListenerContainer$AsyncMessageListenerInvoker.executeOngoingLoop(DefaultMessageListenerContainer.java:1134)
	at org.springframework.jms.listener.DefaultMessageListenerContainer$AsyncMessageListenerInvoker.run(DefaultMessageListenerContainer.java:1031)
	at java.lang.Thread.run(Thread.java:745)
```

接下来将上一节中获取到线程ID`26`转化为16进制数（如果需要将16进制转为10进制可以使用`echo $((16#1a))`），可以使用命令`echo "obase=16;ibase=10;26" | bc | tr '[:upper:]' '[:lower:]'`得到结果`1a`。通过查找之前保存的日志中的`nid=0x1a`可以找到对应的线程所执行的代码以及线程的状态，如果在Linux下可以使用命令`grep -n -A 15 nid=0x1a jstack_20180104112345.txt`快速定位到对应的线程。

## Windows下操作

- 查看CPU，可以使用任务管理器
- 查看线程，可以使用[Process Explorer](https://docs.microsoft.com/zh-cn/sysinternals/downloads/process-explorer)，如图
    
    <img src="/images/post/2018/2018-01-04-process-explorer.png" alt="显示线程信息">
- 进制转换，可以使用计算器（快捷键`Win + R`启动运行窗口然后输入`calc`，接着依次按下`Alt`、`V`、`S`切换到科学型）

## 参考
[线程Dump](https://my.oschina.net/dabird/blog/691692)

[Process Explorer](https://docs.microsoft.com/zh-cn/sysinternals/downloads/process-explorer)


