---
layout: post
title: "CentOS 7 防火墙配置"
date: 2016-01-29 20:54
comments: true
category: linux
tags: ['systemd', 'firewall']
---

本文主要介绍两种防火墙的配置方式：基于端口和基于服务。

- 基于端口

    ```
    firewall-cmd --zone=public --add-port=9090/tcp --permanent # 允许9090通过防火墙
    ```

- 基于服务

    由于防火墙中的服务跟系统的服务没有直接关系因此需要通过`firewall-cmd --get-services |grep xxx`查询防火墙内置的服务，如果有存在则可以通过`firewall-cmd --zone=public --add-service=xxx --permanent`允许xxx服务（可以放行多个端口）通过防火墙

最后重新载入`firewall-cmd --reload`以生效配置

参考：

[RHEL 7](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/security_guide/sec-using_firewalls)

[CentOS 7 下使用 Firewall](https://havee.me/linux/2015-01/using-firewalls-on-centos-7.html)

[Linux防火墙配置(iptables, firewalld)](http://www.cnblogs.com/pixy/p/5156739.html)

[How To Set Up a Firewall Using FirewallD on CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-7)


