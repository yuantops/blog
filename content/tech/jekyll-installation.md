+++
Categories = ["Tech"]
date = "2014-12-30T00:00:00Z"
Description = "使用GitHub pages搭建博客越来越流行。GitHub pages使用的文件解析引擎是Jekyll。在本地安装Jekyll，将自己的博客调试合适后再推送到GitHub，会省事很多。本文介绍如何在本地安装Jekyll。"
Tags = ["gh-pages"]
title = "Jekyll安装指南"
+++

### 环境准备
准备安装Jekyll前，确保系统满足以下条件：  

* Ruby   
* RubyGems  
* Linux, Unix, 或者 Mac OS X    
* Nodejs, 或者其它JavaScript运行环境   

以Ubuntu为例，安装上述软件的方法：  
**Ruby**  
{{< highlight bash >}}
$ sudo apt-get install ruby, ruby-dev
{{< / highlight >}}
要注意，*ruby-dev*包需要一并安装，否则在后续会报错。   

在Redhat/Fedora下，需要安装的软件包为ruby,ruby-devel。有可能还需要安装gcc包。   
{{< highlight bash >}}
$ sudo yum install ruby, ruby-devel, gcc
{{< / highlight >}}

**RubyGems**  
RubyGems是Ruby程序包管理器，类似Redhat的RPM。更多的概念介绍，请参看[整理Ruby相关的各种概念](http://henter.me/post/ruby-rvm-gem-rake-bundle-rails.html)。   
新版本的Ruby已经包含RubyGems，无需额外安装了。    

**Nodejs**    
{{< highlight bash >}}
$ sudo apt-get install nodejs
{{< / highlight >}}

### 设置Gemfile
将GitHub上你的博客Repo克隆到本地。假设Repo的根目录为blog。终端路径切换到blog目录，新建名为`Gemfile`的文件，并填充内容:

{{< highlight bash >}}
source 'https://rubygems.org'
gem 'github-pages'
{{< / highlight >}}

### 使用RubyGems安装Jekyll
终端路径切换到blog，运行命令：
{{< highlight bash >}}
$ sudo gem install jekyll
{{< / highlight >}}

### 运行Jekyll，查看博客效果
终端路径切换到blog，运行命令：
{{< highlight bash >}}
$ jekyll serve
{{< / highlight >}}
