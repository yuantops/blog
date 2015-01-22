---
layout: post    
category: "Tech"   
tags: [Linux]
title: "Linux确定监听某个端口的进程"      
description: "在Linux下，如何确定一个端口正被哪个进程(Process)占用?如何确定一个运行中的进程占用了哪些端口？这是一篇小笔记，介绍几个常用的命令。"
---

比较常见的命令有:  

- **netstat**  
- **lsof**   
- **ps**
- **/proc/$pid**   

###netstat
{%highlight bash%}
# netstat -tuapn
{%endhighlight%}

参数解释:    

		-t tcp协议   
		-u udp协议   
		-a 显示listening和non-listening端口   
		-p 显示process ID  
		-n 显示数字IP，而不是字符形式的hostname   

可以用grep命令对上条命令的输出进行过滤，显示某条端口的信息。   

###lsof
{%highlight bash%}
# lsof -i :4000
{%endhighlight%}

lsof列出机器上打开的所有文件。这条命令输出端口4000被占用的情况。它的输出形如   
		COMMAND    PID  USER   FD   TYPE DEVICE SIZE/OFF NODE NAME    
		ruby-mri 10482 yyuan   11u  IPv4 252906      0t0  TCP localhost:terabase (LISTEN)

可以看到进程号10482的进程占用了TCP端口4000。    

###ps
{%highlight bash%}
# ps aux
{%endhighlight%}

参数解释:
		-a 显示所有用户的进程  
		-u 显示进程的user/owner  
		-x 也显示不与终端关联的进程   

同样地，也可以用grep命令对上条命令的输出进行过滤，显示某条端口的信息。   

###/proc/$pid
下面是该目录下，各个文件的作用:   

{%highlight bash%}
..............................................................
File		Content
clear_refs	Clears page referenced bits shown in smaps output
cmdline		Command line arguments
cpu			Current and last cpu in which it was executed	(2.4)(smp)
cwd			Link to the current working directory
environ		Values of environment variables
exe			Link to the executable of this process
fd			Directory, which contains all file descriptors
maps		Memory maps to executables and library files	(2.4)
mem			Memory held by this process
root		Link to the root directory of this process
stat		Process status
statm		Process memory status information
status		Process status in human readable form
wchan		If CONFIG_KALLSYMS is set, a pre-decoded wchan
pagemap		Page table
stack		Report full stack trace, enable via CONFIG_STACKTRACE
smaps		a extension based on maps, showing the memory consumption of
each 		mapping and flags associated with it
...............................................................
{%endhighlight%}

##具体应用
###找到进程3813的owener
{%highlight bash%}
# ps aux | grep 3813
{%endhighlight%}

或者 cat /proc/3813/environ , 查看USER字段。   

###看到一个根本不认识的端口号
/etc/services文件用来将协议/端口号映射到服务的名字。可以用grep命令来匹配某个不认识的端口。
