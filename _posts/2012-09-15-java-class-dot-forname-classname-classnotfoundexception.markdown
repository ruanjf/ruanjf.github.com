---
layout: post
title: "java Class.forName(className) ClassNotFoundException异常"
date: 2012-09-15 11:59
comments: true
category: java
tags: ['java']
---

``` java
package com.hou;
public class Car {}

package com.hou;
public class Main {
	public static void main(String [] args){
		try {
			Object c = Class.forName("car").newInstance();
		} catch (InstantiationException e) {
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}
}
```

编译运行后出现：

``` java
java.lang.ClassNotFoundException: car
	at java.net.URLClassLoader$1.run(Unknown Source)
	at java.security.AccessController.doPrivileged(Native Method)
	at java.net.URLClassLoader.findClass(Unknown Source)
	at java.lang.ClassLoader.loadClass(Unknown Source)
	at sun.misc.Launcher$AppClassLoader.loadClass(Unknown Source)
	at java.lang.ClassLoader.loadClass(Unknown Source)
	at java.lang.ClassLoader.loadClassInternal(Unknown Source)
	at java.lang.Class.forName0(Native Method)
	at java.lang.Class.forName(Unknown Source)
	at com.hou.Main.main(Main.java:6)
```

把上面部分改为如下，异常不在出现：`Object c = Class.forName("com.hou.car").newInstance();`
思考：虽然同一个包中的类可以直接引用。但类名前的包名已默认又编译器加上去了。通过`Class.forName(className)`方式加载类的时候，如果不加包名则默认在 default 包中去找，所以找不到。因此用`Class.forName(className)`方式加载类的时候应加上包名。