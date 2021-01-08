+++
title = "使用自定义 Classloader 加载类，利用反射创建实例时出现 NoSuchMethodException"
author = ["yuan.tops@gmail.com"]
description = "java 中的类是由类的全名以及类的 classloader 来限定的；同一个类被不同 classloader 加载，它们将变成不同的类"
lastmod = 2021-01-08T17:15:22+08:00
categories = ["Tech"]
draft = false
keywords = ["java"]
+++

最近在做一个需求，需要在程序运行时, 从当前 classpath 之外的指定路径加载(已经编译好的)类，并创建它的实例对象。

在程序运行时改变程序结构，本是动态语言的技能点，不是 Java 的强项。但借助 Java 语言 `JavaCompiler` 与 `反射` 等动态相关特性，也能勉强做到。 好在就这个需求而言，我们拿到的是编译好的 `.class` ，不需要编译开始从头做起。

所以我们就从类的动态加载出发，开始做了。 下面是实施步骤，以及遇到的问题。


## 步骤 {#步骤}

1.  我们使用了 Github 上一个可以动态加载 Maven 类的依赖库: [ModRun](https://github.com/nanosai/modrun)。
2.  将要加载的类所在 jar 包，连同它依赖的 jar 包，按 maven repository 目录结构放置。得到 ModRun 的一个 moduleClassloader。
3.  用 moduleClassLoader 加载类，得到 Class `clazz` 。
4.  使用反射，调用 `clazz.getDeclaredConstructor(xxxType1.class, xxxType2.class)` ，得到构建函数。
5.  构建函数调用 `invoke()`, 传入参数，预期得到所需要的对象。


## 问题 {#问题}

进行到第 4 步，会报错，提示没有对应的构造函数。但肉眼看上去，同样签名的构造函数明明存在。何故？


## 分析 {#分析}

在 StackOverflow 搜到答案: [StackOverflow 网友回答](https://stackoverflow.com/questions/2999824/classcastexception-when-creating-an-instance-of-a-class-using-reflection-and-cla) 。网友回复道: Since class objects depend on the actual class **AND** on the classloader, they are really different classes。

用 IDEA 断点调试，观察报错点，查看第 4 步入参的 classloader，与 clazz 的 classloader 确实不一样。如果改为传入 moduleClassLoader 加载的类，报错会消失，走到第 5 步；第 5 步会报错: object is not an instance of declaring class

原因不变，还是因为传入的对象，与调用者不属于同一个 classloader，违反了可见性原则。


## 解决方法 {#解决方法}

放弃使用 ModRun ，用自定义的 ClassLoader 替代。在实现这个 ClassLoader 时，要将当前使用的 ClassLoader 设置 parent。这样依据双亲委托机制，这样就满足了可见性原则。可以参考 [IsolatingClassLoader.java](https://github.com/eclipse-vertx/vert.x/blob/master/src/main/java/io/vertx/core/impl/IsolatingClassLoader.java) 。


## Java 类加载机制三大原则 {#java-类加载机制三大原则}

1.  委托原则： 如果一个类还没有被加载，类加载器会委托它的父加载器去加载它
2.  可见性原则: 被父亲类加载器加载的类对于孩子加载器是可见的，但关系相反相反则不可见。
3.  独特性原则: 当一个类加载器加载一个类时，它的孩子加载器绝不会重新加载这个类。


## 参考资料 {#参考资料}

1.  Java 类加载器（ ClassLoader）浅析: <https://blog.csdn.net/BIAOBIAOqi/article/details/6864567>
2.  Class Loaders in Java: <https://www.baeldung.com/java-classloaders>
