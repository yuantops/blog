+++
title = "Go从GitHub安装命令时指定commit/tag"
date = "2018-05-14T09:49:03Z"
Categories = ["Tech"]
Tags = ["Golang"]
Description = "Go的版本管理是一大痛点，最近我就亲身经历了一遭。这篇博客介绍一种非官方、指定git commit安装go命令的方法。"
+++

Go的版本管理是一大痛点，最近我就亲身经历了一遭。在[Blog自动部署实践](https://blog.yuantops.com/tech/hugo-travis-ci-auto-deploy-to-gh-pages/)一文中，我把部署博客的工作流交给了Travis
CI。第二天，我照例打开Google Analytics查看访问量，发现前一天的访问量跌到0：一定出了什么问题。

我从GitHub上把 `gh-pages` 分支pull下来，grep我的Google Analysis跟踪码，居然没有。在本地用 `hugo`
命令生成静态文件，在public目录里发现每篇文章的html页面都包含Google Analytics跟踪代码。到此基本确定问题：Travis
CI build生成的静态网页货不对版，因为默认使用最新版本 `hugo` 命令，所以绝对是 `hugo` 版本更新导致的兼容问题。

解法也很简单，在 `.travis.yml` 文件里安装指定版本的 `hugo` 命令，让它和我本地`hugo`命令的版本号保持一致。

`.travis.yml` 用go get安装Go命令。虽然官方不支持指定commit，但我在[Stackoverflow:How to do
“go get” on a specific tag of a github
repository](https://stackoverflow.com/questions/30188499/how-to-do-go-get-on-a-specific-tag-of-a-github-repository)
上找到了曲线救国方法，摘录如下：

    1. Run the get command without the tag - it should clone the master branch.
    2. Move to the clone directory and checkout the tag or branch that you want.
    3. Run the go get command again, it should process the command on the checked out branch.

事实上，这个方法行之有效。更新后， `.travis.yml` 文件的install部分长这样:

    install:
      - go get -d github.com/spf13/hugo 
      - cd $GOPATH/src/github.com/spf13/hugo
      - git checkout tags/v0.20.7
      - go get github.com/spf13/hugo
      - cd $TRAVIS_BUILD_DIR
      - hugo version

我指定安装v0.20.7版本的hugo，并手工打出版本号确认。重新部署后，Google Analytics统计恢复正常。
