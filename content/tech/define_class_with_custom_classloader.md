+++
title = "Java 使用指定 classloader 创建 class"
author = ["yuan.tops@gmail.com"]
description = "一个 Java hack"
lastmod = 2021-01-06T11:11:24+08:00
categories = ["Tech"]
draft = false
keywords = ["java"]
+++

有时需要在程序运行时动态创建 Java 类（加载自定义文件，或者是加载 Javassist 之类字节码增强工具创建出来的字节码等）。要注意的是，不同类加载器加载的类，彼此是不可见的，也就不能直接实例化。

要突破这个限制，需要一点 hack: 利用反射机制，在根据字节码创建类时，指定 classloader。下面的代码从著名的 `jodd` 库摘录，请自行学习。

```java
/**
 * Defines a class from byte array into the specified class loader.
 * Warning: this is a <b>hack</b>!
 * @param className optional class name, may be <code>null</code>
 * @param classData bytecode data
 * @param classLoader classloader that will load class
 */
public static Class defineClass(final String className, final byte[] classData, ClassLoader classLoader) {
    if (classLoader == null) {
        classLoader = Thread.currentThread().getContextClassLoader();
    }
    try {
        final Method defineClassMethod = ClassLoader.class.getDeclaredMethod("defineClass", String.class, byte[].class, int.class, int.class);
        defineClassMethod.setAccessible(true);
        return (Class) defineClassMethod.invoke(classLoader, className, classData, 0, classData.length);
    } catch (Throwable th) {
        throw new RuntimeException("Define class failed: " + className, th);
    }
}
```
