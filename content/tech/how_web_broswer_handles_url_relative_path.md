+++
title = "浏览器会处理URL里的相对路径"
author = ["yuan.tops@gmail.com"]
description = "如果要访问的url包含相对路径，浏览器会尝试解析相对路径，再访问解析得到的地址。"
date = 2019-11-21T15:53:00+08:00
lastmod = 2019-11-21T15:54:32+08:00
tags = ["gh-pages", "hugo"]
categories = ["Tech"]
draft = false
keywords = ["http"]
+++

新系统上线前，安全部门扫描出一个高危漏洞：文件任意下载漏洞。渗透测试人员在URL里加上相对路径，不断发起HTTP请求，居然成功下载到Linux系统密码文件。修复漏洞挺简单，限制HTTP服务访问文件系统权限，不允许超出指定目录，几行代码搞定。

修复之后准备进行验证，第一步当然是复现漏洞。没想到，这一步就挺曲折。


## 消失的点号 {#消失的点号}

打开chrome，在地址栏输入带了相对路径( **..** )的URL。URL指向一个文件，理论上，会触发文件下载。结果是：地址栏URL路径里点号全不见了，变成了一个正常地址。多试几遍，把双点号换成单点号，仍然如此。用 wiresharks 抓包看HTTP报文，请求头 _path_ 没有点号。这说明，浏览器做了手脚。

1.  Google搜之，找到一份解析URI的RFC3968标准，专门有一章论述解析点号：[Remove Dot Segments](https://tools.ietf.org/html/rfc3986#section-5.2.4)。经过解析，点号和双点号会消失，这个过程被称为 **remove\_dot\_segments** 。(RFC3968给出了这个过程的伪代码。)

2.  Google官方在一篇文章里，将Chrome解析URL的过程称为 \`Canonicalization\` ([display-urls-in-canonical-form](https://chromium.googlesource.com/chromium/src/+/master/docs/security/url%5Fdisplay%5Fguidelines/url%5Fdisplay%5Fguidelines.md#display-urls-in-canonical-form)) 。经过解析，Chrome地址栏的点号变成实际值。

结合两篇文档，原理清楚了：浏览器遵循RFC3968规范处理URL相对路径，所以点号和双点号都被干掉了。


## 改用Burp Suite重现问题 {#改用burp-suite重现问题}

不能用浏览器复现问题，改尝试 **curl** 命令。结果，curl也不能复现。好在可以借助 **Burp Suite** 工具。

Burp Suite是一款攻击web服务的集成工具，一般黑客用它来渗透网络。我们牛刀小用，用来拦截、修改HTTP请求报文。过程不在此赘述。总之，用它绕过了相对路径解析、重现了漏洞。


## 修复漏洞 {#修复漏洞}

略。
