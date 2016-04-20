---
layout: post    
category: "Tech"   
title: "写一套简易的视频点播系统——API Server"      
tags: [Android]
description: "视频播放系统的Web API Server基于Spring MVC结构，是一个最简单、常用的实现。"
---


<div id="table-of-contents">
<h2>目录</h2>
<div id="text-table-of-contents">
<li><a href="#sec-1-1">1. 前言</a></li>
<li><a href="#sec-1-2">2. 工程代码结构</a></li>
<li><a href="#sec-1-3">3. 数据加载流程</a></li>
</ul>
</li>
</ul>
</div>
</div>

## 前言<a id="sec-1-1" name="sec-1-1"></a>

作为一个视频点播系统的后台，应该为客户端(见 [《写一套简易的视频点播系统&#x2013;Android视频播放器》)](http://blog.yuantops.com/tech/write-your-own-vod-system-android) 提供合理良好的API接口。同样，这里我们完成了最简单最基本的功能: 基于Spring MVC结构，当有http请求到来时，从MySQL数据库获取数据，返回json格式的数据。  

## 工程代码结构<a id="sec-1-2" name="sec-1-2"></a>

如下所示(省略了一些文件): 

    .
    ├── main/
    │   ├── java/
    │   │   └── com/
    │   │       └── yuantops/                 
    │   │           ├── exception/             //Exception包
    │   │           ├── tv/                    
    │   │           │   ├── bean/              //Video对象，对应数据库中数据模型
    │   │           │   ├── controller/        //Spring MVC中的C
    │   │           │   ├── dao/               //数据库增删改查
    │   │           │   ├── impl/              //service接口实现
    │   │           │   └── service/           //service接口
    │   │           └── utils/                 //工具类
    │   ├── resources/
    │   │   ├── application-root-context.xml   //Spring MVC启动加载的初始化上下文
    │   │   ├── com/
    │   │   │   └── yuantops/
    │   │   │       └── tv/
    │   │   │           ├── dao/               //对应dao java文件的xml文件，属于MyBatis配置
    │   │   │           └── settings/          //MyBatis的配置信息
    │   │   ├── config/                        //编码、jdbc等配置文件
    │   │   ├── front-servlet-context.xml      //有HttpRequest时加载的上下文的配置
    │   │   ├── log4j.xml                      //log4j的配置
    │   │   └── properties/                    //properties文件
    │   │       └── jdbc.properties
    │   └── webapp/                            
    │       ├── WEB-INF/
    │       │   ├── front_page/                //Spring MVC中的V
    │       │   └── web.xml                    //整个web app的配置文件
    │       └── index.jsp
    └── test/                                  //测试文件

## 数据加载流程<a id="sec-1-3" name="sec-1-3"></a>

和所有基于Servlet的Web Application一样，app的入口在web.xml，会加载application-root-context.xml和front-servlet-context.xml两个context。在这两个context中，会分别load一些config/目录下的配置文件。

项目除了Spring MVC框架，还用了log4j(日志记录)，MyBatis(数据库连接)两个开源插件。
