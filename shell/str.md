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
* 字符串拼接
    * 直接将多个字符串并排放就ok, 注意字符串之间不能有空格
    ```
    i='hello'" "'world'
    j='david say':${i}
    echo ${j}
    -------------------
    输出：
    david say:hello world
    ```
    * 注意：$name 和 $url 之间之所以不能出现空格，是因为当字符串不被任何一种引号包围时，遇到空格就认为字符串结束了，空格后边的内容会作为其他变量或者命令解析
* 字符串截取
    ```
    # 总结
    ${string: start :length}	从 string 字符串的左边第 start 个字符开始，向右截取 length 个字符。
    ${string: start}	从 string 字符串的左边第 start 个字符开始截取，直到最后。
    ${string: 0-start :length}	从 string 字符串的右边第 start 个字符开始，向右截取 length 个字符。
    ${string: 0-start}	从 string 字符串的右边第 start 个字符开始截取，直到最后。
    ${string#*chars}	从 string 字符串第一次出现 *chars 的位置开始，截取 *chars 右边的所有字符。
    ${string##*chars}	从 string 字符串最后一次出现 *chars 的位置开始，截取 *chars 右边的所有字符。
    ${string%*chars}	从 string 字符串第一次出现 *chars 的位置开始，截取 *chars 左边的所有字符。
    ${string%%*chars}	从 string 字符串最后一次出现 *chars 的位置开始，截取 *chars 左边的所有字符。
    ```
    * 从字符串左边开始计数
        * ${string: start :length}
        * ${string: start} 截取到最后
    * 从右边开始计数
        * ${string: 0-start :length}
        ```
        url="c.biancheng.net"
        echo ${url: 0-13: 9}
        ------------------------
        biancheng
        ```
        * ${string: 0-start} 从倒数第start个位置截取到最后
    * 从指定字符（子字符串）开始截取
        * 使用 # 号截取右边字符 ${string#*chars}
            * 表明截取string中出现在chars后面的字符串，*字符表示通配chars前出现的所有字符
            ```
            var='http://www.baidu.com'
            echo ${var#*//}
            echo ${var#*/}  # 匹配首次出现的
            echo ${var#http://}  # 也可不用通配符
            ------------------------------
            www.baidu.com
            /www.baidu.com
            www.baidu.com
            ```
            * 若希望匹配到最后一个chars时使用${string##*chars}
            ```
            var='http://www.baidu.com/v1/key=123'
            echo ${var##*/}
            -----------------------------
            key=123
            ```
        * 使用 % 截取左边字符 ${string%chars*}
            * 表明截取string中出现在chars前面的字符串，*字符表示通配chars后出现的所有字符
            ```
            url="http://c.biancheng.net/index.html"
            echo ${url%/*}  #结果为 http://c.biancheng.net
            echo ${url%%/*}  #结果为 http:
            str="---aa+++aa@@@"
            echo ${str%aa*}  #结果为 ---aa+++
            echo ${str%%aa*}  #结果为 ---
            ```
* 对于打印\t或者\n
    * echo -e 'a\tb' # 一定要带上单引号或者双引号
        * 这种方式只能在echo中使用
    * echo $'a\tb'  # 只能用单引号
        * 可以在赋值中使用
        * a=$'a\tb'
            