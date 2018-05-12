+++
title = "emacs macOS配置中文字体"
date = "2017-12-10T00:50:07Z"
Categories = ["Tech"]
Tags = ["Emacs"]
Description = ""
+++

1. 从网上攒来的emacs字体配置地址  
   https://github.com/yuantops/emacs.d/blob/universal/lisp/init-fonts.el

1.  列出系统提供的所有字体  
    参考链接 <http://cnborn.net/blog/2014/10/emacs-chinese-font-on-osx/>  
    
    ``` commonlisp
    (print (font-family-list))
    ```

2.  找到中文字体，添加到chn font list 开头  

