---
layout: post
title: "安装Shadowsocks服务器"
date: 2018-02-24 21:58
comments: true
category: linux
tags: ['shadowsocks']
---


```sh
# 创建文件夹并进入
mkdir /opt/shadowsocks && cd "$_"
# 下载程序
wget https://github.com/shadowsocks/shadowsocks-go/releases/download/1.2.1/shadowsocks-server.tar.gz
# 解压程序
tar zxvf shadowsocks-server.tar.gz
# 下载配置
wget https://github.com/shadowsocks/shadowsocks-go/raw/master/config.json
# 或者添加配置
tee -a config.json << EOF
{
    "server":"127.0.0.1",
    "server_port":9100,
    "local_port":1080,
    "local_address":"127.0.0.1",
    "password":"R3NRbdcyq",
    "method": "aes-128-cfb",
    "timeout":600
}

EOF


# 启动测试，可用后按Ctrl + C停止程序
./shadowsocks-server


# 安装服务
tee -a /etc/systemd/system/shadowsocks.service << EOF
[Unit]
Description=Shadowsocks Server.
After=network.target

[Service]
ExecStart=/opt/shadowsocks/shadowsocks-server -c /opt/shadowsocks/config.json
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target

EOF


# 设置权限
chmod 664 /etc/systemd/system/shadowsocks.service
# 重新加载服务配置
systemctl daemon-reload
# 启动服务
systemctl start shadowsocks.service
# 查看服务状态
systemctl status shadowsocks.service
# 开启服务自启动
systemctl enable shadowsocks.service
```

参考
[shadowsocks-server](https://shadowsocks.org/en/download/servers.html)
[shadowsocks-go](https://github.com/shadowsocks/shadowsocks-go)


