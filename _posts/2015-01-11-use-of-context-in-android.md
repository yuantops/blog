---
layout: post    
category: "Tech"   
title: "Android中Context的作用"     
tags: [Android]
description: "Android中Context是十分重要的一个类，它继承自java.lang.Object，几乎在所有代码中都会用到。本文参考其它资料，对Context的常用用法做一个总结。"
---

##官方文档中对Context的介绍
>Interface to global information about an application environment. This is an abstract class whose implementation is provided by the Android system. It allows access to application-specific resources and classes, as well as up-calls for application-level operations such as launching activities, broadcasting and receiving intents, etc.   

翻译：   
Context是Android应用的全局信息的接口。它是一个虚类，它的实现由Android系统完成。它提供了对某个应用的资源和类的访问权限，也提供对应用层面操作(如启动Activity，发送broadcast，接受intent)的调用接口。  

##总结
[StackoverFlow.com](http://stackoverflow.com/questions/3572463/what-is-context-in-android)上有人根据自己的理解总结了Context的用法，说得很有道理，以下是我的翻译。  

正如Context的名字所说，它是一个应用/对象(applicaton/object)当前状态的上下文。它让新建的对象知道当前正在发生着什么。典型的用法，你可以调用它来得到关于你程序其它部分(Activity，package/application等)的信息。    

你可以通过以下方式得到context: getApplicationContext(), getContext(), getBaseContext()或者this(当位于一个Activity class中时)。   

典型用法：  

- **新建对象**：新建views, adapters, listeners等：    
        TextView tv = new TextView(getContext());
	ListAdapter adapter = new SimpleCursorAdapter(getApplicationContext(), ...);   

- **访问资源**：譬如LAYOUT_INFLATER\_SERVICE, SharedPreferences一类的资源：   
        context.getSystemService(LAYOUT_INFLATER_SERVICE)   
        getApplicationContext().getSharedPreferences(*name*, *mode*);	

- **隐式访问组件**：content providers, broadcast, intent 等：   
        getApplicationContext().getContentResolver().query(uri, ...);    


