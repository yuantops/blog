+++
title = "用Benchmark验证sync.Pool对GC latency的优化效果"
date = "2018-05-11T10:33:25Z"
Categories = ["Tech"]
Tags = ["Golang"]
Description = "sync.Pool确实能极大减少GC次数。"
keywords = ["go GC优化","sync.Pool性能"]
+++


可能是为了避免重复造轮子，Go官方库推出了sync.Pool:一个thread-safe、可回收/重用对象的内存池。对性能优化狂魔而言，sync.Pool无疑是一个优化GC的好工具，因为理论上重用对象会减少了GC次数，缩短latency。这篇文章是sync.Pool的性能验证报告：sync.Pool确实能极大减少GC次数。

# Benchmark关注什么？

在写Benchmark代码之前，要先确定如何衡量GC效果。很直观地，GC次数越少，效果越好。但GC次数的粒度太大，说服力不够，还需要其他的指标。

这篇文章[Golang real time
gc](https://making.pusher.com/golangs-real-time-gc-in-theory-and-practice/)
给我了答案。不断往一个size固定的buffer里覆盖写入数据，记录写入耗时。被覆盖掉的数据会变成垃圾，继而触发GC，所以耗时就是latency。

原文引述如下：

    The benchmark program repeatedly pushes messages into a size-limited buffer. Old messages constantly expire and become garbage.

于是，Benchmark的实现，以及关注的指标就确定了：

1.  GC次数
2.  数据写入耗时

# 代码实现

## 不用sync.Pool的实现

见https://play.golang.org/p/049Xmy1lTfV

``` go
   package main

import (
  "fmt"
  "time"
)

const (
  windowSize = 200000
  msgCount   = 100000000
)

type (
  message []byte
  buffer  map[int]message
)

var worst time.Duration

func mkMessage(n int) message {
  m := make(message, 1024)
  for i := range m {
      m[i] = byte(n)
  }
  return m
}

func pushMsg(b *buffer, highID int) {
  start := time.Now()
  m := mkMessage(highID)
  (*b)[highID%windowSize] = m
  elapsed := time.Since(start)
  if elapsed > worst {
      worst = elapsed
  }
}

func main() {
  b := make(buffer, windowSize)
  for i := 0; i < msgCount; i++ {
      pushMsg(&b, i)
  }
  fmt.Println("Worst push time: ", worst)
}
```

## 用sync.Pool的实现

见https://play.golang.org/p/Wop29wN7<sub>Dp</sub>

``` go
   package main

import (
  "fmt"
  "sync"
  "time"
)

const (
  windowSize = 200000
  msgCount   = 100000000
)

type (
  message []byte
  buffer  map[int]message
)

var worst time.Duration

//pool for statistics model
var statModelPool = sync.Pool{
  New: func() interface{} {
      return make(message, 1024)
  },
}

func mkMessage(n int) message {
  m := statModelPool.Get().(message)
  for i := range m {
      m[i] = byte(n)
  }
  return m
}

func pushMsg(b *buffer, highID int) {
  start := time.Now()
  m := mkMessage(highID)
  if highID > windowSize {
      statModelPool.Put((*b)[highID%windowSize])
  }

  (*b)[highID%windowSize] = m
  elapsed := time.Since(start)
  if elapsed > worst {
      worst = elapsed
  }
}

func main() {
  b := make(buffer, windowSize)
  for i := 0; i < msgCount; i++ {
      pushMsg(&b, i)
  }
  fmt.Println("Worst push time: ", worst)
}
```

# 运行代码

因为要观察GC次数，我们需要打开GODEBUG的GCTRACE开关\`GODEBUG=gctrace=1\`。

(下面的数据是在我的Thinkpad T450上跑出来的。)

## 不使用sync.Pool的实现

触发454次GC，最差写入耗时50.40ms。

摘录一部分output:

``` shell
$ GODEBUG=gctrace=1 go run benchmark_gc.go
gc 1 @0.041s 0%: 0.044+0.39+0.037 ms clock, 0.13+0.19/0.26/0.40+0.11 ms cpu, 4->4->0 MB, 5 MB goal, 4 P
...
gc 454 @106.994s 4%: 0.012+29+0.045 ms clock, 0.048+1.6/26/39+0.18 ms cpu, 422->437->219 MB, 439 MB goal, 4 P
Worst push time:  50.401524ms
```

## 用sync.Pool的实现

触发22次GC，最差写入耗时36.14ms

摘录一部分output:

``` shell
 GODEBUG=gctrace=1 go run benchmark_gc_pool.go 
gc 1 @0.045s 0%: 0.047+1.2+0.077 ms clock, 0.19+0.12/1.1/0.50+0.30 ms cpu, 4->4->0 MB, 5 MB goal, 4 P
# command-line-arguments
gc 1 @0.007s 6%: 0.051+2.2+0.024 ms clock, 0.15+0.32/2.1/1.5+0.073 ms cpu, 4->4->3 MB, 5 MB goal, 4 P
.....
gc 22 @76.006s 0%: 0.015+53+0.039 ms clock, 0.062+1.7/32/0.62+0.15 ms cpu, 401->401->205 MB, 411 MB goal, 4 P
Worst push time:  36.141858ms
```

# 结论

sync.Pool的效果很不错，值得尝试。
