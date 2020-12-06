+++
title = "手工验证一张数字证书的有效性"
author = ["yuan.tops@gmail.com"]
description = "尽可能细致地实践证书验证算法"
lastmod = 2020-12-06T12:03:30+08:00
categories = ["Tech"]
draft = false
keywords = ["ssl", "CA"]
+++

上一篇 [博客](https://blog.yuantops.com/tech/how%5Fdo%5Fweb%5Fbroswer%5Fvalidate%5Fssl%5Fcertificates/) 讨论浏览器验证数字证书的流程。这篇文章更深入一步，用原始方法一步步手工验证证书的合法性。本文主要参考: [回答](https://security.stackexchange.com/questions/127095/manually-walking-through-the-signature-validation-of-a-certificate) 与 [X.509、PKCS文件格式介绍](https://segmentfault.com/a/1190000019008423)。


## 基础名词 {#基础名词}


### ASN.1, DER与PEM {#asn-dot-1-der与pem}

ASN.1是一种接口描述语言，它用来定义一种数据结构。

DER是一种编码规则，它用二进制表示ASN.1定义的数据。很多密码学标准使用ASN.1定义数据结构，用DER编码。

但因为DER的内容是二进制的，不方便传输，人们对DER二进制内容进行Base64编码，将其转换为ASCII码，并在头和尾加上标签，就是PEM格式。PEM全称Privacy-Enhanced Mail，起初是为了便于邮件传输，后来在很多场景得到广泛应用。


### X.509 {#x-dot-509}

X.509是RFC5280定义的一种公钥证书格式(public key certificate)。X.509证书也被称为数字Digital Certificate。一张X.509包含一个Public Key和一个身份信息。X.509证书要么是自签发，要么是被CA签发。


## 如何得到一张证书 {#如何得到一张证书}

借助浏览器，可以方便导出数字证书。

打开chrome，访问本博客网址(<https://blog.yuantops.com>)，地址栏最左侧有个小锁图案 —— 这是网站受到HTTPS加密保护的标志。

在"Details"标签，观察"Certificate Subject Alternative Name"字段，值包含"DNS Name: yuantops.com" "DNS　Name: \*.yuantops.com"，说明证书的确属于这个域名。

点击小锁　-> "certificate" -> "Details" -> "Export..."，可以选择证书的导出格式。

选择"Base64-encoded ASCII, single certificate"，得到一张PEM格式证书。将它保存为\`sni.cloudflaressl.com\`。

```txt
-----BEGIN CERTIFICATE-----
MIIEwzCCBGmgAwIBAgIQDVZy4W9/IjNEOZEGQ2ADTjAKBggqhkjOPQQDAjBKMQsw
CQYDVQQGEwJVUzEZMBcGA1UEChMQQ2xvdWRmbGFyZSwgSW5jLjEgMB4GA1UEAxMX
Q2xvdWRmbGFyZSBJbmMgRUNDIENBLTMwHhcNMjAwODA3MDAwMDAwWhcNMjEwODA3
MTIwMDAwWjBtMQswCQYDVQQGEwJVUzELMAkGA1UECBMCQ0ExFjAUBgNVBAcTDVNh
biBGcmFuY2lzY28xGTAXBgNVBAoTEENsb3VkZmxhcmUsIEluYy4xHjAcBgNVBAMT
FXNuaS5jbG91ZGZsYXJlc3NsLmNvbTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IA
BCh3/Sz4YWHFP32cBLzErjTKy4/AdFKU37wFK8kzP7sdhM3/BxdJNKeRYNwcDimw
k76zgHaaGki0AzvCTMa+llWjggMMMIIDCDAfBgNVHSMEGDAWgBSlzjfq67B1DpRn
iLRF+tkkEIeWHzAdBgNVHQ4EFgQUi9pqgIAX5apgTXwOGZ9k1FALDL0wPgYDVR0R
BDcwNYIOKi55dWFudG9wcy5jb22CFXNuaS5jbG91ZGZsYXJlc3NsLmNvbYIMeXVh
bnRvcHMuY29tMA4GA1UdDwEB/wQEAwIHgDAdBgNVHSUEFjAUBggrBgEFBQcDAQYI
KwYBBQUHAwIwewYDVR0fBHQwcjA3oDWgM4YxaHR0cDovL2NybDMuZGlnaWNlcnQu
Y29tL0Nsb3VkZmxhcmVJbmNFQ0NDQS0zLmNybDA3oDWgM4YxaHR0cDovL2NybDQu
ZGlnaWNlcnQuY29tL0Nsb3VkZmxhcmVJbmNFQ0NDQS0zLmNybDBMBgNVHSAERTBD
MDcGCWCGSAGG/WwBATAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2Vy
dC5jb20vQ1BTMAgGBmeBDAECAjB2BggrBgEFBQcBAQRqMGgwJAYIKwYBBQUHMAGG
GGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBABggrBgEFBQcwAoY0aHR0cDovL2Nh
Y2VydHMuZGlnaWNlcnQuY29tL0Nsb3VkZmxhcmVJbmNFQ0NDQS0zLmNydDAMBgNV
HRMBAf8EAjAAMIIBBAYKKwYBBAHWeQIEAgSB9QSB8gDwAHYA9lyUL9F3MCIUVBgI
MJRWjuNNExkzv98MLyALzE7xZOMAAAFzyS9NoAAABAMARzBFAiB5au5KCRfkyBcI
7jECy/NvNPkKEoMUUTwZP+rZbHtn8AIhAKOR2Lh2zsCw+gy38abKie1fyd1rmm0c
GA/pP6PykChvAHYAXNxDkv7mq0VEsV6a1FbmEDf71fpH3KFzlLJe5vbHDsoAAAFz
yS9N0wAABAMARzBFAiALkQMvm51FKVO2JRFiWWEgqu4x9rGHy2JH6P2m18lrLQIh
AN1PcRtCiY+gihkncncx18OZM6e5CGZruk05EDGThLTvMAoGCCqGSM49BAMCA0gA
MEUCIHXeLOwERMHY88NliKhUzs1MwoJap9sNm9qQLGXYCpEMAiEA1ZsGvWxusXK9
tAgwUjlWi5Ke5rvM/i01sYl6bpls4Z0=
-----END CERTIFICATE-----
```


## 分析证书结构 {#分析证书结构}

RFC5280规定了X.509证书的语法:

```txt
Certificate  ::=  SEQUENCE  {
     tbsCertificate       TBSCertificate,
     signatureAlgorithm   AlgorithmIdentifier,
     signatureValue       BIT STRING  }
```

根据定义,证书由TBSCertificate, 签名算法，签名值三部分构成。 我们可以将它们分别提取出来。提取之前，先观察证书结构:

```shell
openssl asn1parse -i -in sni.cloudflaressl.com
```


#### 选项解释 {#选项解释}

\`-in filename\`: 输入文件名

\`-i\`: 标记实体，输出缩进标记，将一个ASN1实体下的其他对象缩进显示。此选项非默认选项，加上此选项后，显示更易看懂。


#### 输出 {#输出}

```txt
   0:d=0  hl=4 l=1219 cons: SEQUENCE
   4:d=1  hl=4 l=1129 cons:  SEQUENCE
   8:d=2  hl=2 l=   3 cons:   cont [ 0 ]
  10:d=3  hl=2 l=   1 prim:    INTEGER           :02
  13:d=2  hl=2 l=  16 prim:   INTEGER           :0D5672E16F7F2233443991064360034E
  31:d=2  hl=2 l=  10 cons:   SEQUENCE
  33:d=3  hl=2 l=   8 prim:    OBJECT            :ecdsa-with-SHA256
  43:d=2  hl=2 l=  74 cons:   SEQUENCE
  45:d=3  hl=2 l=  11 cons:    SET
  47:d=4  hl=2 l=   9 cons:     SEQUENCE
  49:d=5  hl=2 l=   3 prim:      OBJECT            :countryName
  54:d=5  hl=2 l=   2 prim:      PRINTABLESTRING   :US
  58:d=3  hl=2 l=  25 cons:    SET
  60:d=4  hl=2 l=  23 cons:     SEQUENCE
  62:d=5  hl=2 l=   3 prim:      OBJECT            :organizationName
  67:d=5  hl=2 l=  16 prim:      PRINTABLESTRING   :Cloudflare, Inc.
  85:d=3  hl=2 l=  32 cons:    SET
  87:d=4  hl=2 l=  30 cons:     SEQUENCE
  89:d=5  hl=2 l=   3 prim:      OBJECT            :commonName
  94:d=5  hl=2 l=  23 prim:      PRINTABLESTRING   :Cloudflare Inc ECC CA-3
 119:d=2  hl=2 l=  30 cons:   SEQUENCE
 121:d=3  hl=2 l=  13 prim:    UTCTIME           :200807000000Z
 136:d=3  hl=2 l=  13 prim:    UTCTIME           :210807120000Z
 151:d=2  hl=2 l= 109 cons:   SEQUENCE
 153:d=3  hl=2 l=  11 cons:    SET
 155:d=4  hl=2 l=   9 cons:     SEQUENCE
 157:d=5  hl=2 l=   3 prim:      OBJECT            :countryName
 162:d=5  hl=2 l=   2 prim:      PRINTABLESTRING   :US
 166:d=3  hl=2 l=  11 cons:    SET
 168:d=4  hl=2 l=   9 cons:     SEQUENCE
 170:d=5  hl=2 l=   3 prim:      OBJECT            :stateOrProvinceName
 175:d=5  hl=2 l=   2 prim:      PRINTABLESTRING   :CA
 179:d=3  hl=2 l=  22 cons:    SET
 181:d=4  hl=2 l=  20 cons:     SEQUENCE
 183:d=5  hl=2 l=   3 prim:      OBJECT            :localityName
 188:d=5  hl=2 l=  13 prim:      PRINTABLESTRING   :San Francisco
 203:d=3  hl=2 l=  25 cons:    SET
 205:d=4  hl=2 l=  23 cons:     SEQUENCE
 207:d=5  hl=2 l=   3 prim:      OBJECT            :organizationName
 212:d=5  hl=2 l=  16 prim:      PRINTABLESTRING   :Cloudflare, Inc.
 230:d=3  hl=2 l=  30 cons:    SET
 232:d=4  hl=2 l=  28 cons:     SEQUENCE
 234:d=5  hl=2 l=   3 prim:      OBJECT            :commonName
 239:d=5  hl=2 l=  21 prim:      PRINTABLESTRING   :sni.cloudflaressl.com
 262:d=2  hl=2 l=  89 cons:   SEQUENCE
 264:d=3  hl=2 l=  19 cons:    SEQUENCE
 266:d=4  hl=2 l=   7 prim:     OBJECT            :id-ecPublicKey
 275:d=4  hl=2 l=   8 prim:     OBJECT            :prime256v1
 285:d=3  hl=2 l=  66 prim:    BIT STRING
 353:d=2  hl=4 l= 780 cons:   cont [ 3 ]
 357:d=3  hl=4 l= 776 cons:    SEQUENCE
 361:d=4  hl=2 l=  31 cons:     SEQUENCE
 363:d=5  hl=2 l=   3 prim:      OBJECT            :X509v3 Authority Key Identifier
 368:d=5  hl=2 l=  24 prim:      OCTET STRING      [HEX DUMP]:30168014A5CE37EAEBB0750E946788B445FAD9241087961F
 394:d=4  hl=2 l=  29 cons:     SEQUENCE
 396:d=5  hl=2 l=   3 prim:      OBJECT            :X509v3 Subject Key Identifier
 401:d=5  hl=2 l=  22 prim:      OCTET STRING      [HEX DUMP]:04148BDA6A808017E5AA604D7C0E199F64D4500B0CBD
 425:d=4  hl=2 l=  62 cons:     SEQUENCE
 427:d=5  hl=2 l=   3 prim:      OBJECT            :X509v3 Subject Alternative Name
 432:d=5  hl=2 l=  55 prim:      OCTET STRING      [HEX DUMP]:3035820E2A2E7975616E746F70732E636F6D8215736E692E636C6F7564666C61726573736C2E636F6D820C7975616E746F70732E636F6D
 489:d=4  hl=2 l=  14 cons:     SEQUENCE
 491:d=5  hl=2 l=   3 prim:      OBJECT            :X509v3 Key Usage
 496:d=5  hl=2 l=   1 prim:      BOOLEAN           :255
 499:d=5  hl=2 l=   4 prim:      OCTET STRING      [HEX DUMP]:03020780
 505:d=4  hl=2 l=  29 cons:     SEQUENCE
 507:d=5  hl=2 l=   3 prim:      OBJECT            :X509v3 Extended Key Usage
 512:d=5  hl=2 l=  22 prim:      OCTET STRING      [HEX DUMP]:301406082B0601050507030106082B06010505070302
 536:d=4  hl=2 l= 123 cons:     SEQUENCE
 538:d=5  hl=2 l=   3 prim:      OBJECT            :X509v3 CRL Distribution Points
 543:d=5  hl=2 l= 116 prim:      OCTET STRING      [HEX DUMP]:30723037A035A0338631687474703A2F2F63726C332E64696769636572742E636F6D2F436C6F7564666C617265496E6345434343412D332E63726C3037A035A0338631687474703A2F2F63726C342E64696769636572742E636F6D2F436C6F7564666C617265496E6345434343412D332E63726C
 661:d=4  hl=2 l=  76 cons:     SEQUENCE
 663:d=5  hl=2 l=   3 prim:      OBJECT            :X509v3 Certificate Policies
 668:d=5  hl=2 l=  69 prim:      OCTET STRING      [HEX DUMP]:3043303706096086480186FD6C0101302A302806082B06010505070201161C68747470733A2F2F7777772E64696769636572742E636F6D2F4350533008060667810C010202
 739:d=4  hl=2 l= 118 cons:     SEQUENCE
 741:d=5  hl=2 l=   8 prim:      OBJECT            :Authority Information Access
 751:d=5  hl=2 l= 106 prim:      OCTET STRING      [HEX DUMP]:3068302406082B060105050730018618687474703A2F2F6F6373702E64696769636572742E636F6D304006082B060105050730028634687474703A2F2F636163657274732E64696769636572742E636F6D2F436C6F7564666C617265496E6345434343412D332E637274
 859:d=4  hl=2 l=  12 cons:     SEQUENCE
 861:d=5  hl=2 l=   3 prim:      OBJECT            :X509v3 Basic Constraints
 866:d=5  hl=2 l=   1 prim:      BOOLEAN           :255
 869:d=5  hl=2 l=   2 prim:      OCTET STRING      [HEX DUMP]:3000
 873:d=4  hl=4 l= 260 cons:     SEQUENCE
 877:d=5  hl=2 l=  10 prim:      OBJECT            :CT Precertificate SCTs
 889:d=5  hl=3 l= 245 prim:      OCTET STRING      [HEX DUMP]:0481F200F0007600F65C942FD1773022145418083094568EE34D131933BFDF0C2F200BCC4EF164E300000173C92F4DA000000403004730450220796AEE4A0917E4C81708EE3102CBF36F34F90A128314513C193FEAD96C7B67F0022100A391D8B876CEC0B0FA0CB7F1A6CA89ED5FC9DD6B9A6D1C180FE93FA3F290286F0076005CDC4392FEE6AB4544B15E9AD456E61037FBD5FA47DCA17394B25EE6F6C70ECA00000173C92F4DD3000004030047304502200B91032F9B9D452953B6251162596120AAEE31F6B187CB6247E8FDA6D7C96B2D022100DD4F711B42898FA08A1927727731D7C39933A7B908666BBA4D3910319384B4EF
1137:d=1  hl=2 l=  10 cons:  SEQUENCE
1139:d=2  hl=2 l=   8 prim:   OBJECT            :ecdsa-with-SHA256
1149:d=1  hl=2 l=  72 prim:  BIT STRING
```


#### 输出格式解析 {#输出格式解析}

```nil
0:d=0  hl=4 l=1219 cons: SEQUENCE
```

\`0\`: 表示节点在整个文件中的偏移长度
\`d=0\`: 表示节点深度
\`hl=4\`: 表示节点头字节长度
\`l=1219\`: 表示节点数据字节长度
\`cons\`: 表示该节点为结构节点，表示包含子节点或者子结构数据
\`prim\`: 表示该节点为原始节点，包含数据


#### tbsCertificate和signature位置 {#tbscertificate和signature位置}

观察可知，tbsCertificate的偏移位置是4, 签名值signatureValue的偏移位置是1137。


## 提取tbsCertificate {#提取tbscertificate}

引用RFC5280 4.1.1.3:

```txt
The signatureValue field contains a digital signature computed upon
the ASN.1 DER encoded tbsCertificate.  The ASN.1 DER encoded
tbsCertificate is used as the input to the signature function.
```

根据上述定义，计算签名的输入是DER编码的tbsCertificate。而我们从浏览器导出的证书是PEM格式，需要使用openssl将其转化为DER格式。

```nil
openssl x509 -in sni.cloudflaressl.com -inform PEM -out sni.cloudflaressl.com.der -outform DER
```

然后，我们从DER证书中提取tbsCertificate。 根据asn1parse输出结果第二行，tbsCertificate偏移位置是4, 大小是1133 = ４(头部长度) + 1129(数据长度)。

```nil
4:d=1  hl=4 l=1129 cons:  SEQUENCE
```

使用\`dd\` 按偏移位置截取。输出内容保存到\`yuantops.tbs\`。

```nil
dd if=sni.cloudflaressl.com.der of=yuantops.tbs skip=4 bs=1 count=1133
```


## 提取signatureValue {#提取signaturevalue}

根据asn1parse输出结果末尾一行:

```nil
1149:d=1  hl=2 l=  72 prim:  BIT STRING
```

signatureValue偏移量是1137。如果直接使用\`dd\`截取，将得到\`BIT STRING\`编码后的签名值，不能直接使用。需要用\`ans1parse\`的\`-strparse\`选项，将其转换为二进制数据。

```shell
openssl asn1parse -in sni.cloudflaressl.com -strparse 1137 -out cloudflaressl.sig
```

签名数据保存在cloudflaressl.sig文件。


#### 选项解释 {#选项解释}

\`-in filename\` ：输入文件名，默认为标准输入。

\`-offset number\`：开始数据分析的字节偏移量，分析数据时，不一定从头开始分析，可用指定偏移量，默认从头开始分析。

\`-strparse offset\`：此选项也用于从一个偏移量开始来分析数据，不过，与-offset不一样。-offset分析偏移量之后的所有数据，而-strparse只用于分析一段数据，并且这种数据必须是SET或者SEQUENCE，它只分析本SET或者SEQUENCE范围的数据。


#### 查看提取的签名是否正确 {#查看提取的签名是否正确}

使用\`od\`命令，以16进制打印签名文件内容:

```nil
`od -tx1 cloudflaressl.sig`
0000000 30 45 02 20 75 de 2c ec 04 44 c1 d8 f3 c3 65 88
0000020 a8 54 ce cd 4c c2 82 5a a7 db 0d 9b da 90 2c 65
0000040 d8 0a 91 0c 02 21 00 d5 9b 06 bd 6c 6e b1 72 bd
0000060 b4 08 30 52 39 56 8b 92 9e e6 bb cc fe 2d 35 b1
0000100 89 7a 6e 99 6c e1 9d
0000107
```

与浏览器Certificate Viewer中看到的证书\`SignatureValue\`对比，二者应该相同。

下一步，我们获取签发者的公钥。


## 获取issuer公钥 {#获取issuer公钥}

在上一篇博客中提到，服务器返回给浏览器一组证书链。通过浏览器Certificate Viewer可以看到证书继承关系。 \`sni.cloudflaressl.com\`证书的签发者是\`Cloudflare Inc ECC CA-3\`。

我们将其导出为文件，保存到本地，文件名为 \`Cloudflare\_Inc\_ECC\_CA-3\`。

```nil
openssl x509 -in Cloudflare_Inc_ECC_CA-3 -noout -pubkey > Cloudflare_Inc_ECC_CA-3.pub
```

将公钥转换为PEM格式，以观察内容:

```text
openssl pkey -in Cloudflare_Inc_ECC_CA-3.pub -pubin -text

-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEua1NZpkUC0bsH4HRKlAenQMVLzQS
fS2WuIg4m4Vfj7+7Te9hRsTJc9QkT+DuHM5ss1FxL2ruTAUJd9NyYqSb1w==
-----END PUBLIC KEY-----
Public-Key: (256 bit)
pub:
    04:b9:ad:4d:66:99:14:0b:46:ec:1f:81:d1:2a:50:
    1e:9d:03:15:2f:34:12:7d:2d:96:b8:88:38:9b:85:
    5f:8f:bf:bb:4d:ef:61:46:c4:c9:73:d4:24:4f:e0:
    ee:1c:ce:6c:b3:51:71:2f:6a:ee:4c:05:09:77:d3:
    72:62:a4:9b:d7
ASN1 OID: prime256v1
NIST CURVE: P-256
```


## 验证签名 {#验证签名}

回顾签名流程:

1.  生成ASN.1 DER格式的tbsCertificate
2.  使用摘要算法，计算tbsCertificate摘要值
3.  签发者(issuer)使用自己的私钥，使用signatureAlgorithm对摘要进行签名，得到signatureValue

对应地，我们的验证流程:

1.  提取提取ASN.1 DER格式的tbsCertificate
2.  使用摘要算法，计算tbsCertificate摘要值 hash1
3.  提取证书的SignatureValue
4.  使用签发者(issuer)公钥，证书的摘要值hash1，证书的signatureValue，进行RSA签名认证。

我们可以使用\`openssl\` 命令, 将｀2｀ \`3\` \`4\` 合成一步：

```nil
openssl sha256 <yuantops.tbs -verify Cloudflare_Inc_ECC_CA-3.pub -signature cloudflaressl.sig
Verified OK
```

或者，将\`3\` \`4\` 合成一步：

```nil
openssl sha256 <yuantops.tbs -binary >hash
```

```nil
openssl pkeyutl -verify -in hash -sigfile cloudflaressl.sig -inkey Cloudflare_Inc_ECC_CA-3.pub -pubin -pkeyopt digest:sha256
Signature Verified Successfully
```

到此，证书签名验证结束。


## 其他　 {#其他}


### 为什么x509证书中，signatureValue要进行bit string编码? {#为什么x509证书中-signaturevalue要进行bit-string编码}

<https://crypto.stackexchange.com/questions/55574/why-is-the-signature-field-in-x-509-a-bit-string-despite-there-being-asn-1-der>

<https://security.stackexchange.com/questions/161982/asn-1-encapsulated-bitstring-type-in-openssl>


### 为什么不解密SignatureValue，将得到的hash值与tbsCertificate的hash值比较? {#为什么不解密signaturevalue-将得到的hash值与tbscertificate的hash值比较}

这一点上，我还没有特别明白。

[这篇文章](http://yongbingchen.github.io/blog/2015/04/09/verify-the-signature-of-a-x-dot-509-certificate/)　完全没有用到openssl验证签名，他手动用公钥解出了signature对应的hash值。

但是，我Google公钥解密签名的方法，回答都说不能 **解密\*，只能 \*验证**.

知乎问题　[RSA的公钥和私钥到底哪个才是用来加密和哪个用来解密？](https://www.zhihu.com/question/25912483) 下面 刘巍然的回答 详细论述了RSA加解密算法和签名体制的区别，他说道:

> 在签名算法中，私钥用于对数据进行签名，公钥用于对签名进行验证。这也可以直观地进行理解：对一个文件签名，当然要用私钥，因为我们希望只有自己才能完成签字。验证过程当然希望所有人都能够执行，大家看到签名都能通过验证证明确实是我自己签的。

看来，似乎确实不能根据公钥对签名进行 **解密**?
