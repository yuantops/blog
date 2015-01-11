---
layout: post    
category: "Tech"   
title: "[转载]Android Intent原理分析"     
tags: [Android]
description: "Android中intent用来定义操作，在启动Activity等场合有极为重要的作用。有很多文章介绍intent的用法，介绍其中原理的文章就很少了。本文转载一篇介绍Intent原理的博客，并附上自己的分析。"
---

##原文链接
[Android Intent原理分析](http://blog.chinaunix.net/uid-741742-id-359319.html)

##转载原文正文
Revision History

wylhistory

1.    Abstract    
2.    Introduction    
3.    Intent的架构   
4.    Intent的发送过程   
4.1      Intent消息在发送进程的逻辑   
4.2      Intent发送在服务器端的执行   
4.2.1       进入消息队列之前   
4.2.2       进入消息队列后的处理   
4.2.3       消息的分发过程    
4.2.4       deliverToRegisteredReceiver的逻辑   
4.2.5       processCurBroadcastLocked的逻辑   
4.2.6       startProcessLocked的逻辑   
5.    Intent的接收过程   
5.1      Receiver的注册   
5.2      scheduleReceiver   
5.3      scheduleRegisteredReceiver的逻辑   
7.    未分析   

1. Abstract   

主要是分析一下android的IPC通讯之Intent；   


2. Introduction

任何一个操作系统，都有自己的IPC通讯机制，Android也不例外；    
IPC通讯在linux下面通常包括共享内存，管道，消息队列等，这其中共享内存的效率比较高，我想；     
这里将要说的Intent的通讯机制是基于Binder的，而Binder的机制本质上是共享内存；    
Intent中文翻译为：n.意图，意向，目的 a.专心的；急切的；没有一个特别适合，所以我还是决定用英文；    
它的作用，我想就是传达一些信息各特定的对象，或者广播一些信息各某些对象；这里涉及两方面的内容：    
A） 消息的发送；     
B） 消息的接收；     

后面就会具体的展开；

讨论之前先看一个简单的例子：
Intent intent = new Intent(AudioManager.ACTION_AUDIO_BECOMING_NOISY);    
mContext.sendBroadcast(intent);    

这是摘自HeadsetObserver.java的代码；   
后面将会以此为例，分析发送和接收的过程；     

3. Intent的架构

Intent的架构包括三方面：   
Client，也就是发送这个Intent的activity；     
Server，也就是activityManagerService.java,它主要是负责分发这些Intent给适当的对象；      
Target，也就是那些需要处理这个Intent的activity，我们称为Receiver；       

需要大致的了解一下，Intent通常有哪些部分？我们常用的包括三方面：       
A）    action，就是这个intent是想达到什么目的，比如是想打电话，还是想告诉我们电池电量低？      
B）      数据，也就是这个intent要处理的是这些数据，如果你是receiver的话，你需要考虑，你是否需要处理这个intent，这里包括数据的URI，以及数据的类型；      
C）      Category，这个就是需要处理这个Intent的activity的种类，这个种类是比较难以理解的，我想Google的本意是想区分一下不同的Activity的种类，比如对于CATEGORY_LAUNCHER，这个就表示它是一个启动器，有些消息只需要由特定类型的activity来处理；      

当然还有其它的一些属性，但是我们经常遇到的就是这三个，而这三个里面最常用的是Action；      
这些项的作用，主要是被activityManagerService用来挑选适当的Activity来处理这个Intent；      
好了，太多的概念，让人有点头晕，后面会再详细的讲；      

4. Intent的发送过程      

4.1 Intent消息在发送进程的逻辑    

回到我们先前的那个例子：    

Intent intent = new Intent(AudioManager.ACTION_AUDIO_BECOMING_NOISY);     
mContext.sendBroadcast(intent);     

第一句话是构造一个Intent，注意只传入了一个参数，这个参数就是一个Action，没有指定data以及Category；也就是说如果某个Receiver写成这样（在AndroidManifext.xml里面）：     

<receiver android:name="MediaButtonIntentReceiver">
          <intent-filter>
	           <action android:name="android.media.AUDIO_BECOMING_NOISY" />
	 </intent-filter>				      
</receiver>     

这个receiver的onReceive函数将会被调用，其中receiver表示处理这个Intent消息的类，而intent-filter表示这个receiver关心哪些Intent，这里写明了，我只关心，action == android.media.AUDIO_BECOMING_NOISY的Intent，如果是其它的Intent请别来烦我；     

第二句话的目的就是把这个消息广播出去，谁关心谁处理去，从此和我没关系了；   
我可以很负责任的说，这个mContext的类型为ApplicationContext，在Android的代码里，这样命名的变量多半是这个类型，所以后面的逻辑就简单描述为：    
Android的代码很多都这样，一层层的调用，很多时候都是二传手，这是模块化设计需要付出的代价，不过，值得；    

对于分析来说，需要理清楚这个调用到底去了什么地方？    

代码在ActivityManagerNative.java里面：    
这是一个典型的Binder调用，从此以后代码的执行进入了另外一个进程；

4.2  Intent发送在服务器端的执行    
4.2.1 进入消息队列之前    
这个图的逻辑是由ActivityManagerService.java来执行的，基本上也没什么意思；    
重要的是最后调用的这个函数broadcastIntentLocked，基本上主要的工作都是由它来完成的；    
这个函数非常重要，需要详细分析：     
1，首先是进行一些权限检查，保证非串行的Intent其resultTo receiver必须是null;     
2，如果这个Intent是说某个包被删除了或者改变了，那么当前的历史栈里面的属于这个包的activity就必须被关掉；     
3，如果是时区改变的消息，那么将会先被放进队列里面通知当前正在运行的进程；     
4，权限检查，判断是否有权限发送受保护的Intent，对于SYSTEM_UID，PHONE_UID，SHELL_UID，或者callingUid == 0的情况不做检查，也就是说默认这些调用者有这个发送的权限；    
5，对于sticky类型的Intent做一些特殊处理（关于sticky类型等概念后面会讲），简单就是把这个Intent加入到mStickyBroadcasts链表中去；    
6，判断这个Intent是有一个明确的对象，如果是那么直接把它的对象加入到receivers列表中去，如果不是，那么会继续判断是不是这个Intent在发送的时候设置了FLAG_RECEIVER_REGISTERED_ONLY标志，如果是，那么这个Intent将只发送给已经注册的Receiver，不会发送给Broadcast receiver,否则就发送给所有的那些满足条件的receivers；这里就涉及Intent的匹配原则，主要是通过函数queryIntent(Intent intent, String resolvedType, boolean defaultOnly)来匹配的，原则就是我前面说的，根据Action，data type，category等来匹配，记住，每条规则之间的关系是或的关系，比如：   
<receiver android:name="MediaButtonIntentReceiver">
	<intent-filter>
		<action android:name="android.intent.action.MEDIA_BUTTON" />
		<action android:name="android.media.AUDIO_BECOMING_NOISY" />
	</intent-filter>
 </receiver>         

就表示只要匹配到其中一条就算成功；另外，对于没有写明的匹配规则默认就算成功，比如对于此规则，没有写明数据类型，种类等，那么默认所有的数据类型都可以匹配上；    

7，如果是registeredReceivers不为空并且这个Intent不是串行的，也就是上一步已经取出了对应的接收者，那么就需要把这个Intent封装成一个BroadcastRecord，然后加入到mParallelBroadcasts，这个称为并行广播，也就是说可以同时发送给多个接收者，再通过scheduleBroadcastsLocked触发真正的发送；     
8，过滤一种特殊情况，也就是对于ACTION_PACKAGE_ADDED消息，这个被安装的包本身不能作为这个消息的接收者；     
9，然后对registeredReceivers和receivers做一个合并，如果这两个都不为空的话，记住，合并前这个receivers标识了“具有固定对象的接收者或者是当前已经注册的接收者不包括广播接收者”，而registeredReceivers表示broadcast Filter，另外这步能合并的前提是这个Intent是串行的Intent，否则是不会合并的；    
10，  合并以后receivers表示所有的串行receivers通过mOrderedBroadcasts.add(r)加入到列表中去，再通过scheduleBroadcastsLocked触发真正的发送；     

OK，这个函数基本上就结束了，这里有三个概念需要解释，串行,并行，sticky的BroadCast；      
串行：就表示这个Intent必须一个一个的发送给接收者；     
并行：表示这个Intent可以同时发送给多个接收者，通常广播的消息都是并行的；      
Sticky：这个类型的BroadCast比较难以理解，问了google也没有答案，我个人的理解是这样的，某些Intent需要被保留，当新的应用起来后，需要关注这个消息，但是呢，又不需要启动这个应用来接收此消息，比如耳机插入等消息，这里说实话，真的很巧妙，我们以前在maemo上碰到过这个问题，当时我们的策略是应用起来的时候自己查询耳机的状态，这里的处理明显就高明许多；     

总结一下这个函数：它的主要作用是根据这个Intent的特点，构造BroadCastRecord加入到不同的列表，等待被处理；       

OK，控制到了scheduleBroadcastsLocked这里，它的逻辑很简单：    
private final void scheduleBroadcastsLocked() {
 if (mBroadcastsScheduled) {
return;
mHandler.sendEmptyMessage(BROADCAST_INTENT_MSG);
mBroadcastsScheduled = true;
先判断mBroadcastsScheduled是否为真，如果为真就直接返回,这个变量主要是实现scheduleBroadcastsLocked和processNextBroadcast之间的顺序执行，后面会看到在processNextBroadcast函数里面会把它设置为false；     
下面就是通过BROADCAST_INTENT_MSG消息放入到消息队列里面，从这个角度来说Intent最后也是通过线程本身的消息队列来实现Intent的分发的；     

4.2.2 进入消息队列后的处理    
上面有提到会通过mHandler.sendEmptyMessage(BROADCAST_INTENT_MSG)，把这个消息传递给mHandler，下面看看这个逻辑是如何实现的；    
到这里消息就是按照时间顺序进入了mQueue了；    
我们再看看一个activity的thread是如何进入主循环的：    
首先是通过prepareMainLooper建立基本的数据结构，包括mQueue以及mThread,mMainLooper;    
并把当前的这个Looper放入到线程独有的变量中；    
其次是通过Looper.loop进入到主循环，逻辑如下：    
首先是取出当前进入主循环的Looper，然后取出这个looper所拥有的mQueue，接下来就开始处理这个队列里面的消息了；    
根据处理方式分两种消息，一种是消息的处理由一个线程来完成，一种是消息的处理时由一个函数来完成；     
后者的话也分两种，一种是handler创建的时候提供了callback，这种情况非常少见；另外一种是通过handleMessage的方式来处理，通常我们在创建handler的时候都会提供这样一个函数，于是消息就可以被处理了；    
					                     
注意，最左边的分支我们还没有讨论，后面会遇到；    

我们先看看这个handleMessage对于BROADCAST_INTENT_MSG的处理：     
这是最重要的函数，如果说broadcastIntentLocked是负责把Intent转化为BroadCast的话放入不同的队列，那么这个函数主要就是负责分发了，当然也涉及一点接收的流程；      

4.2.3 消息的分发过程     

下面分析函数private final void processNextBroadcast(boolean fromMsg)；      
1，先判断fromMsg,如果是通过消息发送过来的就为真，否则为假，如果为真mBroadcastsScheduled = false，这样的话在函数scheduleBroadcastsLocked里面就可以再次发送BROADCAST_INTENT_MSG的消息从而触发processNextBroadcast函数被再次调用；     
2，先判断mParallelBroadcasts是否为空，不为空就开始调用这个列表里面的receivers来接收消息，这个过程后面在串行intent的时候也会碰到，我们留到后面讨论，这里只需要知道它通过一个while循环把Intent发送给关注这个Intent的所有的receivers；     
3，再判断mPendingBroadcast是否为空，如果不为空，就表示先前发送的串行的Intent还没有处理完毕，一般出现这种可能是因为我们要发送到的receiver还没有启动，所以需要先启动这个activity，然后等待起来的这个activity处理，这时候，这个mPendingBroadcast就为true；如果发送这种情况需要判断这个Activity是否死了，如果死了，那么就把mPendingBroadcast设为false，否则就直接返回，继续等待；    
4，接下来就顺序的从mOrderedBroadcasts里面取出BroadCastRecord消息，然后对这个消息的receiver一个一个的调用其接收流程，注意这里要把这个BroadCast的所有的receivers串行发送，都发送完了，才会进入到下一个BroadCastRecord消息；对于这个消息的处理，先判断其接收者是不是BroadFilter，如果是，就调用deliverToRegisteredReceiver来接收，它的处理流程和前面的处理并行BroadCast一样，所以留到后面讲；     
5，如果不是BroadCast Filter，就需要找出这个reiver所在的进程，这时候通常就是一个IntentFilter所在的进程，如果这个进程活着，那么就调用processCurBroadcastLocked(r, app)来处理，否则      
6，需要先启动这个进程，这就是startProcessLocked做的事情，然后设置mPendingBroadcast = r，这样等应用起来它会处理这个消息，后面会有进一步的说明；   

到这里这个函数就结束了，比较复杂，里面还有一些安全的检查等等，上面遗留了三个问题：      
A）deliverToRegisteredReceiver的处理流程；     
B）processCurBroadcastLocked的处理流程；     
C）startProcessLocked以后的进程如何处理这个唤醒它的Intent；    

4.2.4 deliverToRegisteredReceiver的逻辑      
这里也分为这个receiver是否启动，如果已经启动就通过binder调用到了接收 activity的进程里面了，右边的分支performReceive也会调用到activityThread这边，留到接收过程再看；    

4.2.5 processCurBroadcastLocked的逻辑     
可以看到它和deliverToRegisteredReceive的最终差别，只在于一个调用的是ScheduleRegisterdReceiver,一个是scheduleReceiver，这两个函数最后都会进入到目标activity的线程；     

4.2.6 startProcessLocked的逻辑    
从这里可以看出最后通过Process.start启动了ActivityThread.java的进程，我们看看这个线程启动后的执行逻辑：     
首先是在进入主循环之前调用attachApplication通过binder调用进入到activityManagerService.java的进程；    
这个服务器进程在把我们先前设置的mPendingBroadcast设置为null，表示这个pending的broadcat已经得到处理了，然后调用processCurBroadcastLocked来处理这个broadcast消息，最后通过app.thread.scheduleReceiver进入到目标线程的接收流程；     
OK,到这里的话所有的发送分发流程已经结束了，剩下的就是两个接收函数还没有讨论一个就是ScheduleRegisterdReceiver,一个是scheduleReceiver；    

5.  Intent的接收过程    

5.1  Receiver的注册   

Receiver的注册一般分为动态注册和静态注册，动态注册就是通过API registerReceiver来注册，静态的一般就是写在AndroidManifest.xml,比如我们在前面已经看到的：    

<receiver android:name="MediaButtonIntentReceiver">
<intent-filter>
<action android:name="android.intent.action.MEDIA_BUTTON" />
<action android:name="android.media.AUDIO_BECOMING_NOISY" />
</intent-filter>
</receiver>

至于它的原理以后在分析packageManger的时候再分析；    
下面重点来看看这个动态注册的逻辑：    

这两条路径都可能被走到，如果不在ApplicationContent环境里面就需要通过context.registerReceiver来注册了，经过几层传递会通过registerReceiverInternal进入主题；    

这个图看起来复杂，其实很简单，就是构造receiver放入到列表中去，只是中间又经历了Binder，这些receiver也就是我们先前在发送的过程中看到的那些receiver，当然它们能进入到broadcast的列表还要看发送的intent是否满足它们给自的filter；    

好，现在可以看看我们在发送阶段遗留的两个函数：    

scheduleReceiver    
scheduleRegisteredReceiver；    

5.2  scheduleReceiver    

它的入口通常是Binder的分发函数，如下：    

右下方的这个函数scheduleReceiver才会真正调用到ActivityThread.java，这个就是目标activity的母体；   

前面两个就是封装参数，最后放入到消息队列中，等待主循环的处理，这段逻辑我们前面已经看到了，就不再细说，总之会调用到handlemessage函数；  

在收到这个消息的时候通过handleReceiver来处理；     

这又是一个非常重要的函数，需要详细分析：     

1，取得这个Intent指向的component，包括包名，类名；    

2，取得包信息，这个结构提供了getClassLoader接口；    

3，通过java.lang.ClassLoader cl = packageInfo.getClassLoader取得classLoader；    

4，动态创建一个receiver，receiver = (BroadcastReceiver)cl.loadClass(component).newInstance()；    

5，调用receiver.onReceive(context.getReceiverRestrictedContext(), data.intent)，进入到真正的处理流程中去了；    

6，调用finishReceiver来触发ActivityManagerService这个消息到其它receivers的发送或者下一个broadcast的发送；    

这其中最重要的就是这个onReceive函数，我们通常都会实现这么一个函数，然后在里面处理我们收到的消息；    

5.3             scheduleRegisteredReceiver的逻辑    

入口还是Binder得分发函数，如下：    

这种处理在Android的代码里面随处可见，都是在native文件里面通过onTransact分发调用service文件里面的同名函数来完成真正的功能；     

逻辑如下：     

也就是说，这里把参数打包放入到args里面去，然后通过post放入到消息队列里面等待处理，后面的逻辑和一个消息的发送很相似，如下：    

这里需要关注两个点，    

一个就是m.callback=r,这个赋值会导致后面在分发消息的时候走不同的路径；    

Msg.target=this,表示将来分发的时候谁来处理这个消息，如果设置为null将会导致主循环退出；    

分发的逻辑前面我们有介绍就是dispatchMessage的时候，我们再看看这段代码：    

public void dispatchMessage(Message msg) {    

if (msg.callback != null) {

handleCallback(msg);

} else {

if (mCallback != null) {

if (mCallback.handleMessage(msg)) {

return;

handleMessage(msg);

这里就是需要先判断msg.callback是否为null，前面我们已经看到赋值了，所以这里不为null；    

于是调用handleCallback,如下：    

private final void handleCallback(Message message) {    

message.callback.run();    

这个callback我们也看到了其实就是我们封装的Args的args，原型为：    

class Args implements Runnable，    

也就是说它是一个类似线程的对象，它的run函数代码有点多，所以画了个图：    

基本上这个逻辑就和我们之前看到的逻辑一致了，会调用receiver提供的onReceive函数来处理，这个onReceive函数是需要我们自己提供的，里面一般的逻辑都是根据不同的消息做不同的处理；    

最后就是通过finishReceiver来触发ActivityManagerService对Intent的其它receivers的发送；    

需要总结一下，    

Intent从使用的角度来说，就是构造Intent，提供适当的参数，比如Action，比如数据类型，数据的uri等，然后发送出去；接收方需要注册一个receiver，然后提供onReceive函数就可以了；这个注册可以简单的写在AndroidManifest.xml里面也可以通过registerReceiver来完成；    

发送的时候有三个API可以用：    

sendBroadcast    

sendStickyBroadcast    

sendOrderedBroadcast    

第一个用于发送并行广播；    

第二个用于发送粘性广播；    

第三个用于发送串行广播；    

从原理的角度来说，本质上都是通过共享内存把信息传递给ActivityManagerService，它查询已经注册的那些receiver的过滤器，看是否和这个Intent匹配，如果匹配成功就加入到这个Intent的receiver列表中去，当然要根据这个Intent的参数决定加入到并行，串行，还是sticky的列表中，再通过Message传递，到主循环的下一轮来分发；这时候控制已经到了另外一个进程，然后分发好以后再调用目标线程的处理函数，所以基本上就是涉及三个进程，源——>server——>receiver；当然，源和目的可以是同一个进程；    

另外这里需要处理一种情况，就是这个消息发送的时候，目标线程还没有创建，比如我们系统里面的校准程序，需要在第一次开机的时候执行，那么就需要捕捉一个广播消息，比如：    

<receiver android:name="StartupIntentReceiver" >

<intent-filter>

<action android:name="android.intent.action.BOOT_COMPLETED" />

<category android:name="android.intent.category.HOME" />

</intent-filter>

</receiver>

这个消息的意思就是说启动已经完毕了；    

处理这个消息的类是StartupIntentReceiver,首先包含这个receiver的主activity将会被执行，然后再执行这个接收类的onReceive来接收消息并处理，所谓主activity是这样的：    
	<activity android:name=".CalibrationTest"

android:label="Calibration Test"

android:theme="@android:style/Theme.Black.NoTitleBar.Fullscreen"

android:configChanges="keyboard|keyboardHidden|navigation|orientation">

<intent-filter>

<action android:name="android.intent.action.MAIN" />

<category android:name="android.intent.category.LAUNCHER" />

</intent-filter>

</activity>

就是activity filter里面包含ACTION android.intent.action.MAIN,种类包含android.intent.category.LAUNCHER的activity；    

这个启动过程是由ActivityManagerService.java来完成的，我们不必关心；    

OK，基本上就这些了，关于Activity本身的原理，需要专门的文档来描述；    
7. 未分析    

1，包管理器的信息来源；    

2，AndroidManifest.xml的解析；    

3，权限的检查；    

4,其它；    

作者：wylhistory    

联系方式：wylhistory@gmail.com    


##个人思考
当调用startIntent方法时，从这篇文章可以看出，其实是在消息队列中添加了一个消息。之后，这个消息会被分发、处理。如果是用Intent启动某个Activity，启动的过程会在调用方法的那个进程结束后才会开始。这是需要注意的，因为不是startActivity方法被调用后马上就会启动一个新的Activity。   
