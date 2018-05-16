+++
title = "Orgmode利用ox-pandoc导出hugo博客的workflow"
date = "2017-12-10T13:16:22Z"
Categories = ["Tech"]
Tags = ["Emacs"]
Description = "我用orgmode + hugo写博客的个人实践，希望对orgmode中文用户/hugo blogger有所启发。"
keywords = ["orgmode写博客","ox-pandoc导出博客"]
+++


使用Emacs有一年多了吧，终于开始体会到它的强大。这段盘旋上升的磨合期，值得写几篇文章记录一下。这篇博客就是我用orgmode + hugo写博客的个人实践，希望对orgmode中文用户/hugo blogger有所启发。

# 之前的workflow

自从转到hugo后，我发博客的workflow是这样的：

1.  在org文件里添加内容
2.  按下 `C-c C-e` （export命令），再按 `C-s` (只导出当前subtree)，再按 `m o`
    (导出格式markdown)，生成markdown 内容
3.  把markdown内容保存到 `hugo/content/` 目录，手动加上文件头(front matter)
4.  本地部署hugo server，检查效果。无误则运行部署脚本 `deploy.sh` push到github仓库的 `hugo` 分支
5.  github上我给 `hugo` 分支加了webhook，会触发构建，部署生成的html内容到 `gh-pages` 分支

这段流程一直还凑合，直到我的博客里出现表格：org导出的markdown表格会变成一坨翔，我要在第4步浪费很多时间人肉调整格式。  

怒google一把，发现是[org markdown官方导出引擎不支持table](http://orgmode.org/manual/Markdown-export.html)导致的:

    Since md is built on top of the HTML back-end, any Org constructs not supported by Markdown, such as tables, the underlying html back-end (see HTML export) converts them.

搜索时我发现有网友提到 `ox-pandoc`
，点进去github主页看了看，pandoc和orgmode的天作之合啊。pandoc对表格的支持无懈可击，还有啥好说，马上就决定是它了！

# Emacs安装ox-pandoc

## 安装pandoc

因为ox-pandoc是对pandoc的调用封装，所以首先得装上pandoc。pandoc可能是haskell语言最著名的作品了，支持非常多种文件格式的互转，极其强大。官网有安装文档，不再赘述。
确认已装好:

``` shell
pandoc -v
```

## 安装ox-pandoc

1.  官方github: [ox-pandoc主页](https://github.com/kawabata/ox-pandoc)

2.  `init.el` 加上elpa源:
    
    ``` commonlisp
    (setq package-archives
       '(("melpa" . "http://melpa.milkbox.net/packages/")))
    ```

3.  添加hook:
    
    ``` commonlisp
    (with-eval-after-load 'ox
    (require 'ox-pandoc))
    ```

4.  删掉旧的markdown导出：
    
    找到类似配置，删掉
    
    ``` commonlisp
    '(require 'ox-md nil t)
    ```

5.  重启emacs
    
    打开org文件，按下 `C-c C-e` ，弹出的orgmode export dispather窗口中应该出现了 `p`
    开头的很多选项，而且原来 `m` 开头的markdown选项不见了。

## 配置ox-pandoc 参数

ox-pandoc的导出选项可以配置在文档头部，就像org原生的导出选项配置一样。将官方wiki上关于文档的描述翻译如下：

    Value nil overrides preceding option setting.
    nil会覆盖之前为某个选项设置的值。
    
    Value t means only specify option, but not its value.
    t会打开某个选项的开关，而不会设置它的值。
    
    Options are delimited by space.
    多个选项间用空格分隔。
    
    #+PANDOC_OPTIONS: can be specified multiple times. 
    #+PANDOC_OPTIONS: 能多次使用。
    
    If you want to specify the option value which include space character, quote entire option-value pair.
    如果某个选项的值包含空格，那么要将“选项-值”都放到引号里。
    
    Specifying Multiple values to single options by using colon-sparated lists.
    给一个选项指定多个值，要使用逗号分隔的列表。

例如，ox-pandoc给导出文档添加目录:

    #+PANDOC_OPTIONS: toc-depth:3
    #+PANDOC_OPTIONS: toc:t

再例如，使用ox-pandoc `C-c C-e p l` 导出latex文档，如果中文不能正常显示，需要加上这两行：

    #+PANDOC_OPTIONS: pdf-engine:xelatex
    #+PANDOC_OPTIONS: "variable:CJKmainfont:Noto Sans CJK SC"

*xelatex* 是latex的一种处理引擎，对中文支持不错。如何安装xelatex，这里不赘述。

*Noto Sans CJK SC* 是我系统(Ubuntu)上安装的中文字体。用下面的命令查看安装了哪些中文字体:

    fc-list :lang=zh
    # 命令output: 字体名是两个冒号之间的、第一个逗号前的内容
    # /usr/share/fonts/opentype/noto/NotoSansCJK-Light.ttc: Noto Sans CJK SC,Noto Sans CJK SC Light:style=Light,Regular

## 配置hugo front-matter的snippet

如果你像我一样正在用Emacs的 `yasnippet`
包，可以参考我的做法，迅速添加带标题和日期的hugo文件头。这里参考了：[setting-up-the-blog](http://whyarethingsthewaytheyare.com/setting-up-the-blog/#workflow)
。

添加yasnippet模板文件，然后在org的subtree开头按下 `hmatter [TAB]` 即可。

    # key: hmatter
    # name: hugo-blog-matter
    # --
    #+BEGIN_SRC xxx
    +++
    title = "`(cdr (assoc "ITEM" (org-entry-properties)))`"
    date = "`(format-time-string "%Y-%m-%dT%H:%M:%S")`Z"
    Categories = ["Tech"]
    Tags = [""]
    Description = ""
    +++

# 现在的workflow

基本和之前的一样，但是现在导出按键顺序变成了

1.  `hmatter [TAB]` 插入front-matter，
2.  `C-c C-e` export命令，
3.  `C-s` 只导出当前subtree，
4.  `p g` 用pandoc导出github风格的markdown.

现在导出的格式堪称完美，达到了我的预期。

其实，最理想的workflow应该是写一个function把上述几步串起来，而且已经有人这么做了。等我哪天开始学elisp了，再来自己造轮子吧！
