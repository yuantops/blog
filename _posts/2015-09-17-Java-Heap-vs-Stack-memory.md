---
layout: post    
category: "Tech"   
title: "Java堆内存与栈内存的区别"      
tags: [Java, 面试]    
description: "Java面试题。资料整理，非原创。"
---

Java中提供"栈"这种数据结构的实现，java.util.Stack。但此处我们所讨论的不是数据结构，而是JVM内存中的堆与栈，Java Runtime中存放数据的地方。   

### JVM中的堆  
Java Runtime使用Heap为Object分配内存。所有的对象，无论是何时何地创建的，都保存在Heap中。垃圾回收(Garbage Collection)在Heap上运行，释放不被引用的Object。Heap中生存的Object能在程序的任何地方被引用。    

### JVM中的栈
Stack memory是为执行的thread分配的，包含一些生存时间短的值和指向Heap中对象的引用。Stack Memory总是LIFO的。当调用一个Method时，Stack Memory会为它分配一块区域，用来存储本地的primitive value和对Object的引用。一旦这个method结束，这块区域将变得不可用，下一次Method调用时又可以使用它。   

相比Heap，Stack要小得多。   

### 区别
1. 存储内容：栈存放局部变量以及引用，堆存放**所有**对象。   
2. 被谁占有：堆被整个程序共享，栈中的对象被所有线程可见；栈属于单个线程，存储的变量只在其所属的线程中可见。   
3. 空间管理：Stack内存满足LIFO，但Heap就复杂多了。Heap被分为Young Generation, Old Generation, Permanent Generation，在它基础上会运行垃圾回收机制。 
4. 生存时间：Stack Memory伴随调用它的Method存在、消失，而Heap Memory从程序的开始一直存活到终止。    
5. 体积大小：Stack Memory体积远大于Heap Memory。由于Stack用LIFO调度，它的访问速度也快得多。可以用-Xms或者-Xmx定义Heap的初始大小，用-Xss定义Stack的初始大小。    
6. 异常错误：当Stack满了，Java Runtime会抛出java.lang.StackOverFlowError。当Heap满了，会抛出java.lang.OutOfMemoryError: Java Heap Space Error。  
