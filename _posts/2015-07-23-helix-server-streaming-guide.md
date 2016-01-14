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

1.  添加服务器的IP地址   
左侧："服务器设置"-"IP绑定"    
右侧：点击小加号，输入服务器的IP地址。    

2. 配置流服务的端口号    
Helix 的点播支持Http协议、RTSP协议，直播支持RTSP协议。Helix为这些协议分配了默认的端口号，如果有需要的话我们可以修改它们。   
左侧："服务器设置"-"端口"    
右侧：修改"RTSP端口"，"HTTP端口"。    

3. 添加视频加载点    
左侧："服务器设置"-"配置加载点"    
右侧：点击"加载点描述"右边的小加号    
	* "编辑描述"随便给这个配置取一个描述性的名字；     
	* "加载点"设置视频目录的加载点（它将作为视频流URL的一部分出现），输入内容形如"/NGB/"（注意有两个左斜杠）；     
	* "基于路径"输入视频文件所在目录的绝对路径，形如"E:\Videos"。    

4. 将加载点添加到HTTP 分发目录    
左侧："服务器设置"-"HTTP分发"   
右侧：点击"路径"右边的小加号，在"编辑路径"中填入上面设置的视频加载点，形如"/NGB"(注意此处只有一个左斜杠)。    

5. 将MP4格式加到HTTP协议支持的MIME类型列表    
左侧："服务器设置"-"MIME类型"    
右侧：点击"MIME类型"右边的小加号    
	* "编辑MIME类型"填入"video/mp4"    
	* "扩展名"填入"mp4"    

6. 测试配置是否成功    
假设视频文件目录有文件"E:\Videos\akame.mp4",视频目录挂载点为"/NGB/",配置的Http协议端口为80，Rtsp协议端口为554。在PC上打开一个能播放网络媒体流的视频播放器（推荐VLC），输入下面的URL播放视频：     
    * http://192.168.1.100:80/NGB/akame.mp4     
    * rtsp://192.168.1.100:554/NGB/akame.mp4    

点播流的创建到此结束了。完成上述步骤后，下面再来介绍如何用Helix 提供的小命令，由视频文件生成模拟直播流。    

###生成模拟直播流
1. 准备命令   
在Helix Server的安装路径下找到/bin目录，将slta.bat和slta.exe文件拷贝到视频目录（此处为"E:\Videos\"）。

2. 配置Helix为Receiver模式    
打开Web Console。左侧：“广播分发”-“接受服务器”，在右侧“加载点”框内输入直播流的挂载点，例如"/broadcast/"（注意有两个左斜杠）。    

3. 运行模拟直播流命令    
模拟直播流播放哪几个视频，按什么顺序播放它们，是可以自己定义的。例如，如果想循环播放akame.mp4和anotheVideo.mp4这两个视频，我们可以创建一个节目单文本文件：playlist.txt，将“akame.mp4”和“anotheVideo.mp4”做两行写到文件。  
运行命令`slta.bat 192.168.1.100 178771 admin admin tv1 playlist.txt`创建直播流，其中：  
	* 是slta.bat，而不是slta           
	* IP地址是这台机器的IP地址                  
	* 178771是Web Console的端口号。用浏览器打开Web Console，可以在URL中找到              
	* admin/admin分别是账号和密码        
	* tv1是为直播流分配的任意频道号，可自定义       
	* playlist.txt是节目单文件。如果只播放单个视频，也可以换成视频文件名，如"akame.mp4"     

4. 播放验证直播流    
打开视频播放器，输入形如"rtsp://192.168.1.100:554/broadcast/tv1"的网址，播放视频。   

上述步骤创建一个直播流。新开一个cmd窗口，重复上述步骤，可以创建多路直播流。   


