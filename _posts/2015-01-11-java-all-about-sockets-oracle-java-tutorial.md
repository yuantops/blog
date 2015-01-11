---
layout: post    
category: "Tech"   
title: "Sockets in Java -- Oracle Java Tutorial 翻译"      
tags: [Java]    
description: "本文是Oracle Java开发手册中Sockets系列的翻译第一篇，个人手工翻译，非转载。"
---

##课程：关于Sockets的一切
URL和URLConnection为获取因特网上的资源提供了一种相对高层次(high-level)的机制。但有时候，你的程序需要一种相对低层次(lower-level)的网络通信，譬如说，你可能需要编写一个客户端-服务器(client-server)程序。   

在客户端-服务器程序中，服务器端提供一些服务：譬如处理数据库查询，或者发送当前的期货价格。客户端利用服务器提供的这些服务器，用来向用户显示数据库查询的结果，或者给投资者提供期货的购买建议。客户端和服务器端的通信因此必须是**可信**的。换言之，数据不能丢失，而且它到达客户端的顺序必须与服务器的发送顺序一致。  

TCP协议提供了一个可信的、点到点的通信信道，因特网上的客户端-服务器端程序可以使用它来通信。为了基于TCP通信，客户端程序和服务器程序要和对方建立连接。每个程序各自将一个socket绑定到连接的一头。当通信时，客户端和服务器各自从与连接绑定的socket里面读/写数据。   

##Socket是什么?
因特网上运行着的两个程序建立了一个双向的通信连接，Socket就是这个连接的一端。Socket类用来表示一个客户端程序和一个服务器程序间的连接。java.net包中提供了Socket和ServerSocket这两个类，它们分别是这一连接的客户端实现和服务器端实现。  

##通过Socket读和写
[Reading from and Writing to a Socket](http://docs.oracle.com/javase/tutorial/networking/sockets/readingWriting.html)包含一个小例子，它演示了客户端程序如何从Socket读数据和向socket写数据。   

##编写一对socket Client/Server
[Reading from and Writing to a Socket](http://docs.oracle.com/javase/tutorial/networking/sockets/readingWriting.html)演示了客户端程序如何通过socket与一个存在的服务器端交互。[Writing a Client/Server Pair](http://docs.oracle.com/javase/tutorial/networking/sockets/clientServer.html)则演示如何实现连接的另一端——服务器端的功能。   

##原文链接
[Lesson: All About Sockets](http://docs.oracle.com/javase/tutorial/networking/sockets/index.html)
