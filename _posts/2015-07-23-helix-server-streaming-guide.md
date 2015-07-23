---
layout: post    
category: "Tech"   
title: "用Helix Server建立点播流/直播流的方法"      
description: "Helix Server是Real公司旗下的一款流媒体服务器，能提供稳定的视频点播服务（支持HTTP、RTSP多种协议），还提供生成模拟直播流的小工具（SLTA）。本文介绍用Helix Server生成直播流和点播流的方法。"
---

##视频文件预处理
Helix Server支持的视频格式很多，我只使用过MP4格式，其余的格式请自行探索。     

一个MP4格式的视频文件要想被Helix流化，必须具有符合要求的头部信息。mp4box这个小命令正是用来做这件事的，它是开源软件GPAC内提供的命令。先安装GPAC(https://gpac.wp.mines-telecom.fr/mp4box/)， 后在安装目录下找到MP4BOX.exe。如何调用命令不赘言。它的使用格式是：      
`mp4box mymovie.mp4 -hint`    
在安装Helix Server前，将所有的视频文件都用这条命令处理一遍。    

##安装
Helix Server是收费的，但在官网能申请到一个试用版license，免费使用一段时间。当然，如果你在网上找到了破解版，请在使用时自觉忏悔。    

安装过程不多说，只是要注意记忆所设的帐号和密码。安装完成后，在桌面会生成两个图标：一个指向web控制台，还有一个是启动Helix的快捷方式。我们双击web控制台的图标，输入帐号和密码，进入Web Console。    

##参数配置
进入Web Console后，左侧是一栏设置菜单，右侧是对应菜单条目的详情。在Web Console上我们能完成**点播流**的所有配置,以及直播流的必要配置。   
1. 添加服务器的IP地址   



