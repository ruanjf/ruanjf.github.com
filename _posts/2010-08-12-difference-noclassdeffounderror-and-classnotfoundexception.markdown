---
layout: post
title: "ClassNotFoundException和NoClassDefFoundError的区别"
date: 2010-08-12 17:05
comments: true
category: java
tags: ['java']
---

这2个东西应该是java里很常见，很简单，他们都和classpath设定有关，但区别在哪里呢？ 我们都知道java里生成对象有如下两种方式：

``` java
//1
Object obj = new ClassName(); //直接new一个对象

//2
Class clazz = Class.forName(ClassName);
Object obj = clazz.newInstance(); //通过class loader动态装载一个类，然后获取这个类的实例
```

同样是生成对象，1在编译期间检查`classpath`, 如果没有类定义，编译没法通过。而2在编译期间是不会检查的，不过需要抛出或者自己`catch ClassNotFoundException`。 运行期间，如果1编译时依赖的类不在`classpath`中（导致classloader装载失败），此时抛出的异常就是 `NoClassDefFoundError`。而如果2在运行期间需要装载的类不在classpath中，抛出的则是 `ClassNotFoundException`。

`NoClassDefFoundError`是编译期间能找到，但runtime找不到。而`ClassNotFoundException`则是说`runtime`找不到，因为编译期间是不做检查的