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
一份X.509 Certificate往往会通过DER(Distinguished Encoding Rules)方式翻译成二进制文件。对于不能处理二进制的传输过程，二进制文件会用Base64 编码转翻为ASCII文件。当Base64 编码后的证书数据被置于“-----BEGIN CERTIFICATE-----”和“-----END CERTIFICATE-----”之间时，这就是PEM(Privacy-enhanced Electronic Mail)格式。  

不同格式的证书常见的后缀名有:  
- .cer, .crt, .der : 二进制DER格式   
- .pem: Base64 编码后的DER格式  

###X.509的层级架构PKI
###生成自己的根证书
###用根证书生成自己网站的数字证书
