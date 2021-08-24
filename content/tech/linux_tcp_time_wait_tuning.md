+++
title = "TCP TIME_WAIT 连接太多"
author = ["yuan.tops@gmail.com"]
description = "服务器发起短连接过多，可能出现端口耗尽情况。通过调整 ipv4 参数解决。"
date = 2021-08-24T00:00:00+08:00
publishDate = 2021-08-24T00:00:00+08:00
lastmod = 2021-08-24T13:53:25+08:00
tags = ["Linux"]
categories = ["Tech"]
draft = false
keywords = ["tcp", "time_wait"]
+++

压测一个服务，性能卡住了上不去。错误信息提示是没有可分配端口。搜索发现别人也遇到过类似问题([linux 大量的TIME\_WAIT解决办法](https://www.cnblogs.com/softidea/p/6062147.html))。

把解决配置摘录如下：

> 配置 tcp 连接参数 vim /etc/sysctl.conf
> 编辑文件，加入以下内容：
> net.ipv4.tcp\_syncookies = 1
> net.ipv4.tcp\_tw\_reuse = 1
> net.ipv4.tcp\_tw\_recycle = 1
> net.ipv4.tcp\_fin\_timeout = 30

另外，也要关注系统本身对资源限制:

> 配置 /etc/security/limits.conf，把值加大:
>
> -   soft    nofile  65535
> -   hard    nofile  65535
> -   soft    nproc  65535
> -   hard    nproc  65535


## net.ipv4.tcp\_fin\_timeout 做了啥? {#net-dot-ipv4-dot-tcp-fin-timeout-做了啥}

Stackoverflow 网友[如是说](https://stackoverflow.com/questions/46066046/unable-to-reduce-time-wait):

> Your link is urban myth. The actual function of net.ipv4.tcp\_fin\_timeout is as follows:
>
> This specifies how many seconds to wait for a final FIN packet before the socket is forcibly closed. This is strictly a violation of the TCP specification, but required to prevent denial-of-service attacks. In Linux 2.2, the default value was 180.
>
> This doesn't have anything to do with TIME\_WAIT. It establishes a timeout for a socket in FIN\_WAIT\_1, after which the connection is reset (which bypasses TIME\_WAIT altogether). This is a DOS measure, as stated, and should never arise in a correctly written client-server application. You don't want to set it so low that ordinary connections are reset: you will lose data. You don't want to fiddle with it at all, actually.

是时候破除迷思了！这个参数和 \`TIME\_WAIT\` 没有直接关系。根据TCP/IP状态机，主动发起关闭的一方，将进入\`FIN\_WAIT\_1\`状态，等待接收\`FIN\`报文。\`net.ipv4.tcp\_fin\_timeout\` 规定在\`FIN\_WAIT\_1\`状态的停留时间。时间一到，跳过 \`TIME\_WAIT\` 状态，连接被强行关闭。
