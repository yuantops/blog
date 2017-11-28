+++
Categories = ["Tech"]
Description = "随手记录，用自动化工具将人类从繁琐低值的手工劳动中解脱出来。"
Tags = ["java"]
date = "2017-10-17T10:30:53+08:00"
title = "MyBatis generator生成Dao和Mapper小记"
+++

## 需下载文件<a id="sec-1-1" name="sec-1-1"></a>

1.  Mybatis Generator jar包

    下载地址 <https://mvnrepository.com/artifact/org.mybatis.generator/mybatis-generator-core>

2.  JDBC 驱动jar 包

    对MySQL数据库而言，下载MySQL connector。下载地址 <https://mvnrepository.com/artifact/mysql/mysql-connector-java>

## 配置config.xml<a id="sec-1-2" name="sec-1-2"></a>

config.xml 文件指定自动生成代码时的一些配置项：数据库的url, 用户名密码，生成类名、导出地址等。  

数据库url, 用户名，密码是最重要的配置。

下面是示例：

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE generatorConfiguration
      PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
      "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">
    <generatorConfiguration>
        <!--数据库驱动, 注意jar包版本号与实际下载的版本号一致-->
        <classPathEntry    location="mysql-connector-java-3.1.13.jar"/>
        <context id="DB2Tables"    targetRuntime="MyBatis3">
            <commentGenerator>
                <property name="suppressDate" value="true"/>
                <property name="suppressAllComments" value="true"/>
            </commentGenerator>
            <!--数据库链接地址账号密码, 更新此处-->
            <jdbcConnection driverClass="com.mysql.jdbc.Driver" connectionURL="jdbc:mysql://xx.xxx.xxx.xx:36360/?characterEncoding=UTF-8" userId="xxx" password="xxx">
            </jdbcConnection>
            <javaTypeResolver>
                <property name="forceBigDecimals" value="false"/>
            </javaTypeResolver>
            <!--生成Model类存放位置-->
            <javaModelGenerator targetPackage="domain" targetProject="src">
                <property name="enableSubPackages" value="true"/>
                <property name="trimStrings" value="true"/>
            </javaModelGenerator>
            <!--生成映射文件存放位置-->
            <sqlMapGenerator targetPackage="dao" targetProject="src">
                <property name="enableSubPackages" value="true"/>
            </sqlMapGenerator>
            <!--生成Dao类存放位置-->
            <javaClientGenerator type="XMLMAPPER" targetPackage="mapper" targetProject="src">
                <property name="enableSubPackages" value="true"/>
            </javaClientGenerator>
            <!--生成对应表及类名-->
            <table tableName="%"  enableCountByExample="true" enableUpdateByExample="true" enableDeleteByExample="true" enableSelectByExample="true" selectByExampleQueryId="true">
            </table>
        </context>
    </generatorConfiguration>

## 运行命令<a id="sec-1-3" name="sec-1-3"></a>

将上面的文件放到一个目录，结构如下：

    tree 
    .
    ├── config.xml
    ├── mybatis-generator-core-1.3.0.jar
    └── mysql-connector-java-3.1.13.jar

运行命令，

    java -jar mybatis-generator-core-1.3.0.jar -configfile config.xml -overwrite

自动生成的`src`目录包含生成的代码。
