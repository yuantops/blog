---
layout: post    
category: "Tech"   
title: "REST基础概念笔记"      
description: "REST是什么，框架，协议，还是语言？这篇博客是关于REST的一些基础知识。"
---

**Representational State Transfer(REST)**    
REST is an architecture style or design pattern used as a set of guidelines for creating web services which allow anything connected to a network (web servers, private intranets, smartphones, fitness bands, banking systems, traffic cameras, televisions etc.) to communicate with one another via a shared common communications protocol known as Hypertext Transfer Protocol (HTTP). --[REST Wikipedia](http://en.wikipedia.org/wiki/Representational_state_transfer)     

REST是一种**架构风格**，**设计模式**，因此没有一本语法书规定REST应该这样实现，应该那样实现。它不是一种标准。它是一种风格，具有指导意义，凡是遵循这种风格的设计，都可以称之为"RESTful"。   

REST的常见应用场景是Web服务。在RESTful API的实际实现中，往往遵循一些*约定的*规则：  

- 基于URI，例如http://example.com/resources/   
- 传输的数据格式是JSON。虽然理论上数据格式可以是任意一种(XML,ATOM等)，但往往大家都用JSON。  
- 使用标准HTTP方法，即GET, PUT, POST, DELETE四个动词。  

###例子
[How Simple is REST](http://rest.elkstein.org/2008/02/how-simple-is-rest.html)这篇文章里举了这样一个例子：  

假设这样一个Web服务，它是一个电话本应用，我们要向它查询某个用户的信息。我们只有用户的ID。  

REST风格下，查询看起来这样:   
>http://www.acme.com/phonebook/UserDetails/12345  

不需要在请求中设置额外的body，一条URL就搞定。这条URL以GET方式发送给服务器，返回原始的HTTP数据。返回的数据不嵌套在任何东西里，我们可以直接使用。   

所以，使用REST风格对开发有好处：我们可以用浏览器测试API，哪怕客户端的部分还没完成。  

另外，注意这条URL使用了"UserDetails"，而不是"GetUserDetails"。这是REST设计风格的一个例子：使用*名词*而不是*动词*来表示简单的*资源*。   

###资源的概念
**资源(Resources)**是REST架构中一个非常重要的概念。**逻辑**URL标识着资源。资源同时表示**状态(state)**和**功能(functionality)**。  

- 逻辑URL，意味着这个资源能被系统中的其它部分定位(universally addressable)。  
- 资源是一个RESTful 设计中的核心元素。它不同于"methods"或是"services"。
