+++
Categories = ["Tech"]
Description = "Jekyll，你的包依赖太TM难搞了，不带你玩啦！"
Tags = ["golang"]
date = "2017-05-06T14:03:44+08:00"
title = "放弃Jekyll，拥抱Hugo"

+++

大约半年前，我更换了自己的工作电脑。装完系统后，开始装各种常用程序。    

一切都是那么美好，直到我开始尝试装Jekyll。各种依赖下不下来，或者版本对不上。前者要问候GFW，后者就是Ruby自己的锅了。我，一个Ruby盲，多次被毫不留情的依赖版本问题整崩溃。哪怕一次次长夜痛哭，最终也没有成功。   

直到有一天，我看到小巧精炼的[Hugo](https://gohugo.io/)。   

Hugo 是用Golang 写的静态网站生成器，只有一个二进制命令，开箱即用。而且，一个命令既可以生成静态文件，又可以直接开http server。所以，那些乱七八糟的gem 包， screw you!  

在将Jekyll迁移到Hugo的过程中，需要重新梳理一下文章的组织结构。不过这些都是小case。   

我的博客托管在Github Pages。Github本身支持Jekyll引擎，以前直接把markdown文件 push上去就可以，Github会自动帮忙渲染源文件。但Github不支持Hugo的文件布局，所以博客内容要先在本地生成html，再push到github。   

我的Github项目地址在[这里](https://github.com/yuantops/blog/)。`hugo`分支存放源文件，`gh-pages`存放编译好的html。   

最后，再次赞美go， 赞美Hugo!  
