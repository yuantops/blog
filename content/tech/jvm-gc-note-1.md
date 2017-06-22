+++
Categories = ["Tech"]
Description = "关于JVM 和GC, Oracle 官方的介绍文档值得一读。"
Tags = ["java"]
date = "2017-06-21T23:32:37+08:00"
title = "JVM 和Java GC 笔记"

+++


## 学习材料

- 讲义地址： <http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/gc01/index.html>  
- Youtube 视频地址：  [Video The JVM and Java Garbage Collection](https://www.youtube.com/watch?v=DoJr5QQYsl8)

## Java & JVM概述

1.  Garbage Collection is automatic.
2.  Java source code is compiled into byte code.
3.  Byte code is stored in .class files
4.  .class files are loaded into a Java Virtual Machine(JVM) and executed.
5.  A seperated JVM is created for each Java application. (备注：！每个Java程序都对应着一个单独的JVM)

## GC 的职责

1.  为新对象分配memory
2.  确保被引用的对象留在memory Ensuring that any referenced objects(live objects) remain in memory
3.  回收死掉的对象占用的memory Recovering memory used by objects that no longer reachable(dead objects)

## GC的stages

step 1. marking(标记将被删除的对象)  
step 2. Normal Deletion/sweeping(删除标记的对象)   
step 3. Deletion with Compacting (整理内存，把碎片归拢)  

## Generational Collection

出发点：Java中绝大多数对象的生存周期很短。
因此按generation 来运行GC, 可以将memory 分为三部分：

### Young Generation(for young objs)

-   Eden
-   A "from" survivor space (S0)
-   A "to" survivor space (S1)

### Tenured (old) Generation

-   for old objs
-   超过了Minor GC age theshold的obj, 被挪到这里

### Premanent Generation

-   for meta data, classes, and so on
-   Contains metadata required by the JVM
-   Class objs and methods

### Minor GC

1.  发生在Young Generation，频繁发生
2.  fast，efficient。因为young gen space 通常很小，而且包含很多短命的obj
3.  熬过几次minor gc的obj，将被 **promote** 到old generation space

### Major GC

1.  发生在old Generation的GC
2.  old generation space 比yong gen 大，被占用的space 缓慢增长
3.  infrequently, 而且花费的时间远多于 minor gc

## Aging Obj in Yong Gen

1.  新Obj 被分配到eden space
2.  当eden space 满，触发minor GC: " **Stop the world** " event (all the application threads stop)
3.  eden space满，则运行GC，把eden space 中活下来的obj + survivor space 中活下来的obj 移到另一个survivor space(反复来回倒), 并把这些obj 的age + 1
4.  如果obj的age 超过threshold(一般为15)， 将它挪到Old Gen

## 感受

除了官方的文档、视频，Oracle JDK还提供了demos 和samples, 自己可以实际操作，加深感受。

