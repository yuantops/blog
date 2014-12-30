---
layout: post    
category: "Tech"   
title: "Java 的一些术语解释"      
tags: [Java]  
description: "本文介绍Java初学者容易弄糊涂的一些概念：JRE，JDK，JavaSE，JavaME，JavaEE等"
---

作为JAVA初学者，往往弄不清楚一系列术语的概念。这篇文章搬运[文章一](http://stackoverflow.com/questions/1906445/what-is-the-difference-between-jdk-and-jre)与[文章二](http://stackoverflow.com/questions/10858193/java-jdk-sdk-se)，解释JRE与JDK, JavaSE、JavaME与JavaEE，Java版本等术语 。  

###JRE vs JDK
**JRE**: Java Runtime Environment  
基本说来它是Java Virtual Machine，你的Java程序在它上面运行。它也为浏览器提供Applet运行插件。  

**JDK**: Java Development Kit  
Java软件开发包，它不仅**包括** JRE,还包括编译器等其它工具(JavaDoc, Java Debugger等)。它用来创建、编译程序。  

一般说来，如果你仅仅想让Java程序在自己的电脑和浏览器上跑起来，那么只需安装JRE。如果你想用Java编程，那么需要安装JDK。  

###JavaSE，JavaME和JavaEE
因为围绕Java形成的生态圈十分庞大，所以Sun公司提供了Java的不同发行版。  

**JavaSE**: Java Standard Edition  
适合于客户端软件、常规程序等。我们平时所使用的、所下载的Java版本一般都是它。  

**JavaME**: Java Mobile Edition  
通常是老式手机游戏所产生的平台，它对Java进行了精简，使其更适合低性能的处理器。  

**JavaEE**: Java Enterprise Edition  
通常用来研发服务器端的产品，因此往往它包含很多服务器需要用到的包。  

###Java的版本号
我们在下载安装Java JRE或者JDK后，使用"java -version"命令查看当前的Java版本，会发现类似下面的信息：  
{%highlight bash%}
java version "1.7.0_71"
{%endhighlight %}
Java 1.7是我机器上的java版本号，它也被称为Java 7：它们是一个东西，两个名称。再累赘一点地说，它也是JavaSE 7。   

###扩展阅读
更详细、更权威的资料，可以阅读Oracle的[Java SE Technologies文档](http://www.oracle.com/technetwork/java/javase/tech/index.html)。  
