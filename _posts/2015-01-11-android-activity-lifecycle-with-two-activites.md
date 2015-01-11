---
layout: post    
category: "Tech"   
title: "Activity的生命周期以及两个Activity跳转时的状态变化"     
tags: [Android]
description: "Activity有属于自己的生命周期。本文介绍当应用通过intent在两个Activity间跳转时，它们状态的变化。"
---

##Android Activity的生命周期
下面这张图非常清晰地介绍了Activity的生命周期：  
![Activity Lifecycle](http://www.startandroid.ru/images/stories/lessons/L0023/L0023_010_en.jpg)    

##当通过intent跳转时的状态变化
一个Activity的状态有三个：Stopped(存在但看不见)，Paused(部分可见，但无焦点)，Resumed(激活状态，拥有焦点，可以与之交互)。如果将不存在也算作一个状态，那样一共就有四个状态。  

[这篇文章](http://www.startandroid.ru/en/lessons/complete-list/232-lesson-24-activity-lifecycle-example-about-changing-states-with-two-activities.html)非常详细地讨论了当通过intent在一个Activity中启动另一个Activity时，它们两个Activity的状态变化过程。   

**当由MainActivity跳转到ActivityTwo时**，下面是方法的调用顺序：  

        MainActivity: onPause()     
	ActivityTwo: onCreate()     
	ActivityTwo: onStart()     
	ActivityTwo: onResume()     
	MainActivity: onStop()     

步骤为：MainActivity失去焦点，转到Paused状态->ActivityTwo新建但不可见,处于Stopped状态->ActivityTwo可见，处于Paused状态->ActivityTwo获得焦点，处于Resumed状态->MainActivity不可见，处于Stopped状态。   

值得注意的是，当ActivityTwo位于前台时，MainActivity并没有被销毁，而是仍保存在内存中。    

**按下后退键，由ActivityTwo返回MainActivity时**，方法的调用顺序为：  

        ActivityTwo: onPause()     
	MainActivity: onRestart()     
	MainActivity: onStart()     
	MainActivity: onResume()     
	ActivityTwo: onStop()     
	ActivityTwo: onDestroy()   

步骤与上一步类似。值得注意之处有二：    

- 其一，MainActivity.onRestart方法先于MainActivity.onStart方法调用。如果Activity不是从无到有新建出来的，那么在onStart方法前都会先调用onRestart方法。    
- 其二，ActivityTwo被销毁了。至于为什么此时ActivityTwo会被销毁，涉及到Task的原理。在[这篇文章](http://www.startandroid.ru/en/lessons/complete-list/234-lesson-25-task-what-is-it-and-how-it-is-formed.html)中有介绍。
