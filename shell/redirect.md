* 输入方向就是数据从哪里流向程序。数据默认从键盘流向程序，如果改变了它的方向，数据就从其它地方流入，这就是输入重定向。
* 输出方向就是数据从程序流向哪里。数据默认从程序流向显示器，如果改变了它的方向，数据就流向其它地方，这就是输出重定向。
* stdin、stdout、stderr 默认都是打开的，在重定向的过程中，0、1、2 这三个文件描述符可以直接使用。
------
* 标准输出重定向	
    * command >file	以覆盖的方式，把 command 的正确输出结果输出到 file 文件中。
    * command >>file	以追加的方式，把 command 的正确输出结果输出到 file 文件中。
* 标准错误输出重定向	
    * command 2>file	以覆盖的方式，把 command 的错误信息输出到 file 文件中。
    * command 2>>file	以追加的方式，把 command 的错误信息输出到 file 文件中。
* 正确输出和错误信息同时保存	
    * command >file 2>&1	以覆盖的方式，把正确输出和错误信息同时保存到同一个文件（file）中。
    * command >>file 2>&1	以追加的方式，把正确输出和错误信息同时保存到同一个文件（file）中。
    * command >file1 2>file2	以覆盖的方式，把正确的输出结果输出到 file1 文件中，把错误信息输出到 file2 文件中。
    * command >>file1  2>>file2	以追加的方式，把正确的输出结果输出到 file1 文件中，把错误信息输出到 file2 文件中。
    * command >file 2>file	【不推荐】这两种写法会导致 file 被打开两次，引起资源竞争，所以 stdout 和 stderr 会互相覆盖，我们将在《结合Linux文件描述符谈重定向，彻底理解重定向的本质》一节中深入剖析。
    * command >>file 2>>file
* **只用重定向最好使得左右两边不用空格隔开  e.g. echo 123 2>1.txt**
------
* 输入重定向（仅仅支持文件或目录的重定向）
    * cmd < file 将file文件的内容作为cmd的输入
    * 不可以cmd < $var
    * 不可以 cmd < $(...)
* Here Document
    * 将两个限定符中间的文档作为输入导给cmd
    * 格式如下
    ```
    cmd << delimiter
        DOCUMENT
    delimiter
  
    // e.g.
    $ wc -l << EOF
        欢迎来到
        菜鸟教程
        www.runoob.com
    EOF
    ```
    * 注意：
        1. 结尾的delimiter 一定要顶格写，前面不能有任何字符，后面也不能有任何字符，包括空格和 tab 缩进。
        2. 开始的delimiter前后的空格会被忽略掉。
    
