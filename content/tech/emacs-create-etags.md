+++
Categories = ["Tech"]
Description = "Emacs下阅读源码的必要准备。"
Tags = ["emacs"]
date = "2017-07-19T21:35:16+08:00"
title = "Emacs阅读C/C++代码——生成TAGS文件"

+++

1. 生成TAGS文件  

		$ find . -iname "*.[chCHS]" | etags -  

2. Emacs 导入TAGS文件  
   在emacs中，`M-x visit-tags-table`，选择刚刚生成的TAG文件。  

3. 命令：  
   - 跳转到光标所在词对应的标签：`M-.`  
   - 回退到上个位置：`M-*`  
