---
layout: post    
category: "Tech"   
title: "视频格式学习笔记"      
description: "平时我们常能听人说“视频格式”。有时候我们说一个视频是AVI格式，MKV格式，或者RMVB，MOV等。有时候又在别的场合把H.264, H.263, MPEG称作视频格式。这往往令人感到混乱。最近我在网上查了一些资料，写一篇博客做一下总结。"
---


在生活语境里所说的“视频格式”，在学术上有两个概念与之对应：Container format (封装格式)和Codec (暂且译为“编解码格式”)。    

1. Container format (封装格式)
	Container format 描述了视频文件的结构。正如它的字面含义所说，它是对一个“容器”的规范。一个视频文件往往会包含图像和音频，还有一些配置信息(如图像和音频的关联，如何解码它们等)：这些内容需要按照一定的规则组织、存储起来，Container format就是这些规则。    

    如果一个视频文件是以某个Container format封装起来的，那么它的后缀名一般会体现出来。所以，后缀名只是形式，只是为了便于识别(例如，windows系统会根据文件的后缀名决定以什么程序打开它)，不代表实质性的内容。     
	
	附录(一)是常见的视频封装格式和后缀的对应表。

2. Codec (编解码格式)    
	Codec是一种压缩标准。而文件的压缩/还原是通过编/解码实现的，所以Codec也可理解成编/解码标准。要知道，未经过处理的原始视频和音频文件十分巨大，不好存储、传输。为了节省磁盘空间和网络带宽，原始的视频和音频文件都会通过编码压缩体积，然后需要播放时再通过逆向过程解码还原。Codec就是规定编/解码实现细节(数字存储空间、帧速率、比特率、分辨率等)的标准，不同的标准对于压缩的质量和效率有影响。    
    
	世界上制定这套标准的有两大阵营：ITU-T VCEG(Visual Coding Experts Group，国际电联旗下的标准化组织)和MPEG(Moving Picture Experts Group, ISO旗下的组织)。MPEG系列标准是MPEG制定的，H.26x系列标准是ITU-T制定的。这两套标准的更进一步介绍可以参见附录(二)。     
	
3. Container format 和Codec 有关系吗？    
    不妨将视频文件看作容器(Container)，那么这个容器里盛放的就是遵循某种Codec的内容(Content)。一个容器里应该能放下视频、音频、数据信息，即使它们遵循的Codec不相同。例如，QuickTime File Format (.MOV)支持几乎所有的Codec，MPEG(.MP4)也支持相当广的Codec。所以，单从视频文件的格式是无法获知它的质量细节的，这些细节取决与采用的Codec。比较专业的说法是，“给我一个H.264 Quicktime文件(.mov)”。    

4. 为何还是有点迷糊？    
    以上的解释是从学术角度出发的。只要分清了这些术语，那么在学术讨论时不会有含糊。但现实生活中人们不会一丝不苟地区分“Container format ”“Codec”，往往只会说“这是一个mov文件”。这是日常用语与学术术语混用造成的理解上的混乱。    
		
    另外，Container format和Codec的命名也有让清醒的人摸不清头脑。例如，“MPEG-4”既是“Container format ”，也是“Codec”，这也让混乱的名词世界更糟糕。    

###参考
1. https://library.rice.edu/services/dmc/guides/video/VideoFormatsGuide.pdf
2. https://app.zencoder.com/docs/faq/codecs-and-formats

###附录一 常见的视频封装格式和后缀的对应表
![常见的视频封装格式和后缀的对应表](https://app.yinxiang.com/shard/s11/res/a7088df6-98db-4089-8bb6-93a2beb1c76e/7295b9399a1a37290870fa8f35f4762e_b.jpg.png?resizeSmall&width=313)

