## jvm的常见格式
* -XX:+\<option\> 表示开启option选项
* -XX:-\<option\> 表示关闭option选项
* -XX:\<option\>=\<value\> 表示给option选项赋值

## JVM的常见参数
* -XX:+TraceClassLoading 追踪类的加载信息
* -XX:+TraceClassUnloading 追踪类的卸载信息
* -XX:+HeapDumpOnOutOfMemoryError 打印堆溢出错误信息
    * 当程序呈现堆溢出，为了查看溢出时候的相关信息，可以再运行java程序的时候加上这个参数
        从而当堆溢出的时候，会转出溢出时刻的堆上存储现场情况。通关转储到磁盘上上生成一个.hprof的文件
        通过jvisualvm来查看这个文件
* 堆设置
    * -Xms:初始堆大小
    * -Xmx:最大堆大小
    * -Xmn:新生代大小
    * -XX:NewRatio:设置新生代和老年代的比值。如：为3，表示年轻代与老年代比值为1：3
    * -XX:SurvivorRatio:新生代中Eden区与两个Survivor区的比值。注意Survivor区有两个。如：为3，表示Eden：Survivor=3：2，一个Survivor区占整个新生代的1/5  
    * -XX:MaxTenuringThreshold:设置转入老年代的存活次数。如果是0，则直接跳过新生代进入老年代
    * -XX:PermSize、-XX:MaxPermSize:分别设置永久代最小大小与最大大小（Java8以前）
    * -XX:MetaspaceSize、-XX:MaxMetaspaceSize:分别设置元空间最小大小与最大大小（Java8以后）
* 收集器设置
    * -XX:+UseSerialGC:设置串行收集器
    * -XX:+UseParallelGC:设置并行收集器
    * -XX:+UseParalledlOldGC:设置并行老年代收集器
    * -XX:+UseConcMarkSweepGC:设置并发收集器
* 垃圾回收统计信息
    * -XX:+PrintGC
    * -XX:+PrintGCDetails
    * -XX:+PrintGCTimeStamps
    * -Xloggc:filename
* 并行收集器设置
    * -XX:ParallelGCThreads=n:设置并行收集器收集时使用的CPU数。并行收集线程数。
    * -XX:MaxGCPauseMillis=n:设置并行收集最大暂停时间
    * -XX:GCTimeRatio=n:设置垃圾回收时间占程序运行时间的百分比。公式为1/(1+n)
* 并发收集器设置
    * -XX:+CMSIncrementalMode:设置为增量模式。适用于单CPU情况。
    * -XX:ParallelGCThreads=n:设置并发收集器新生代收集方式为并行收集时，使用的CPU数。并行收集线程数。



