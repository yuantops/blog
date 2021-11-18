+++
title = "理论扫盲-清算"
author = ["yuan.tops@gmail.com"]
description = "关于\"清算\"的学习笔记，主要摘抄总结自《支付清算理论与实务》"
lastmod = 2021-11-11T17:53:32+08:00
tags = ["FinTech"]
categories = ["tech"]
draft = false
keywords = ["金融术语"]
+++

先放豆瓣链接: [支付清算理论与实务](https://book.douban.com/subject/27088012/) 。

起因是最近接触到交易领域一些术语，尤其对“清算”有一些似是而非的理解。把一些有助自己理解的部分摘录在此。


## 支付过程 P8 {#支付过程-p8}

……
目前，支付过程的划分主要遵循国际清算银行支付结算委员会的划分方法，将支付处理过程划分为三个标准化过程，即交易过程（transaction），清算过程（clearing）和结算过程（settlement）。

交易过程：包括支付的产生、确认和发送，特别是对交易有关各方的身份确认、对支付工具的确认以及对支付能力的确认。

清算过程：包含了在收付款人金融机构之间交换支付工具以及计算金融机构之间待结算的债权，支付工具的交换也包括交易撮合、交易清分、数据收集等。

结算过程：该过程是完成债权最终转移的过程，包括收集待结算的债权并进性完整性检验、保证结算资金具有可用性、结清金融机构之间的债权债务以及记录和通知各方。

……
一般而言，结算过程完成后，该支付交易就最终完成了。结算中使用的资产也成为最终结算资产，最终结算资产可以是中央银行货币，也可以是商业银行货币。为了保证支付的安全性，保证交易各方的利益，结算过程一旦完成后，支付交易一般是不可撤销的，因此，结算过程的完成通常标志着该项或该次支付交易交易全过程的结束，标志着对应的商品交易债权债务的最终清偿。……因此，支付过程是一个完整的过程，或者说，支付应具有完整性。


## 清算与结算 {#清算与结算}

……
在这一定义中，清算(clearing)是指结算前对支付工具清分、撮合，对待结算的债权债务进性计算、轧差的过程，例如，在支票支付过程中的票据的收集、清分、轧差；在银行卡的支付过程中，对通过POS机形成的支付指令的传递，对银行卡信息的路由和传递；对日切前当日各个会员银行间待结算债权债务的轧差，计算出各个参与会员的应收应付额等，这些活动都属于清算的范畴。

结算(settlement)主要是指各个结算银行间资金的最终转移的过程，包括收集待结算的债权并进性完整性检验、保证结算资金具有可用性，结清金融机构之间的债权债务以及记录和通知各方。这些任务中，最为重要的是对相应账户的处理，通过对账户的借记和贷记处理，资金从一个账户转移到另一个账户。因此，从这个意义上可以说，清算是为了更高效率完成结算的经济行为，结算是对清算后的债权债务最终的资金转移行为。为了进一步提高效率，众多银行机构的支付工具的清算过程都集中于一家机构进性处理，即所谓的集中清算，如银联集中处理所有银行的银行卡清算，而同城票据清算所处理该区域所有会员的票据。其实，区别纯清算机构有个简单的方法，纯清算机构不持有其成员机构的账户，而客户的结算账户是结算银行或结算机构的必要条件之一。

……
我国目前所使用的“清算”与“结算”就是与 clearing 和 settlement 相对应的。但不是一一对应的：不论是“清算”还是“结算”，其含义都包含clearing和settlement这两个过程。

……
产生这些“模糊”认识的原因，可能与如下的事实有关：按照我国金融界传统习惯上的认识，一般将中央银行为其他商业银行提供的支付相关的结算服务成为“清算”，而将商业银行为企事业单位和个人客户提供的支付服务成为“银行结算”，或者简称“结算”。


## 清算模式 P41 {#清算模式-p41}

在现代支付系统中，轧差的方式是区分不同系统的主要依据，理论上，我们将轧差的方式分为实时全额、双边净额和多边净额方式等，实时清算模式下的结算没有时延，因此其最终的结算方式称为实时结算，而由于双边净额和多边净额不可避免的产生时延，因此其最终的结算方式称为延时结算。


### 实时全额 {#实时全额}

实时全额清算模式是一种没有延时的清算模式，其特点是实时发送、逐笔处理、全额清算资金，建立在实时全额清算模式上的资金结算系统成为 RTGS 系统（Real Time Gross Settlement system）。由于 RTGS 要求支付方拥有足够的头寸，并且具有实时到账的特性，因此，RTGS 系统减少了清算资金的信用风险敞口，广泛为各国中央银行采用，例如美国的 Fedwire, 加拿大的 LVPS，英国的 CHAPS，欧盟的 TARGETS，中国的大额支付 HVPS 等系统都采取了 RTGS 模式。
但是，由于实时全额清算模式意味着每一支付都需要足额的资金保证，因此，RTGS 系统需要参与者具有充足的支付头寸，对参与银行的流动性管理提出了较高的要求，因此，实时全额模式也被称为“资金饥渴”型模式。……


### 双边净额 {#双边净额}

双边净额清算模式是一种延时清算方式，与实时清算模式不同，延时清算是指在一定的时间间隔后，将这段时间间隔内发生的所有支付进性轧差计算后，得到参与者的应收应付资金额，参与者在结算时只需要支付清算后的净额，不需要对每一笔原始支付进性支付。双边净额清算后，正的净额方成为收差方，负的净额方成为付差方，即付款方。如果净额计算是基于两两参与者的债权债务，则称为双边净额。

双边净额清算模式的特点是：节约结算所需的资金，但是，由于资金的结算有时延，因此可能会导致出现信用风险敞口，所以，双边净额清算模式需要设计良好的法律规章制度，以避免参与者违约所造成的系统性风险。由于双边净额模式良好的流动性节约机制，所以，双边净额清算模式在金融支付领域被广泛采用，特别是零售支付领域。例如，中国人民银行的小额支付清算系统、票据清算系统、中国银联银行卡跨行清算系统等。


### 多边净额 {#多边净额}

多边净额清算与双边净额清算的最大区别是，多边净额清算只有一个多边轧差的净额，失去了直接的债务和债权方，因此需要一个共同的交易对手来承担结算的债权债务方，这一角色通常由清算机构来承担。比如，目前我国证券交易的清算采用多边净额模式，中国证券登记结算公司作为清算方承担着共同对手方的角色。因此，相比于实时全额和双边净额，虽然多边净额清算模式资金效率更高，但是，多边净额清算模式也相应增加了制度设计的成本，因为多边净额结算的风险更高，比如，单个银行的支付失败对全体支付是否成功的影响显著加大，因此，多边净额清算通常需要制定严格的结算失败后幸存者风险承担制度。


## 结算模式 P47 {#结算模式-p47}

国际上目前倡导的结算模式有 DVP 结算模式，PVP 结算模式和中央对手方结算模式。


### 往来账户 {#往来账户}

银行间对开账户，通过相互存款的方式解决这个问题(债权债务问题)，就是往来账户方式。


### 代理银行 {#代理银行}

假如有一家银行，可以集中持有其他银行的存款，并负责通过这些来帐账户解决银行之间的债权债务的结算，那么资金分散的问题就可以解决了。这种具有为其他银行提供支付清算服务功能的银行成为代理行，也称为清算银行或结算银行。

……

另外，银行间的结算客观上需要一个稳定的结算资产，需要一个为同业支付结算清偿相互间债权债务的公共银行。银行将一部分存款作为储备金放在公共的银行中，这部分存款既可以用于结算银行间的债权，又可以防止银行过度扩展导致的破产等风险。这种公共的银行也是代理银行的原型之一，而以国家信用为广大的银行提供最终结算和服务的公共银行就是中央银行了。因此，从这个意义上看，中央银行是银行层次体系中的上层代理银行。


### DVP结算 {#dvp结算}

DVP(Delivery Versus Payment) 结算，是指债权交易达成后，在双方指定的结算日，债券的交割和资金的结算同步进行，并互为条件的一种结算方式。DVP 也可以定义为：当且仅当一种资产的最终转账发生时，另一种资产的最终转账才发生。两种资产的转移同时达到最终性。后一种定义方式更广泛一些，将债券和结算资金都看作是资产。DVP 结算的要义是资产交换的同步性和同时性，以闭合风险敞口。

目前DVP结算有多种翻译方法，本书采用中国人民银行的翻译方法，即券款对付。其他的翻译有“券款交收”、“同步交收”、“同步交割”等。


### PVP结算 {#pvp结算}

PVP(Payment Versus Payment)结算，是指外汇交易达成后，在双方指定的结算日，外汇的交割和资金的结算同步进行，并互为条件的一种结算方式。

目前PVP结算有多种翻译方法，本书采用中国人民银行的翻译方法，即同时支付。其他的翻译有“对等支付”、“同步支付”、“同时对付”等。