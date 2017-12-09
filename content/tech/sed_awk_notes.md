+++
title = "sed和awk学习笔记"
date = 2017-12-09T17:12:59+08:00
Categories = ["Tech"]
Tags = [""]
Description = "提升效率，随手备查"
+++

1.  为什么加上单引号: 防止shell
        expansion
    
        Enclosing the instruction in single quotes is not requir ed in all cases but you should get in the habit of always doing it. The enclosing single quotes prevent the shell from interpreting special characters or spaces found in the editing instruction.(The shell uses spaces to determine individual arguments submitted to a program;characters that are special to the shell are expanded before the command is invoked.)

2.  通用语法
    
    ``` bash
    awk -f scriptfile file
    sed -f sedscript file
    ```

3.  命令的组成: pattern和procedure

## sed

### sed里的模式空间 pattern space

Sed maintains a pattern space, a workspace or temporary buffer where a
single line of input is held while the editing commands are applied.\*

pattern space的内容是动态的(dynamic)，sed脚本中的任何一条命令都可能改变其中内容。

As a consequence, any sed command might change the contents of the
pattern space for the next command.

### sed的addressing策略

1.  vim中的替换命令默认只对当前行生效；sed不一样，sed命令默认对所有行生效。

2.  可以在命令前指定address。address可以是一个正则表达式,a line number,或者line addressing
    symbol
    
      - If no address is specified, then the command is applied to each
        line.
      - If there is only one address, the command is applied to any line
        matching the address.
      - If two comma-separated addresses are specified, the command is
        performed on the first line matching the first address and all
        succeeding lines up to and including a line matching the second
        address.
      - If an address is followed by an exclamation mark (\!), the
        command is applied to all lines that do not match the address.

3.  关于行号：sed 内部维护的行号，不是文件的行号。输入是多个文件时，只会有一个行号1。 The line number refers
    to an internal line count maintained by sed. This counter is not
    reset for multiple input files. Thus, no matter how many files were
    specified as input, there is only one line 1 in the input stream

4.  如果指定了两个address,那么命令只会在它们组成的range内生效。理解为：第一个address enable，第二个address
    disable。

5.  地址后面出现的惊叹号，作用是反转地址匹配结果。

### sed的命令分组

用花括号给命令行分组{}，用来在命令里嵌套命令，或者对同一个地址应用多个命令。to nest one address inside
another or to apply multiple commands at the same address.

### sed常用命令

1.  替换s
    
      - syntaxt: \[address\]s/pattern/replacement/flags
      - As a metacharacter, the ampersand (&) represents the extent of
        the pattern match, not the line that was matched.

2.  删除d

3.  变形Transform y
    
      - syntax: \[address\] y/abc/xyz
      - 逐个字符替换，而不是逐个单词替换

4.  打印p
    
      - 输出pattern space的内容
      - 常用来debug

5.  打印行号= 跟在address后面的等号(=)会打印出匹配行的行号。

6.  读取文件内容r
    
      - syntax: \[address\]r file
      - The read command reads the contents of file into the pattern
        space after the addr essed line
      - No subsequent command will affect the lines read from the file.
        For instance, you can’t make any changes to the list of
        companies that you’ve read into the file. However, commands that
        address the original line will work.

7.  退出命令q
    
      - syntax: \[line-address\]q
      - The quit command (q) causes sed to stop reading new input lines
        (and stop sending them to the output)
      - 例子:
    
    <!-- end list -->
    
    ``` bash
    # 类似head -n 3
    sed '3q' a.txt
    ```

## awk

1.  awk是"输入驱动" input-driven. That is, nothing happens unless there are
    lines of input on which to act. When you invoke the awk program, it
    reads the script that you supply, checking the syntax of your
    instructions. Then awk attempts to execute the instructions for each
    line of input.

2.  假定“输入是结构化的”

### BEGIN/END pattern

The **BEGIN** pattern specifies actions that are performed before the
first line of input is read.

If a program has only a BEGIN pattern, and no other statements, awk will
not process any input files.

A BEGIN rule is executed once only, before the first input record is
read. Likewise, an END rule is executed once only, after all the input
is read.

### Basic programming model

**main input loop**: a routine that reads one line of input from a file
and makes it available for processing. Awk 默认提供，不需要手动实现。

每一行都会执行。没有可读行时停止。

### 模式匹配 pattern matching

与sed 类似，匹配到某种模式后才会执行命令。

When awk reads an input line, it attempts to match each pattern-matching
rule in a script. Only the lines matching the particular pattern are the
object of an action.

If no action is specified, the line that matches the pattern is printed
(executing the print statement is the default action)

### 分隔符 FS file separator

  - 默认FS: 空格
  - 单字符作分隔符
  - 多字符作分隔符: 被当做正则表达式
  - 一般在BEGIN section中定义FS。 Typically, the field and record separators
    are defined in the BEGIN procedure because you want these values set
    before the first input line is read.

### 系统变量 System Variables

  - FS: Field Seperator
  - NF: 当前输入行的field count
  - RS: record separator, 默认是换行符
  - NR: 当前输入行的行号 the number of the current input record
  - OFS: print 命令中，逗号会输出一个OFS。The output field separator (OFS) is
    generated when a comma is used to separate the arguments in a print
    statement.

### 格式化输出 Formatted Printing: **printf**

  - syntax: printf(format-expression\[,arguments\])
  - format-expression: %-width.precision format-specifier。“-”表示左对齐
  - The precision modifier, used for decimal or floating-point values,
    controls the number of digits that appear to the right of the
    decimal point. For string values, it controls the maximum number of
    characters from the string that will be printed.

### 向脚本中传递参数

  - syntax:
    
    ``` bash
    awk 'script_content' var=value datafile
    awk -f scriptfile var=value datafile
    ```

### 字符串操作函数

Awk Function
Description

|                     |                                                                                                                                                                                            |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| gsub(r,s,t)         | Globally substitutes s for each match of the regular expression r in the string t. Returns the number of substitutions. If t is not supplied,defaults to $0.                               |
| index(s,t)          | Returns position of substring t in string s or zero if not present.                                                                                                                        |
| length(s)           | Returns length of string s or length of $0 if no string is supplied.                                                                                                                       |
| match(s,r)          | Returns either the position in s wher e the regular expression r begins, or 0 if no occurrences are found. Sets the values of RSTART and RLENGTH.                                          |
| split(s,a,sep)      | Parses string s into elements of array a using field separator sep;retur ns number of elements. If sep is not supplied, FS is used. Array splitting works the same way as field splitting. |
| sprintf(“fmt”,expr) | Uses pr intf for mat specification for expr.                                                                                                                                               |
| sub(r,s,t)          | Substitutes s for first match of the regular expression r in the string t.Retur ns 1 if successful; 0 otherwise. If t is not supplied, defaults to$0.                                      |
| substr(s,p,n)       | Returns substring of string s at beginning position p up to amaximum length of n. If n is not supplied, the rest of the string from p is used.                                             |
| tolower(s)          | Translates all uppercase characters in string s to lowercase and returns the new string.                                                                                                   |
| toupper(s)          | Translates all lowercase characters in string s to uppercase and returns the new string                                                                                                    |

### 使用\#\!语法调用awk脚本

  - 在脚本开头加上 \#\!/bin/awk -f
  - 用法: $ awkscript datafile
