+++
Categories = ["Tech"]
Description = "偶尔见到、不常使用的机制，Java SE的一部分。"
Tags = ["Java"]
date = "2017-07-22T18:26:25+08:00"
title = "JMX学习笔记"

+++

JMX，全称`Java Management Extensions`，借用贾宝玉的一句话描述它：「这个妹妹，我曾见过的。」

见过却不熟悉，它在我心中是Java规范中比较冷门的一个角落。  

几次看到Java的招聘JD要求对JMX的理解，所以，在Oracle官网翻到教程，跟着学习学习。  

## Oracle教程地址  
[Java Management Extensions(JMX): Table of Contents](https://docs.oracle.com/javase/tutorial/jmx/TOC.html)  

这份文档讲的内容很基础，介绍了JMX的整体架构、用处、基础组件，以及给出了带代码的简单演示。  

## JMX用来做什么？  
JMX是Java 标准规范的一部分，可以用来 **监控** 和 **管理** JVM中运行时的资源。除了监控运行时占用的CPU、内核、线程资源，JMX还可以让你直接invoke 方法、修改对象属性（有点暴力了吧。。）。  
- JDK中自带的`jconsole`工具，利用的就是JMX。  

JMX可以将管理接口暴露成HTTP调用，这样，通过ip和端口号可以远程监控、管理服务器上的JVM。  
 - 远程调试需要打开服务器上打开某个端口，利用的也是JMX。  
 - Tomcat有个HTTP 的管理页面，用的也是JMX。  

## JMX怎么用  
1. 监控JVM  
   JVM自带支持JMX，开箱即用(`out-of-box`)。意味着，不需要额外操作就可以用`jconsole`之类的命令监控JVM。  

2. 监控Applicaiton  
   Application的实现得满足JMX标准。JMX标准是什么，见下文。   

## JMX标准  
1. MBeans  
   JMX将它管理的对象称为`MBean`。换言之，要使用JMX，就得把要管理的资源封装成MBeans。  

	JMX定义了几类`MBeans`，就标准MBeans(`Standard MBeans`)而言，它是这么定义的：后缀为`MBean`的interface(例如`HelloMBean`), 以及除去`MBean`后缀的实现MBean的实现类(这里就是`Hello`)。  

2. JMX Agent  
   JMX Agent又称为JMX Server，用来管理MBeans。  

	关键的代码类似：  
	
		MBeanServer mbs = ManagementFactory.getPlatformMBeanServer(); 
        ObjectName name = new ObjectName("com.example:type=Hello"); 
        Hello mbean = new Hello(); 
        mbs.registerMBean(mbean, name);

3. JMX Connector  
   用`JVM connector`，MBean可以暴露给远程客户端，然后远程客户端就可以管理它了。  

	常用的Connector包括：HTTP，RMI。与之对应的管理client: web浏览器，JMX Client。  

## JMX的通知机制  
JMX允许MBeans发送通知。  

如果MBeans实现了发送Notification的逻辑，就可以用`jconsole`一类的工具收到通知。  
