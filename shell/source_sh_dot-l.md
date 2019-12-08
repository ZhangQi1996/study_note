* source与sh
    * source script或者 . script
    * sh script
    * 相同点
        1. 都是使用bash运行脚本文件
        2. 都不需要由可运行的权限，即x权限
    * 不同点
        1. sh script：bash父进程需要等到子script进程运行结束后方可继续执行 （停等式）
        2. source script：这个命令其实只是简单地读取脚本里面的语句依次在当前shell里面执行，没有建立新的子shell。那么脚本里面所有新建、改变变量的语句都会保存在当前shell里面。（当这个shell关闭后就失效了）
* ./script
    * 运用./的方式运行脚本文件，需要该文件由可执行的权限
    * 其次执行该文件的解释器由开头的#!/xxx指定
        * 比如#!/bin/bash   #!/usr/bin/python
    * 若没有指定则由默认的bash解释器来执行
        
    