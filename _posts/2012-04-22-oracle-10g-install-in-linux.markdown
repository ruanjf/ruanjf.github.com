---
layout: post
title: "linux下oracle 10g 安装全过程"
date: 2012-04-22 00:26
comments: true
category: oracle
tags: ['oracle','linux']
---

## 1、准备工作
验证依赖：

``` bash 
$ rpm -q binutils compat-libstdc++-33 elfutils elfutils-libelf-devel gcc gcc-c++ glibc glibc-common glibc-devel glibc-headers libaio libaio-devel libgcc libstdc++ libstdc++-devel make sysstat unixODBC unixODBC-devel libXp gcc
```
如果出现xxxx is not installed 请用rpm -ivh xxx 安装对应包

## 2、设置正确的内核参数Kernel Parameter

``` bash
$ vi /etc/sysctl.conf
```

在文件末尾添加如下参数：

``` bash
# Kernel Parameters for Oracle Database 10g
fs.file-max = 6553600
kernel.shmall = 2097152
kernel.shmmax = 2147483648
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 1024 65000
net.core.rmem_default = 4194304
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 262144
```

因为默认CentOS 6.0不支持10.2.0需修改配置文件，使CentOS 6.0支持Oracle10g .

``` bash
$ vi /etc/redhat-release
CentOS Linux release 4.0 (Final)
```

## 3、设置系统资源限制

``` bash
$ vi /etc/security/limits.conf
```

``` bash
#Add for Install Oracle Database 10g
oraclesoft   nproc   2047
oracle  hard  nproc   16384
oracle  soft   nofile  1024
oracle  hard   nofile  65536
```
接着，设置/etc/pam.d/login，启动系统资源限制

``` bash
$ vi /etc/pam.d/login
```

``` bash
#Add for Install Oracle Database 10g
session    required     /lib/security/pam_limits.so
session    required     pam_limits.so
```

最后，为了能让用户oracle在每次登录操作系统后，都会自动设置其最大可启动进程数与最多可开户文件数：

``` bash
$ vi /etc/profile
```

``` bash
#Add for Install Oracle Database 10g
if [ $USER = "oracle" ]; then
        if [ $SHELL = "/bin/ksh" ]; then
              ulimit -p 16384
              ulimit -n 65536
        else
              ulimit -u 16384 -n 65536
        fi
fi
```

## 4、网络设置
关闭SELinux

``` bash
$ vi /etc/selinux/config
```

确保以下内容

``` bash
SELINUX=disabled
```

另外在安装oracle数据库的时候要注意`/etc/hosts`与`/etc/sysconfig/network`文件主机名的一致性，否则会在后面运行`netca`和`dbca`可能出现错误提示。

## 5、创建用户组与用户账户

``` bash
#groupadd oinstall
#groupadd dba
#groupadd oper
#useradd -g oinstall -G dba,oper oracle
#passwd oracle
```

## 6、设置用户环境变量

``` bash
$ vi /home/oracle/.bash_profile
```

在文件末尾添加如下参数：

``` bash
#Add for Install Oracle Database 10g
umask 022
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/10.2.0/db_1
ORACLE_SID=orcl
PATH=$ORACLE_HOME/bin:$PATH
 
export PATH
export ORACLE_BASE ORACLE_HOME ORACLE_SID
```

## 7、设置安装路径

``` bash
$ mkdir -p -m 775 /u01/app
$ chown -R oracle:oinstall /u01/app
```

## 8、安装Oracle Database 10g
注意：要使用非root用户账号安装Oracle数据库，注销root账户以oracle登录。到oracle用户主目录（Home Directory）下。

``` bash
[oracle@linuxde ~]$ wget http://download.oracle.com/otn/linux/oracle10g/10201/10201_database_linux32.zip
[oracle@linuxde ~]$ unzip 10201_database_linux32.zip //解压安装文件为database
[oracle@linuxde ~]$ cd database
[oracle@linuxde database]$ ./runInstaller  //执行安装程序文件
```

linux安装Oracle安装界面乱码解决方法！

``` bash
#export NLS_LANG=AMERICAN_AMERICA.UTF8
#export LC_ALL=C
```