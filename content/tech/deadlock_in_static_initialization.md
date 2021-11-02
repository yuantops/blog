+++
title = "偶遇 static 初始化死锁"
author = ["yuan.tops@gmail.com"]
description = "死锁有很多，在类初始化流程遭遇死锁比较少见。这里提供一份示例代码，恰好复现这种死锁。"
lastmod = 2021-11-02T09:31:32+08:00
categories = ["Tech"]
draft = false
keywords = ["java", "deadlock"]
+++

最近开发新系统，用到了内存数据库 H2 web . 上线时，遇到问题：服务启动流程卡住，不报错，也起不来。

用 \`jstack\` 查看栈信息，main thread 状态为 RUNNABLE，另外一个线程 \`H2 Console Server\` 状态也为 RUNNABLE。仔细观察， `main` 栈包含一段可疑信息: `-locked <xxxx> (a java.lang.Class for org.h2.Driver)` ，疑似线程被锁。

有两个诡异之处：1. 服务启动阻塞具有偶然性，有的机器（特别是性能比较差的机器）大概率不会卡。2. 虽然阻塞了，但此时 h2 数据库 web console 已经成功起来了。WHY??

作为应急措施，在启动 H2 web 之后，立马让当前线程停一会儿(`Thread.sleep(500)`)，服务顺利启动。接下来，是我慢慢和它死磕的过程。


## 调试 {#调试}

单步调试法 + 日志大法。

调试小技巧：如果类在依赖的 jar 里，又想在这个类里打日志，只需按它的包结构在 IDE 里对应建立目录层级，再把源码拷贝进去就好了。

最后发现了问题：在类静态方法加载过程中，形成了死锁。

下面是摘出来的问题代码:


## 问题代码 {#问题代码}

{{< highlight java "linenos=table, linenostart=1" >}}
import org.h2.Driver;
import org.h2.tools.Server;

import java.sql.SQLException;

public class Main {
    public static void main(String[] args1) throws InterruptedException {

        int port = 9081;
        Server webServer = null;
        String[] args = ("-web,-webAllowOthers,-trace,-webPort," + port).split(",");
        try {
            webServer = org.h2.tools.Server.createWebServer(args);
            webServer.start();
        } catch (SQLException e) {
            String msg = "h2 web server create failed";
            throw new IllegalStateException(msg, e);
        }

        System.out.println("["+Thread.currentThread().toString()+"]尝试加载 driver " + System.currentTimeMillis());
        Thread.sleep(32);
        Driver driver = new Driver();

        System.out.println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!看到我，说明死锁重现失败。多试几次！！！！！！！！！！！！");
    }
}
{{< /highlight >}}


## 死锁分析 {#死锁分析}

1.  main() 方法运行的线程，为 [main] 线程。
2.  执行到第 14 行，执行 webServer.start() 方法后，第二个线程 [H2 Console Thread] 将被启动(通过单步追踪，可以定位具体代码)。具体流程为:
    2.1. 创建 ServerSocket, 开始监听服务端端口
    2.2. 新建名为[H2 Console Thread] 的线程，每当服务端口读到了数据，则
    2.3. 新分配一个线程，处理数据流。

3.  在 2.1 ，为了确认 ServerSocket 成功建立，会尝试与服务端口号建立一个 socket，一旦成功，则认为服务端口已经起来, 并关闭 socket。

4.  2.3 中创建的新线程，读到一个空白文件流，抛出 EOF 异常。在异常处理类 `DbException.java` 中，会加载 DriverManager.java (详见代码)。进入 static {} 后，持有了锁B。同时在 static 方法中，它通过 ServiceLoader 尝试加载所有 Driver，这意味着，它要等待 Driver.java 初始化的锁(锁A)

5.  main 线程中，在故意等待了一小段时间(第21行)后，main() 方法继续执行。在第 22 行创建 driver 实例的过程中，进入static {} 方法，持有了 Driver.java 的锁(锁A)。同时，在 static {} 中，尝试 load DriverManager.java，需要等待 DriverManager.java 的锁(锁B)

6.  两个线程，彼此等待对方持有的锁。也就形成了死锁。


## 自问自答: 初始化存在锁?? {#自问自答-初始化存在锁}

参考回答: <https://stackoverflow.com/questions/878577/are-java-static-initializers-thread-safe>

静态代码块 static {} 是线程安全的，同时只能在一个线程中运行。

以及回答：<https://stackoverflow.com/questions/55204559/what-happens-when-multiple-threads-ask-for-the-same-class-to-be-loaded-at-same-t>

类的初始化，确实存在锁。


## 自问自答: 为什么 `Thread.sleep(500)` 有用? {#自问自答-为什么-thread-dot-sleep--500--有用}

死锁的本质在资源争抢。加上 Java 类加载存在缓存机制，只要让一个线程先执行完，就破解了锁。


## 他山之玉 {#他山之玉}

另外，搜到一篇类似博文，都是由 `DriverManager` 在多个线程被初始化形成锁: [Avoiding deadlock when using Multiple JDBC Drivers in an Application](https://medium.com/@priyaaggarwal24/avoiding-deadlock-when-using-multiple-jdbc-drivers-in-an-application-ce0b9464ecdf)。
