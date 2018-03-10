---
layout: post
title: "Dnsmasq安装配置"
date: 2016-09-01 19:18
comments: true
category: Linux
tags: ['dns']
---

为了避免在内网环境下每台机子都要修改`hosts`文件添加域名，所以通过在路由器上配置自己搭建的DNS服务从而不用在每台机子上配置了，特别是通过移动设备访问内网应用时就方便多了（如iOS在未越狱时想修改比较困难）。这里选用[Dnsmasq](https://wiki.archlinux.org/index.php/Dnsmasq_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))作为DNS服务器

## 安装Dnsmasq

```sh
# Ubuntu/Debian
$ apt-get install dnsmasq
# Centos/RHEL
$ yum install dnsmasq
```

## 配置Dnsmasq

> 注：本机IP地址为`192.168.16.189`

安装完后通过新建配置文件`/etc/dnsmasq.d/address.conf`这样可以避免修改默认配置。主要配置有：
- 配置上游DNS，这个值可以是由路由器提供（可能内网有做其他网络配置）
- 配置DNS监听地址，可以配置上本机`127.0.0.1`和IP地址`192.168.16.189`
- 配置泛域名解析ip，默认支持子域名，配置格式如：`address=/work.net/192.168.16.11`

如果`/etc/hosts`中有配置也会被DNS服务器获取

完整配置如下：

```
# 上游DNS
server=192.168.18.1
# 本机和局域网dns可用
listen-address=127.0.0.1,192.168.16.189

address=/work.net/192.168.16.189
address=/22.work.net/192.168.16.22
address=/33.work.net/192.168.16.33
```

如果本机上装了Docker，容器中的应用也需要配置`hosts`的话还需要添加DNS服务器地址`nameserver 192.168.16.189`到`/etc/resolv.conf`中。

配置完后可通过`dnsmasq --test`测试配置文件是否有错误，然后通过`systemctl start dnsmasq.service`启动服务。

如果机子有启用防火墙的话，需要配置服务允许通过防火墙

```sh
$ firewall-cmd --zone=public --add-service=dns --permanent # 允许dns通过防火墙
$ firewall-cmd --reload # 重新载入以生效
```

接着通过`dig`测试DNS服务是否可用（最好在局域网中的其他机器上也进行测试）

```sh
$ dig @127.0.0.1 22.work.net
$ dig @192.168.16.189 22.work.net
$ nslookup 22.work.net
```

测试完成后添加开机自启服务`systemctl enable dnsmasq.service`

## 路由器配置

登录路由器`http://192.168.1.1/`（有些ip可能会不一样），找到`网络配置`修改`首选DNS服务器`地址为`Dnsmasq`安装的机子

## 参考

[Dnsmasq](https://wiki.archlinux.org/index.php/Dnsmasq_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

[利用Dnsmasq部署DNS服务](http://www.yunweipai.com/archives/8664.html)


