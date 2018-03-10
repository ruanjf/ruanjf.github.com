---
layout: post
title: "Linux下添加开机自启服务"
date: 2016-03-20 21:33
comments: true
category: linux
tags: ['systemd']
---


本文使用[Systemd](https://wiki.archlinux.org/index.php/systemd_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))配置自启动服务，操作系统为`Centos 7`

## 编写配置文件

配置文件可以通过拷贝现有的`/usr/lib/systemd/system/xxxx.service`或者新建文件。这里使用新建文件`/etc/systemd/system/intellij.service`的方式：

```
[Unit]
Description=IntelliJ IDEA License Server.
After=network.target

[Service]
ExecStart=/root/IntelliJIDEALicenseServer/IntelliJIDEALicenseServer_linux_386 -p 10170 -u idea
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
```

## 启用服务

修改文件的权限`chmod 664 /etc/systemd/system/intellij.service`，接着重新加载配置`systemctl daemon-reload`，然后启动服务`systemctl start intellij.service`再通过`systemctl status intellij.service`查看服务状态是否正常如果非`active`的话可以通过`journalctl -u intellij.service`查看日志信息。最后通过`systemctl enable intellij.service`加入开机自启。

## 防火墙配置

如果有启用防火墙则还需下面配置

```
firewall-cmd --zone=public --add-port=10170/tcp --permanent # 允许10170通过防火墙
firewall-cmd --reload # 重新载入以生效
```

## 参考

[CREATING AND MODIFYING SYSTEMD UNIT FILES](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/sect-managing_services_with_systemd-unit_files)




