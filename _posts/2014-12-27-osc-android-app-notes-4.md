---
layout: post    
category: "Tech"   
title: "OSC Android源码学习笔记 四 listview初始化、获取数据、加载数据的流程"      
tags: [Android, OSC]    
description: "OSC Android App从服务器获取数据，解析数据，再加载到ListView中。本文粗略分析其中的流程，及实现方法。"
---

OSC App显示的信息分为资讯(news)，博客(blog)，问答(Question)，动弹(tweet)几屏，每屏对应一个ListView。以资讯(news)为例，粗略看一下它的ListView是如何初始化、获取数据、加载数据的。  

1. 实例化一个ListViewNewsApapter并添加到lvNews：  
{% highlight java %}
lvNewsAdapter = new ListViewNewsAdapter(this, lvNewsData, R.layout.news_listitem);
{% endhighlight %}
ListViewNewsApapter这个类继承BaseAdapter，重写了getView()方法。值得注意的是，getView()方法中news实体被被作为Tag添加到了listView的ItemView中。  

为lvNews设置lvNewsAdapter。lvNews和lvNewsAdapter都是Main这个类持有的变量，而不是某个函数的局部变量。  

2. 为lvNews设置OnClickListener，这个Listener以匿名内部类方式初始化：
当点击单个item view时，从view中取出news这个Tag，然后使用UIHelper.showNewsRedirect()方法跳转到新闻阅读详情页。  

3. 实例化一个lvNewsHandler：  
{% highlight java %}
lvNewsHandler = this.getLvHandler(lvNews, lvNewsAdapter, lvNews_foot_more, lvNews_foot_progress, AppContext.PAGE_SIZE);
{% endhighlight %}

这个Handler定义了当接收到有数据更新的通知时，应该作何处理。主要是通知adapter数据发生了变化：   
{% highlight java %}
adapter.notifyDataSetChanged();
{% endhighlight %}

4. 下载数据，加载数据：  
{% highlight java %}
loadLvNewsData(curNewsCatalog, 0, lvNewsHandler, UIHelper.LISTVIEW_ACTION_INIT);
{% endhighlight %}
新开进程，调用appContext.getNewList()从服务器获取数据。数据获取完成后，通过传入的lvNewsHandler发送Message，回调handleMessage(Message msg)方法。  


