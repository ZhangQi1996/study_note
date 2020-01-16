#### UI工具
1. jvisualvm
    * 基本涵盖所有功能
    * 使用
        1. 通过在命令行模式下键入jvisualvm打开该应用
        2. 通过本应用查看进程运行情况，查看线程等等
        3. 检测死锁
2. jconsole检测死锁
#### CMD工具 一般一个工具包含一种功能
1. jmap
    * 查看jmap的help
    ![](jmap_help.png)
    * -clstats PID 打印类加载器的数据（在jdk1.8之前是使用-permstat选项）
    ![](jmap_clstats_pid.png)
    * -heap PID 查看heap
2. jstat
    * -gc PID 查看元空间的相关信息
    ![](jstat_gc.png)
3. jcmd
    * PID help 查看对于当前java进程可以执行那些操作
    ![](jcmd_help.png)
    * PID VM.flags 查看该jvm启动参数
    ![](jcmd_jvm_params.png)
    * PID help OPS 查看OPS的相关选项以及信息
    * PID PerfCounter.print 查看jvm性能相关的参数
    ![](jcmd_jvm_perform.png)
    * PID GC.class_histogram 查看类中的类实例的统计信息
    * PID Thread.print 查看java进程中所有线程的堆栈信息（jconsole，jvisualvm均包含这个功能）
        * 通过这个可以查看是否存在死锁问题
    
    
    
       

    