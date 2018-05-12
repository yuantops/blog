+++
title = "Blog自动部署实践: Hugo + Travis CI -> GitHub Pages"
date = "2018-05-12T8:45:52Z"
Categories = ["Tech"]
Tags = ["gh-pages"]
Description = "这篇文章记录了如何使用免费Travis CI平台，将Hugo生成的静态博客站点自动部署到GitHub Pages。"
+++

这个博客托管在GitHub
Pages上已经有一段时间。最初使用的静态站点生成工具是Jekyll，后来[换成Hugo](http://blog.yuantops.com/tech/transfer-from-jekyll-to-hugo/)，因为是免费，一直都还比较满意。只有一个小痛点，博客从写完到部署的步骤多：写文章
-\> build -\>
deploy…

我之前[写过一篇用Emacs写博客的workflow](http://blog.yuantops.com/tech/emacs-orgmode-hugo-with-oxpandoc/)，把"写文章"的流程优化了一把。之后又小打小闹，用GitHub的webhook做了一个commit
message关键字触发的小服务，把"build"和"deploy"做成自动化。这个服务跑在免费的Google
Cloud上，使用体验还不错，可惜主机没续费，服务直接停掉，源码也丢失了。

随手Google一把GitHub Page的持续集成，才后知后觉地发现自己想要的东东已经有了成熟解决方案，而且还可以 **免费**
用：[Travis CI](https://travis-ci.org/)。于是我颇愉快地接受它，并简单地在这里记录下来。

# 什么是Travis CI

一个持续化集成平台，类似Jenkins。功能强大，和GitHub的集成尤其好，我们用它部署个人博客算大材小用。它有两个版本:

  - <https://travis-ci.org/> 免费版本，可以集成GitHub的public项目
  - <https://travis-ci.com/> 商业版本，可以集成GitHub的private项目

我们使用第一个，免费版本。

# 本博客现状回顾

在进一步描述具体步骤之前，有必要先简要回顾本博客的现状：

  - 用[Hugo](https://gohugo.io/)生成静态站点文件
  - 两个git分支, `hugo`: 存放博客源码, `gh-pages`: 存放Hugo生成的静态站点文件
  - 自定义域名: \`blog.yuantops.com\`, 而不是默认的yuantops.github.io

# 配置Travis CI

## 为Travis CI生成GitHub Token

打开GitHub。路径: "Settings"-\>"Developer settings"-\>"Personal access
tokens"-\>"Generate new token"。

因为是public项目，而且Travis CI是用来push代码，所以只需勾选 `public_repo`, `repo:status`,
`repo_deployment` 三项。

Token一会儿就会隐藏，不能找回，所以拷贝好，进入下一步。

## 配置Travis CI构建选项

1.  用GitHub方式登录Travis CI(<https://travis-ci.org/>)
2.  "Settings"-"General" 勾选"Build only if .travis.yml is present"和"Build
    pushed branches"两项。
3.  "Settings"-"Environment Variables"
    添加"GITHUB<sub>TOKEN</sub>"，值是上一步得到的Token

## 在git根目录下添加 `.travis.yml` 文件

    language: go
    
    go:
      - "1.8"  # 指定Golang 1.8
    
    # Specify which branches to build using a safelist
    # 分支白名单限制: 只有hugo分支的提交才会触发构建
    branches:
      only:
        - hugo 
    
    install:
    # 安装最新的hugo
      - go get github.com/spf13/hugo 
    
    script:
    # 运行hugo命令
      - hugo
    
    deploy:
      provider: pages # 重要，指定这是一份github pages的部署配置
      skip-cleanup: true # 重要，不能省略
      local-dir: public # 静态站点文件所在目录
      target-branch: gh-pages # 要将静态站点文件发布到哪个分支
      github-token: $GITHUB_TOKEN # 重要，$GITHUB_TOKEN是变量，需要在GitHub上申请、再到配置到Travis
      fqdn: blog.yuantops.com # 如果是自定义域名，此处要填
      keep-history: true # 是否保持target-branch分支的提交记录
      on:
        branch: hugo # 博客源码的分支

把 `.travis.yml` 放到hugo分支，push到GitHub。

# 自动部署

上述操作完成后，自动部署就生效了。我们写完一篇博客，只需在hugo分支提交commit、再push到GitHub，Travis
CI会自动触发后续的构建、部署动作。
