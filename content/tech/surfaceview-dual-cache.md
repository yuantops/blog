---
Categories:
- Tech
date: 2015-07-26T00:00:00Z
Description: SurfaceView控件适合内存耗费大、需要频繁刷新的场景，常用于显示游戏、动画、视频等。为提升显示性能，SurfaceView使用了双缓存机制。但我在使用过程中出现了闪屏现象：刷新过程中，正常帧和黑屏交替出现。本文讨论闪屏问题的原因，以及可行的改进方法。
Tags:
- Android
title: Android SurfaceView双缓存机制与闪屏现象分析
---

##理解SurfaceView   
SurfaceView是View的子类，所以View有的特点它都有。但它有特殊之处：它引入了缓存机制，优化了内容刷新的过程，使UI Thread不至于崩溃。更新它的内容，我们要用到与之关联的SurfaceHolder。     

比较特殊的在于SurfaceView的“双缓存”(Double-buffer)机制。更新SurfaceView的常见流程是"lockCanvas-drawCanvas-unlockCanvasAndPost", 如果你遇到SurfaceView闪烁的情况，像鬼片里电视机的那种闪法，那十之八九是栽倒在双缓存的坑里了。Google告诉了我这个问题的答案，希望你能用上。    

##双缓存(Double-buffer)与黑屏闪烁   
以下内容来自[邮件列表的讨论](http://markmail.org/message/mxserqvi37hnajp5)，我对它们进行一点梳理。    

1. 每个SurfaceView 对象有两个独立的graphic buffer，官方SDK将它们称作"front buffer"和"back buffer"。    

2. 常规的"double-buffer"会这么做：每一帧的数据都被绘制到back buffer，然后back buffer的内容被持续翻转(flip)到front buffer；屏幕一直显示front buffer。但Android SurfaceView的"double-buffer"却是这么做的：在buffer A里绘制内容，然后让屏幕显示buffer A; 下一个循环，在buffer B里绘制内容，然后让屏幕显示buffer B; 如此往复。于是，屏幕上显示的内容依次来自buffer A, B, A, B,....这样看来，两个buffer其实没有主从的分别，与其称之为"front buffer""back buffer"，毋宁称之为"buffer A""buffer B"。    

3. Android中"double-buffer"的实现机制，可以很好地解释闪屏现象。在第一个"lockCanvas-drawCanvas-unlockCanvasAndPost"循环中，更新的是buffer A的内容；到下一个"lockCanvas-drawCanvas-unlockCanvasAndPost"循环中，更新的是buffer B的内容。如果buffer A与buffer B中某个buffer内容为空，当屏幕轮流显示它们时，就会出现画面黑屏闪烁现象。  

##解决方法
出现黑屏是因为buffer A与buffer B中一者内容为空，而且为空的一方还被post到了屏幕。于是有两种解决思路：    

1. 不让空buffer出现：每次向一个buffer写完内容并post之后，顺便用这个buffer的内容填充另一个buffer。这样能保证两个buffer的内容是同步的，缺点是做了无用功，耗费性能。   

2. 不post空buffer到屏幕：当准备更新内容时，先判断内容是否为空，只有非空时才启动"lockCanvas-drawCanvas-unlockCanvasAndPost"这个流程。     
