---
layout: post
title: "npm添加二进制文件镜像地址"
date: 2016-04-02 15:42
comments: true
category: nodejs
tags: ['npm']
---

由于国内访问[S3](https://s3.amazonaws.com)比较慢，导致通过[npm](https://npmjs.com)下载二进制文件依赖时会中断或者直接下不动，所以需要在`npm`命令后面加上`--{module_name}_binary_host_mirror`，其中`module_name`存在于`package.json`中。每个模块名称又不一样（例如：`sqlite3`的模块名为`node_sqlite3`）这时可以通过`npm view sqlite3 binary`或者指定版本`npm view sqlite3@3.1.3 binary`查询到模块名称而不需要去仓库查看打印结果如下：

```
$ npm view sqlite3@3.1.3 binary
{ module_name: 'node_sqlite3',
  module_path: './lib/binding/{node_abi}-{platform}-{arch}',
  host: 'https://mapbox-node-binary.s3.amazonaws.com',
  remote_path: './{name}/v{version}/{toolset}/',
  package_name: '{node_abi}-{platform}-{arch}.tar.gz' }
```

找到模块名称后组成`--node_sqlite3_binary_host_mirror`，再添加上[淘宝 NPM 镜像](https://npm.taobao.org/)组合成完整的命令`npm install sqlite3 --node_sqlite3_binary_host_mirror=https://npm.taobao.org/mirrors`。需要注意的是镜像地址的路径`host`、`remote_path`和`package_name`组合以后的地址是否正确。

如果在安装依赖时遇到`node-gyp`权限的问题可以加上`--unsafe-perm`配置

参考

- [npm-view](https://docs.npmjs.com/cli/view)
- [node-pre-gyp](https://github.com/mapbox/node-pre-gyp#download-binary-files-from-a-mirror)
- [node-gyp权限](https://github.com/nfarina/homebridge/issues/405#issuecomment-164803485)
- [淘宝 NPM 镜像](https://npm.taobao.org/)

