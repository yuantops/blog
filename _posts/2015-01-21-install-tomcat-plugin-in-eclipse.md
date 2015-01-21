---
layout: post    
category: "Tech"   
title: "Eclipse中添加Tomcat插件"      
tags: [Java]  
description: "在使用Tomcat作为web服务器时，往往需要对它进行实时调试。本文介绍Linux下安装Tomcat、并在Eclipse中添加Tomcat插件的方法"   
---

##安装Tomcat
**下载链接**:[Tomcat7](http://tomcat.apache.org/download-70.cgi)    

- 下载tar.gz包到本地，譬如到/home/yuan/Downloads目录   
- 通过`tar -zxf **.**.tar.gz`命令解压tar.gz包，将解压出来的文件夹转移到你希望保存的目的地(譬如说/home/yuan/tomcat7)   
- 用vi打开~/.bashrc文件，在末尾添加如下内容:   
       alias tomcat='bash ~/tomcat7/bin/startup.sh'         
	   export CATALINA\_HOME=/home/tomcat7           
	   export JRE\_HOME=/usr/lib/jvm/java-7-openjdk-i386/jre     

其中，JRE\_HOME是本机的JRE环境所在目录，需要根据系统的安装情况而定。   
保存退出  

现在，重新打开终端，运行`tomcat`可以启动Tomcat服务   

##在Eclipse中添加Tomcat插件
**下载链接**: [TomcatPluginV33.zip](http://www.eclipsetotale.com/tomcatPlugin/tomcatPluginV33.zip)    

- 下载压缩包，将解压后的目录复制到Eclipse安装目录下的plugins/目录。启动Eclipse，可以在状态栏中看到三个有小猫的图标。   
- 菜单栏，"Window"-"Preferences"-"Tomcat",将Tomcat version和Tomcat home改为对应值。  
- 单击小猫图标，即可启动Tomcat。在浏览器中输入`http://127.0.0.1:8080`能看到欢迎页。   

##在Eclipse中新建一个Tomcat项目
- "File"-"New"-"Project..."-"Java"-"Tomcat Project",新建一个Tomcat工程。   
- 添加源码在"WEB-INF/src"目录下。   
- 不要忘记在"WEB-INF"目录下添加web.xml文件。  

