---
layout: post    
category: "Tech"   
title: "开源中国安卓客户端源码学习笔记 二 欢迎界面跳转与渐变效果"      
tags: [Android, OSC]   
description: "本文分析OSC 安卓客户端中界面跳转效果的实现原理。" 
---

OSC客户端启动时会先显示欢迎界面，再跳转到主页，其中跳转过程有渐变效果。  

这里使用了AlphaAnimation类。AlphaAnimation类能实现渐进渐出的效果，官方文档里说“This animation ends up changing the alpha property of a Transformation”。alpha property可以理解为透明度，"0.0"为全透明，“0.5”为半透明，“1.0”时不透明。  

{% highlight java %}

	//渐变展示启动屏
	AlphaAnimation aa = new AlphaAnimation(0.3f,1.0f);
	aa.setDuration(3000);
	view.startAnimation(aa);
	aa.setAnimationListener(new AnimationListener()
	{
		@Override
		public void onAnimationEnd(Animation arg0) {
			redirectTo();
		}
		@Override
		public void onAnimationRepeat(Animation animation) {}
		@Override
		public void onAnimationStart(Animation animation) {}
	});

{% endhighlight %}

另外，欢迎界面的图片可以更新。从代码分析，在将View设置为ContentView之前，程序会检查欢迎界面对应缓存文件夹里的图片文件，图片文件的文件名有一个时间期限，如果今天正好落在这个期限内，那么就将它设为背景图片。如此可以推测APP会在启动后自动下载新的图片文件(如果存在的话)到缓存文件夹，从而达到更新效果。  

果然，在跳转到Main Activity后，在onCreate()方法里调用了checkBackGround()方法。这个方法会新开一个Thread去服务器检查是否有新的图片需要下载，如果有，那么会下载下来。  
