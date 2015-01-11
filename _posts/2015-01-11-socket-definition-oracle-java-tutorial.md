---
layout: post    
category: "Tech"   
title: "Socket是什么 -- Oracle Java Tutorial 翻译"      
tags: [Java]    
description: "本文是Oracle Java开发手册中Sockets系列的翻译第二篇，个人手工翻译，非转载。"
---

一般而言，一个服务器运行在一台电脑上，这个服务器有一个绑定了端口号的socket。这个服务器一边等待，一边守着socket监听从客户端发过来的连接请求。  

在客户端：客户端知道服务器所在的主机的主机名(hostname)和服务器正在监听的端口号。为了发出连接请求，客户端尝试着连接服务器所在的主机名和端口。客户端同时也需要向服务器端证明自己的身份，因此它也绑定了一个本地的端口号以便在本次连接中使用。这一般是由系统指定的。   
![Server listening on port](http://docs.oracle.com/javase/tutorial/figures/networking/5connect.gif)    
如果一切顺利，服务器会接受连接。一旦接受了连接，服务器会得到一个绑定了本地相同端口的新socket，这个socket的另一端被置为客户端的地址和端口。服务器需要一个新的socket,所以它能一边继续在原来的socket监听连接请求，一边处理已建立连接的客户端的需求。   
![connection_established](http://docs.oracle.com/javase/tutorial/figures/networking/6connect.gif)    

在客户端，如果连接请求被接受，会成功新建一个socket。客户端能利用这个socket来与服务器端通信。   

现在，客户端和服务器能通过向它们的sockets读/写数据来通信了。   

>定义      
>Socket是网络上运行着的两个程序所形成的双向通信连接的一端(endpoint)。每个socket都绑定了一个端口号，所以TCP层能确定数据接收方的程序。  

*连接的一端*(*endpoint*)是一个IP地址和一个端口号的组合。每个TCP连接能被两个*连接的一端*唯一标志。这样，主机和服务器之间就能存在多个连接。   

Java平台上的java.net包提供了Socket这个类，它实现了Java程序和网络上另一个程序的双向连接的一边。Socket类位于依赖于平台的实现方式的顶端，向Java程序隐藏了所有系统的细节。通过使用java.net.Socket类而不是系统的原生代码，Java程序能一种独立于平台的实现方式与网络通信。    

另外，java.net包也包括了ServerSocket类，它实现的socket能被服务器用来监听、接受来自客户端的连接请求。   

如果你想连接Web，那么URL类和与之相关的类(URLConnection, URLEncoder)可能比Socket类更适合。事实上，URL类是连接Web相对更高层次的方式，它也用到sockets作为底层的部分实现。   


##原文链接
[What Is a Socket?](http://docs.oracle.com/javase/tutorial/networking/sockets/definition.html)
