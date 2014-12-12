---
layout: post    
category: "Tech"   
title: "SSL证书的细节与制作方法"      
---

本篇文章将介绍SSL证书的格式标准X.509，CA的层级架构，以及如何在一台Linux服务器上制作Root证书、用制作的Root证书签发SSL证书。  

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

>注:- 一般Subject Name, 或者Issuer name + Serial number唯一确定一份证书;  
>- Certificate Data中的Signature algorithm ID必须和Certificate Signature Algorithm中的内容一致，标志CA用来生成Certificate Signature所用的加密算法。  

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
- .cer, .crt, .der : 二进制DER格式   
- .pem: Base64 编码后的DER格式  

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

###生成自己的根证书
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

制作自签名证书(根证书)步骤：  
> #生成一个RSA私钥private.key   
>  openssl genrsa -out private.key 1024  
> #从私钥文件private.key中取出公钥public.key  
>  openssl rsa -in private.key -out public.key
> #生成一个证书签发请求
>  openssl x509 -new -key 



###用根证书生成自己网站的数字证书
