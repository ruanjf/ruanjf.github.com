---
layout: post
title: "获取git两次commit变化的文件"
date: 2013-07-15 22:24
comments: true
category: ci
tags: ['git', 'linux']
---

由于在网络上无法找到git两次提交变化的文件（用[svn](http://subversion.tigris.org/)相对就简单多了），于是萌生了自己写个脚本实现该功能。
至于为啥要这么用呢，为了这货[jenkins](https://www.jenkins-ci.org/)


## 用法

``` bash
# 工程根路径
export wkp="/root/.jenkins/jobs/tw/workspace/"
# 需要提取变化文件的目录（包含子目录，可使用相对路径）
export cpp="WebRoot/"
# 提取的变化文件存放位置（可使用相对路径）
export upn="update_tmp"
sh /root/git-get-pull-files.sh
```
其中有几个文件需要注意：

 - `update_lastPull`记录上次pull的commit SHA hash，`update_lastPull`文件不存在则默认为全更新
 - `${upn}/delFiles.txt`记录已经被删除的文件

运行过程如下：

``` bash
rjf@rjf-ubuntu:~$ export wkp="/root/.jenkins/jobs/tw/workspace/"
rjf@rjf-ubuntu:~$ export upn="update_tmp"
rjf@rjf-ubuntu:~$ export cpp="WebRoot/"
rjf@rjf-ubuntu:~$ sh /root/git-get-pull-files.sh
update dir WebRoot/
update tmp update_tmp/
update key update_lastPull
update model: true
backup update_tmp to update_tmp_bf8d59381bd6c62b4fa05cf1458e9a5f8d170a6f
create update_tmp/
copy files to update_tmp/
update to commit 34ddb49d49cd82767857c3759a0195a34b0c3deb
rjf@rjf-ubuntu:~$ 
```

## 执行逻辑

 - 使用`git diff`获取变化文件
 - 使用`awk`拼装复制文件的代码片段
 - 使用`eval`执行拼装好的代码片段

主要代码片段如下：

```bash
#lp  表示最近一次pull的commit id
#cpp 表示需要提取变化文件的目录
#upn 表示变化文件存放位置
#td  临时变量存储代码片段
td=`git diff --diff-filter=[ADM] --name-status $lp -- $cpp | awk '
    {
      if ($1 == "D") { 
        { print "echo "$2" >> "uw"delFiles.txt;" }
      } else {
        { print "mkdir -p \`dirname "uw$2"\`;" }
        { print "\\\cp -f "$2" "uw$2";" }
      } 
    }
' uw="${upn}/"`
eval $td
```

## 源代码如下：（or [这里](https://gist.github.com/ruanjf/5999964)）
<script src="https://gist.github.com/ruanjf/5999964.js"></script>
