+++
title = "Bash Guideline Notes"
author = ["yuan.tops@gmail.com"]
description = "《Bash Guideline》摘抄与笔记"
date = 2019-07-25T00:00:00+08:00
publishDate = 2019-07-25T00:00:00+08:00
lastmod = 2019-11-21T15:54:34+08:00
tags = ["Linux"]
categories = ["Tech"]
draft = false
keywords = ["bash"]
+++

## 关于重定向顺序 {#关于重定向顺序}

>
>
> Note that the order of redirections is signi cant. For example, the command <br />
> <br />
> ls > dirlist 2>&1 <br />
> directs both standard output ( file descriptor 1) and standard error ( le descriptor 2) to the file dirlist, while the command ls 2>&1 > dirlist directs only the standard output to file dirlist, because the standard error was made a copy of the standard output before the standard output was redirected to dirlist. <br />


## 将Stdout 和 Stderr 重定向到 文件 {#将stdout-和-stderr-重定向到-文件}

> This construct allows both the standard output ( file descriptor 1) and the standard error output ( file descriptor 2) to be redirected to the file whose name is the expansion of word. <br />
> <br />
> There are two formats for redirecting standard output and standard error:<br />
> <br />
> &>word and <br />
> <br />
> >&word
> <br />
> Of the two forms, the first is preferred. This is semantically equivalent to<br />
> >word 2>&1<br />


## Here Document {#here-document}

```nil
Here Documents
This type of redirection instructs the shell to read input from the current source until a line containing only word (with no trailing blanks) is seen.

All of the lines read up to that point are then used as the standard input for a command.

The format of here-documents is:

          <<[-]word
                  here-document
          delimiter
No parameter expansion, command substitution, arithmetic expansion, or pathname expansion is performed on word. If any characters in word are quoted, the delimiter is the result of quote removal on word, and the lines in the here-document are not expanded. If word is unquoted, all lines of the here-document are subjected to parameter expansion, command substitution, and arithmetic expansion. In the latter case, the character sequence \<newline> is ignored, and \ must be used to quote the characters \, $, and `.

If the redirection operator is <<-, then all leading tab characters are stripped from input lines and the line containing delimiter. This allows here-documents within shell scripts to be indented in a natural fashion.

$ cat <<EOF > print.sh
#!/bin/bash
echo \$PWD
echo $PWD
EOF
```
