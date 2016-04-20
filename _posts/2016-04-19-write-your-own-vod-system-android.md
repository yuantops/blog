---
layout: post    
category: "Tech"   
title: "写一套简易的视频点播系统 —— Android篇"      
tags: [Android]
description: "介绍Android客户端的代码结构，启动后数据流程。"
---

作为一个视频点播系统的客户端，播放视频是最基本的功能。本着最精简最偷懒的原则，这个客户端实现的功能包括:   

1.  列表显示服务器上的直播视频、点播视频   
2.  点击列表条目，播放视频   

## 工程代码结构<a id="sec-1-1" name="sec-1-1"></a>

客户端用Android Studio开发，整个项目的结构按gradle风格组织，代码路径是TopsTVPlayer/app/src/main/java。

    .
    └── com
        └── yuantops
            └── tvplayer      
                ├── adapter         加载list的Adapter
                ├── player          播放器组件
                ├── ui              Fragment和Activity显示界面
                └── util            工具类

在player/包下，为直播视频和点播视频分别建立了一个类，因为Android原生的MediaPlayer组件对RTSP协议的直播流支持不全面，所以用原生的MediaPlayer播放点播视频(http)，用Vitamio提供的MediaPlayer播放直播视频(rtsp)。

## 数据加载流程<a id="sec-1-2" name="sec-1-2"></a>

所有与网络的数据交流方法都封装在util/VolleySingleton.java文件中，使用了Volley这个优秀的开源http包。

1.  app启动时，首先加载WebAPIServerActivity.java界面，填写web服务器(提供api接口的服务器，不是多媒体服务器)的Base URL。点击确认按钮，会跳转到MainActivity。
2.  MainActivity包含两个Fragment。在Fragment被加载时，会调用VolleySingleton.java里的方法从web服务器上获取json格式的视频列表数据。数据下载完成后，会以list的形式显示出来。
3.  点击listView中的item，会跳转到VideoPlayActivity，初始化对应的直播/点播MediaPlayer。MediaPlayer组件根据视频的URL，从视频服务器获取数据，开始播放。

## 引用的库<a id="sec-1-3" name="sec-1-3"></a>

-   [ActionbarSherlock](http://actionbarsherlock.com/)
-   [Vitamio SDK](https://www.vitamio.org/en/)
-   [Android Volley](https://github.com/mcxiaoke/android-volley)
