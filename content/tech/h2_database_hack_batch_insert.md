+++
title = "H2 Database hack —— 批量插入的猥琐实现"
author = ["yuan.tops@gmail.com"]
description = "通过SQL实现的批量插入都不够快！本文分享一种猥琐实现：把数据直接灌到h2底层数据表。"
date = 2021-08-27T00:00:00+08:00
publishDate = 2021-08-27T00:00:00+08:00
lastmod = 2021-08-30T18:30:10+08:00
tags = ["Linux"]
categories = ["Tech"]
draft = false
keywords = ["H2", "batch"]
+++

H2 数据库是一款优秀的内存数据库，它具备几个特点：体积小，文档全，功能完善，而且是Java写的。

最近用到它这些优良特性，做内存计算。以内存模式启动了一个H2实例。接下来，要把外部数据导入H2数据库。这就面临一个问题：数据量大（几万+）的情况下，如何保证插入速度？


## 常规方案 {#常规方案}

随便一种JDBC 持久层工具, 例如 **JdbcTemplate**, **MyBatis**,都封装了批量接口。怀着封装越少、效率越高的朴素信念，用H2原生JDBC Connection.insert() 方法，循环插入。2.7 万条数据，耗时约 3s。

另外，h2 database 官方有一种做法：把数据先导到 csv 文件，然后加载csv。虽没有实际验证这种方案，但纸上谈兵分析，即使数据加载变快，但增加了两次I/O。效果估计不会特别优秀。


## 快速方案 {#快速方案}

同事脑洞大开：内存数据库插入语句，先是SQL解析，再把Java对象写进内存。既然都是Java 对象，能不能跳过SQL这一遭，直接写内存?

不经过JDBC，不经过SQL，这种思路也是不按常规出牌了。但原理非常说得通，而且肯定更快。

经过一步步断点调试，找到了关键类: **org.h2.table.Table** 。insert() 语句走到最后，是往table 里添加行(**org.h2.result.Row**)。换言之，只要拿到 table，又按格式构造行，就可以了。

-   获取Table
    按作者原意，应该是不希望使用者直接操作 Table 对象的。但是架不住我们猥琐啊，借助反射机制，什么都拿得到。
    下面，是一步步抠出 Table 对象的实现。

    ```java
     String sql = "select * from " + tableName;
    try (JdbcPreparedStatement ps = (JdbcPreparedStatement) connection.prepareStatement(sql)) {
        CommandContainer commandContainer = (CommandContainer) getFieldByForce(ps, JdbcPreparedStatement.class,
                "command");
        Session session = (Session) getFieldByForce(ps, JdbcPreparedStatement.class, "session");
        Select command = (Select) getFieldByForce(commandContainer, CommandContainer.class, "prepared");
        Table table = new ArrayList<>(command.getTables()).get(0);
    ```

-   构造行
    待插入的数据格式是Map, key是列名，value是值。对应到 **org.h2.result.Row** 的话 ，map每个entry对应一列。当然，涉及一些列名提取与转化，数据类型处理的工作。
    下面是构造行的实现。

    ```java
    Row newRow = table.getTemplateRow();
    Column[] columns = table.getColumns();
    for (Column c : columns) {
        int index = c.getColumnId();
        String columnName = c.getName();
        if (!map.containsKey(columnName)) {
            newRow.setValue(c.getColumnId(), ValueNull.INSTANCE);
        } else {
            Object value = map.get(columnName);
            if (value instanceof String) {
                newRow.setValue(index, ValueString.get(value.toString()));
            } else if (value instanceof Integer) {
                newRow.setValue(index, ValueInt.get((Integer) value));
            } else if (value instanceof Timestamp) {
                newRow.setValue(index, ValueTimestamp.get(TimeZone.getDefault(), (Timestamp) value));
            } else if (value instanceof BigDecimal) {
                newRow.setValue(index, ValueDecimal.get((BigDecimal) value));
            } else {
                // todo 类型还需充分枚举
                newRow.setValue(index, ValueString.get(value.toString()));
            }
        }
    ```

