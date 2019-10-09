```
字符串（String）就是一系列字符的组合。字符串是 Shell 编程中最常用的数据类型之一（除了数字和字符串，也没有其他类型了）。
字符串可以由单引号' '包围，也可以由双引号" "包围，也可以不用引号。它们之间是有区别的，稍后我们会详解。
e.g.
str1=c.biancheng.net
str2="shell script"
str3='C语言中文网'
```
* 在字符串中用单双引号
    * 都需要用\引着
    ```
    i=hello'world'
    echo $i
    -----------------------
    结果：
    helloworld
    
    i=hello\'world\'
    echo $i
    -----------------------
    结果：
    hello'world'
    ```
 * 获取str的长度
    * ${#str_name}
    