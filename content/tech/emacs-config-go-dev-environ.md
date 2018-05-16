+++
title = "Emacs Golang开发环境配置指南"
date = "2018-01-04T00:31:08Z"
Categories = ["Tech"]
Tags = ["Emacs", "Golang"]
Description = "换过几次电脑，每次配Golang环境都要求助Google，比较浪费时间。刚刚在公司的Mac上把Golang+Emacs开发环境搭好，趁着记忆还热乎，把步骤记录下来。"
keywords = ["Emacs","Go环境搭建"]
+++

# 安装Go

虽然像是废话，但为了配置过程的完整性，还是记下来吧。

官网install链接: <https://golang.org/doc/install>

装好后记得配置 `$GOPATH` 。为了能在任何地方使用Go编译出来的命令，还可以把 `$GOPATH/bin` 附到环境变量$PATH。

我在Mac上使用iTerm2+oh-my-zsh，所以把它们写到 `.zshrc` :

``` bash
# go path
export GOPATH=~/go
# add go commands to system path
export PATH=$GOPATH/bin:$PATH
```

# 让go get命令绕过Great Wall的束缚

有了Go的开发环境，我们就可以用它编译、安装一些十分有用的小命令了。但在此之前，还有一些客观存在的技术障碍需要扫除。

一般 `go get`
命令会自动帮我们下载源码、编译、安装命令，如果托管源码的网站被block了(如gopkg.in)，整个过程就会卡住，卡到人抓狂(记得在内心f\*\*k
GFW哦~)。

这时，如果电脑上刚好运行着shadowsocks，事情就变得简单了。go get
支持http_proxy和https_proxy，我们需要动一点手脚，把sock5协议转换成http协议。

(以下步骤的前提是电脑上运行着shadowsocks。)

1.  安装 polipo
    
    ``` 
    brew install polipo   
    ```

2.  配置 polipo 在家目录下新建 `.polipo` 文件，内容如下:
    
        #必填
        socksParentProxy = "localhost:1080"
        socksProxyType = socks5

3.  运行 polipo
    
        polipo &

    默认会监听8123端口的http请求。

4.  在go get命令前加上http_proxy参数

    以不幸被墙的cobra命令为例,它的代码网址是https协议,用:
    
        https_proxy=127.0.0.1:8123 go get -v github.com/spf13/cobra/cobra

    如果是http_proxy, 用：
    
        http_proxy=127.0.0.1:8123 go get -v github.com/blah/blah

# 安装goimports，gocode等有用工具

## goimports

  - goimports命令能自动格式化代码，自动添加、移除imports，而且与Emacs集成良好。可以替代官方gofmt命令。

  - 安装命令:
    
        go get -u golang.org/x/tools/cmd/goimports

## gocode

  - gocode命令能为代码自动补全提供后台支持，是Emacs下Go代码补全必不可少的backend。

  - 安装命令:
    
    ``` 
    go get -u github.com/nsf/gocode  
    ```

## godef

  - godef命令能在Go源码变量、函数定义间跳转，是查看变量、函数、文件定义的好助手。

  - 安装命令：
    
        go get github.com/rogpeppe/godef

# 安装Emacs

呃。。。这一步就略过吧

# Emacs配置Go mode

1.  安装go-mode

2.  添加自动格式化的hook(需要安装goimports命令)
    
    ``` commonlisp
    ;; Call Gofmt before saving
     (setq gofmt-command "goimports")
     (add-hook 'before-save-hook 'gofmt-before-save)
    ```

3.  配置自动补齐(需要安装gocode命令)
    
    ``` commonlisp
    ;;autocomplete
    (set (make-local-variable 'company-backends) '(company-go))
    (company-mode)
    ```

4.  配置自动跳转按键(需要安装godef命令)
    
    ``` commonlisp
    ;; Godef jump key binding
     (local-set-key (kbd "M-,") 'godef-jump)
     (local-set-key (kbd "M-.") 'pop-tag-mark)
    ```
