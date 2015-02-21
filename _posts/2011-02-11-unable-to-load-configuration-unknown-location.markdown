---
layout: post
title: "Unable to load configuration unknown location"
date: 2011-02-11 11:12
comments: true
category: java
tags: ['java']
---

``` java
 Unable to load configuration. - [unknown location]
    at com.opensymphony.xwork2.config.ConfigurationManager.getConfiguration(ConfigurationManager.java:69)
    at org.apache.struts2.dispatcher.Dispatcher.init_PreloadConfiguration(Dispatcher.java:371)
    at org.apache.struts2.dispatcher.Dispatcher.init(Dispatcher.java:415)
    at org.apache.struts2.dispatcher.ng.InitOperations.initDispatcher(InitOperations.java:69)
    at org.apache.struts2.dispatcher.ng.filter.StrutsPrepareAndExecuteFilter.init(StrutsPrepareAndExecuteFilter.java:51)
    at org.apache.catalina.core.ApplicationFilterConfig.getFilter(ApplicationFilterConfig.java:295)
    at org.apache.catalina.core.ApplicationFilterConfig.setFilterDef(ApplicationFilterConfig.java:422)
    at org.apache.catalina.core.ApplicationFilterConfig.<init>(ApplicationFilterConfig.java:115)
    at org.apache.catalina.core.StandardContext.filterStart(StandardContext.java:4001)
    at org.apache.catalina.core.StandardContext.start(StandardContext.java:4651)
    at org.apache.catalina.core.ContainerBase.addChildInternal(ContainerBase.java:791)
    at org.apache.catalina.core.ContainerBase.addChild(ContainerBase.java:771)
    at org.apache.catalina.core.StandardHost.addChild(StandardHost.java:546)
    at org.apache.catalina.startup.HostConfig.deployDirectory(HostConfig.java:1041)
    at org.apache.catalina.startup.HostConfig.deployDirectories(HostConfig.java:964)
    at org.apache.catalina.startup.HostConfig.deployApps(HostConfig.java:502)
    at org.apache.catalina.startup.HostConfig.start(HostConfig.java:1277)
    at org.apache.catalina.startup.HostConfig.lifecycleEvent(HostConfig.java:321)
    at org.apache.catalina.util.LifecycleSupport.fireLifecycleEvent(LifecycleSupport.java:119)
    at org.apache.catalina.core.ContainerBase.start(ContainerBase.java:1053)
    at org.apache.catalina.core.StandardHost.start(StandardHost.java:785)
    at org.apache.catalina.core.ContainerBase.start(ContainerBase.java:1045)
    at org.apache.catalina.core.StandardEngine.start(StandardEngine.java:445)
    at org.apache.catalina.core.StandardService.start(StandardService.java:519)
    at org.apache.catalina.core.StandardServer.start(StandardServer.java:710)
    at org.apache.catalina.startup.Catalina.start(Catalina.java:581)
    at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
    at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:39)
    at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:25)
    at java.lang.reflect.Method.invoke(Method.java:597)
    at org.apache.catalina.startup.Bootstrap.start(Bootstrap.java:289)
    at org.apache.catalina.startup.Bootstrap.main(Bootstrap.java:414)
Caused by: Cannot locate the chosen ObjectFactory implementation: org.apache.struts2.spring.StrutsSpringObjectFactory - [unknown location] 
    at org.apache.struts2.config.BeanSelectionProvider.alias(BeanSelectionProvider.java:293)
    at org.apache.struts2.config.BeanSelectionProvider.alias(BeanSelectionProvider.java:264)
    at org.apache.struts2.config.BeanSelectionProvider.register(BeanSelectionProvider.java:202)
    at com.opensymphony.xwork2.config.impl.DefaultConfiguration.reloadContainer(DefaultConfiguration.java:180)
    at com.opensymphony.xwork2.config.ConfigurationManager.getConfiguration(ConfigurationManager.java:66)
    ... 31 more
```

主要是这句

``` java
Caused by: Cannot locate the chosen ObjectFactory implementation: org.apache.struts2.spring.StrutsSpringObjectFactory - [unknown location]
```
原因`struts.xm`中有配置插件，但是包没导入。包名：`struts2-spring-plugin-xxx.jar`