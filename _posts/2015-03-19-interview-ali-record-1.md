---
layout: post    
category: "Tech"   
title: "Ali面试记录"      
description: "今天下午接到了阿里的电面，集中在Android开发方面。虽然被虐得很惨，但还是要说面试官人很nice，赞。"
---

记录：
1. 以支付宝的输入密码界面为例。当支付宝再次回到前台时，有时会进入输手势密码的界面。请问你的实现思路？    
面试官的解答：编写一个BaseActivity继承Activity，然后App中所有的Activity都继承BaseActivity。在BaseActivity中设置计时器，重写BaseActivity的onStop()和onStart()方法....

2. 百度、腾讯等旗下有多款App，这些App有的在后台共享SDK数据。请问其中原理？

3. IPC调用。

4. Android中APP是单例还是多例？    

5. 判断一个Activity是不是位于栈顶。

6. Java中run()和start()区别

7. Java中lock()和Syncronized()区别

8. 在按下Back键时，如何自定义返回到哪个Activity？
