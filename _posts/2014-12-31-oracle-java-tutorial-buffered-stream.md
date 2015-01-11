---
layout: post    
category: "Tech"   
title: "Buffered Streams -- Oracle Java Tutorial 翻译"      
tags: [Java]    
description: "本文是Oracle Java开发手册中关于Buffered Streams章节的翻译，个人手工翻译，非转载。"
---

##Buffered Streams 缓冲流 
此前我们所见识的例子使用的大多*非缓冲I/O*。非缓冲，意味着每一次读/写的请求都由底层的OS直接处理。这降低了程序效率，因为每一次请求往往会触发磁盘操作、网络活动、或者其它代价昂贵的操作。  

为了减少这类消耗，Java平台实现了*缓冲I/O*流。输入缓冲流从一块别名为"缓存"(*buffer*)的内存区域中读入数据;只有当缓存区变空的时候，原生的输入API才会被调用。类似地，缓冲的输出流向一块缓存中写数据，只有当缓存区满了的时候，原生的API的输出API才会被调用。  

程序能把一个非缓冲流转化为缓冲流。我们已经使用过几次这样的"包装类"了：非缓冲流作为参数传入缓冲流类的构造函数。下面就是一个例子，你可以在用它替代CopyCharacters代码中的构造函数以使用缓冲I/O：  
{%highlight java%}
inputStream = new BufferedReader(new FileReader("xanadu.txt"));
outputStream = new BufferedWriter(new FileWriter("characteroutput.txt"));
{%endhighlight %}

可以用来包裹非缓冲流的缓冲流类有4类：BufferedInputStream和BufferedOutputStream生成缓冲字节流, BufferedReader 和BufferedWriter 生成缓冲字符流。  

###洗刷(flush)缓冲流
在某些重要的时刻，我们等不及缓存填满就要将它的内容输出。这样的操作一般被称作*洗刷(flush)*缓存。  

一些缓冲输出流支持"自动洗刷(autoflush)"，只要你在它的构造函数中指定某个参数即可。当开启了自动洗刷后，某些关键事件会触发洗刷。例如，一个自动洗刷的PrintWriter对象，每当*println*或者*format*被调用时都会自动洗刷缓存。  

可以使用*flush*函数来手动洗刷缓存。可以对任何一个输出流使用*flush*函数，但只有在这个流被缓冲时才有效果。  

>注：flush也可以翻译成“刷新”，但我觉得这样可能造成含混，所以还是将它翻作“洗刷”来得直白。  

###原文链接
[Buffered Streams](http://docs.oracle.com/javase/tutorial/essential/io/buffers.html)
