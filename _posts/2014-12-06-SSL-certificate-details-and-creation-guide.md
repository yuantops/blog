---
layout: post    
category: "Tech"   
title: "SSL证书的细节与制作方法"      
tags: [SSL]   
description: " 本文介绍SSL证书的格式标准X.509，CA的层级架构，以及如何在一台Linux服务器上制作Root证书、用制作的Root证书签发SSL证书。  "
---

在上篇文章中，讨论了数字证书(digital certificate)的重要意义。在实际中，Internt工程任务组(IETF)PKI X.509专门负责制定数字证书的格式，并提出了一套标准。根据这套标准(X.509)，互联网上的各级单位各自予以实现，从而形成一套完备的公钥基础设施(Public Key Infrastructure, PKI)。这是本篇文章将要讨论的内容。  

###SSL证书的X.509标准
X.509 规定一份digital certificate应该由这几部分构成：  

- Certificate Data  
	- Version (marked as X.509 v3, even if v4 or v5)  
	- Serial number   
	- Signature algorithm ID  
	- Issuer name(DN, Distinguished Name)   
	- Validity (start and end time)  
	- Subject name(DN)  
	- Subject Public key 
	- Extensions (added in X.509 v3): Extra identification information, usage constraints, policies, and general kitchen-sink area  
- Certificate Signature Algorithm  
- Certificate Signature  

>注:
- 一般Subject Name, 或者Issuer name + Serial number唯一确定一份证书;  
- Certificate Data中的Signature algorithm ID必须和Certificate Signature Algorithm中的内容一致，标志CA用来生成Certificate Signature所用的加密算法。  

在Certificate Data的Subject name与Issuer name这两项中，其Distinguished Name包含更多字段(这些字段往往用字母简写)，以更好地作唯一标识：  
- CN: Common Name, 证书持有者的名称  
- O: Organization or Company, 持有者所在的公司/组织  
- OU: Organization Unit, 持有者在公司/组织的部门  
- L: City/Locality, 持有者所在的城市  
- ST: State/Province, 持有者所在的州/省  
- C: Country, 持有者所在的国家(ISO码)  

###SSL X.509证书的后缀名
一份X.509 Certificate往往会以DER(Distinguished Encoding Rules)方式翻译成二进制格式的文件。如果有些传输过程不能处理二进制数据，那么二进制格式的文件会以Base64 编码转翻为ASCII文件。用Base64 编码后的数据被置于“-----BEGIN CERTIFICATE-----”和“-----END CERTIFICATE-----”之间，这就是PEM(Privacy-enhanced Electronic Mail)格式。  

不同格式的证书常见的后缀名有:  
- cer, .crt, .der : 二进制DER格式   
- pem: Base64 编码后的DER格式  

###X.509的“证书链”与“信任锚点”
数字证书存在的意义，在于认证持有者的身份。譬如说，在Alice申请证书的时候，证书颁发机构(CA, Certificate Authority)会先确认Alice本人的信息与她申请书上所写的一致。  

由于证书上有第三方认证中心的真实性确认签名、由第三方认证中心的信用为这张证书的真实性背书，所以，只要确定了证书为真，就能确认证书持有者的身份为真。但这样问题还是没得到解决，而是变成了另一个问题：如何确定一张证书的真伪？  

为了回答这个问题，需要先了解实际部署在互联网上的证书颁发机构(CA, Certificate Authority)的架构。互联网中，一个证书颁发机构(CA, Certificate Authority)有自己的证书。一个证书颁发机构(CA, Certificate Authority)不仅可以给证书申请者颁发证书，也可以给其它证书颁发机构(CA, Certificate Authority)颁发证书。那么谁来给最顶层的证书颁发机构(top-level Certificate Authority)授权呢？答案是：它自己给自己签名，自己给自己授权(它拥有的证书，Issuer和Subject是一样的)。  

这样就形成了一个“证书链”(Certificate chain),也称“证书路径”(Certificate path)：最开始为用户持有的证书，最末尾为自己给自己签名的证书。证书链中:  

- 每个证书(最末尾的证书除外)的颁发者(Issuer)是下一个证书的持有者(Subject);  
- 每个证书的(最末尾的证书除外)的Certificate Signature都能用下一个证书中包含的Public Key解密;  
- 最末尾的证书是“信任锚点”(a trust anchor)——往往它会以某种值得信赖的方式，提前传递到你手中。  

所以，确认一张证书真实性的过程，就是一个不断追溯，直到“信任锚点”的过程。  

在主流的浏览器(IE, Chrome, Firefox等)中，预置了主流证书颁发机构(VeriSign等)的根证书。当浏览器收到网站的SSL证书后，会有一系列验证过程，如果该证书的“证书链”中任意一环存储在本地，那么就能确认该证书为真实。浏览器对证书链的认证过程，将在另一篇文章中介绍。  

###生成根证书与签发证书
上面讲了那么多，都是理论。现在转入实战，介绍如何生成一张证书, 以及这张证书的持有者如何为申请者签发证书。  

>Linux下最常使用的SSL根证书相关的命令是openssl的一套工具。  

