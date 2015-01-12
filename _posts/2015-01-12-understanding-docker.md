---
layout: post    
category: "Tech"   
title: "理解Docker -- Docker Official Docs翻译"      
tags: [Docker]    
description: "Docker是新兴的一种虚拟化技术，发展势头强劲，而且已经被很多企业投入到实际部署中。本文是Docker.com官方文档的翻译，介绍Docker的技术优势、应用场景、架构、组件以及使用到的技术。个人手工翻译，原创非转载。"
---

###Docker是什么
Docker是用于开发(develop)、转移(ship)、运行(run)程序(application)的一个开放平台。Docker的设计目的是为了更快地传递程序。在Docker的帮助下，你能将程序与硬件基础(infrastructure)隔离、把硬件基础看作一个可管理的程序。Docker能帮你更快地转移代码、测试代码、部署代码，缩短编写代码与运行代码之间的周期。   

Docker将一种轻量级的容器虚拟化平台技术(container virtualization platform)与相应的工作流程和工具结合起来，从而能帮你管理、部署自己的程序。  

在核心层面，Docker支持在一个容器(container)中安全(securely)、独立(isolated)地运行几乎任何一种程序。这种独立性、安全性允许你在主机(host)上同时运行多个容器。容器在运行时不需要分配额外负载给监视程序(hypervisor)，它的这种轻量级特性意味着你能更大限度地使用硬件资源。   

基于容器虚拟化，Docker提供的工具和平台能帮助你：   

- 将你的程序(和支持的组件)放到Docker容器中   
- 分发(distribute)、转移(ship)这些容器给自己的团队成员，以便他们后续的开发和测试  
- 把这些程序部署到产品环境中，不管你的产品环境位于本地数据中心还是在云中  

##我能用Docker做什么？
*更快地转移程序*   
Docker是帮你处理开发周期的绝好工具。Docker能允许开发者在包含你的程序和服务的本地容器上开发，然后它能整合到一个连续的整合、部署工作流程中。   

举个例子。开发者在本地编写程序，通过Docker将开发环境与同事共享。当他们的工作完成时，开发者将他们的代码和开发环境推送到一个测试环境上，并且执行任何必要的测试。然后，你能从测试环境将Docker镜像(image)推送到产品，部署代码。   

*更方便地部署、扩展*  
Docker基于容器的平台支持高便携性(portable)的工作负载(workload)。Docker容器能运行在开发者的本地机器上、数据中心的物理/虚拟机器上，也能运行在云端。   

*支持更高密度，运行更多工作负载*   
Docker是轻量级的，而且很快。与基于监督程序(hypervisor)的虚拟机相比，它提供了可变的、低消耗的替代方案。在高密度(high density)的工作环境中，这一点就显得格外重要，例如：当搭建你自己的云或者Platform-as-a-service服务时。不止如此，当你想尽可能地利用你的资源来做小型/中型的部署时，Docker也同样有用。   

##Docker的主要组件有哪些？
Docker主要组件有两个：  

