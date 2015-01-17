---
layout: post    
category: "Tech"   
title: "厘清Java Socket端口问题 -- 服务器的端口是什么"      
tags: [Java]    
description: "java中用ServerSocket.accept()方法接受客户端的socket连接申请后，一个新的socket将会生成。关于这个socket，它两头的IP和端口是怎么确定的，存在着不同解释。本文将说明并验证：新建socket的服务器端端口号就是服务器正在监听的端口号，而不是随机分配的端口号。"
---

在我之前翻译的[Socket是什么](http://blog.yuantops.com/tech/socket-definition-oracle-java-tutorial/)一文中，对java中socket建立的流程有描述。在服务器接受客户端socket连接的部分，它这么说道：  

> 如果一切顺利，服务器会接受连接。一旦接受了连接，服务器会得到一个绑定了**本地相同端口**的新socket，这个socket的另一端被置为客户端的地址和端口。服务器需要一个新的socket,所以它能一边继续在原来的socket监听连接请求，一边处理已建立连接的客户端的需求。   
>
> (原文)  
> If everything goes well, the server accepts the connection. Upon acceptance, the server gets a new socket bound to the **same local port** and also has its remote endpoint set to the address and port of the client. It needs a new socket so that it can continue to listen to the original socket for connection requests while tending to the needs of the connected client.  

配图:  
![socket connection established](http://docs.oracle.com/javase/tutorial/figures/networking/6connect.gif)    

**本地相同端口(same local port)**指的到底是哪个端口？依示例图所示，它指的就是服务器端的**监听端口**，而不是其它的端口。   

官方文档的说法按说是权威的——事实上的确它是对的。但是，在*Head First Java*中描述ServerSocket.accept()方法有这么一段话：  

> When a client finally tries to connect, the method returns a plain old Socket(on a different port) that knows how to communicate with the client(i.e, knows the client's IP address and the port number).   

> The socket is on a different port than the ServerSocket, so that the server socket can go back to waiting for other clients.   

这个说法就不太正确了。幸好*Head First Java*出版社已经发现了这个小失误，并在官方网站的勘误表上贴出了[说明](http://www.oreilly.com/catalog/errataunconfirmed.csp?isbn=9780596009205)：    

> This isn't the case. The thing that has to be unique for each socket is the source port, source ip, destination port & destination ip.   

根据勘误表上的解释，每一个socket连接都需要保证是唯一的，而socket的标志符由源IP、源端口、目的IP、目的端口四部分构成。只要四者有一个不同，那么就能建立两个不同的socket。所以，对于不同的Socket连接，服务器端的IP和端口号可以相同。   

但*Head First Java*十分畅销，导致错误的说法流传甚广，造成了学习者很多误解。  

###来源参考
[StackOverflow.com](https://stackoverflow.com/questions/4307549/serversocket-accept-method/4308243#4308243)有网友这么解释道：  

> The client chooses its port at random (you don't need to do anything special in Java) and connects to the server on whichever port you specified.  

###实践验证
根据这个网友提供的思路，我们可以实际检验一下。   

[Writing the server side of a socket](http://docs.oracle.com/javase/tutorial/networking/sockets/clientServer.html)中提供了客户端和服务器端的两个小例子。按照文章里面说的，我将几段代码下载到我的Fedora机器上，先运行服务器代码，它监听4444端口。  
java KnockKnockServer 4444    

使用`netstat -na` 命令查看机器上打开的端口，(省略无关条目)：   
{%highlight bash%}
Proto Recv-Q Send-Q Local Address   Foreign Address         State      
tcp6       0      0        :::4444       :::*               LISTEN
{%endhighlight%}

再运行客户端代码，它与本机上的服务器程序建立socket连接。    
java KnockKnockClient 127.0.0.1 4444    
再使用`netstat -na` 命令查看机器上打开的端口，(省略无关条目)：   
{%highlight bash%}
Proto Recv-Q Send-Q Local Address   Foreign Address         State      
tcp6       0      0 :::4444                 :::*                    LISTEN     
tcp6       0      0 127.0.0.1:50031         127.0.0.1:4444          ESTABLISHED  
tcp6       0      0 127.0.0.1:4444          127.0.0.1:50031         ESTABLISHED  
{%endhighlight%}

有两条socket的记录。其中一条是服务器的，另一条是客户端的。它们的local address和foreign address刚好是相反的，这对应了socket的local和remote概念。从这两条记录看，建立的socket连接，服务器端占用的端口还是监听端口(4444)，而且此时服务器还在端口(4444)监听连接请求。    
