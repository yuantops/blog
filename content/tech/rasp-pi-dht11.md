+++
title = "树莓派连接DHT11温度湿度传感器"
date = "2018-07-28T20:30:45Z"
Categories = ["Tech"]
Tags = ["树莓派"]
Description = "我眼角余光瞟到书桌一角红色指示灯默默闪烁的树莓派Model 3 B，一年前将它买入，把玩几天就失去热情，从此心安理得地对它视而不见。微微尴尬歉意涌上心头，吹去外壳积尘陷入沉思。恰逢2018年过去一半又两个月，就像分手又复合男女下定决心狂甩誓言，命运(或许是空调冷气?)让我对该廉价所谓Geek玩物重燃兴趣。"
keywords = ["树莓派","DHT11"]
+++

记录一下给树莓派安装温度湿度传感器的过程。

树莓派主板有一排GPIO扩展口，可以方便地驱动硬件。温度湿度传感器DHT11是一种常见传感器，很适合作为入门器件，探索树莓派的硬件能力。  

我上次接触硬件知识还是在大二的单片机小学期，几乎已经忘光，正好趁机抢救性回忆一下。

# 目标  

在树莓派上读到温度和湿度数据。  

# 元件清单  

除了传感器DHT11，还需要连接线、面包板等元件，在淘宝上很好买到。  

我额外买了一块树莓派特制GPIO扩展板，用它把树莓派的40根针脚延长到面包板，类似USB延长线。很怀疑这是来自中国的"微创新"，值得赞美，因为确实解决了树莓派针脚空间狭小不便于插线的小痛点。  

下面是元件清单：  

1.  树莓派Model 3 B  
2.  DHT11传感器。我用的是三脚型号。  
3.  面包板  
4.  杜邦线/连接线  

# 插线

在实际插线之前，有必要先来认识树莓派针脚。树莓派3代一共40根针脚，这么辨认物理编号：横着放，让2排针脚在上面，上面那排是偶数，从左到右是2到40；下面那排是奇数，从左到右是1到39。  

40根针脚里，有28根GPIO针脚。这28根针脚，又有两种命名规则：BCM编号，WiringPi编号。还要注意，树莓派2代和3代的对应关系不一样，参考网上资料时要看清针脚图的型号。  

  - BCM编号，就是我们常看见的 `GPIOxx` 里面的 `xx` 。
  - WiringPi编号，是 [WiringPi库](http://wiringpi.com/)
    使用的编号。除非是用WiringPi库驱动针脚，否则不需关注。

对我这样的新手而言，最初物理编号和BCM编号两套规则切换起来有些烦人，需要一些细心。  

下面的接线方案，用的是物理编号：

1.  左边 `+` 接3.3V电源，选择 `1` 口。
2.  中间 `DATA` ，选择 `7` 口。
3.  右边 `-` 接地，选择 `14` 口。

# 安装命令

DHT11是非常成熟通用的传感器，对它的驱动封装也特别多，不需再造轮子。货比三家，我发现Adafruit公司开源的代码质量最高，运行起来最稳定。

1.  安装Adadruit公司的开源库：[Adafruit Python DHT](https://github.com/adafruit/Adafruit_Python_DHT)

2.  在安装目录下, 进入example目录，运行 `AdafruitDHT.py`
    文件:
    
    ``` shell
    pi@raspberrypi:~/Adafruit_Python_DHT/examples $ python AdafruitDHT.py 
    0 30.0 C 70.0%
    ```
	我房间此时是30摄氏度，湿度70%。  
	
至此DHT11温度湿度传感器的安装完成。

更进一步，在手机上查看，或者在LCD显示屏上展示，请期待后续文章。