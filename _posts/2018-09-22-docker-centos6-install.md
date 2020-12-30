# RHEL 6.6 安装Docker 1.7
CentOS、RHEL版本要求：6.5以上64位系统
内核要求：3.10（7.0版本）、2.6.32-431（6.5以上版本）

# 查看RHEL发行Linux版本
cat /etc/redhat-release
# 查看内核版本
uname -r

# 测试是否可以访问外网
curl -vI https://www.baidu.com

# 查看ip网卡配置
ifconfig |grep -C 2 172.20
# 添加dns配置
vi /etc/sysconfig/network-scripts/ifcfg-bond0
DNS1=218.85.157.99
# 重启生效dns配置
service network restart


# https://docs.docker.com/v1.7/installation/rhel/#red-hat-enterprise-linux-6.5-installation
# https://raw.githubusercontent.com/moby/moby/v1.7.0/contrib/check-config.sh

# 下载Docker安装包
curl -O -sSL https://get.docker.com/rpm/1.7.0/centos-6/RPMS/x86_64/docker-engine-1.7.0-1.el6.x86_64.rpm
wget https://get.docker.com/rpm/1.7.0/centos-6/RPMS/x86_64/docker-engine-1.7.0-1.el6.x86_64.rpm

# 安装Docker安装包
yum localinstall --nogpgcheck docker-engine-1.7.0-1.el6.x86_64.rpm

# 启动服务
service docker start

# 执行测试
docker run hello-world
docker run --rm -it anapsix/alpine-java:8u141b15_jdk java -version
docker run --name=test1 -d -p 5555:5555 anapsix/alpine-java:8u141b15_jdk nc 0.0.0.0 5555 -l
docker run --name=test2 -d -p 5566:5566 --link=test1 anapsix/alpine-java:8u141b15_jdk nc 0.0.0.0 5566 -l
docker run --rm -it anapsix/alpine-java:8u141b15_jdk httpd -p 127.0.0.1:8080 -h /app
docker run --name=test1 -d -p 5555:5555 anapsix/alpine-java:8u141b15_jdk sh -c 'echo "abcd" | nc 0.0.0.0 5555 -l'
docker run --name=fileserver -d -p 8080:8080 172.20.0.228:5000/mms:0.15 fileserver

# 配置Docker
# Docker版本大于1.10时配置
vi /etc/docker/daemon.json
{
  "insecure-registries": ["172.20.0.228:5000"],
  "registry-mirrors": ["https://ty6jkzoh.mirror.aliyuncs.com"]
}

# Docker版本小于1.10时配置
# https://docs.docker.com/v1.7/articles/configuring/
vi /etc/sysconfig/docker
other_args="--bip=10.172.0.0/16 --registry-mirror=https://ty6jkzoh.mirror.aliyuncs.com --insecure-registry=172.20.0.228:5000"

# 启动Docker服务
service docker restart

# 添加开机自启
chkconfig docker on

# 添加docker组
groupadd docker

# 将用于加入docker组
usermod -aG docker smsplatform

# https://docs.docker.com/v1.7/compose/install/
# 安装Docker Compose
https://github.com/docker/compose/releases/1.3.3
curl -L https://github.com/docker/compose/releases/download/1.3.3/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
wget https://github.com/docker/compose/releases/download/1.3.3/docker-compose-`uname -s`-`uname -m`
cp docker-compose-Linux-x86_64 /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


# 镜像仓库（暂时无法使用）
# https://docs.docker.com/registry
docker pull registry
docker run -d -p 5000:5000 --restart always --name registry registry:2
docker run -d -p 5000:5000 --name registry registry:2


# 导入镜像
# https://docs.docker.com/v1.7/docker/reference/commandline/save/
# https://docs.docker.com/v1.7/docker/reference/commandline/load/
# 导出镜像文件
docker save -o mms-0.13.tar 172.20.0.228:5000/mms:0.13
# 压缩镜像文件
tar zcvf mms-0.13.tar.gz mms-0.13.tar
# 解压镜像文件
tar zxvf mms-0.13.tar.gz
# 导入镜像文件
docker load --input mms-0.13.tar


# 测试容器是否可以访问宿主机
nc 192.168.1.11 8080 -v
# CentOS 6.x系统
# 关闭防火墙
service iptables stop
# 或者配置ip运行访问
iptables -I INPUT -s 172.17.0.1/16 -j ACCEPT
# 或者自动读取docker对于网卡IP端
iptables -I INPUT -s `ip route show |grep docker0 |awk '{print $1}'` -j ACCEPT
# 测试是否可用如果不想保存配置可以还原
service iptables restart
# 查看配置列表并显示编号
iptables -L -n --line-number
# 删除配置，其中23为列表编号
iptables -D OUTPUT 23
# 保存配置
service iptables save

# CentOS 7.x系统
systemctl stop NetworkManager.service
firewall-cmd --permanent --zone=trusted --change-interface=docker0
systemctl start NetworkManager.service


# 删除
yum list installed | grep docker
yum -y remove docker-engine.x86_64
rm -rf /var/lib/docker
rm -rf /usr/local/bin/docker-compose


oute add -net 172.17.0.0/24 gw 172.17.0.1

