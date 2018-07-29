+++
title = "[译文]让Siri变身完美家庭助手：兼容Apple Homekit不支持的设备"
date = "2018-07-29T17:48:19Z"
Categories = ["Tech"]
Tags = ["树莓派"]
Description = "译文一篇，非常详细地介绍了Homekit和Homebridge相关概念。"
keywords = ["Homebridge","Homebridge插件开发"]
+++


译文一篇,
原文地址：http://blog.theodo.fr/2017/08/make-siri-perfect-home-companion-devices-not-supported-apple-homekit/
。

Apple推出Homekit已有一段时间，作为智能家具解决布局的重要一环，Homekit在中文互联网上的资料可算寥寥。这篇文章介绍了Homekit平台抽象的关键概念，以及Homebridge这一款破解了Homekit协议、并支持插件化开发扩展的优秀程序。

文章还包含了一个详细教程，一步步教你写简单的Homebridge插件。

即使不是开发者，读完这篇文章，最起码可以让你打开iOS
“家庭”应用时不至于一头雾水。


========================分割线，以下是正文===============================   

# 为什么是Homekit?

[Homekit](https://developer.apple.com/homekit/)是Apple开发的家庭配件管理框架。有了Homekit，Apple设备用户可以使用同一套界面，管理不同厂商的接入设备。它使Siri变得更强，能听懂发给这些设备的指令。

如果你有一部iPhone或者Apple TV，Homekit可以在Home
Assistant等互联协议的基础上做更多好玩的事。iPhone原生支持Homekit，你可以通过"家庭"app
或者快速访问标签，方便地管理设备。Apple
    TV则可以作为设备中枢，让你设置自动化任务，并且让你在非家庭网络下也能掌控家中情况。

# 工作原理

## Homekit Accessory Protocol

Homekit为家庭和各种连接设备定义了一组布局(layout)：

  - 家庭(Home)：家庭是一处住所，它有一个由各种配件组成的网络。
  - 房间(Room)：每个家庭有一个或多个房间，每个房间有一个或多个配件。
  - 平台(Platform)：平台指的是一组配件。
  - 配件(Accessory)：配件指的是一台支持自动化的物理设备。
  - 桥(Bridge)：桥是一种特殊配件，通过它可以和那些不能与Homekit直接通信的配件通信。举例来说，桥可能是一个灯光的中枢，灯光之间通信时并不使用Homekit
    Accessory Protocol协议。
  - 服务(Service)：一个服务对应配件的一种功能。车库门除了提供开关门的服务，还可能额外提供开关车库灯的服务。
  - 特征(Characteristic)：每个服务都有一些被称为特征的属性。对车库门而言，它有 `Current Door State` 和
    `Target Door State`
    两个boolean值。服务的所有特征共同定义了它的当前状态。特征有3种权限：读，写，通知。[这里](https://github.com/KhaosT/HAP-NodeJS/blob/master/lib/gen/HomeKitTypes.js)能找到各种服务列表，以及与之关联的特征。

为了确定要操作的设备以及要触发的动作，iOS的"家庭"应用和Siri发出的每一个请求，都会使用上面的布局。

然而，当前市面上只有少量设备支持Homekit。对其他设备来说，需要在Homekit和设备间设置一个代理(proxy)。大多数厂商会自己定义一套与设备交互的方式(API或者协议)。代理接收Homekit请求，然后将它们翻译成设备能听懂的语言。

## Homebridge

本文使用的代理是[Homebridge](https://github.com/nfarina/homebridge)，一款用[HAP-node.js](https://github.com/KhaosT/HAP-NodeJS)写的NodeJS服务器。Homebridge实例化出一个
`桥`
，然后你用iOS的"家庭"应用把它添加到Homekit。Homebridge支持社区开发的插件，从而在Homekit和五花八门的"智能家居"设备间建立连接。  

社区开发者已经为很多家庭自动化设备开发了插件(例如[Nest](https://github.com/KraigM/homebridge-nest),
[Lifx](https://github.com/devbobo/homebridge-lifx-lan), 甚至是[所有兼容Home
Assitant的设备](https://github.com/home-assistant/homebridge-homeassistant))。如果你没找到要找的插件，这篇教程正是为你而写。

![](http://blog.theodo.fr/wp-content/uploads/2017/08/workflow.png)

# 自己开发插件

## 要求

  - 你已经在LAN中一台设备上安装了Homebridge，而且处于运行状态。参考[这些教程](https://github.com/nfarina/homebridge#installation)。
  - 你已经在iOS的"家庭"应用中，添加了Homebridge配件。

## 教程

我们来动手写一个假的开关插件。

新建一个目录，包含2个文件：管理依赖的 `package.json` 文件，以及放插件核心逻辑的 `index.js` 文件。

我们对开关API的设定如下：

  - 在LAN里，能通过HTTP协议层的RESTful API控制它
  - 在LAN里，开关的IP地址是192.168.0.10
  - 对 `/api/status` 的GET请求返回一个boolean值，代表开关的当前状态。这个请求会读取开关的 `On` 特征
  - 对 `/api/order` 的POST请求里携带一个代表开关目标的boolean值，将触发对应动作。这个请求会写入开关的 `On`
    特征

这个Homebridge插件将提供一个新配件，包含两个服务：

  - `AccessoryInformation` 服务。不管什么类型的配件都必须提供的服务，用来广播设备相关的信息
  - `Switch` 服务，对应我们实际的开关。这个服务需要的特征只包含一个boolean值 `On`
    (参考[服务和特征的对应关系表](https://github.com/KhaosT/HAP-NodeJS/blob/master/lib/gen/HomeKitTypes.js#L3219))。

第一步，把插件注入homebridge。控制逻辑在javascript对象 `mySwitch` 里：

``` javascript
const Service, Characteristic;

module.exports = function (homebridge) {
  Service = homebridge.hap.Service;
  Characteristic = homebridge.hap.Characteristic;
  homebridge.registerAccessory("switch-plugin", "MyAwesomeSwitch", mySwitch);
};
```

在HAP-node.js和Homebridge框架下，把核心逻辑放到 `mySwitch` 对象的 `getService`
函数。在这个函数里实例化服务。我们还要在这个函数里定义，当Homekit请求到来时，要调用哪个服务哪个特征的getter和setter。

我们需要实现：

  - `AccessoryInformation` 服务，包含：
      - `Manufacturer` 特征
      - `Model` 特征
      - `SerialNumber` 特征
  - `Switch` 服务，保护：
      - `On` 特征 —— 这个服务仅需包含这一个特征

`AccesoryInformation` 的特征是可读的，可以在插件初始化时设置。特征 `On`
不同，它是可写的，需要getter和setter。

``` javascript
mySwitch.prototype = {
  getServices: function () {
    let informationService = new Service.AccessoryInformation();
    informationService
      .setCharacteristic(Characteristic.Manufacturer, "My switch manufacturer")
      .setCharacteristic(Characteristic.Model, "My switch model")
      .setCharacteristic(Characteristic.SerialNumber, "123-456-789");

    let switchService = new Service.Switch("My switch");
    switchService
      .getCharacteristic(Characteristic.On)
  .on('get', this.getSwitchOnCharacteristic.bind(this))
  .on('set', this.setSwitchOnCharacteristic.bind(this));

    this.informationService = informationService;
    this.switchService = switchService;
    return [informationService, switchService];
  }
};
```

下面，我们来实现 `On` 特征的getter和setter。把这部分逻辑放到 `mySwitch` 对象的原型函数里。

基于开关提供的RESTful API，做出如下假设：

  - 对 <http://192.168.0.10/api/status> 的GET请求，将返回 `{ currentState: }`
    ，反映开关当前状态
  - 对 <http://192.168.0.10/api/order> 的POST请求，发送 `{ targetState: }`
    ，代表想让开关达到的目标状态

我们使用 `request` 和 `url` 模块处理HTTP请求。

上面的URL要配置在Homebridge的全局JSON配置文件里，然后变成配置对象。

``` javascript
const request = require('request');
const url = require('url');

function mySwitch(log, config) {
  this.log = log;
  this.getUrl = url.parse(config['getUrl']);
  this.postUrl = url.parse(config['postUrl']);
}

mySwitch.prototype = {

  getSwitchOnCharacteristic: function (next) {
    const me = this;
    request({
  url: me.getUrl,
  method: 'GET',
    }, 
    function (error, response, body) {
      if (error) {
  me.log('STATUS: ' + response.statusCode);
  me.log(error.message);
  return next(error);
      }
      return next(null, body.currentState);
    });
  },

  setSwitchOnCharacteristic: function (on, next) {
    const me = this;
    request({
      url: me.postUrl,
      body: {'targetState': on},
      method: 'POST',
      headers: {'Content-type': 'application/json'}
    },
    function (error, response) {
      if (error) {
  me.log('STATUS: ' + response.statusCode);
  me.log(error.message);
  return next(error);
      }
      return next();
    });
  }
};
```

现在，通过全局安装方式，把插件添加到Homebridge：

``` shell
npm install -g switch-plugin
```

用你最爱的文本编辑器，打开位于Homebridge目录的config.json文件。在accessory部分，把下面内容添加到数组:

    {
      "accessory": "MyAwesomeSwitch",
      "getUrl": "http://192.168.0.10/api/status",
      "postUrl": "http://192.168.0.10/api/order"
    }

重启Homebridge。打开iOS的"家庭"应用，现在你应该可以开、关这个假开关了。
