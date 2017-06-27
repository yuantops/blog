+++
Categories = ["Tech"]
Description = "解法是改用mkfs.ext4。"
Tags = [""]
date = "2017-06-27T10:34:04+08:00"
title = "mkfs 报invalid block count错误"

+++

## 问题  
在rh 5u7 上用mkfs 创建文件系统，命令  

	$ mkfs -q -t ext3 -L disk0 /dev/sdb1  
	
居然报错：  
	
	……invalid blocks count……  
	
## 排查  
仔细阅读`man mkfs`使用文档，是这样写的，没发现哪里用得不对。  
	
	mkfs [-V] [-t fstype] [fs-options] filesys [blocks]

Google，发现是[mkfs 解析参数发生了错误](https://unix.stackexchange.com/questions/39998/creating-an-ext4-partition-fails-with-invalid-blocks-count)。  

原因很简单，`mkfs` 其实是`mkfs.type` 的快捷方式。5u 的mkfs 版本过低，不支持`-t`参数，所以阴差阳错把最后的参数`/dev/sdb1` 当作了`[blocks]`。

## 解法  

1. 安装`e4fsprogs`，这是操作ext4 的工具包。官方文档[在此](https://rhn.redhat.com/errata/RHEA-2009-0217.html)。  
2. 改用`mkfs.ext4`：  

		$ mkfs.ext4 -q -t ext3 -L disk0 /dev/sdb1  
	
