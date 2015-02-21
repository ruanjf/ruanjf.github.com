---
layout: post
title: "Linux下设置oracle 10g 服务以及实例自动启动方法"
date: 2012-09-16 13:41
comments: true
category: oracle
tags: ['oracle','linux']
---

Linux中在Oracle安装完毕以后,如果重新启动Linux ,Oracle是不会自动启动的,你可以通过手动调用dbstart命令来进行启动,不过这样似乎也很繁琐.我们可以通过配置Oracle的自动启动脚本,然后利用Linux的Service来启动Oracle服务器.
首先在/etc/init.d/目录下配置Oracle的服务文件.

``` bash
[root@oracle10g ~]#touch oracle10g
[root@oracle10g ~]#chmod a+x oracle10g
```

然后编辑此oracle10g文件.内容如下.

``` bash
[root@oracle10g ~]#vi /etc/init.d/oracle10g
```

``` bash
# !/bin/bash
# whoami
# root
# chkconfig: 345 51 49
# /etc/init.d/oracle10g
# description: starts the oracle dabase deamons
#
ORA_HOME=/oracle/app/oracle/product/10.2.0/db_1
ORA_OWNER=oracle
case "$1" in
start)
echo -n "Starting oracle10g: "
su - $ORA_OWNER -c "$ORA_HOME/bin/dbstart" &
su - $ORA_OWNER -c "$ORA_HOME/bin/lsnrctl start"
su - $ORA_OWNER -c "$ORA_HOME/bin/emctl start dbconsole"
touch /var/lock/subsys/oracle10g
echo
;;
stop)
echo -n "shutting down oracle10g: "
su - $ORA_OWNER -c "$ORA_HOME/bin/dbshut" &
su - $ORA_OWNER -c "$ORA_HOME/bin/lsnrctl stop"
su - $ORA_OWNER -c "$ORA_HOME/bin/emctl stop dbconsole"
rm -f /var/lock/subsys/oracle10g
echo
;;
restart)
echo -n "restarting oracle10g: "
$0 stop
$0 start
echo
;;
*)
echo "Usage: `basename $0` start|stop|restart"
exit 1
esac
exit 0
```

把配置好的拷贝到启动目录（添加linux服务时使用）

``` bash
[root@oracle10g ~]#cp oracle10g /etc/init.d/
```

保存文件,退出以后,添加并启动察看服务.

``` bash
[root@oracle10g ~]#chkconfig --add oracle10g
[root@oracle10g ~]#chkconfig --list oracle10g
[root@oracle10g ~]#chkconfig --level 345 oracle10g on
```

重新启动Linux的时候,如果看到启动项Oracle出现OK,代表Oracle成功随Linux启动了.
注意:
这样的脚本启动一般不会启动实例,如果想让实例也随脚本一起启动的话,就需要修改文件

``` bash
[root@oracle10g ~]#ls /etc/oratab
```

如果这个文件不存在,那么就得运行脚本文件产生它

``` bash
[root@oracle10g ~]#sh /oracle/product/10.2.0/db_1/root.sh
```

比如我的oratab代码如下:

``` bash
#
# This file is used by ORACLE utilities.  It is created by root.sh
# and updated by the Database Configuration Assistant when creating
# a database.
# A colon, ':', is used as the field terminator.  A new line terminates
# the entry.  Lines beginning with a pound sign, '#', are comments.
#
# Entries are of the form:
#   $ORACLE_SID:$ORACLE_HOME:<N|Y>:
#
# The first and second fields are the system identifier and home
# directory of the database respectively.  The third filed indicates
# to the dbstart utility that the database should , "Y", or should not,
# "N", be brought up at system boot time.
#
# Multiple entries with the same $ORACLE_SID are not allowed.
#
#
orcl:/oracle/product/10.2.0/db_1:N
gzgi:/oracle/app/oracle/product/10.2.0/db_1:Y
#看设置,可以看出实例 gzgi 是自动启动的(表识是Y),而orcl的表识是N,则不启动
```
只要在这里设置好后,在配合上面的脚本,即可实现开机自动启动oracle以及实例了.