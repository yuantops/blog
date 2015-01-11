---
layout: post    
category: "Tech"   
title: "Byte Streams -- Oracle Java Tutorial 翻译"      
tags: [Java]    
description: "本文是Oracle Java开发手册中关于Byte Stream章节的翻译，个人手工翻译，非转载。"
---

##Byte Streams 字节流
程序使用*字节流*来处理8bit字节的输入和输出。所有的字节流类都派生(descend)自InputStream和OutputStream。  

字节流类有很多。为了演示字节流的工作原理，我们将关注文件的I/O字节流,FileInputStream和FileOutputStream。其它字节流类的使用方法往往与之类似，仅在构造的方法上存在差别。  

###使用字节流
下面我们通过一段代码CopyBytes来演示FileInputStream和FileOutputStream的用法。这段代码通过字节流逐字节地拷贝xanadu.txt。  

{%highlight java%}
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class CopyBytes {
	   public static void main(String[] args) throws IOException {

        FileInputStream in = null;
        FileOutputStream out = null;

        try {
            in = new FileInputStream("xanadu.txt");
            out = new FileOutputStream("outagain.txt");
            int c;

            while ((c = in.read()) != -1) {
                out.write(c);
            }
        } finally {
            if (in != null) {
               in.close();
            }
            if (out != null) {
               out.close();
            }
        }
    }
}
{%endhighlight%}

CopyBytes在运行时形成一个循环:它不断从输入流中逐字节地读入数据，然后将字节输出到输出流。如下图所示。  

![图片链接](http://docs.oracle.com/javase/tutorial/figures/essential/byteStream.gif "Byte Stream")  

###永远记得关闭流
关闭不再使用的流十分重要——以至于你可以看到在CopyBytes中，我们甚至使用finally区块来确保输入流和输出流即使在出现错误的情况下都能被关闭。关闭操作可以避免严重的资源泄露。  

可能出现的错误是CopyBytes无法打开一个或者多个文件。当这样的错误发生时，与这些文件相关的流变量不会改变它们最初的null值。这就是为什么在CopyBytes中，当我们最后调用close函数时要先确认每个流变量所持有的引用对象非空的原因。  

###何时避免使用字节流
CopyBytes看上去是一个很普通的程序，但它实际上是一种你应该避免使用的、低层次的I/O操作方式。因为xanadu.txt中包含了字符数据，所以最适当的方式是使用字符流(character stream)。我们将在下一部分讨论字符流。对于更复杂的数据类型，也有专门的流类来处理它们。字节流只应该用于最原始的I/O操作。  

那为何还要讨论字节流呢？因为所有其它的流类的**基础**都是字节流。  

###原文链接
[Byte Streams](http://docs.oracle.com/javase/tutorial/essential/io/bytestreams.html)

