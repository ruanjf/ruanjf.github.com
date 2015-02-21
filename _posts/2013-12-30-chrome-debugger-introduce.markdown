---
layout: post
title: "Chrome Debugger 那些你应该知道的功能"
date: 2013-12-30 21:55
comments: true
category: debugger
tags: ['debugger', 'chrome']
---

做前端开发应该都了解浏览器，这里主要介绍[Chrome](https://chrome.google.com)全文参考[chrome-developer-tools javascript-debugging](https://developers.google.com/chrome-developer-tools/docs/javascript-debugging)。如果有Eclipse Debug的经验应该很好理解。Chrome Debugger还可以用于调试nodejs应用这个以后写文章介绍

----------

## 基础调试

 - 格式化压缩的代码`Pretty print` [see](https://developers.google.com/chrome-developer-tools/docs/javascript-debugging/image_0.png)
 
 - 运行到指定行`Continue to Here` [see](https://developers.google.com/chrome-developer-tools/docs/javascript-debugging/image_6.png)
 
 - 条件断点
 
    首先设置一个断点，然后右键该断点选择`Edit breakpoint`在弹出的输入框中填写具体的条件即可

 - 在异常的行触发断点 [see](https://developers.google.com/chrome-developer-tools/docs/javascript-debugging#pause-on-uncaught-exceptions)
 - 动态修改内容 [see](https://developers.google.com/chrome-developer-tools/docs/javascript-debugging#liveedit)
 
    在`Sources`界面内选择某个js文件直接修改，然后使用`Ctrl + S`或者`Cmd + S`。这样即可及时生效

 - 异常栈查看 [see](https://developers.google.com/chrome-developer-tools/docs/javascript-debugging#exceptions)
 
    在右下角有一个打叉的小图标（以js出错为前提）。点击可以查看详细的栈信息，如需查找对于的代码请先点击左边的小三角形图标在展开的栈中点击靠右边的js文件名。如果在代码中像打印栈可以通过`console.log(e.stack)`，打印当前代码调用栈可以通过`console.trace()`

 - 断言`console.assert(var1 !== undefined, "no var1")`

 - Source Maps 用于关联源码位置 [see](https://developers.google.com/chrome-developer-tools/docs/javascript-debugging#source-maps)


## HTML相关调试

 - DOM变化断点 [see](https://developers.google.com/chrome-developer-tools/docs/javascript-debugging#breakpoints-mutation-events)
 
    切换到`Elements`界面，右键需要监控的元素选择`Break on...`(就的版本可能不需要这个) --> `Break on Subtree Modifications`。这样元素的内部发生变化时会触发断点

 - XMLHttpRequest(平常是由JavaScript发起的请求)请求中断
 
    在`Sources`界面的右边找到`XHR Breakpoint`添加URL中包含的字符，这样在发送请求时会触发断点    

 - 事件断点（鼠标事件、键盘事件等）
    
    在`Sources`界面的右边找到`Event Listener Breakpoint`勾选需要的事件，这样在发生事件时会触发断点    

