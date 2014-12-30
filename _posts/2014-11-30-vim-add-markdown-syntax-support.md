---
layout: post    
category: "Tech"   
title: "vim增加markdown语法高亮支持"      
tags: [vim]
description: "本文介绍如何在Linux下配置vim，使它支持对markdown语法的高亮显示。"
---

markdown是一种非常简洁美观的语法格式，非常适合用来撰写博客([简书 语法简介](http://www.jianshu.com/p/q81RER))。在linux下，我个人最习惯用vim做文本编辑器。那么，如何使vim支持markdown的语法高亮呢？

vim是支持自定义语法高亮插件的。于是，问题就变成了两部分：    
1. 找到markdown语法高亮显示的vim配置文件  
2. 在vim中导入这个配置文件  

**vim配置文件下载**  
vim语法配置文件一般后缀为.vim。markdown的语法配置文件可以从下面链接中找到，假设它为markdown.vim, 将其下载到本地。

[vim官网链接](http://www.vim.org/scripts/script.php?script_id=1242), 或者这个项目的最新[github项目](http://github.com/plasticboy/vim-markdown/)

**配置文件导入**  
vim自定义配置文件的导入和安装见[链接](http://www.fleiner.com/vim/create.html)。 在这里我将其转述如下：

1. 在.vimrc文件(.vimrc文件一般在$HOME目录下，若不存在则新建)中添加一条语句，定义一种语法格式，以及这种格式对应的配置文件。  
以本文为例，假设markdown.vim保存路径为$HOME/.vim/markdown.vim，则在.vimrc文件中添加  
> au! Syntax markdown source $HOME/.vim/markdown.vim          

	*注*: 配置文件路径一定要正确配置  

2. 再在.vimrc文件中添加一条语句，规定何种后缀名的文件适用这种语法格式。  
以本文为例，我想后缀名为md与markdown的文件以markdown格式显示，那么在.vimrc中添加语句  
> au BufRead,BufNewFile *.md set filetype=markdown   
> au BufRead,BufNewFile *.markdown set filetype=markdown 

保存.vimrc文件并退出，整个配置过程结束。
