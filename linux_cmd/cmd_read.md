```
read 是 Shell 内置命令，用来从标准输入中读取数据并赋值给变量。如果没有进行重定向，默认就是从键盘读取用户输入的数据；如果进行了重定向，那么可以从文件中读取数据。

后续我们会在《Linux Shell重定向》一节中深入讲解重定向的概念，不了解的读者可以不用理会，暂时就认为：read 命令就是从键盘读取数据。
```
* read 命令的用法为：
    * read [-options] [variables]

    * options表示选项，如下表所示；variables表示用来存储数据的变量，可以有一个，也可以有多个。

    * options和variables都是可选的，如果没有提供变量名，那么读取的数据将存放到环境变量 REPLY 中。
* 注意
    * 使用管道符 | 的方法相当于启动了一个独立的子进程，因此循环中的变量FILENUM是属于自进程中的，与循环外的FILENUM虽然同名，但是值却不同。
    * 使用重定向 < 的方法则不会有这种现象，在脚本启动时并没有子进程出现，因此循环内部变量FILENUM与循环外的FILENUM变量在同一个bash shell中。
    * **故使用 while read line 语句的时候尽量用重定向而不是管道**
* Shell read 命令支持的选项
    * 选项	说明
    * -a array	把读取的数据赋值给数组 array，从下标 0 开始。
    * -d delimiter	用字符串 delimiter 指定读取结束的位置，而不是一个换行符（读取到的数据不包括 delimiter）。
    * -e	在获取用户输入的时候，对功能键进行编码转换，不会直接显式功能键对应的字符。
    * -n num	读取 num 个字符，而不是整行字符。
    * -p prompt	显示提示信息，提示内容为 prompt。
    * -r	原样读取（Raw mode），不把反斜杠字符解释为转义字符。
    * -s	静默模式（Silent mode），不会在屏幕上显示输入的字符。当输入密码和其它确认信息的时候，这是很有必要的。
    * -t seconds	设置超时时间，单位为秒。如果用户没有在指定时间内输入完成，那么 read 将会返回一个非 0 的退出状态，表示读取失败。
    * -u fd	使用文件描述符 fd 作为输入源，而不是标准输入，类似于重定向。
```
【实例1】使用 read 命令给多个变量赋值。
#!/bin/bash
read -p "Enter some information > " name url age
echo "网站名字：$name"
echo "网址：$url"
echo "年龄：$age"
运行结果：
Enter some information > C语言中文网 http://c.biancheng.net 7↙
网站名字：C语言中文网
网址：http://c.biancheng.net
年龄：7

注意，必须在一行内输入所有的值，不能换行，否则只能给第一个变量赋值，后续变量都会赋值失败。

本例还使用了-p选项，该选项会用一段文本来提示用户输入。

【示例2】只读取一个字符。
#!/bin/bash
read -n 1 -p "Enter a char > " char
printf "\n"  #换行
echo $char
运行结果：
Enter a char > 1
1

-n 1表示只读取一个字符。运行脚本后，只要用户输入一个字符，立即读取结束，不用等待用户按下回车键。

printf "\n"语句用来达到换行的效果，否则 echo 的输出结果会和用户输入的内容位于同一行，不容易区分。

【实例3】在指定时间内输入密码。
#!/bin/bash
if
    read -t 20 -sp "Enter password in 20 seconds(once) > " pass1 && printf "\n" &&  #第一次输入密码
    read -t 20 -sp "Enter password in 20 seconds(again)> " pass2 && printf "\n" &&  #第二次输入密码
    [ $pass1 == $pass2 ]  #判断两次输入的密码是否相等
then
    echo "Valid password"
else
    echo "Invalid password"
fi
这段代码中，我们使用&&组合了多个命令，这些命令会依次执行，并且从整体上作为 if 语句的判断条件，只要其中一个命令执行失败（退出状态为非 0 值），整个判断条件就失败了，后续的命令也就没有必要执行了。

如果两次输入密码相同，运行结果为：
Enter password in 20 seconds(once) >
Enter password in 20 seconds(again)>
Valid password

如果两次输入密码不同，运行结果为：
Enter password in 20 seconds(once) >
Enter password in 20 seconds(again)>
Invalid password

如果第一次输入超时，运行结果为：
Enter password in 20 seconds(once) > Invalid password

如果第二次输入超时，运行结果为：
Enter password in 20 seconds(once) >
Enter password in 20 seconds(again)> Invalid password
```