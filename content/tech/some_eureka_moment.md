+++
title = "一次顿悟"
author = ["yuan.tops@gmail.com"]
description = "对于Emacs的一次思考，以及收获……"
date = 2021-09-01T00:00:00+08:00
publishDate = 2021-09-01T00:00:00+08:00
lastmod = 2021-09-01T17:36:02+08:00
tags = ["gh-pages", "hugo", "Emacs"]
categories = ["Tech"]
draft = false
keywords = ["ox-hugo"]
+++

最近用 `Emacs` `ox-hugo` 写了几篇文章，体验比较糟，表现为总是无理由卡顿，特别是在 org 页面按下 \`Ctrl-C, Ctrl-E\`导出markdown时直接卡死，好几次只能强行杀掉Emacs 进程。

总所周知，Emacs 是神的编辑器，肯定不会出问题；我不爽，必定是我不会用了。于是，我鼓足勇气，想看看是哪里出了问题。

经过辛勤搜索，各种修改配置，纹丝不动。焦躁之余，不禁回忆起往事……

原本我是坚定vim党，自得其乐。

后来，受网络meme影响，终于买了一本讲Emacs的电子书，开始像八爪章鱼一样学按键，键位那么多，组合那么多。。。草草翻完一遍，只剩下 "这也行！" 的感叹号。试了 `Dired`, `Magit`, 自觉太复杂，难以记忆。放弃之。

又过了一段时间，心又痒痒了……这次吃了 `org` 的安利，GTD 好厉害！！大概实践了两个星期，只记得按 `Tab` 键可以切换标题等级。

下一次入坑，是受到 `ox-hugo` 的蛊惑: 确实如行云流水，非常满意。

想到这里，我顿悟了，我只是为了 **org-mode 和 ox-hugo 啊** ！ Emacs 再怎么厉害，别人用得再怎么出神入化，用它写代码(特别写Java!!)、看小说、玩游戏、看视频…… 和我有什么关系呢? 弱水三千，只需取一瓢。

于是，爽爽快快删掉攒了多年的配置:

```shell
rm -fr .emacs.d
```

热情投向 `spacemacs` 怀抱:

```shell
git clone -b develop https://github.com/syl20bnr/spacemacs .emacs.d
```

启动emacs。因为是spacemacs第一次加载配置文件，会有一些询问交互。一路选择最小化配置。

最后修改 `.spacemacs`, 加上 `ox-hugo` 支持:

{{< highlight emacs-lisp "linenos=table, linenostart=1" >}}
(setq-default dotspacemacs-configuration-layers
              '((org :variables
                  org-enable-hugo-support t)))
{{< /highlight >}}

重新加载配置，完完全全就好了！

恭喜我自己 :)
