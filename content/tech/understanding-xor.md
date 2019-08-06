+++
title = "Understanding XOR"
author = ["yuan.tops@gmail.com"]
description = "理解xor"
date = 2019-07-25T00:00:00+08:00
publishDate = 2019-07-25T00:00:00+08:00
lastmod = 2019-07-25T16:00:40+08:00
tags = ["Linux"]
categories = ["Tech"]
draft = false
keywords = ["xor"]
+++

> We can interpret the action of XOR in a number of different ways, and this helps to shed light on its properties. The most obvious way to interpret it is as its name suggests, ‘exclusive OR’: A ⊕ B is true if and only if precisely one of A and B is true. Another way to think of it is as identifying difference in a pair of bytes: A ⊕ B = ‘the bits where they differ’. This interpretation makes it obvious that A ⊕ A = 0 (byte A does not differ from itself in any bit) and A ⊕ 0 = A (byte A differs from 0 precisely in the bit positions that equal 1) and is also useful when thinking about toggling and encryption later on. <br />
> <br />
> The last, and most powerful, interpretation of XOR is in terms of parity, i.e. whether something is odd or even. For any n bits, A1 ⊕ A2 ⊕ … ⊕ An = 1 if and only if the number of 1s is odd. This can be proved quite easily by induction and use of associativity. It is the crucial observation that leads to many of the properties that follow, including error detection, data protection and adding. <br />
> <br />
>  Essentially the combined value x ^ y ‘remembers’ both states, and one state is the key to getting at the other.
