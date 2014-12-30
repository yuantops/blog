---
layout: post    
category: "Tech"   
title: "开源中国安卓客户端源码学习笔记 三 自定义Exception类"      
tags: [Android, OSC]   
description: " 异常处理是Java程序中十分重要的环节。OSC Android APP定义了自己的异常类，并对它们针对性处理。这篇文章关注AppException的处理方法。 "
---

<div class="message">
</div>

net.oschina.app包中包含四个类的定义文件，它们分别是AppConfig, AppException, AppManager, AppStart。其中AppStart类继承Activity，是跳转界面。AppException类是Exception的子类，是自定义的异常类。  

AppException类中有8个final static类型的类变量，定义异常类型: network, socket, http, xml, io, run, jason几种。这个类中有对应的静态方法，以Exception为形参，返回对应的新建对象。值得注意的是，代码中预留了debug的选项，如果在新建AppException对象时传入“debug”参数，那么对应的Exception信息会被写到文件中保存。  

这个类中定义了异常的处理方式：收集错误信息，然后显示异常信息&发送错误报告。显示异常信息和发送错误报告的过程在新建的Thread里完成。  
