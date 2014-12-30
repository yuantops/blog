---
layout: post    
category: "Tech"   
title: "开源中国安卓客户端源码学习笔记 一"      
tags: [Android, OSC]  
description: "本文是引言，OSC安卓客户端源代码学习笔记系列的第一篇。"
---

##前言
开源中国(OSCHINA)是国内一个开源社区,社区自己开发了Android和iOS平台的客户端，而且将各自的代码开源了。值得夸奖的是，他们的Android APP不是基于HTML，而是Android原生API。我最近在学习它Android App的[源代码](http://git.oschina.net/oschina/android-app)，毕竟像它这样性能优秀、注释齐全的开源项目是比较稀少的。  

希望能通过阅读源代码，学到一些Android开发的实战技巧，并加深对已有知识的理解。  

##学习笔记一 利用getApplication()共享全局数据  
程序启动Activity是net.oschina.app.AppStart。这个Activity类持有一个自定义的AppContext成员。查看net.oschina.app.AppContext类的定义，作者说它是“全局应用程序类，用于保存和调用全局应用配置及访问网络数据”。  

AppContext类是Application类的子类。Google了getApplication()函数，找到了一篇介绍得比较明白的文章：  
- [android利用getApplication()共享全局数据](http://www.cnblogs.com/liu666bin/archive/2013/01/05/2846081.html)   

在平时开发中，如果需要一些能被所有Activity和View访问到的全局数据，就可以自定义一个继承Application类的子类，扩展它所持有的成员。**值得注意**，还需在android Manifest.xml文件中将application的android:name属性指定为自定义的类。  

另外,关于getApplication()和getApplicationContext()的区别,[stackoverflow](http://stackoverflow.com/questions/5018545/getapplication-vs-getapplicationcontext)上有人这么解释:  

	虽然当前Anroid Activity和Service的实现方式使得getApplication()和getApplicationContext()返回相同的object，但不能保证它们将来会一直这样。  

	如果你想在Manifest.xml文件中注册Application class，那么**永远不要**调用getApplicationContext()并将其cast为你的application类，因为它返回的很可能不是你的application实例。  

	getApplication()仅仅在Activity和Service类中可以被调用，而getApplicationContext()则是在Context类中被声明的。这意味着，譬如说你写了一个Broadcast Receiver，Broadcast Receiver本身不是一个Context类，尽管它能通过onReceive()方式获得一个Context类的引用，这时你就只能调用getApplicationContext()了——这也就意味着，不能确保在BroadcastReceiver中访问到application。  

	另外，Android的官方文档中提到，你**不应该**需要去继承Application类:  

	There is normally no need to subclass Application. In most situation, static singletons can provide the same functionality in a more modular way. If your singleton needs a global context (for example to register broadcast receivers), the function to retrieve it can be given a  Context which internally uses Context.getApplicationContext() when first constructing the singleton.  

虽然官方推荐用静态singleton的方式去设置全局数据，但是在回复中有人提到，在实际中还是继承Application的方式来得更方便。所以，到底用那种方式更好，就见仁见智吧。  
