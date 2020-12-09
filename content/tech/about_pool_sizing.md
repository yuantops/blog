+++
title = "关于连接池大小"
author = ["yuan.tops@gmail.com"]
description = "连接池设多大合适，是个好问题；但肯定不是越大越好"
lastmod = 2020-12-09T16:46:26+08:00
categories = ["Tech"]
draft = false
keywords = ["pool"]
+++

这篇文章讲得很好，值得一读:


## About Pool Sizing {#about-pool-sizing}

<https://github.com/brettwooldridge/HikariCP/wiki/About-Pool-Sizing>


## 结论 {#结论}

综合CPU核数，磁盘IO，网络状况，得到一个经验公式:

> connections = ((core\_count \* 2) + effective\_spindle\_count)

```txt
A formula which has held up pretty well across a lot of benchmarks for years is
that for optimal throughput the number of active connections should be somewhere
near ((core_count * 2) + effective_spindle_count). Core count should not include
HT threads, even if hyperthreading is enabled. Effective spindle count is zero if
the active data set is fully cached, and approaches the actual number of spindles
as the cache hit rate falls. ... There hasn't been any analysis so far regarding
how well the formula works with SSDs.
```
