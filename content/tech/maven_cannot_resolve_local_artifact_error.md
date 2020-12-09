+++
title = "artifact存在, 但maven报错: Could not resolve artifact"
author = ["yuan.tops@gmail.com"]
description = "记录 maven 3.0.x 一个大坑"
lastmod = 2020-12-09T16:33:48+08:00
categories = ["Tech"]
draft = false
keywords = ["maven"]
+++

如果你遇到这个问题，而local repository里jar确实存在，一定看一眼你使用的maven版本：你可能遇到maven 3的一个坑。

简而言之，maven3 开始验证本地仓库jar包的repository\_id。


## 原因 {#原因}

从maven3开始，从远程仓库下载jar包时，会在jar文件旁边生成一个\`\_maven.repositories\`文件，文件里写明它来自哪个repository。

如果当前项目的effective pom(\`mvn <effective-pom>\` 查看)里，生效的repository列表不包含这个jar包的repository\_id，就会 **报错** 。


## 解决办法 {#解决办法}

简单粗暴: 把\`\_maven.repositories\`全删掉

```sh
find ~/.m2/repository -name _maven.repositories -exec rm -v {} \;
```


## 参考 {#参考}

参考 [StackOverflow网友回答](https://stackoverflow.com/questions/16866978/maven-cant-find-my-local-artifacts) 。
