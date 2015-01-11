---
layout: post    
category: "Tech"   
title: "Character Streams -- Oracle Java Tutorial 翻译"      
tags: [Java]   
description: "本文是Oracle Java开发手册中关于Character Stream章节的翻译，个人手工翻译，非转载。"
---

##Character Streams 字符流
Java平台使用Unicode字符集存储字符值(character value)。字符流I/O自动将内部的Unicode格式翻译成本地的字符集，反之亦然。在西方的使用环境(locale)下，本地字符集往往是8bit的ASCII码的超集(superset)。  

对大多数程序来说，使用字符流的I/O不会比使用字节流的I/O更复杂。与输入和输出相关的流类会自动完成与本地字符集的翻译过程。一个使用字符流而不是字节流的程序，它会自动使用本地字符集，而且它可以完成国际化的过程——不需要程序员付出过多的额外工作。  

如果国际化的需求优先级不高，你尽管以最简单的方式使用字符流类，而不需太关注字符集的问题。如果之后有了国际化的需求，你的程序也可以轻松地予以修改。参见[国际化的章节](http://docs.oracle.com/javase/tutorial/i18n/index.html)了解更多。  

###使用字符流
所有的字符流类都派生自Reader和Writer。与字节流一样，有专为文件I/O而设的字符流类：FileReader和FileWriter。下面的CopyCharacters代码演示了它们的使用方法。

{%highlight java%}
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

public class CopyCharacters {
    public static void main(String[] args) throws IOException {

    FileReader inputStream = null;
    FileWriter outputStream = null;

    try {
        inputStream = new FileReader("xanadu.txt");
        outputStream = new FileWriter("characteroutput.txt");
        int c;
        while ((c = inputStream.read()) != -1) {
            outputStream.write(c);
        }
    } finally {
        if (inputStream != null) {
           inputStream.close();
        }
        if (outputStream != null) {
           outputStream.close();
        }
   }
  }
}
{%endhighlight %}

CopyCharacters和CopyBytes很相似。它们之间最大的不同在于CopyCharacters使用FileReader和FileWriter来完成输入和输出，CopyBytes使用FileInputStream和FileOutputStream。值得注意的是，CopyCharacters和CopyBytes都使用了一个int变量来暂存读入/写出的值。在CopyCharacters中这个int变量在它的后16bit中暂存一个字符值(character value),然而在CopyBytes中这个int变量在它的后8bit中暂存一个字节值(byte value)。  

###使用字节流的字符流
字符流往往是字节流的"包装"(wrapper)。字符流利用字节流完成物理I/O操作，同时字符流完成字符和字节之间的翻译。举例来说，FileReader使用FileInputStream，FileWriter使用FileOutputStream。  

起到字节-字符之间“桥梁”(bridge)作用的通用类有两个：InputStreamReader和OutputStreamWriter。在没有已经封装好的字符流包能满足你的操作需求时，你可以用它们创建字符流。[socket lesson](http://docs.oracle.com/javase/tutorial/networking/sockets/readingWriting.html)和[network trial](http://docs.oracle.com/javase/tutorial/networking/index.html)中会介绍如何从socket相关类提供的字节流中创建字符流。  

###行导向的I/O
字符I/O操作的往往不是单个字符，而是更大的单元。最常见的单元是行：以行终止符结尾的一个字符串。行终止符可以是回车(carrige-return)/新行(line-feed)的字符组合("\r\n")，可以是单个的回车符号("\r")，也可以是单个的新行符号("\n")。兼容所有可能存在的行终止符，这样会使程序能读取在任何流行的操作系统上创建的文本。  

让我们对CopyCharacters稍作修改，使其变为基于行的I/O。我们会使用之前没使用的两个类：BufferedReader和PrintWriter。我们将在[Buffered I/O](http://docs.oracle.com/javase/tutorial/essential/io/buffers.html)和[FormaFormattingtting](http://docs.oracle.com/javase/tutorial/essential/io/formatting.html)这两个章节中详细讨论这两个类。  

下文的CopyLines程序会调用BufferedReader.readLine和PrintWriter.println来完成每次输入/输出一行的操作。  

{%highlight java%}
import java.io.FileReader;
import java.io.FileWriter;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.IOException;

public class CopyLines {
    public static void main(String[] args) throws IOException {

        BufferedReader inputStream = null;
        PrintWriter outputStream = null;

        try {
			inputStream = new BufferedReader(new FileReader("xanadu.txt"));
			outputStream = new PrintWriter(new FileWriter("characteroutput.txt"));
			String l;
			while ((l = inputStream.readLine()) != null) {
				outputStream.println(l);
			}
		} finally {
			if (inputStream != null) {
			inputStream.close();
		}
		if (outputStream != null) {
			outputStream.close();
		}
		}
	}
}
{%endhighlight%}

调用readLine会返回文本中的一行。CopyLines使用println输出每一行，println函数会在每一行末尾添上当前操作系统的行终止符，再打印出来。这样的话，最后打印出来的行所使用的行终止符不一定与输入文件中的行终止符相同。  

###原文链接
[Character Streams](http://docs.oracle.com/javase/tutorial/essential/io/charstreams.html)