- Docker: 开源的容器虚拟化平台
- [Docker Hub](https://hub.docker.com/)：Software-as-a-Service平台，用来分享、管理Docker容器  

**注意**：Docker受开源协议Apache 2.0约束   

##Docker的架构
Docker使用客户端-服务器架构。Docker*客户端*(client)与Docker*守护进程*(deamon)通信，后者来完成建立版本(build)、运行(run)、分发(distribute)Docker容器等工作。Docker客户端和守护进程*可以*同时运行在一个系统上；你也可以将Docker客户端连接到一个远程Docker守护进程。Docker客户端和Docker守护进程通过socket或者REST API通信。   

![Docker Arch](https://docs.docker.com/article-img/architecture.svg)   

###Docker守护进程
如上图所示，Docker守护进程运行在一台宿主机器上。用户不直接与守护进程通信，而是通过客户端与之通信。  

###Docker客户端
Docker客户端，往往是二进制形式的`docker`程序，是Docker最主要的用户使用接口。它接收来自用户的命令，将它来回地与守护程序进行通信。   

###在Docker内部
为了理解Docker的内部原理，你需要理解三个组件：  

- 镜像(image)    
- 仓库(registry)  
- 容器(container)  

####镜像
镜像是一个只读(read-only)的模板。例如，一个镜像可能包含安装了Apache和你的Web服务器的一个Ubuntu操作系统。镜像是用来创造Docker容器的。通过Docker，你能以简单的方式创建新的镜像、更新现存的镜像，或者下载别人已经创建好了的镜像。Docker镜像是Docker的**创建(build)**组件。   

###仓库
仓库保存镜像。它们是你用来上传、下载镜像的私有/公有场所。官方的Docker仓库是[Docker Hub](https://hub.docker.com/)，它提供了一个巨大的镜像仓库集以供你使用。你可以自己创建镜像，也可以使用别人事先已经建好了的镜像。Docker仓库是Docker的**分发(distribute)**组件。   

###容器
容器与目录类似。容器包含了运行一个程序所需要的所有东西。每个容器都是创建自一个镜像。容器可以被运行、启动、停止、移动、删除。每个容器都是一个隔离、安全的程序平台。Docker容器是Docker的**运行(run)**组件。   

##那么，Docker到底如何工作？
现在，我们已经知道：  

1. 你可以创建Docker镜像来保存程序   
2. 你可以从Docker镜像中新建Docker容器来运行程序   
3. 你可以通过[Docker Hub](https://hub.docker.com/)或者自己的私有仓库来分享Docker镜像  

下面，让我们看看这些组件是如何协作起来使Docker工作的。   

##镜像如何工作？
我们已经知道，镜像是只读模板，由它们启动容器。每个镜像由一系列层(layer)组成。Docker利用[union file system](http://en.wikipedia.org/wiki/UnionFS)将这些层组合成单个镜像。Union file system允许独立文件系统的文件和目录(被称作branch)被透明地叠架起来(overlaid)，以此组成一个单个紧密的文件系统。  

Docker被称为“轻量级”，原因之一就在于这些层。当你改变一个镜像的时候，譬如说将某个程序更新到了新版本，一个层会被新建出来。如果我们使用的是虚拟机，这时候往往需要替换整个镜像，要不就是整体再创建一个版本。对比之下，Docker只需添加或者更新一个层。如此，你不必再去分发一整个镜像，而仅仅需要更新层就好了，这使得发布Docker的镜像变得更快、更容易。  

每个镜像都以一个基础镜像为起点，譬如`ubuntu`，一个基础的Ubuntu镜像，或者`fedora`，一个基础的Fedora镜像。你也可以用自己的镜像做新镜像的基础镜像，譬如如果你有个基础的Apache镜像，你就能用它作你所有网页程序镜像的基础。   

> 注意：Docker一般从[Docker Hub](https://hub.docker.com/)中获取基础镜像。  

从基础镜像出发，我们能通过简单、描述性的一系列步骤(我们称其为*指示(instructions)*)新建一个镜像。每一步都会在我们的镜像中新建一个层。这些步骤包括以下动作：   

- 运行命令   
- 添加文件或者目录    
- 创建环境变量  
- 定义当启动从这个镜像创建的容器时，应该运行那些进程   

这些指示被保存在`Dockerfile`文件中。当你申请从镜像生成一个版本(build)时，Docker会读取`Dockerfile`、执行指示，然后返回最终的镜像。  

##仓库如何工作？
仓库是Docker镜像的存储之处。当你创建了一个镜像，你可以将它推送到公共仓库[Docker Hub](https://hub.docker.com/)或者自己防火墙之内的私有仓库。  

使用Docker客户端，你能搜索已发布的镜像，然后将它们拉去到本地的Docker主机，再从它里面创建容器。   

[Docker Hub](https://hub.docker.com/)提供镜像的公有和私有存储。公有存储可以被任何人搜索、下载。私有存储不显示在搜索结果中，而且只有你和你的用户能从中拉取镜像、用这些镜像来生成容器。  

##容器如何工作？
容器由操作系统、用户添加的文件和元文件(meta-data)构成。我们已经知道，每个容器都由一个镜像创建。这个镜像告诉Docker应该持有什么、在启动容器时应该运行什么，以及其他一系列的配置文件。镜像是只读的。当Docker从镜像创建一个容器时，它在镜像的顶端加上一个读写层(read-write layer)，这样我们的程序就能在它上面运行了。   

##启动一个容器时，发生了什么
不论通过`docker`命令还是API，Docker客户端通知Docker守护进程去启动一个容器。   
$ sudo docker run -i -t ubuntu /bin/bash     

我们将这条命令分解来看。Docker客户端通过带`run`参数的`docker`命令新启动一个容器。为了启动一个容器，Docker客户端至少需要告知Docker守护进程：    
- 容器应该创建自哪个Docker镜像。在这里是`ubuntu`，一个基础Ubuntu镜像。   
- 当容器启动后，你要在容器内运行什么命令。这里是`/bin/bash`，它在容器内启动了Bash shell。  

那么，当我们运行这条命令时，后台发生了什么呢？   

Docker按顺序做了如下事情：   

- **拉取ubunut镜像**：Docker检查`ubuntu`镜像是否存在，如果在本地不存在，那么它从[Docker Hub](https://hub.docker.com/)下载镜像；如果镜像已经存在，Docker将利用它启动新容器。    
- **创建新容器**：Docker有了镜像，用它来新建一个容器。  
- **分配文件系统，挂载读写层**：在文件系统中新建了容器，并给镜像新添了一个读写层。   
- **分配网络/网桥接口**：新建一个网络接口，使Docker容器能与本地主机通信。   
- **设置IP地址**：从地址池中找到一个可用IP，将它关联到容器。  
- **执行你指定的程序**：运行程序。   
- **捕获、提供程序输出结果**：连接并记录标准输入、标准输出、标准错误，使你能看到程序的运行情况。   

恭喜，你有了一个运行中的容器！从这里，你可以管理容器，与程序交互，然后当结束后停止、移除容器。   

##底层技术
Docker用Go语言编写，而且利用了Linux 内核的相关特性来完成上述的功能。  

###命名空间(namespace)
Docker使用了一项叫作`命名空间(namespace)`的技术来为容器提供隔离的工作空间。当我们启动一个容器时，Docker会为它创建一系列命名空间。   

这样形成了一个隔离层：容器的每个部分都在它自己的命名空间里运行，而且没有访问它之外的权限。  

Docker使用的部分命名空间包括：  
- **pid命名空间**：用于进程隔离(PID, Process ID)     
- **net命名空间**：用于管理网络接口(NET, networking)     
- **ipc命名空间**：用于管理IPC资源(IPC, InterProcess Communication进程间通信)     
- **mnt命名空间**：用于管理挂载点(MNT, Mount)     
- **uts命名空间**：用于内核和版本标志隔离(UTS, Unix Timesharing System)     

###组控制(Control groups)
Docker还用到`cgroups`技术来进行组控制。隔离运行中程序的关键一点在于，让它们只使用你想让它使用的资源。这确保这些容器在宿主机器上能规规矩矩的。组控制允许Docker能向容器共享硬件资源，而且在必要时候设置资源的上限和限制。例如，可以设置某个特定容器的内存上限。   

###Union file Systems
Union file Systems，或者UnionFS，是通过创建层的方式运行的，轻量、快速的文件系统。Docker使用Union file Systems为容器提供块(block)。Docker能利用包括AUFS, btrfs, vfs, 和DeviceMapper在内的Union file Systems。    

###容器格式
Docker将这些组件结合成一个我们称之为容器格式的包裹层(wrapper)。默认的容器格式被称作`libcontainer`。Docker也支持使用[LXC](https://linuxcontainers.org/)的传统Linux容器。未来，Docker可能会支持更多的容器格式，例如可能会整合BSD Jail或者Solaris Zone。    

##下一步
###安装Docker
访问[installation guide](https://docs.docker.com/installation/#installation)   

##Docker用户指南
[Learn Docker in depth](https://docs.docker.com/userguide/)   

##原文链接
[About Docker](https://docs.docker.com/introduction/understanding-docker/)


