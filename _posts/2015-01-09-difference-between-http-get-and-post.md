---
layout: post    
category: "Tech"   
title: "HTTP Methods: GET vs. POST"      
tags: [HTTP]
description: "HTTP协议中最常用的两个method是GET和POST，它们俩经常被弄混。本文翻译W3Schools上面一篇文章，介绍并比较它们二者。"   
---

##HTTP是什么？  
超文本传输协议(The Hypertext Transfer Protocol, HTTP)是为客户端(client)与服务器(server)之间的通信(communication)设计的。  

HTTP是在客户端与服务器之间以请求-响应(request-response)方式工作的协议。   

客户端可以是一个网页浏览器，服务器可以是一台提供web服务的主机上的某个应用程序。  

例如：一个客户端(浏览器)向服务器提交了HTTP请求；服务器接着向客户端返回响应。响应中包含了请求的状态信息，同时可能包含所请求的资源。  

##最常用的两种HTTP请求方式：GET和POST
- **GET**: 向某个指定的资源申请数据  
- **POST**: 向某个指定的资源提交需要处理的数据  

##GET方式
**注意，GET请求的查询字符串(name/value对)是包含在URL中发送的**  
{%highlight html %}
/test/demo_form.asp?name1=value1&name2=value2
{%endhighlight %}

**关于GET还需注意：**  

+  GET请求能被缓存   
+  GET请求保存在浏览器的历史记录中  
+  GET请求能被当作书签添加
+  GET请求永远**不应用在**处理敏感数据的场合  
+  GET请求有长度限制  
+  GET请求只应该用来获取数据  

##POST方式
**注意，POST请求的查询字符串(name/value对)是包含在HTTP消息体中发送的**   
{%highlight html %}
POST /test/demo_form.asp HTTP/1.1
Host: w3schools.com
name1=value1&name2=value2
{%endhighlight %}

**关于POST还需注意：**  

- POST请求不能被缓存  
- POST请求不保存在浏览器的历史记录中  
- POST请求不能被添作标签  
- POST请求没有长度限制  

##GET与POST对比

<table>
  <thead>
    <tr>
      <th></th>
      <th>GET</th>
      <th>POST</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>返回/刷新按钮</td>
      <td>无影响</td>
      <td>数据会被再次提交(浏览器应该会警示用户这一点)</td>
    </tr>
    <tr>
      <td>书签</td>
      <td>能被添作书签</td>
      <td>不能被添作书签</td>
    </tr>
    <tr>
      <td>缓存</td>
      <td>能被缓存</td>
      <td>不能缓存</td>
    </tr>
    <tr>
      <td>编码方式</td>
      <td>application/x-www-form-urlencoded</td>
      <td>application/x-www-form-urlencoded或者multipart/form-data。</td>
    </tr>
    <tr>
      <td>历史记录</td>
      <td>参数保存在浏览器记录中</td>
      <td>参数不保存</td>
    </tr>
    <tr>
      <td>数据长度限制</td>
      <td>在传输数据时，GET方式会将数据添加到URL中，而URL的最大长度是2048个字符。</td>
      <td>无限制</td>
    </tr>
    <tr>
      <td>数据类型限制</td>
      <td>只允许ASCII字符</td>
      <td>无限制。二进制数据也是合法的。</td>
    </tr>
    <tr>
      <td>安全</td>
      <td>与POST相比，更不安全，因为GET方式数据是URL的一部分。永远不要用GET来发送密码之类的敏感信息！</td>
      <td>相对GET更安全一点，因为数据不会存储在浏览器历史记录或者服务器日志中。</td>
    </tr>
    <tr>
      <td>可见性</td>
      <td>每个人都能看见URL中的数据</td>
      <td>数据不在URL中显示</td>
    </tr>
  </tbody>
</table>

##原文链接
[HTTP Methods: GET vs. POST](http://www.w3schools.com/tags/ref_httpmethods.asp)
