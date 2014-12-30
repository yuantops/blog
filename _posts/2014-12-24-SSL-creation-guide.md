---
layout: post    
category: "Tech"   
title: "使用OpenSSL工具制作证书的方法"      
tags: [SSL]
description: "本文将介绍如何在一台Linux服务器(Redhat Enterprise 6.6)上用OpenSSL工具制作CA(Certificate Authority) Root证书、用制作的Root证书签发SSL证书。 " 
---
<div class="message">
</div>

之前[一篇文章](http://blog.yuantops.com/tech/SSL-certificate-details-and-creation-guide/)介绍了SSL证书的一些细节，这篇文章介绍OpenSSL工具的基本使用方法。老实说，OpenSSL工具实在是太难用了，我参考了[How To Setup a CA](http://pages.cs.wisc.edu/~zmiller/ca-howto/)和[基于 OpenSSL 的 CA 建立及证书签发](http://rhythm-zju.blog.163.com/blog/static/310042008015115718637/)这两篇文章，捣鼓了很久才理清流程。虽然原理很清楚，但是操作起来却不那么容易，这告诉我们要多实践才对，不然发现不了问题。  

###一些坑
在使用openssl ca命令时，如果不手动指定-config参数，它会自动调用/etc/pki/tls/openssl.cnf作为-config配置文件，这个openssl.cnf文件里定义了要调用的CA证书、私钥路径。如果我们在创建CA时将它的证书和私钥等文件保存在了别处，或者/etc/pki/tls/openssl.cnf里的定义的那些文件不存在，那么在openssl ca找不到要使用的这些文件时，就会报错。其中典型的错误有：  

{% highlight bash %}
Using configuration from /etc/pki/tls/openssl.cnf
unable to load CA private key
139911890630472:error:0906D06C:PEM routines:PEM_read_bio:no start line:pem_lib.c:703:Expecting: ANY PRIVATE KEY  
{% endhighlight  %}

所以，我们如果想自定义CA的目录位置，那么要事先1）按照OpenSSL的默认配置建立相应的目录结构，2）定制openssl.cnf文件，修改CA目录的路径定义。  

###建立CA，生成Root证书
####生成CA目录结构
假设我要将/root/newCA作为CA文件根目录，那么在Terminal中敲入命令：  
{% highlight bash %}
[root@node ~]# pwd
/root
[root@node ~]# mkdir -p ./newCA/{private,newcerts}
[root@node ~]# touch ./newCA/index.txt
[root@node ~]# echo 01 > ./newCA/serial
{% endhighlight  %}

####定制openssl.cnf文件
将/etc/pki/tls/openssl.cnf文件复制到newCA目录下，将CA_default下面的dir的值更新为自定义的openssl.cnf文件的路径(在本文中为/root/newCA)。  

除此之外，出于方便后续设置的目的，还可以修改openssl.cnf文件中\[req_distinguished_name\]区域内后缀为default的变量，将它们预设合适的值。下面是我修改后的样子：  
>		[ req_distinguished_name ]
		countryName                     = Country Name (2 letter code)
		countryName_default             = CN
		countryName_min                 = 2
		countryName_max                 = 2

>		stateOrProvinceName             = State or Province Name (full name)
		stateOrProvinceName_default     = Beijing

>		localityName                    = Locality Name (eg, city)
		localityName_default            = HaiDian

>		0.organizationName              = Organization Name (eg, company)
		0.organizationName_default      = Yuantops' Company Ltd

>		# we can do this but it is not needed normally :-)
		#1.organizationName             = Second Organization Name (eg, company)
		#1.organizationName_default     = World Wide Web Pty Ltd

>		organizationalUnitName          = Organizational Unit Name (eg, section)
		organizationalUnitName_default  = Head Office

>		commonName                      = Common Name (eg, your name or your server\'s hostname)
		commonName_max                  = 64

>		emailAddress                    = Email Address
		emailAddress_max                = 64   

####生成CA的root key和self-signed的证书
- 生成密钥对  
	 # openssl genrsa -out private/cakey.pem 2048  
- 生成证书申请、用CA的密钥自签名，用一条语句完成  

{% highlight bash %}
[root@node newCA]# openssl req -new -x509 -days 3650 -key private/cakey.pem -out cacert.pem -config openssl.cnf
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
	If you enter '.', the field will be left blank.
	-----
	Country Name (2 letter code) [CN]:
	State or Province Name (full name) [Beijing]:
	Locality Name (eg, city) [HaiDian]:
	Organization Name (eg, company) [Yuantops Company Ltd]:
	Organizational Unit Name (eg, section) [Head Office]:
	Common Name (eg, your name or your server's hostname) []:test.yuantops.com
	Email Address []:
{% endhighlight%}

- 查看我们生成的root-ca.crt的内容  
	 # openssl x509 -noout -text -in root-ca.crt

####使用CA Root证书签署证书
在上一步完成之后，就可以用CA的root 证书来签署证书了。  

可以使用一条OpenSSL命令完成生成密钥对，生成证书签名请求的操作：  
	 # openssl req -newkey rsa:1024 -keyout zmiller.key -config openssl.cnf -out zmiller.req   

然后用CA的Root证书签发证书  
	 # openssl ca -config openssl.cnf -out zmiller.crt -infiles zmiller.req 



