---
layout: post    
category: "Tech"   
title: "SSL术语与基本原理"      
---

非对称加密的又一大应用是SSL。对于SSL的介绍，阮一峰有一篇深入浅出的博客，推荐阅读：[数字签名是什么？](http://www.ruanyifeng.com/blog/2011/08/what_is_a_digital_signature.html)。  

SSL协议对互联网的安全十分重要。要理解SSL协议，必须先理解几个基本概念：**信息摘要(message digest)**，**数字签名(digital signature)**，**数字证书(digital certificate)**。阮一峰的博客里写得十分清楚了，看完后做一点自己的笔记。  

###SSL术语
- 公钥(public key): 非对称加密密钥对中可以分发给其它人的一方。  

- 私钥(private key): 非对称加密密钥对中自己保存的一方。  

- 信息摘要(message digest): 对一段很长的数据消息，计算它的Hash函数值，得到的一串*较短*且*定长*的短数值。Hash函数可以是MD5或者SH1。Hash函数过程是单向不可逆的，不可能通过message digest 反推出原数据信息。同时，message digest也是独一无二的。可以理解为某一段数据内容独一无二的特征值。  

- 数字签名(digital signature): 使用用户私钥对信息摘要(message digest)进行加密，生成的信息。数字签名只能用用户的公钥解开。反过来，如果用户Alice的公钥成功解密了数字签名，那么一定能确定这个签名的签发者是用户Alice(只有可能是Alice的私钥签发了它)。   

- 数字证书(digital certificate): 由某个被信任的机构(Certificate Authority，CA)签发，认证用户身份的数字文件。(数字证书的内容十分复杂，将在另外一篇博客中专门介绍)。  

###SSL基本原理
这里介绍的是SSL的设计思想和大致原理，不是实现细节。转述自从阮一峰的博客。  

> 假设用户Alice有属于自己的公钥/私钥对。她准备和好朋友Bob，Susan等通信。  
> - Alice把自己的公钥送给朋友们：Bob，Susan每人一把。  
> - Bob如果要给Alice写一封保密的信，那么他写完后用Alice的公钥加密，就可以达到保密的效果。  
>

