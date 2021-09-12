+++
title = "最近一次重装系统"
author = ["yuan.tops@gmail.com"]
description = "最新一次重装Windows10"
date = 2021-09-12T00:00:00+08:00
publishDate = 2021-09-12T00:00:00+08:00
lastmod = 2021-09-12T21:22:10+08:00
tags = ["Linux", "Emacs"]
categories = ["Tech"]
draft = false
+++

上次重装系统是什么时候？很久很久之前了吧。

手上这台二手Thinkpad T450s，装着 `Ubuntu` 和 `Windows 10` ，其中 `Ubuntu` 是我装的; `Windows 10` 继承自上任主人，我接手后几乎没有"装修"，一直凑合用着。最近，它越来越不趁手，终于我下定决心——重装Windows。


## 镜像与烧录工具 {#镜像与烧录工具}

根据之前捣腾 `Ubuntu` 的经验，需要准备三件东西:

-   系统镜像
-   将镜像烧录 U 盘的工具软件
-   U盘，用作启动盘

哪个 `Windows` 版本最好？在知乎网搜索一番，很多网友推荐 `Windows Enterprise LTSC 2019` ，而且推荐一个神奇的下载网站 [I Tell You](https://msdn.itellyou.cn/), 上面有各种各样镜像资源。LTSC 镜像下载链接是 \`ed2k\` 格式，依稀记得是一种BT下载协议（？），现在比较少见。我不得不先安装迅雷，再用迅雷处理这个小众的 \`ed2k\` 链接。说句题外话，迅雷居然还活着，实在令人震惊，但接着发现它趁我不备偷偷装上了一个奇怪软件，又有些唏嘘了:国产软件活着不容易啊，就连迅雷也堕落成流氓软件了！

镜像烧录工具，知乎网友推荐用 <https://rufus.ie/zh/> 。

U盘，我随手找到一个8G盘。

这时候，准备工作完毕。


## 重启电脑，开始重装 {#重启电脑-开始重装}

说下前情提要。这台 T450s 装过双系统，启动方案已经是 `UEFI` ，上电后默认进入 Ubuntu Grub 引导，可以选择进入 Ubuntu 还是 Windows。(还记得昔日主流启动引导方案 `MBR` 吗？现在已经称作 `Legacy/MBR` 。真是历史的眼泪啊。)

这里不详述 `UEFI/GPT` 的先进性。在支持双系统启动这一点上， `UEFI/GPT` 比起 `UEFI/GPT`  要复杂一些: 需要修改 `BIOS` 菜单，将 `Secure Boot` 置为 `false` 。具体可以参考[官方文档](https://support.lenovo.com/hk/en/solutions/ht509044-how-to-enable-secure-boot-on-think-branded-systems-thinkpad-thinkstation-thinkcentre)。

我的T450s已经配置过 `BIOS` ，所以跳过上面这步。

进入开机启动，眼疾手快，迅速按 `F12` 进入启动菜单。选择从U盘启动，进入安装界面。


## 新系统升级驱动 {#新系统升级驱动}

系统装好后，总感觉清晰度不够。我猜想，是驱动不适配。搜索 `驱动人生` 关键字，这是类似驱动精灵的一款软件。为什么不直接安装驱动精灵？因为驱动精灵也长成流氓软件的模样了。。 `驱动人生` 实际体验还可以，有点古典互联网软件那意思。

驱动人生识别出系统显卡驱动需要升级。选自动升级，然后屏幕恢复正常。


## 调整 BIOS 引导顺序 {#调整-bios-引导顺序}

重启电脑，如果什么都不做，将默认进入 Windows10。原因是，Windows10 装好后自动生成一条 Windows 引导记录，而且优先级最高。之前 `Ubuntu` 的引导项仍然在那儿，只是往后挪了一位。电脑启动时，总是尝试按优先级加载，自然进入 Windows 。

要找回 Linux GRUB 引导界面，只需进入 `BIOS` 菜单，找到设置引导顺序的界面，把 Linux 引导条目挪到第一位。


## 小问题：双系统，Windows 时间对不上？ {#小问题-双系统-windows-时间对不上}

原因是 Windows 和 Linux 处理硬件时间的方式不一样。参考网友的[解决方案](https://blog.csdn.net/zhouchen1998/article/details/108893660), 用三行命令解决问题:

```bash
sudo apt install ntpdate;
sudo ntpdate time.windows.com;
sudo hwclock --localtime --systohc
```