一般情况下，用户制作证书要经过几个步骤：  
1. 首先用openssl genrsa生成一个私钥  
2. 然后用openssl req生产一个证书签发请求  
3. 最后把证书签发请求交给CA，CA签发后就得到该CA认证的证书。  

如果生成证书签发请求时加上-X509参数，那么就直接生成一个self-signed的证书，即自己充当CA认证自己。  

一张self-signed的证书，不能证明持有者的身份。大部分软件在遇到这种证书时都会发出警告。使用自签发证书的主要意义也不是证明身份，而是使用户与系统间能SSL通信，保证信息传输时的安全。  

使用openssl工具制作证书时，会接触到新名词:  
- CSR(Certificate Signing Request): 提交给CA的认证申请文件，包含了申请者的公钥和名字等信息，通常以.csr为后缀，是中间文件。  

*制作自签名证书(根证书)步骤(参考[内容](http://rhythm-zju.blog.163.com/blog/static/310042008015115718637/))：*  

1. 生成一个RSA私钥private.key   
> $ openssl genrsa -des3  -out private.key 1024  

	参数解释：
	- genrsa: 用于生成RSA密钥对的OpenSSL命令  
	- des3: 使用 3-DES 对称加密算法加密密钥对，该参数需要用户在密钥生成过程中输入一个口令用于加密。今后使用该密钥对时，需要输入相应的口令。如果不加该选项，则不对密钥进行加密。  
	- out: 将生成的密钥保存到文件  
	- 2014:  RSA模数位数，在一定程度上表征密钥强度。  

2. 生成一个CA证书认证申请  
>$ openssl req -new -days 365 -key private.key -out req.csr   

	 参数解释：
	 - req: 用于生成证书认证申请的openSSL命令    
	 - -new： 生成一个新的证书认证请求。加上这个参数后，会提示用户输入申请者的信息  
	 - -days 365: 证书的有效期：从生成之日起365天  
	 - -out req.csr: 证书申请保存的目的文件。为中间文件，可以在证书生成以后删除。

	该命令会提示用户输入密钥的口令(如果上一步中没有加des3参数则不会)，以及一系列证书申请者的相关信息。  

3. 对CA证书申请进行签名  
> $ openssl ca -selfsign -in req.csr -out ca.pem  

	 参数解释：
	 - ca: 用于CA相关操作的命令  
	 - -selfsign: 自签名(用与证书中包含公钥所对应的密钥签名)
	 - -in req.csr: 证书认证申请文件  
	 - -out ca.pem: 证书保存到目的文件  

4. 注：以上两个步骤可以合二为一。利用ca的-x509参数可以生成自签名的证书，将申请和签发两步一起完成：  
	> $ openssl req -new -x509 -days 365 -key private.key -out ca.pem  

**利用生成的根证书签发证书**  

这一部分请参看[文章](http://blog.yuantops.com/tech/SSL-creation-guide)，因为下面的步骤可能有些问题。  

利用生成的根证书签发证书的过程，1，2步与上一部分相同，只是在第3部分，签名的时候有差异:  
> $ openssl ca -in req.csr -cert ca.pem -out userca.pem -keyfile private.key  

	  参数解释：  
	  - ca: 用于CA相关操作的命令  
	  - -in req.csr: 证书认证申请文件  
	  - -cert ca.pem: 用于签发的CA证书  
	  - -out userca.pem:  处理完成后输出的证书文件
	  - -keyfile private.key: CA的私钥文件  


###一些思考与体会
因为openssl工具十分强大，每个人的使用方法都不同，所以在参考别人的使用方法时会有很多疑惑。下面是一些思考与体会：(参考[这篇博客](http://www.cnblogs.com/littlehann/p/3738141.html))  

1. 在生成过程中有很多文件扩展名(.crt、.csr、.pem、.key等等)，从本质上讲，扩展名并不具有任何强制约束作用，重要的是这个文件是由哪个命令生成的，它的内容是什么格式的。 使用这些特定的文件扩展名只是为了遵循某些约定俗称的规范，让人能一目了然。  

2. openssl的指令之间具有一些功能上的重叠，所以我们会发现完成同样一个目的(例如SSL证书生成)，往往可以使用看似不同的指令组达到目的。  

3. 释疑:openssl genrsa -des3 -out private.key 1024 命令生成的private.key真正包含了什么？  
> 注意到, 在生成证书认证申请时($ openssl req -new -days 365 -key private.key -out req.csr)，参数只用了申请者的private.key，而理论上应该提供申请者的public.key。而且根据RSA加密的数学原理，不可能由private key推出public key。所以这往往会带来疑惑: public key从哪儿来？  

参考[这个回答](http://stackoverflow.com/questions/5244129/use-rsa-private-key-to-generate-public-key)  

实际上，第一步( $ openssl genrsa -des3  -out private.key 1024 )命令生成的是public-private 的公钥/私钥对,这一对公钥/私钥都保存在private.key文件中。所以，准确说来这一行命令的作用是：生成用户的**公钥/私钥对**，而不是生成用户的私钥。(虽然一般我们都按后者的方式说)。因此，答案就是：public key本身就包含在private.key中。  

另外，可以使用openssl命令，从private.key中提取出public.key  
> $ openssl rsa -in private.key -pubout -out public.key  
