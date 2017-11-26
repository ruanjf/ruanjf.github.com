---
layout: post
title: "macOS配置"
date: 2017-11-22 23:08
comments: true
category: Apple
tags: ['macOS']
---

由于近期重装升级了新的系统[macOS High Sierra](https://www.apple.com/cn/macos/high-sierra/)，这里记录下系统配置和软件安装

## 系统配置

```sh
# 键盘长按支持
defaults write -g ApplePressAndHoldEnabled 0
# 修改系统截图位置
defaults write com.apple.screencapture location ~/Pictures/ScreenShots; killall SystemUIServer
```

安装命令行工具 [参考](http://osxdaily.com/2014/02/12/)

```sh
# open a dialog for installation of the command line developer tools
install-command-line-tools-mac-os-x/
xcode-select --install
```

设置代理，方便下载（如果有代理的话）

```sh
export http_proxy=http://127.0.0.1:1087;export https_proxy=http://127.0.0.1:1087;
# 或者
export ALL_PROXY=socks5://127.0.0.1:1086
```

## 必备软件

安装[Oh My ZSH!](https://github.com/robbyrussell/oh-my-zsh)

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

安装[brew](https://brew.sh/)

```sh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install wget
```

安装brew第三方包[Homebrew-Cask](https://caskroom.github.io/) 不清楚Cask的可以看[这里](https://docs.brew.sh/brew-tap.html)

``` sh
brew tap caskroom/cask
brew tap caskroom/versions # 支持安装特定版本
```

安装Quick Look插件 [参考](https://github.com/sindresorhus/quick-look-plugins)

```sh
brew cask install qlcolorcode qlstephen qlimagesize webpquicklook suspicious-package qlvideo provisionql
```

安装[rlwrap](https://github.com/hanslub42/rlwrap)解决命令行下运行的命令无法使用键盘上下键问题

```sh
brew install rlwrap
```

安装[tree](http://mama.indstate.edu/users/ice/tree/)用于树形方式显示目录

```sh
brew install tree
```

## 开发工具

安装[wrk](https://github.com/wg/wrk)压力测试工具

```sh
brew install wrk
```

安装[wireshark](https://www.wireshark.org/)网络封包分析工具

```sh
brew cask install wireshark

# 或者
brew install wireshark --with-qt
brew cask install wireshark-chmodbpf
```

安装[Steel Bank Common Lisp](http://www.sbcl.org/)

```sh
brew install sbcl
# 可以在命令行包裹rlwrap使用，在.zshrc中添加
tee -a ~/.zshrc << EOF

# 包裹Steel Bank Common Lisp以便支持键盘上下键
alias sbcl="rlwrap sbcl"
EOF
```

安装Java开发环境 [参考](https://www.kancloud.cn/kancloud/ocds-guide-to-setting-up-mac/71035)

```sh
brew cask install java
# 或者安装JDK8，安装之前确保已经安装了caskroom/versions，如果没有可以通过brew tap caskroom/versions进行安装
brew cask install java8
```

如果觉得下载太慢可以在外部下载后拷贝的Cask缓存文件夹，通过
`brew cask info java8`查看Java版本信息，进行手动下载

```
java8: 1.8.0_152-b16,aa0333dd3019491ca4f6ddbe78cdb6d0
https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
Not installed
From: https://github.com/caskroom/homebrew-versions/blob/master/Casks/java8.rb
==> Name
Java Standard Edition Development Kit
==> Artifacts
JDK 8 Update 152.pkg (Pkg)
==> Caveats
```

通过以下命令将下载好的dmg安装包拷贝到Cask缓存文件夹

```sh
cp ~/Downloads/jdk-8u152-macosx-x64.dmg `brew --cache`/Cask/`brew cask info java8 |grep java8: | sed -E "s/: /--/"`.dmg
brew cask install java8
```

安装[Apache Maven](https://maven.apache.org/)

```sh
brew install maven
```

安装Node.js开发环境，使用[nvm](https://github.com/creationix/nvm)进行管理 [参考](https://nodejs.org/en/download/package-manager/#nvm)
安装Oh My ZSH! [zsh-nvm](https://github.com/lukechilds/zsh-nvm)插件

```sh
# 下载插件
git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm

# 添加插件到zsh配置中
perl -0777 -pe 's/^(plugins=\(\n(\s|.)*?)\)$/\1  zsh-nvm\n)\n#延迟加载zsh-nvm插件\nexport NVM_LAZY_LOAD=true\n/m' -i ~/.zshrc

# 更新nvm插件
nvm upgrade
# 安装Node.js https://github.com/creationix/nvm#usage
nvm install 8.9
# 设置默认Node.js版本
nvm alias default 8.9
# 使用特定版本
nvm use 6.12
```


安装[nginx](http://nginx.org/)使用[homebrew nginx](https://github.com/Homebrew/homebrew-nginx)扩展仓库

```sh
# 添加扩展仓库
brew tap homebrew/nginx

# 查看安装配置选项
brew options nginx-full
brew info nginx-full

# 安装
brew install nginx-full --with-flv --with-gunzip --with-gzip-static --with-http2 --with-mp4 --with-realip --with-status --with-sub --with-cache-purge-module --with-echo-module --with-lua-module --with-mp4-h264-module --with-subs-filter-module
```

安装MySQL

```sh
brew install mysql
```

安装[Alfred QRCode](https://github.com/hilen/Alfred.QRCode) Python依赖

```sh
sudo easy_install pip
# 使用--user可以避免sudo
pip install --user pillow
pip install --user qrcode
```

安装[golang](https://golang.org/)开发环境
```sh
brew instal go
# 在.zshrc中添加
tee -a ~/.zshrc << EOF

# 添加golang path
export PATH=$PATH:/usr/local/opt/go/libexec/bin
EOF
```

