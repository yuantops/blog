---
layout: post    
category: "Tech"   
title: "BIND安装笔记"      
tags: [BIND, DNS]
description: " BIND是Linux平台上最通用、功能强悍的DNS服务器程序。这篇文章介绍如何手动搭建、配置BIND DNS服务器。 " 
---

###安装环境  
- 网络环境：两台KVM虚拟机，通过NAT方式组成子网(IP地址分别为192.168.100.139, 192.168.100.172)，彼此能ping通，均能访问互联网  
- 系统：Redhat 6.6  
- 要解析的域名：yuantops.com

###安装BIND软件包
> $ yum install bind bind-utils  

###为要解析的域名生成DNSSEC KEY
这一步不是配置基本DNS解析器时必须包括的步骤，因此可以省略。  

DNSSEC是为了解决DNS欺骗和缓存污染而设计的一种安全机制。由于DNS域名解析系统在设计之初没有考虑到安全问题，经常有针对DNS系统的攻击发生，而且由于DNS协议十分脆弱，攻击一旦发生就会造成大面积的影响甚至瘫痪。DNSSEC的原理是通过引入加密技术，依靠数字签名保证DNS应答报文的真实性和完整性。具体的介绍请见[DNSSEC的原理、配置与部署简介](http://netsec.ccert.edu.cn/duanhx/archives/1479)一文。  

假设我要解析的域名为yuantops.com，准备将这个域名对应的DNSSEC KEY文件保存在/var/named/路径下。  
> $ cd /var/named  
> $ dnssec-keygen -a HMAC-SHA256 -b 256 -n USER -r /dev/urandom yuantops.com  

在/var/named/路径下生成了文件名形如Kyuantops.com.+163+15844.key和Kyuantops.com.+163+15844.private的一对key文件。  

###启用rndc工具作为BIND的控制工具
这一步同样不是配置一个最基本的DNS解析服务器所必须包含的步骤，因此可以省略。  

rndc是BIND安装包提供的一种域名服务控制工具，它可以运行在其他计算机上，通过网络与DNS服务器进行连接，然后根据管理员的指令对named服务进行远程控制，此时，管理员不需要DNS服务器的根用户权限。更重要一点，rndc能实现数据的**热更新**，这对繁忙的实际场景而言是十分有必要的。具体的介绍可以请见[这篇文章](http://book.51cto.com/art/200912/169294.htm)。  

使用rndc-confgen命令生成rndc的配置文件。  
> $ rndc-confgen -a -r /dev/urandom  

在/etc路径下生成了rndc.key文件。  

###配置BIND对域名的解析
这一步是必须完成的、最重要的步骤。  

1. 新建yuantops.com域的zone文件，保存到/var/named/dynamic目录。  
	域的zone文件有自己的语法规范，配置起来需要事先对DNS的术语有一定了解。可以参看[文章一](http://www.zytrax.com/books/dns/ch8/soa.html)和 [文章二](http://www.zytrax.com/books/dns/ch6/mydomain.html)。  
	下面是域yuantops.com的zone文件yuantops.com.db的内容:  
	>$TTL	86400 ; 24 hours could have been written as 24h or 1d  
	; $TTL used for all RRs without explicit TTL value  
	$ORIGIN yuantops.com.  
	@  1D  IN  SOA ns1.yuantops.com. hostmaster.yuantops.com. (  
								      2002022401 ; serial  
					  			      3H ; refresh  
					  			      15 ; retry  
					  			      1w ; expire  
					  			      3h ; minimum    )  
	       IN  NS     ns1.yuantops.com. ; in the domain  
		          IN  MX  10 mail.yuantops.com. ;   
				  ; server host definitions  
				  ns1    IN  A      192.168.100.172;name server definition     
				  www    IN  A      192.168.100.172;web server definition  
				  ftp    IN  CNAME  www.yuantops.com.  ;ftp server definition  

2. 将yuantops.com域的DNSSEC Key添加到/var/named/目录。  
	在生成DNSSEC Key的第一步中，我们得到了一对key文件。如果因为不准备部署DNSSEC key而跳过了第一步，那么现在这一步也应该跳过。  
	打开/var/named/Kyuantops.com.+163+15844.private文件，复制其中的Key字段到剪贴板。  
	新建/var/named/yuantops.com.key文件，将以下内容填入文件:  
	>key yuantops.com {  
				algorithm HMAC-SHA256;  
				secret "2viM+VhhgiFGMrOjLAqBtY9usGstiRuZdOElI5U6l/o=";  
	};  

	替代secret字段为剪贴板中的内容。  	

3. 配置BIND的配置文件/etc/named.conf，添加yuantops.com域的定义、DNSSEC Key定义。  
	named.conf文件是BIND服务器的全局配置文件，非常重要。我们要在里面加入对yuantops.com域的定义、yuantops.com域的DNSSEC Key的定义。  
	将以下内容填入/etc/named.conf文件:  
	>options {  
			        listen-on port 53 { any; };//注意，此处为any，不是127.0.0.1  
			        listen-on-v6 port 53 { ::1; };  
			        directory       "/var/named";  
			        dump-file       "/var/named/data/cache_dump.db";  
			        statistics-file "/var/named/data/named_stats.txt";  
			        memstatistics-file "/var/named/data/named_mem_stats.txt";  
			        allow-query     { any; }; //注意，此处是any，不是localhost  
			        recursion yes;  
				    dnssec-enable yes;  
				    dnssec-validation yes;  
				    dnssec-lookaside auto;  
				   	/* Path to ISC DLV key */  
                    bindkeys-file "/etc/named.iscdlv.key";  
	                managed-keys-directory "/var/named/dynamic";  
	};  
	logging {  
		        channel default_debug {  
                file "data/named.run";  
                severity dynamic;  
	        };  
};  
	 	// use the default rndc key  
		include "/etc/rndc.key";  
		controls {  
		    inet 127.0.0.1 port 953  
			allow { 127.0.0.1; } keys { "rndc-key"; };  
		};  
		zone "." IN {  
			  type hint;  
			  file "named.ca";  
		}//;  
>		include "/etc/named.rfc1912.zones";  
>		include "/etc/named.root.key";  
		include "yuantops.com.key";  
		zone "yuantops.com" IN {  
		  type master;  
		  file "dynamic/yuantops.com.db";  
		  allow-update { key yuantops.com ; } ;  
		};  

###修改配置文件的权限，使能被读取
>$ chmod 644 /etc/named.conf  

###启动BIND服务器
>$ service named start  

如果以后BIND服务器设置有改动，需要重启named服务。  

###将机器的DNS服务器IP地址设为BIND程序所在机器的IP地址
BIND服务器所在机器的IP地址为192.168.100.172。如果有一台192.168.100.139的机器想以192.168.100.172为DNS服务器，那么修改它的/etc/resolv.conf文件，将第一次出现的nameserver 地址改为192.168.100.172。  

###验证BIND服务已经成功安装并启动
在192.168.100.139机器上运行命令：  
>$ dig @192.168.100.172 www.yuantops.com  

如果成功解析出IP地址，证明成功。否则，可以检查BIND服务器的/var/log/message日志文件，寻找原因。  

###使用nsupdate命令操作BIND服务器的配置
