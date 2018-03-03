---
layout: post
title: "JVM Instrument使用介绍"
date: 2018-02-25 21:38
comments: true
category: java
tags: ['java', 'jvm']
---


本文介绍如何使用JVM Attach API在应用运行中修改代码(本文通过`jar`的方式，如需`C\C++`的请参考[这里](https://yq.aliyun.com/articles/56)，避免应用需要重启启动。使用方式有两种：

- 命令行接口，在应用启动时添加`-javaagent:`参数
- VM 启动后启动代理，在应用启动后获取[进程ID](https://zh.wikipedia.org/wiki/%E8%BF%9B%E7%A8%8BID)(pid)，通过Attach API动态加载代码

以下代码在Oracle Java虚拟机环境中使用，主要利用[Instrumentation.redefineClasses(ClassDefinition... definitions)](https://docs.oracle.com/javase/6/docs/api/java/lang/instrument/Instrumentation.html#redefineClasses(java.lang.instrument.ClassDefinition...))实现代码的热更新。为了简化所以代码都整合到一个jar中，具体工程详见[GitHub](https://github.com/ruanjf/jvm-instrument)。

## 先决条件
- 已安装[JDK 6](http://www.oracle.com/technetwork/java/javase/downloads/index.html)以上版本
- 已安装[Maven](http://maven.apache.org/)
- （可选）JAVA环境变量`classpath`已设置`tools.jar`，如未设置环境变量可参考[这里](http://www.runjf.com/java/java-environment-variable)或者在命令行中通过`-cp`显示设置

## 打包jar
如果觉得打包太过麻烦，可跳过打包环节直接下载[jar](https://github.com/ruanjf/jvm-instrument/releases/download/1.0-beta.1/jvm-instrument-1.0-SNAPSHOT.jar)

创建一个Maven工程在`pom.xml`文件中添加`tools.jar`依赖（由于Maven中默认不包含），依赖中的`toolsjar`与系统有关系需要使用`<profiles>`

```xml
<dependency>
    <groupId>jdk.tools</groupId>
    <artifactId>jdk.tools</artifactId>
    <version>system</version>
    <scope>system</scope>
    <systemPath>${toolsjar}</systemPath>
</dependency>

...

<profiles>
    <profile>
        <id>windows_profile</id>
        <activation>
            <os>
                <family>windows</family>
            </os>
        </activation>
        <properties>
            <toolsjar>${java.home}/lib/tools.jar</toolsjar>
        </properties>
    </profile>
    <profile>
        <id>Macos_profile</id>
        <activation>
            <os>
                <family>mac</family>
            </os>
        </activation>
        <properties>
            <toolsjar>${java.home}/../lib/tools.jar</toolsjar>
        </properties>
    </profile>
</profiles>
```

在`pom.xml`的`maven-jar-plugin`中添加`<Can-Redefine-Classes>true</Can-Redefine-Classes>`代理配置允许重定义此代理所需的类，如未设置会导致出现`java.lang.UnsupportedOperationException: redefineClasses is not supported`错误，详细信息如下：

```
Exception in thread "Attach Listener" java.lang.reflect.InvocationTargetException
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:498)
	at sun.instrument.InstrumentationImpl.loadClassAndStartAgent(InstrumentationImpl.java:386)
	at sun.instrument.InstrumentationImpl.loadClassAndCallAgentmain(InstrumentationImpl.java:411)
Caused by: java.lang.UnsupportedOperationException: redefineClasses is not supported in this environment
	at sun.instrument.InstrumentationImpl.redefineClasses(InstrumentationImpl.java:156)
	at com.runjf.test.jvm.instrument.Util.redefineClasses(Util.java:41)
	at com.runjf.test.jvm.instrument.AgentMain.agentmain(AgentMain.java:19)
	... 6 more
Agent failed to start!
```

创建一个主类`com.runjf.test.jvm.instrument.Main`用于测试动态更新代码是否生效。该类的执行逻辑为：打印指定类的指定方法，然后休眠指定的秒数，重复指定的次数。当执行代理后发现先后两次的打印结果不一样则说明动态加载生效了，main的默认打印`Demo 1, ret: 1`，设置代理后打印`Demo 2, ret: 2`，结果类似：

```
Demo 1, ret: 1
AgentMain done: Demo,/Demo.class.2
Demo 2, ret: 2
```

### 命令行接口
新建一个类`com.runjf.test.jvm.instrument.Premain`添加一个静态方法`public static void premain(String agentArgs, Instrumentation inst);`或者`public static void premain(String agentArgs);`用于启动时代理的入口，在`pom.xml`的`maven-jar-plugin`中添加`<Premain-Class>com.runjf.test.jvm.instrument.Premain</Premain-Class>`代理类配置

### VM 启动后启动代理
新建一个类`com.runjf.test.jvm.instrument.AgentMain`添加一个静态方法`public static void agentmain(String agentArgs, Instrumentation inst);`或者`public static void agentmain(String agentArgs);`用于启动代理的入口，在`pom.xml`的`maven-jar-plugin`中添加`                            <Agent-Class>com.runjf.test.jvm.instrument.AgentMain</Agent-Class>
`代理类配置。再添加一个类`com.runjf.test.jvm.instrument.AgentAttach`用于调用`Attach API`启动代理。

```java
    public static void main(String[] args) throws IOException, AttachNotSupportedException, AgentLoadException,
            AgentInitializationException {
        String jarFileName = args[0];
        String processId = args[1];
        VirtualMachine virtualMachine = VirtualMachine.attach(processId);
        try {
            virtualMachine.loadAgent(jarFileName, args[2]);
        } finally {
            virtualMachine.detach();
        }
        System.out.println("AgentAttach done: " + Arrays.toString(args));
    }
```

需要传入的参数分别为：包含代理代码的jar、已启动的Java进程号和代理启动需要的参数(动态加载的类名,Class所在位置。例如：`Demo,/Demo.class.2`)


接下来进入`jvm-instrument`文件夹执行`mvn package`命令生成`jvm-instrument-1.0-SNAPSHOT.jar`


## 执行测试命令

进入`target`文件夹，执行下面两种测试

- 命令行接口

    首先，执行命令`java -jar jvm-instrument-1.0-SNAPSHOT.jar 6 10 Demo getInt`观察默认的结果，每隔10秒打印一次`Demo.getInt`方法共重复6次，控制台打印结果如下。
    
    ```
    14203@rjf-mba.local
    [6, 10, Demo, getInt]
    Demo 1, ret: 1
    Demo 1, ret: 1
    Demo 1, ret: 1
    Demo 1, ret: 1
    Demo 1, ret: 1
    Demo 1, ret: 1
    ```
    然后，在命令中添加代理配置`java -javaagent:jvm-instrument-1.0-SNAPSHOT.jar=Demo,/Demo.class.2 -jar jvm-instrument-1.0-SNAPSHOT.jar 6 10 Demo getInt`，控制台打印结果如下：
    
    ```
    14255@rjf-mba.local
    [6, 10, Demo, getInt]
    Demo 2, ret: 2
    Demo 2, ret: 2
    Demo 2, ret: 2
    Demo 2, ret: 2
    Demo 2, ret: 2
    Demo 2, ret: 2
    ```
    需要注意下`javaagent`的参数传递格式`-javaagent:<jarpath>[=<选项>]`

- VM 启动后启动代理

    首先，启动默认的jar`java -jar jvm-instrument-1.0-SNAPSHOT.jar 6 10 Demo getInt`控制台打印结果如下：

    ```
    10153@rjf-mba.local
    [6, 10, Demo, getInt]
    Demo 1, ret: 1
    ```
    > 注意，接下来的一步需要`tools.jar`有些同学的`classpath`并为包含该jar，可以在命令中显示指定(如：`java -cp /Library/Java/JavaVirtualMachines/jdk1.8.0_152.jdk/Contents/Home/lib/tools.jar`)或者在`classpath`中添加jar路径(如：`CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/jre/lib/rt.jar`)。
    
    然后，新开一个终端进入到`target`文件夹执行`java -cp /Library/Java/JavaVirtualMachines/jdk1.8.0_152.jdk/Contents/Home/lib/tools.jar:jvm-instrument-1.0-SNAPSHOT.jar:. com.runjf.test.jvm.instrument.AgentAttach jvm-instrument-1.0-SNAPSHOT.jar 10153 Demo,/Demo.class.2`来启动代理，其中`10153`为之前启动的java应用进程号，控制台打印结果如下：

    ```
    AgentAttach done: [jvm-instrument-1.0-SNAPSHOT.jar, 10153, Demo,/Demo.class.2]
    ```
    现在回到前一个终端可以看到(可能需要等几秒)如下信息则说明动态加载生效了

    ```
    10153@rjf-mba.local
    [6, 10, Demo, getInt]
    Demo 1, ret: 1
    Demo 1, ret: 1
    AgentMain done: Demo,/Demo.class.2
    Demo 2, ret: 2
    ```

## 参考文档
- [Attach API](https://docs.oracle.com/javase/6/docs/jdk/api/attach/spec/com/sun/tools/attach/VirtualMachine.html)
- [Manifest customization](https://maven.apache.org/plugins/maven-jar-plugin/examples/manifest-customization.html)
- [Apache Maven](https://www.ibm.com/developerworks/cn/java/j-5things13/index.html)


