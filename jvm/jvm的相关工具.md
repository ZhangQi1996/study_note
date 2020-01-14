#### UI工具
1. jvisualvm
    * 基本涵盖所有功能
    * 使用
        1. 通过在命令行模式下键入jvisualvm打开该应用
        2. 通过本应用查看进程运行情况，查看线程等等
        3. 检测死锁
2. jconsole检测死锁
#### CMD工具 一般一个工具包含一种功能
1. jmap -clstats PID 打印类加载器的数据
    * 在jdk1.8之前是使用-permstat选项的
    