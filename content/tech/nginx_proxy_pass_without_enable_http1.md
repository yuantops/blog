+++
title = "nginx 反向代理不开启http1.1时的行为探究"
author = ["yuan.tops@gmail.com"]
description = "nginx 做反向代理服务器，与upstream之间默认使用http1.0协议。借助tcpdump和wireshark,来看看开启http1.1前后的区别。"
date = 2021-08-24T00:00:00+08:00
publishDate = 2021-08-24T00:00:00+08:00
lastmod = 2021-08-24T16:56:12+08:00
tags = ["Linux"]
categories = ["Tech"]
draft = false
keywords = ["nginx"]
+++

最近给一个tomcat服务加上nginx代理，陆续遇到一些问题（坑）。

第一个坑，一个接口直接访问正常，经nginx代理后报104错误(104: Connection reset by peer)。奇葩之处在于，只有特定的接口出现这种错。


## 先说解决方案：配置反向代理长链接 {#先说解决方案-配置反向代理长链接}

很容易搜到104错误的解决方案.在nginx配置中，加上下面两句:

```nil
proxy_http_version 1.1;
proxy_set_header Connection "";
```

加上之后，执行命令 **nginx -s reload** 生效。

翻看nginx[官方文档](http://nginx.org/en/docs/http/ngx%5Fhttp%5Fproxy%5Fmodule.html#keepalive)，这么说:

```nil

For HTTP, the proxy_http_version directive should be set to “1.1” and the “Connection” header field should be cleared:
upstream http_backend {
    server 127.0.0.1:8080;

    keepalive 16;
}

server {
    ...

    location /http/ {
        proxy_pass http://http_backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        ...
    }
}
```

到这里，问题已经解决。我们再进一步，看看配置前后的区别。


## tcpdump 抓包 {#tcpdump-抓包}

在修改前后，各自抓包。

> tcpdump -iensxxx -vvvs0 -l -A 'tcp port 80 or tcp port 8082' -w tcpdump.cap


## wireshark分析 {#wireshark分析}

将\*.cap文件用wireshark 打开.

1.  在filter里输入 **http.request && http contains "HTTP/1.0"** ，过滤出nginx到上游服务的请求.
2.  随意选中一条记录。右键，"追踪流..." -> "TCP流"。这样，筛选出了TCP会话的所有包记录。
3.  右键, "复制" -> "摘要为文本"，可以将报文导出为文本。

下面的记录，第一条是异常响应报文，第二条是正常响应报文。

```nil
--- not ok tcp.stream eq 75
HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
Content-Type: application/json;charset=UTF-8
Date: Mon, 23 Aug 2021 09:41:57 GMT
Connection: close

[{"xxxxxx":"xxxxxxxxxxxxxxx","xxxx":"xxx","xxxxxx":"xxxxxxxxxxxxx","xxx":xx}]


--- ok tcp.stream eq 104
HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
Content-Type: application/json;charset=UTF-8
Transfer-Encoding: chunked
Date: Mon, 23 Aug 2021 09:45:33 GMT

4d
[{"xxxxxx":"xxxxxxxxxxxxxxx","xxxx":"xxx","xxxxxx":"xxxxxxxxxxxxx","xxx":xx}]
```

可以观察到:

1.  头部不一致。
    -   异常报文多了 "Connection: close" ，含义是数据返回后将关闭连接。
    -   正常报文多了 "Transfer-Encoding: chunked"，含义是返回的数据采取“分块编码”, 也就是分多块返回。
2.  body不一致。
    -   正常报文在body之前，声明了数据块的大小。
3.  我们使用HTTP1.0发起请求，但返回报文头部居然写着 HTTP/1.1。这是怎么回事??
    参考 <https://stackoverflow.com/questions/19461312/why-tomcat-reply-http-1-1-respose-with-an-http-1-0-request>, 返回头的HTTP版本号只是一个声明，告知调用方服务端所支持的最高HTTP版本。

<!--listend-->

```nil

This Connector supports all of the required features of the HTTP/1.1 protocol, as described in RFC 2616, including persistent connections, pipelining, expectations and chunked encoding. If the client (typically a browser) supports only HTTP/1.0, the Connector will gracefully fall back to supporting this protocol as well. No special configuration is required to enable this support. The Connector also supports HTTP/1.0 keep-alive.

RFC 2616 requires that HTTP servers always begin their responses with the highest HTTP version that they claim to support. Therefore, this Connector will always return HTTP/1.1 at the beginning of its responses.
```


## 为什么有的接口不报错? {#为什么有的接口不报错}

在此之前，先思考一个问题：http协议是基于tcp的，tcp本身不处理数据包的边界，那客户端怎么做到恰到好处地读取数据？

无外乎两种方案：1. 在报文中，先声明数据大小，客户端读满为止；2.约定一个边界，客户端看到这个记号再停。

HTTP/1.0中，采用第一种方案，在HTTP头部利用 “Content-Length”声明http body的长度;

HTTP/1.1协议引入 "Transfer-Encoding: chunked"头。浏览器不需要等到内容字节全部下载完成,只要接收到一个chunked块就可解析页面。这种情况下，每个chunk块之前会声明chunk大小，之后有分隔符。

有了这些思考，再用wireshark来分析HTTP/1.0请求的返回报文。正常接口返回的TCP报文，虽然HTTP头部没有声明Content-Length，但因为数据量大，被拆分为若干个Frame。报错接口返回的报文，数据量很小。

我的推测是：虽然它们都没有显式声明大小或者边界，但是当数据量大到被拆分为多个Frame时，客户端能基于Frame解析出来。
