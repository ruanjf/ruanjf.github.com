---
layout: post
title: "基于Spring Cloud的分布式微服务化项目搭建"
date: 2018-02-28 21:18
comments: true
category: java
tags: ['spring', 'docker']
---

本项目使用[Spring Cloud](https://projects.spring.io/spring-cloud/)的[Camden.SR7](http://cloud.spring.io/spring-cloud-static/Camden.SR7/)版本。主要包含以下部分：

- 服务发现微服务
- 配置微服务
- 客户端负载均衡
- 熔断
- 路由
- 网关微服务
- 多租户
- 分布式追踪
- Docker集成

## 前期准备

本项目使用到了Spring Cloud、Spring Boot、Maven、Git其中Maven由于工程管理，Git用于存储配置。

### 工程搭建

创建一个[Maven](http://maven.apache.org/) POM文件添加Spring Boot和Spring Cloud依赖的公共POM`demo-parent`用于复用配置，POM文件如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.4.5.RELEASE</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.runjf.springcloud</groupId>
    <artifactId>demo-parent</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>pom</packaging>

    <properties>
        <java.version>1.8</java.version><!-- 指定Java版本 -->
        <spring.boot.version>1.4.5.RELEASE</spring.boot.version>
        <spring.cloud.version>Camden.SR7</spring.cloud.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring.cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <dependencies>
        <dependency><!-- 统一配置 -->
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-config</artifactId>
        </dependency>
        <dependency><!-- 服务发现客户端 -->
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-eureka</artifactId>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin><!-- spring boot 插件用于打包可执行jar -->
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>

</project>
```

由于每个工程都会包含配置和服务发现因此在pom文件中添加了`spring-cloud-starter-config`和`spring-cloud-starter-eureka`依赖，接着创建Maven工程添加`parent`配置：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <groupId>com.runjf.springcloud</groupId>
        <artifactId>demo-parent</artifactId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.runjf.springcloud</groupId>
    <artifactId>demo-xxx</artifactId>

</project>
```

工程结构如下：

```
demo-xxx
├── pom.xml
├── src
│   ├── main
│   │   ├── docker
│   │   │   └── Dockerfile
│   │   ├── java
│   │   │   └── com
│   │   │       └── runjf
│   │   │           └── springcloud
│   │   │               └── xxx
│   │   │                   └── Application.java
│   │   └── resources
│   │       ├── application.yml
│   │       └── bootstrap.yml
│   └── test
└── target
```

### 配置文件
由于Spring Cloud基于[Spring Boot](https://projects.spring.io/spring-boot/)搭建的因此这里先介绍一些使用到的功能：

- 启动应用，其中`SpringApplication.run`用于启动应用`@SpringBootApplication`用于启用相关配置具体查看[这里](https://docs.spring.io/spring-boot/docs/1.4.5.RELEASE/reference/htmlsingle/#using-boot-using-springbootapplication-annotation) 
    
    ```java
    package com.runjf.springboot.demo;
        
    import org.springframework.boot.SpringApplication;
    import org.springframework.boot.autoconfigure.SpringBootApplication;
        
    @SpringBootApplication
    public class Application {
        
        public static void main(String[] args) {
            SpringApplication.run(Application.class, args);
        }
        
    }
    ```
    
- 配置读取，Spring Boot应用默认会依次查找当前目录（`Application.class`所在目录）下`/config`子目录、当前目录、classpath下`/config`子目录和classpath根目录下的`application.properties`或者`application.yml`配置文件，具体代码在`org.springframework.boot.context.config.ConfigFileApplicationListener`中。

由于Spring Cloud通过`org.springframework.cloud.bootstrap.BootstrapApplicationListener`启动初始化上下文，并[设置](https://docs.spring.io/spring-boot/docs/1.4.5.RELEASE/reference/htmlsingle/#howto-change-the-location-of-external-properties)`spring.config.name`配置文件名称为`bootstrap`因此有了配置文件`bootstrap.properties`或者`bootstrap.yml`，默认`bootstrap`配置优先级较高无法被本地配置覆盖。

为了更好的区别服务发现中注册的每个微服务，我们通过`spring.appliction.name=demo-xxx`给每个微服务一个特定的名字

想要使用Spring Cloud首先要选定一种服务优先启动（服务发现优先、配置管理优先）方式，选择不同的方式将导致微服务的启动顺序有所不同相应的配置有所变化。当使用服务发现优先时可以把`配置管理微服务`注册到`服务发现微服务`这样其他的微服务只需`服务发现微服务`地址而不用关心`配置管理微服务`地址（可以通过服务发现获取）。当使用配置管理优先时需要在每个微服务中配置`配置管理微服务`地址，再在配置仓库中设置`服务发现微服务`的地址。Spring Cloud默认为配置管理优先，本架构使用服务发现优先因此需要在`bootstrap.yml`中配置`spring.cloud.config.discovery.enabled=true`

## 服务发现微服务

服务发现包含两个部分：

- 服务端，用于提供提供服务发现和注册
- 客户端，用于获取其他应用的注册信息和把本应用注册到服务端

### 服务端创建

创建Maven工程`demo-discovery`用于启动服务发现微服务，参考前面的工程搭建然后在pom文件中添加`spring-cloud-starter-eureka-server`依赖结果如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <groupId>com.runjf.springcloud</groupId>
        <artifactId>demo-parent</artifactId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.runjf.springcloud</groupId>
    <artifactId>demo-discovery</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-eureka-server</artifactId>
        </dependency>
    </dependencies>

</project>
```

首先添加配置信息，服务发现的启动方式有两种：独立方式、多实例互相注册方式，具体的配置信息可参考`org.springframework.cloud.netflix.eureka.EurekaClientConfigBean`。这里使用独立方式，配置信息`application.yml`如下:

```yaml
server:
  port: 8761 # 指定微服务的端口

eureka:
  client:
    registerWithEureka: false # 不需要在服务发现中注册
    fetchRegistry: false # 不需要获取其他服务发现中的注册信息
    serviceUrl:
      defaultZone: ${SPRING_DISCOVERY_URI:http://localhost:8761/eureka/}
  instance:
    preferIpAddress: true # 使用ip代替hostname
```

其中添加`SPRING_DISCOVERY_URI`是为了启动时方便设置地址。

然后在`Application.java`中加入`@EnableEurekaServer`注解用于启动服务发现

```java
@EnableEurekaServer // 启动服务发现服务
@SpringBootApplication
public class Application {
    
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
    
}
```

启动好服务后就可以通过`http://localhost:8761/`查看信息了

### 客户端配置

其他工程需要通过`@EnableDiscoveryClient`结合`@SpringBootApplication`或者直接使用`@SpringCloudApplication`启用服务发现并在`bootstrap.yml`中配置服务发现服务端的地址。入口代码如下：

```java
@EnableDiscoveryClient
@SpringBootApplication
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

}
```

修改配置文件`bootstrap.yml`中添加服务发现服务端的地址

```yaml
eureka:
  client:
    serviceUrl:
      defaultZone: ${SPRING_DISCOVERY_URI:http://localhost:8761/eureka/}
```

由于已在`demo-parent`中添加了`spring-cloud-starter-eureka`依赖所以pom无需做修改。


## 配置微服务

配置管理也包含两个部分：

- 服务端，用于提供配置一般使用[Git](https://git-scm.com/)作为配置的存储，不过也可以使用其他存储
- 客户端，用于获取当前应用的配置信息

### 服务端创建

创建Maven工程`demo-config`用于启动配置微服务，参考前面的工程搭建然后在pom文件中添加`spring-cloud-config-server`依赖结果如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <groupId>com.runjf.springcloud</groupId>
        <artifactId>demo-parent</artifactId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.runjf.springcloud</groupId>
    <artifactId>demo-config</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-config-server</artifactId>
        </dependency>
        <dependency><!-- 接收配置文件变化 -->
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-config-monitor</artifactId>
        </dependency>
    </dependencies>

</project>
```

接着修改配置`bootstrap.yml`添加本微服务名称、服务发现地址和配置存储地址，这里使用Git作为后端存储由于Git默认没有提供图形界面不好管理所以使用[Gitlab](https://gitlab.com/)的Docker[镜像](https://github.com/sameersbn/docker-gitlab)搭建。配置如下：

```yaml
spring:
  application:
    name: demo-config
  cloud:
    config:
      server:
        git:
#         本地文件配置方式（Linux）file://${user.home}/config-repo
#                     (Windows) file:///${user.home}/config-repo
          uri: ${SPRING_CONFIG_GIT_URI:http://gitlab.local/demo/config.git}

eureka:
  client:
    serviceUrl:
      defaultZone: ${SPRING_DISCOVERY_URI:http://localhost:8761/eureka/}

```

然后在`application.yml`中添加微服务端口`server.port: 8888`，再在`Application.java`中加入`@EnableConfigServer`注解用于启动服务发现

```java
@EnableConfigServer // 启动配置服务
@SpringBootApplication
public class Application {
    
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
    
}
```

由于之前在pom中添加了`spring-cloud-config-monitor`依赖现在可以通过Gitlab的[Webhooks](http://gitlab.work.net/help/user/project/integrations/webhooks)触发配置修改的更新，这样就可以通过浏览器修改配置。如果配置更新后想通知其他应用可以添加`spring-cloud-starter-bus-amqp`依赖（这个利用的[Spring Cloud Bus](http://cloud.spring.io/spring-cloud-static/Camden.SR7/#_spring_cloud_bus)提供的支持）

### 客户端配置

修改配置文件`bootstrap.yml`中添加配置微服务配置，由于配置服务已注册到了服务发现所以只要在配置文件中配置配置服务的名称`demo-config`和设置服务发现优先

```yaml
spring:
  cloud:
    config:
      discovery:
        enabled: true # discovery first
        serviceId: demo-config
```

由于已在`demo-parent`中添加了`spring-cloud-starter-config`依赖所以pom无需做修改。

客户端通过`spring.application.name`读取配置文件（例如：`demo-xxx.yml`），如果配置仓库中存在`application.yml`则会作为共享配置。启动应用后会看到如下日志信息：

```
b.c.PropertySourceBootstrapConfiguration : Located property source: CompositePropertySource [name='configService', propertySources=[MapPropertySource [name='configClient'], MapPropertySource [name='http://gitlab.local/demo/config.git/demo-xxx.yml'], MapPropertySource [name='http://gitlab.local/demo/config.git/application.yml']]]
```

## 客户端负载均衡

通过客户端负载均衡进行微服务间的通信由于我们的应用对外提供的都是RESTful风格的api所以可以直接使用`RestTemplate`结合`@LoadBalanced`实现客户端负载均衡。这个是利用了`RestTemplate`可以自动配置使用`Ribbon`，其中`spring-cloud-starter-ribbon`依赖已由`spring-cloud-starter-eureka`提供了就不用显示添加了。现在Spring默认已经不创建`RestTemplate`Bean了因此需要在`Application.java`中显示添加配置Bean，代码如下：

```java
@LoadBalanced
@Bean
public RestTemplate restTemplate() {
    return new RestTemplate();
}
```

如果想自定义`RestTemplate`的参数（如：访问超时、读取超时等）可以使用构造方法`RestTemplate(ClientHttpRequestFactory requestFactory)`例如：

```java
PoolingHttpClientConnectionManager connectionManager = new PoolingHttpClientConnectionManager(30, TimeUnit.SECONDS);
connectionManager.setDefaultMaxPerRoute(20);
connectionManager.setMaxTotal(100);
CloseableHttpClient httpClient = HttpClients.createMinimal(connectionManager);
HttpComponentsClientHttpRequestFactory requestFactory = new HttpComponentsClientHttpRequestFactory(httpClient);
RestTemplate restTemplate = new RestTemplate(requestFactory);
```

具体的使用`String str = restTemplate.getForObject("http://demo-xxx/data", String.class);`，其中使用微服务名称（通过`spring.application.name`设置，本例子中的`demo-xxx`）代替具体的域名或者ip，负载均衡的`RestTemplate`支持配置失败重试可以通过`spring.cloud.loadbalancer.retry.enabled=true`启用该功能，具体的配置项可以参看`org.springframework.cloud.config.client.RetryProperties`。微服务名称到具体ip的切换是通过`org.springframework.cloud.netflix.ribbon.RibbonLoadBalancerClient`

## 熔断

熔断用于当请求链（一个请求会依次调用多个服务）中的某个微服务无响应或者超过指定的请求时间（特定策略）的微服务进行下线。添加仪表盘可以查看实时的请求情况（采样部分数据）

### 配置

首先需要在pom文件中添加`spring-cloud-starter-hystrix`依赖，然后在需要使用熔断的Bean的方法中添加`@HystrixCommand`注解用于启用熔断，如果需要整合多个微服务的熔断采样信息可以添加`spring-cloud-netflix-hystrix-stream`和`spring-cloud-starter-stream-*`依赖，具体配置如下：

```xml
<dependency><!-- 熔断器 -->
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-hystrix</artifactId>
</dependency>
<dependency><!-- 熔断器 输出统计数据 -->
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-netflix-hystrix-stream</artifactId>
</dependency>
<dependency><!-- 流相关 可用于汇总统计数据 -->
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-stream-rabbit</artifactId>
</dependency>
```

在Bean添加熔断注解：

```java
@Component
public class StoreIntegration {

    @HystrixCommand(fallbackMethod = "defaultStores")
    public Object getStores(Map<String, Object> parameters) {
        //do stuff that might fail
    }

    public Object defaultStores(Map<String, Object> parameters) {
        return /* something useful */;
    }
}
```

如果想进行熔断的[配置](https://github.com/Netflix/Hystrix/wiki/Configuration)可以在`application.yml`文件中添加如下配置：

```yaml
# 熔断开启线程超时（默认是启用的）
hystrix.command.default.execution.timeout.enabled: true
# 熔断处理请求的线程超时时间为10秒
hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds: 10000
# getStores方法的特定配置，熔断处理请求的线程超时时间为30秒
hystrix.command.getStores.execution.isolation.thread.timeoutInMilliseconds: 30000
```

可以在`getStores`方法中使用`RestTemplate`这时需要注意熔断配置和`HttpClient`配置的结合（例如：超时时间等）

然后在`Application.java`文件中添加`@EnableCircuitBreaker`结合`@SpringBootApplication`或者直接使用`@SpringCloudApplication`开启熔断支持，启用后获取Hystrix数据的方式有两种：

- 通过`HystrixStreamEndpoint`提供一个地址`/hystrix.stream`用来获取数据
- 通过Spring Cloud Stream来传递数据

### Hystrix仪表盘创建

Hystrix仪表盘用于可视化显示每个熔断器的运行情况。启动一个仪表盘需要在`pom.xml`中添加`spring-cloud-starter-hystrix-dashboard`依赖和在`Application.java`中添加注解`@EnableHystrixDashboard`。当想合并多个微服务中的Hystrix数据时可以在`pom.xml`中添加`spring-cloud-starter-turbine-stream`依赖、在`Application.java`中添加注解`@EnableTurbineStream`和在`application.yml`中[配置](http://cloud.spring.io/spring-cloud-static/Camden.SR7/#_turbine)服务信息。

启动Hystrix仪表盘后可以通过`http://hostname:port/hystrix`访问，然后在页面中填入已开启熔断支持的微服务的地址`http://app_hostname:port/hystrix.stream`即可看到Hystrix数据的图标了。


## 网关微服务

用来统一对外提供服务，集成了用户权限校验、路由（基于反向代理）等。

### 微服务创建

创建Maven工程`demo-gateway`用于启动配置微服务，参考前面的工程搭建然后在pom文件中添加`spring-cloud-starter-zuul`依赖结果如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <groupId>com.runjf.springcloud</groupId>
        <artifactId>demo-parent</artifactId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.runjf.springcloud</groupId>
    <artifactId>demo-gateway</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zuul</artifactId>
            <exclusions>
                <exclusion>
                    <groupId>commons-logging</groupId>
                    <artifactId>commons-logging</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <dependency>
            <groupId>com.netflix.netflix-commons</groupId>
            <artifactId>netflix-commons-util</artifactId>
        </dependency>
    </dependencies>

</project>
```

接着修改配置`bootstrap.yml`添加本微服务名称、服务发现地址。配置如下：

```yaml
spring:
  application:
    name: demo-gateway
  cloud:
    config:
      discovery:
        enabled: true # discovery first
        serviceId: demo-config

eureka:
  client:
    serviceUrl:
      defaultZone: ${SPRING_DISCOVERY_URI:http://localhost:8761/eureka/}
```

添加启动入口`Application.java`

```java
@EnableZuulProxy
@SpringCloudApplication
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

}
```

由于本项目是网页应用如果存在多个地址会导致js跨域问题（当然也可以通过配置允许跨域的Header）和需要传递用户标识，所以这里使用的是`@EnableZuulProxy`否则可以使用`@EnableZuulServer`。

### 路由

接下来可以进行后端应用的路由配置，设置指定前缀的路径将路由到指定的微服务上，在`application.yml`中配置如下：

```yaml
zuul:
  routes:
    abc:
      path: /abc/** # 指定前缀的路径
      stripPrefix: true # 访问后端时是否要包含前缀/abc
      serviceId: demo-abc # 对应的后端微服务
  ignored-headers: userid,keyabc # 忽略前端传递的Header
```

其中`stripPrefix`的配置依赖于后端微服务是否包含`ContextPath`（默认为空），可以通过`server.contextPath`配置Spring Boot 2.0以后的配置为`server.servlet.contextPath`。`serviceId`则是通过`spring.application.name`进行配置。

如果向后端发起请求时有添加自定义的Header，为了安全考虑应该添加`zuul.ignored-headers`使前端传递的Header无效化。

由于Zuul包含了熔断和负载均衡所以可以针对性的进行配置。对于熔断[配置](https://github.com/Netflix/Hystrix/wiki/Configuration)有：

```yaml
# 熔断是否开启全局线程超时
hystrix.command.default.execution.timeout.enabled: true
# 熔断处理请求的全局线程超时时间为1秒
hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds: 1000

hystrix:
  command:
    demo-abc:
      # demo-abc微服务熔断处理请求的全局线程超时时间5秒
      execution.isolation.thread.timeoutInMilliseconds: 5000
      threadPoolKeyOverride: demo-abc
  threadpool:
    demo-abc: # demo-abc微服务特定的线程池配置
      coreSize: 11 # 30 rps * 0.2 seconds = 6 + 5 = 11
```

对于负载均衡[配置](https://github.com/Netflix/ribbon/wiki/Programmers-Guide)有：

```yaml
# 读取超时时间
ribbon.ReadTimeout: 6000 
# demo-abc微服务负载均衡特定配置
demo-abc:
  ribbon:
    MaxTotalConnections: 200 # 最大连接数
    MaxConnectionsPerHost: 50 # 每个host最大连接数
    ConnectTimeout: 2000 # 连接超时时间
    ReadTimeout: 5000 # 读取超时时间
```

如果还有前置的反向代理，则前置反向代理的读取超时时间应该要大于或者等于负载均衡中配置的最大读取超时时间，例如还有前置反向代理服务器[Nginx](http://nginx.org/)则需要在`nginx.conf`中[配置](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_read_timeout)超时时间`proxy_read_timeout 60s;`

### 用户权限校验

通过集成[Shiro](https://shiro.apache.org/)进行权限校验，校验通过后会在请求Header中添加用户标识符方便后端微服务获取用户信息。

## 分布式追踪

使用[Spring Cloud Sleuth](http://cloud.spring.io/spring-cloud-static/Camden.SR7/#_spring_cloud_sleuth)进行请求链路的追踪，通过[Zipkin](https://github.com/openzipkin/zipkin)查看采样数据。首先在微服务的`pom.xml`中添加`spring-cloud-starter-sleuth`依赖如果想通过Stream的方式传递数据可以再添加`spring-cloud-sleuth-stream`和`spring-cloud-starter-stream-rabbit`（如果之前的Hystrix已添加则可忽略）依赖。然后创建Zipkin服务端添加如下依赖：

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-sleuth</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-sleuth-zipkin-stream</artifactId>
</dependency>
<dependency>
    <groupId>io.zipkin.java</groupId>
    <artifactId>zipkin-autoconfigure-ui</artifactId>
    <version>1.31.3</version>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-jdbc</artifactId>
</dependency>
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
</dependency>
```

其中`zipkin-autoconfigure-ui`提供了UI界面方便查看数据，`spring-boot-starter-jdbc`和`mysql-connector-java`用来存储追踪的采样数据`ZipkinServerConfiguration`默认的存储`zipkin.storage.type`是在内存中使用一段时间后会把内存占满因此建议改用外部存储。默认的采样百分比为`10%`在`application.yml`中可以配置`spring.sleuth.sampler.percentage`也可以自己创建Bean提供采样策略替换`SleuthStreamAutoConfiguration`中默认配置。

接下来在`Application.java`中添加注解`@EnableZipkinStreamServer`用于启动Zipkin服务，用浏览器打开服务的地址就可以看到界面了。

由于项目中使用了[WebSocket](https://zh.wikipedia.org/wiki/WebSocket)和[JMS](https://zh.wikipedia.org/zh-cn/Java%E6%B6%88%E6%81%AF%E6%9C%8D%E5%8A%A1)这部分追踪数据不是必须的因此添加如下配置

```yaml
spring:
  sleuth:
    integration: # 关闭 Trace Messaging指定MQ队列
      enabled: false
      patterns: demo-*,topic://demo- # 或者指定队列不采集
      websockets:
        enabled: false
    scheduled: # 关闭定时
      enabled: false
```

## 多租户

通过[EclipseLink](http://www.eclipse.org/eclipselink/)提供的多租户功能并扩展`JpaTransactionManager`和代理`EntityManagerFactory`从而提供了EclipseLink需要的租户标识`eclipselink.tenant-id`。

## Docker集成

Spring Boot提供的打包插件`spring-boot-maven-plugin`支持将所有依赖和到一个jar中，这样很方便的启动一个微服务只需要在命令行下执行`java -jar demo-xxx-1.0.jar`即可。为了简化部署考虑通过将微服务打包为[Docker](https://www.docker.com/)镜像连`java`环境也可以一并包含了，只要通过简单的`docker run rjf/demo-xxx`。

为了达到这个目的首先需要在`pom.xml`添加Docker[插件](https://github.com/spotify/docker-maven-plugin)`docker-maven-plugin`并配置`Dockerfile`位置`<dockerDirectory>`、镜像名称`<imageName>`、打包参数`<buildArgs>`以及一些需要包含的资源`<resources>`。`<buildArgs>`用于将参数传递给`Dockerfile`比如jar包的名称以及版本号等

```xml
<properties>
    <docker.image.prefix>rjf</docker.image.prefix>
    <docker.app.pkg>${project.build.finalName}.jar</docker.app.pkg>
</properties>

<plugin>
    <groupId>com.spotify</groupId>
    <artifactId>docker-maven-plugin</artifactId>
    <version>0.4.13</version>
    <configuration>
        <buildArgs>
            <APP_NAME>${project.artifactId}</APP_NAME>
            <APP_VERSION>${project.version}</APP_VERSION>
            <APP_PKG>${docker.app.pkg}</APP_PKG>
        </buildArgs>
        <imageName>${docker.image.prefix}/${project.artifactId}</imageName>
        <dockerDirectory>src/main/docker</dockerDirectory>
        <resources>
            <resource>
                <targetPath>/</targetPath>
                <directory>${project.build.directory}</directory>
                <include>${docker.app.pkg}</include>
            </resource>
        </resources>
    </configuration>
</plugin>
```

然后在`src/main/docker`文件夹中新建文件`Dockerfile`，其中[HEALTHCHECK](https://docs.docker.com/v17.03/engine/reference/builder/#healthcheck)用于检查微服务是否启动完成配合[Docker Compose](https://docs.docker.com/v17.03/compose/reference/overview/)（需要在`docker-compose.yml`中指定`version: '2.1'`以上版本）的[depends_on](https://docs.docker.com/v17.03/compose/compose-file/compose-file-v2/#depends_on)下的配置`condition: service_healthy`可以实现按照指定顺序启动微服务，内容如下：

```docker
FROM frolvlad/alpine-oraclejdk8:slim
VOLUME /tmp
ARG APP_PKG
ARG APP_NAME
ARG APP_VERSION
ENV APP_NAME ${APP_NAME}
ENV APP_VERSION ${APP_VERSION}
ENV JAVA_OPTS ""
ADD ${APP_PKG} app.jar
RUN sh -c 'touch /app.jar'
HEALTHCHECK --interval=1m --timeout=10s \
  CMD wget -qO- "http://localhost:8761/info" || exit 1
CMD exec java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app.jar
```

其中最后的`CMD`命令未使用`CMD ["param1","param2"]`是因为两原因：

- 避免启动后的PID`1`被`sh`占用，通过`pstree -s <pid>`查看可以看出`───docker-containe───entrypoint.sh───java───137*[{java}]`和`───docker-containe───java───63*[{java}]`的区别，其中多了`entrypoint.sh`这样会存在当传递信号时未被真正的java进程接收并处理的问题。
- 当使用`docker exec`命令时正常可以执行，否则需要添加Shell脚本文件`entrypoint.sh`并在中其中处理参数`exec "$@"`。

接下来打开终端进入到工程目录执行`mvn package`生成jar文件，然后执行`mvn docker:build`构建Docker镜像。如果Docker服务在远程则可以通过`export DOCKER_HOST=tcp://192.168.1.123:2375 && mvn docker:build`进行远程构建。

构建完成后执行`docker run --rm rjf/demo-xxx`即可启动微服务，如果不想执行默认的java进程可以在后面添加要执行的命令即可，例如想执行`ls`命令可以用`docker run --rm -it rjf/demo-xxx ls`

## 参考

- [Spring Boot](https://docs.spring.io/spring-boot/docs/1.4.5.RELEASE/reference/htmlsingle)
- [Spring Cloud](http://cloud.spring.io/spring-cloud-static/Camden.SR7/)
- [Hystrix](https://github.com/Netflix/Hystrix/wiki/Configuration)
- [Ribbon](https://github.com/Netflix/ribbon/wiki/Programmers-Guide)
- [ngx_http_proxy_module](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_read_timeout)
- [Zipkin](https://github.com/openzipkin/zipkin)
- [docker-maven-plugin](https://github.com/spotify/docker-maven-plugin)
- [Dockerfile](https://docs.docker.com/v17.03/engine/reference/builder)
- [Docker Compose](https://docs.docker.com/v17.03/compose/reference/overview/)



