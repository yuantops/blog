---
layout: post    
category: "Tech"   
title: "关于Git,需要理解的几个关键概念"      
tags: [Git]   
description: " Git是十分强大的文件版本控制工具,是程序员必备的基本技能,掌握它是很有必要的。我接触Git很长时间了,但惭愧一般只用add, commit两个命令。最近听了Git专家的一次讲座,觉得收获很大,对Git的理解加深了很多。可见“内行一句话,胜读半月书”,要多向牛人请教。本文是自己对Git原理性知识的一些理解。  "
---


Git的控制哲学十分优雅,特别是了解它后会更为之倾倒。Git的入门在此不赘述。在掌握常用命令之后,再思考下面这些概念,相信对Git的认识会得到提升。  

###Git基于Commit,每个Commit有独一无二的SHA 1作为标志  
Git有Working Tree,Index,Repo的概念。Working Tree指当前的工作目录,当这个目录下有改动时,通过add命令将改动添加到Index区域。当改动都被加到了Index、需要提交时,使用commit命令将它们提交到Repo中。这次提交会形成一个Commit记录,它相当于当前状态的一个SnapShot。  

基于Commit的版本控制是十分优雅的想法。原因在于：  

- 每次Commit,系统只是保存了**文件的改变**(而不是改变后的文件),这样节省了磁盘空间
- 每次Commit都是在上次Commit的基础上发生的(当Git Repo初始化时建立第一个Commit,它是所有Commit的最终基础),包含了对上次Commit的引用,因此一次次的Commit形成了一个链式结构
- 每个Commit都有**唯一**的标志符号: (一般为)SHA 1值。它是Commit的内容经过数学计算得到的。  

通过引入Commit,我们的所有改动都被纳入系统中,使改动变得有迹可循。  


###Branch, HEAD, TAG本质上都是为Commit所取的别名
只有先理解“Git基于Commit”,才能理解上面这句话。  

因为Repo的更改记录是以一个个Commit组织起来的,它们就像一个个节点,能确定某个确定时刻的目录状态。因此,当我们想要切换到某个状态时,就要在庞大的Commit网络中定位某个Commit,并转到那个Commit。但唯一标准Commit的SHA 1值是很长的一串数字,为了方便识别与输入,就给这些SHA 1添加字符串的别名。因此Branch,HEAD,TAG本质上都是SHA 1的别名,确定Commit用的。   

但Branch, HEAD, TAG毕竟有特殊的地方(不然为什么不给所有的Commit都取别名呢？),它们标记的是特殊的Commit：    

- Branch标记某个分支上离现在时刻最近的那次Commit。显然,随着在分支上不断提交Commit,Branch的指向对象也不断前进。试想一棵有枝干和树叶的树,那么Branch就是所有树枝末端的那片叶子。又因为每个Commit都包含它父Commit的标识(SHA 1值),所以确定了一个分叉的末端,就相当于确定了这个分叉上的所有Commit。一般而言,Git Repo都默认存在一个叫master的Branch。  

- HEAD标记当前工作在哪个Commit位置。试想我正在开发软件项目,5个不同分支对应相对5个独立的功能,我要接着修改哪一个分支,就把HEAD移到这个分支上。又因为Branch指向分支的最新Commit,所以也就是把HEAD移到了这个Branch上。当然,如果我不想接着某个Branch的最新进度修改,当然也是可以的,直接切换到那个Commit即可。总之,可以将HEAD想象成*我此时此刻站着干活的地方*。  

- TAG是单纯的给Commit的SHA 1取的别名。  

###Checkout其实是在移动HEAD
只有理解了HEAD的意义,才能理解上面这句话。  

当我们谈论“在不同branch之间切换时”,真正起作用的是HEAD。既然HEAD指向的是某个Commit,那么checkout的参数可以是任何能确定Commit的标志(Branch,TAG,或者直接某个SHA 1值)。当然,checkout命令的用法很多,也有特殊情况checkout命令不会改变HEAD指向的Commit。  



