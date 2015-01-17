---
layout: post    
category: "Tech"   
title: "北邮校园网通过配置IPv6使用Google服务"      
description: "北邮作为教育网华北主节点之一，对IPv6的支持十分成熟，校内IPv6资源十分丰富。本文介绍IPv6的配置方法，它使我们能最大程度地利用校内外的IPv6资源。"
---

##前提
首先，本文针对的是北邮校园网。我在北邮学十亲测，机器是Linux Mint。   

其次，请确保:  

1. 自己的机器支持IPv6。Win7默认安装了IPv6协议，WinXP可能需要自己手动安装。我自己的Linux mint默认安装了IPv6。    
2. 自己的网络支持IPv6。包括北邮在内的绝大多数高校校园网都架设了IPv6，通过校园网上网的同学理论上不必担心这点。所以，还在使用校园网的同学们，趁IPv6还没被盯上，珍惜现在吧。  

*验证方法*    

打开浏览器，访问[IPv6test.com](http://ipv6-test.com/)，页面上"IPv6 connectivity"一项如果显示"Supported"，说明前提条件满足。或者访问[BYR BT](http://bt.byr.cn)，这是只支持IPv6方式访问的站点，如果能访问也说明前提条件满足。   

##目标

- 使用谷歌的服务(google search, gmail, google calendar, google scholar, google plus, youtube, etc.)   
- 访问其它支持IPv6的网站: wikipedia, facebook, etc.    

除了能部分避开G)(F)(W之外，北邮校园网内通过IPv6通道产生的流量是不计费的，所以，即使从节约流量这一点看也是值得的。  

##姿势简介
总的来说，这个方法是靠访问网站的IPv6地址。如果要去的网站没有IPv6地址，那就没辙。而让我的电脑知道一个网站的IPv6地址(如果存在的话)，有两个法子:  

- 修改hosts文件  
- 使用IPv6 DNS服务器  

当系统准备访问一个站点时，它需要知道目的站点的IP地址。它先会读取hosts文件，看里面是否有* IP-主机名* 的记录。如果有，它会直接按IP地址访问站点。如果hosts文件中没有相应记录，那么它会向系统设置的DNS服务器查询。DNS服务器会返回目的站点的IP地址。    

所以，这两个方法可以同时使用。(有关DNS的知识，本文限于篇幅将不做讨论。)   

###修改hosts文件

这是一份内容随时更新的hosts文件：[Hosts](https://raw.githubusercontent.com/lennylxx/ipv6-hosts/master/hosts) 。这份文件属于托管在GitHub上的[一个项目](https://github.com/lennylxx/ipv6-hosts/)，里面除了IPv6地址外还有一小部分由活雷锋搜集的IPv4地址，大家可以参考。  

将[Hosts](https://raw.githubusercontent.com/lennylxx/ipv6-hosts/master/hosts)文件的文本复制过来，用任意一款文字编辑器打开hosts文件，将内容粘贴进来。  

hosts文件在不同操作系统中的位置不同。在Windows下，它的默认路径是:   
		%SystemRoot%\system32\drivers\etc\hosts    

在Linux下，以我的Mint为例，它的路径是:   
		/etc/hosts       

修改它需要系统权限。如果是Linux，记得在前面加上sudo。   

改完hosts，就已经能达到我们的目标了，可以使用Google的服务了。当然，我们还可以继续下面一步，来个双保险。  

###使用IPv6 DNS服务器
支持IPv6 的免费DNS解析服务器很多，在此仅以Google为例。如果使用其它的IPv6 DNS服务器，将下文中的IP地址替换过来就好。   

Google提供公共[DNS解析服务](https://developers.google.com/speed/public-dns/docs/using)，能解析IPv6地址。Google DNS服务器在它的IPv6地址上监听IPv6的通道发来的查询请求。如果这个查询求的是IPv6地址，而且地址存在，那么Google服务器会返回结果AAAA记录。   

GoogleDNS服务器的IPv6地址是:   

- 2001:4860:4860::8888   
- 2001:4860:4860::8844   

将它们设为自己的首选DNS服务器。对于一个典型的Linux系统:   

1. 编辑/etc/resolv.conf文件:  
		sudo vi /etc/resolv.conf     
2. 添加如下两条记录:  
	nameserver 2001:4860:4860::8888     
	nameserver 2001:4860:4860::8844      
	这两条记录顺序无所谓；也可以只添加一条。   
3. 保存退出。   

如果系统是通过DHCP服务器获取的IP地址，那么resolv.conf文件可能会在每次开机时自动被初始化覆盖。这时，可以尝试将DNS服务器的记录保存在初始化的配置文件中。   

例如，我的Mint中/etc/resolv.f文件提示“OpenDNS Fallback (configured by Linux Mint in /etc/resolvconf/resolv.conf.d/tail)”，那么我将这两条记录拷贝到/etc/resolvconf/resolv.conf.d/tail里就好了。   

好了，到现在配置已经完成。可以通过浏览器访问Google的网站试试看了。   

##其它
###北邮校园网内网的DNS服务器
DNS查询也是需要走校外流量的。所以，最好不要将首选DNS服务器设置为外网服务器。北邮校园网内搭建有DNS服务器，譬如:   

\#学十能用的内网DNS服务器    
	10.3.9.4， 10.3.9.5， 10.3.9.6    

###手机科学上网
如果手机通过WiFi接入IPv6网络，修改DNS服务器地址为Google DNS服务器的地址，那么手机也能访问Google了。亲测，iOS7的safari能打开youtube。   

###一些观察手段
在Chrome浏览器地址栏中输入: `chrome://net-internals/#dns`可以看到浏览器的DNS解析记录。  


