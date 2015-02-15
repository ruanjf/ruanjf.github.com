```
layout: post
title: "获取git两次commit变化的文件"
date: 2013-07-15 22:24
comments: true
tags: ['git', 'linux']
```

鉴于Google提供的[文档](http://www.chromium.org/chromium-os/quick-start-guide)存在很多坑，Google向来简约但是文档也简这就不应该了，其实还提供了一份完整的[文档](http://www.chromium.org/chromium-os/developer-guide)巨长无比。因此有了这篇文章主要目的让大家看完后也可以编译[Chromium OS](http://zh.wikipedia.org/zh/Chromium_OS)
#### 前提条件

 - [Ubuntu](http://www.ubuntu.com/) Linux 12.04 版本切记实用
 - 64的系统（为了编译可以快点）这里提供[下载](http://releases.ubuntu.com/12.04/ubuntu-12.04.2-desktop-amd64.iso)
 - 一个可以使用sudo的账户

#### 下载源码

 - 安装必要的软件
	``` bash
	rjf@rjf-ubuntu:~$sudo apt-get install aptitude
	rjf@rjf-ubuntu:~$sudo aptitude install git-core gitk git-gui subversion curl
	```
	安装[depot_tools](http://dev.chromium.org/developers/how-tos/install-depot-tools)到你想要的目录（第一个坑，git提供的https访问不了不知为啥现改为http）
	``` bash
	rjf@rjf-ubuntu:~/chromiumos$git clone http://chromium.googlesource.com/chromium/tools/depot_tools.git
	rjf@rjf-ubuntu:~$vi ~/.bashrc
	```
 - 配置环境
	``` bash
	rjf@rjf-ubuntu:~$vi ~/.bashrc
	```
	在其最后添加如下内容到`.bashrc`
	``` bash
	# depot_tools安装目录
	export PATH="$PATH":/usr/local/depot_tools
	# chromiumos存放目录，最好预留30G以上
	export SOURCE_REPO=${HOME}/chromiumos
	# 后两个选添一个即可想编译32位选择x86-generic、64选择amd64-generic
	export BOARD=x86-generic
	export BOARD=amd64-generic
	```
	内容添加完后记得关闭当前shell并打开新的shell进行下面的操作，不然配置不会生效

 - 下载源码
	这里需要等上较长时间本来话了两个小时，没事可以看片去了
	``` bash
	rjf@rjf-ubuntu:~$cd ${SOURCE_REPO}
	rjf@rjf-ubuntu:~/chromiumos$repo init -u https://git.chromium.org/chromiumos/manifest.git
	rjf@rjf-ubuntu:~/chromiumos$repo sync
	```

#### 编译源码

 - 配置编译环境
``` bash
rjf@rjf-ubuntu:~/chromiumos$cros_sdk -- ./setup_board --board=${BOARD}
```

 - 编译包
``` bash
rjf@rjf-ubuntu:~/chromiumos$cros_sdk -- ./build_packages --board=${BOARD}
```

 - 编译映像，存放于`${SOURCE_REPO}/src/build/images/${BOARD}/latest/chromiumos_image.bin`
``` bash
rjf@rjf-ubuntu:~/chromiumos$cros_sdk -- ./build_image --board=${BOARD}
```

 - 生成[VMware](http://www.vmware.com/)文件与映像存放在同一目录下，对于用虚拟机打开时无网络可在`xxx.vmx`文件中添加`ethernet0.virtualDev = "e1000"`。当然也可以选择[其他](http://www.chromium.org/chromium-os/developer-guide#TOC-Building-an-image-to-run-in-a-virtu)的
``` bash
rjf@rjf-ubuntu:~/chromiumos$cros_sdk -- ./image_to_vm.sh --board=${BOARD} --format=vmware
```

 - 生成U盘映像
``` bash
rjf@rjf-ubuntu:~/chromiumos$cros_sdk -- ./image_to_usb.sh --board=${BOARD}
```

#### 关键命令整理
``` bash
sudo apt-get install aptitude
sudo aptitude install git-core gitk git-gui subversion curl
git clone http://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$PATH":/usr/local/depot_tools
export SOURCE_REPO=${HOME}/chromiumos
export BOARD=x86-generic
export BOARD=amd64-generic
cd ${SOURCE_REPO}
repo init -u https://git.chromium.org/chromiumos/manifest.git
repo sync
cros_sdk -- ./setup_board --board=${BOARD}
cros_sdk -- ./build_packages --board=${BOARD}
cros_sdk -- ./build_image --board=${BOARD}
cros_sdk -- ./image_to_vm.sh --board=${BOARD} --format=vmware
cros_sdk -- ./image_to_usb.sh --board=${BOARD}
```