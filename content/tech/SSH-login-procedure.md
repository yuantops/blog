+++
Categories = ["Tech"]
date = "2014-12-05T00:00:00Z"
Description =  "在上一篇博客中，介绍了非对称加密的原理。非对称加密使用公钥/私钥对，保证通信过程的安全性。这篇文章介绍非对称加密原理的常用应用之一： SSH登录。"
Tags = ["SSL"]
title = "SSH登录原理"
+++

关于SSH登录的原理，阮一峰的这篇博客写得很清楚，值得一看。  
>[SSH原理与运用(一)](http://www.ruanyifeng.com/blog/2011/12/ssh_remote_login.html)  

读完这篇博客后，下面是笔记和摘抄。

### SSH密码登录的流程
> 1. 远程主机收到用户的登录请求，把自己的公钥发给用户。  
> 2. 用户使用这个公钥，将登录密码加密后，发送回来  
> 3. 远程主机用自己的私钥，解密登录密码，如果密码正确，就同意用户登录。  

### 如何防范"中间人"攻击
如果有人拦截了远程主机发给用户的公钥，然后将自己的公钥发送给用户，可能会造成远程主机密码泄漏(著名的“中间人攻击”)。用户要识别公钥的真伪，没有更好的办法，只有比较收到的公钥的fingerprint（公钥的MD5值）是不是与服务器公布在网站上的fingerprint相同。  

在用户初次SSH登录一台远程主机时，终端往往会显示远程主机的fingerprint和一条Warning，询问是否确定远程主机的身份并继续。当用户选择确认后，远程主机的公钥会记录到本地系统的known\_hosts文件中。下次再登录时，系统如果发现远程主机的公钥记录在案，就不再发出Warning。  

### SSH公钥登录的流程
以密码方式SSH登录远程主机，每次都需要输入密码，这样既麻烦，又存在密码泄露的潜在危险。公钥登录可以解决这两个问题。(有的高安全规格的服务器甚至不允许用户以SSH密码登录，只允许以SSH公钥方式登录。)  

公钥登录的流程：  
1. 用户将自己的公钥存储在远程主机上。  
2. 登录时，远程主机会向用户发送一段随机字符串，用户用自己的私钥加密后，再发回来。  
3. 远程主机用实现存储的公钥解密，如果成功，就证明用户是可信的，直接允许登录shell，不再要求密码。   

### Linux下生成公钥/私钥对的命令
在用SSH公钥登录时，第一步需要用户提供自己的公钥。Linux，特别是服务器环境下，经常会有用到公钥/私钥对的场景，生成它们的命令也十分基础。  

1. 生成公钥/私钥对  
>$ ssh-key  

	运行命令，并确认它的默认设置，会在$HOME/.ssh/目录下生成两个文件： id\_rsa.pub和id\_rsa。rsa意味着它们是以RSA加密算法生成的。以pub为后缀的是公钥，可以分发出去(会在下一步添加到远程服务器)；后者是自己的私钥，要妥善保存。  

2. 存储用户公钥到远程服务器  
用户公钥需要添加到远程主机上对应用户的$HOME/.ssh/authorized\_keys文件中，以字符串形式附到末尾。有两种方式可以做到：  
   
- ssh系列命令
> $ ssh-copy-id user@host

- 等价的手工操作  
> $ ssh user@host #登录远程主机  
> $ mkdir -p $HOME/.ssh #如果用户主目录下.ssh目录不存在则创建  
> $ gedit .ssh/authorized_keys #用文本编辑器打开.ssh/authorized_keys文件，将上一步生成的id_rsa.pub文件里的内容附在末尾。   

### 个人思考：信任的锚点如何建立
SSH无论密码登录还是公钥登录，为了保证传输的安全，不得不考虑各种潜在的安全漏洞。由于SSH引入了公钥/私钥机制，可以认为已经建立的连接是安全的。最高危的时刻是建立连接的时候：谁来确认对方的身份、建立对它的信任？  

机器是不能帮我们做到的。所以在首次登录远程主机时，终端会显示远程主机公钥的fingerprint，并询问是否要继续连接它。这时，就需要我们自行承担风险：我信任，或者不信任。一旦选择"信任"，就意味着建立了"信任的锚点"。后面的连接都会根据这个锚点而建立信任关系。  

SSH公钥登录的方式也是同理。对一台远程主机而言，当用户的公钥被附到authorized\_key文件末尾时，就意味着建立了"信任的锚点"。执行这个操作的人，就是建立"信任的锚点"的人，显然也是承担风险的人。  

我觉得从这个角度来思考SSH登录的原理，也是很独特的。  