-   提交插入
    因为从 **org.h2.engine.Session** 剥离出了Table对象，而h2是支持事务的数据库，所以在插入结束后，还需要执行commit，让改变生效。

    ```java
    session.commit(false);
    ```


## 最终效果 {#最终效果}

2.7w 条数据，耗时 700ms。相比传统方案(2.7w条数据，3000ms)，耗时减少了将近八成，颇为可观了。


## 源码 {#源码}

```nil

import lombok.extern.slf4j.Slf4j;
import org.h2.command.CommandContainer;
import org.h2.command.dml.Select;
import org.h2.engine.Session;
import org.h2.jdbc.JdbcConnection;
import org.h2.jdbc.JdbcPreparedStatement;
import org.h2.result.Row;
import org.h2.table.Column;
import org.h2.table.Table;
import org.h2.value.*;
import org.springframework.util.ReflectionUtils;

import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

@Slf4j
public class H2InsertUtil {

    public static void batchInsert(Connection toSqlSession, String tableName, List<Map<String, Object>> data) {
        assert isH2Dialect(toSqlSession);

        try {
            JdbcConnection connection = toSqlSession.unwrap(JdbcConnection.class);
            doBatchInsert(connection, tableName, data);
        } catch (SQLException e) {
            throw new RuntimeException("使用H2批量插入出错.", e);
        }
    }

    private static boolean isH2Dialect(Connection sqlSession) {
        try {
            return sqlSession.isWrapperFor(JdbcConnection.class);
        } catch (SQLException e) {
            log.warn("判断connection类型时出错", e);
            return false;
        }
    }

    private static void doBatchInsert(JdbcConnection connection, String tableName, List<Map<String, Object>> batchData) throws SQLException {
        String sql = "select * from " + tableName;
        try (JdbcPreparedStatement ps = (JdbcPreparedStatement) connection.prepareStatement(sql)) {
            CommandContainer commandContainer = (CommandContainer) getFieldByForce(ps, JdbcPreparedStatement.class,
                    "command");
            Session session = (Session) getFieldByForce(ps, JdbcPreparedStatement.class, "session");
            Select command = (Select) getFieldByForce(commandContainer, CommandContainer.class, "prepared");
            Table table = new ArrayList<>(command.getTables()).get(0);

            for (Map<String, Object> data : batchData) {
                Row newRow = createRow(table, data);
                table.addRow(session, newRow);
            }
            session.commit(false);
        } catch (Exception e) {
            log.error("", e);
            throw e;
        }
    }

    private static Object getFieldByForce(Object obj, Class<?> clazz, String fieldName) {
        Field field = ReflectionUtils.findField(clazz, fieldName);
        ReflectionUtils.makeAccessible(field);
        return ReflectionUtils.getField(field, obj);
    }

    private static Row createRow(Table table, Map<String, Object> map) {
        Row newRow = table.getTemplateRow();
        Column[] columns = table.getColumns();
        for (Column c : columns) {
            int index = c.getColumnId();
            String columnName = c.getName();
            if (!map.containsKey(columnName)) {
                newRow.setValue(c.getColumnId(), ValueNull.INSTANCE);
            } else {
                Object value = map.get(columnName);
                if (value instanceof String) {
                    newRow.setValue(index, ValueString.get(value.toString()));
                } else if (value instanceof Integer) {
                    newRow.setValue(index, ValueInt.get((Integer) value));
                } else if (value instanceof Timestamp) {
                    newRow.setValue(index, ValueTimestamp.get(TimeZone.getDefault(), (Timestamp) value));
                } else if (value instanceof BigDecimal) {
                    newRow.setValue(index, ValueDecimal.get((BigDecimal) value));
                } else {
                    // todo 类型还需充分枚举
                    newRow.setValue(index, ValueString.get(value.toString()));
                }
            }
        }
        return newRow;
    }
}
```
