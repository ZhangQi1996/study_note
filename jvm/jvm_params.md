## jvm的常见格式
* -X开头的参数是非标准参数，也就是只能被部分VM识别，而不能被全部VM识别的参数。
* -XX开头的参数是非稳定参数，随时可能被修改或者移除。
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
    * -XX:SurvivorRatio:新生代中Eden区与两个Survivor区的比值。注意Survivor区有两个。
        如：为3（就是eden与其中一个比值为3:1），表示Eden：Survivor=3：2，一个Survivor区占整个新生代的1/5  
        * -XX:SurvivorRatio=8
    * -XX:MaxTenuringThreshold:设置转入老年代的存活次数。如果是0，则直接跳过新生代进入老年代
    * -XX:PermSize、-XX:MaxPermSize:分别设置永久代最小大小与最大大小（Java8以前）
    * -XX:MetaspaceSize、-XX:MaxMetaspaceSize:分别设置元空间最小大小与最大大小（Java8以后）
* 收集器设置
    * -XX:+UseSerialGC:设置串行收集器
    * -XX:+UseParallelGC:设置并行收集器
    * -XX:+UseParalledlOldGC:设置并行老年代收集器
    * -XX:+UseConcMarkSweepGC:设置并发低停顿收集器，不推荐使用（过于复杂）
    * -XX:+UseG1GC: 设置g1垃圾收集器
* 垃圾回收统计信息
    * -XX:+PrintGC
    * -XX:+PrintGCDetails
    * -XX:+PrintGCTimeStamps
    * -Xloggc:filename
    * -verbose:gc 打印gc的冗余信息
* 并行收集器设置
    * -XX:ParallelGCThreads=n:设置并行收集器收集时使用的CPU数。并行收集线程数。（STW阶段的收集）
    * -XX:MaxGCPauseMillis=n:设置并行收集目标最大暂停时间
    * -XX:GCTimeRatio=n:设置垃圾回收时间占程序运行时间的百分比。公式为1/(1+n)
* 并发收集器设置
    * -XX:ConcGCThreads=n: 设置处在并发标记阶段，并行执行gc的线程数（每个线程单独处理各自的所属部分）
    * -XX:+CMSIncrementalMode:设置为增量模式。适用于单CPU情况。
* 其他
    * -XX:+PrintCommandLineFlags    打印jvm的启动参数  
    ```
    // 比如默认参数打印如下
    -XX:InitialHeapSize=131900928 -XX:MaxHeapSize=2110414848 -XX:+PrintCommandLineFlags 
    -XX:+UseCompressedClassPointers -XX:+UseCompressedOops 
    -XX:-UseLargePagesIndividualAllocation -XX:+UseParallelGC
    // *****************************************************************
    1. -XX:+UseCompressedClassPointers 对指针进行压缩，从而节省空间
    2. -XX:+UseCompressedOops 用于处理32bit到64bit系统的指针膨胀问题，对指针进行压缩
    3. -XX:-UseLargePagesIndividualAllocation   暂未查到
    4. -XX:+UseParallelGC 指定对于在新生代/老年代采用并行gc
    ``` 
    * -XX:PretenureSizeThreshold=xxx (字节) 设置直接放入老年代中的对象大小阈值
        1. 需要设置收集器为串行收集器(在新生代/老年代)
          * -XX:+UseSerialGC
        2. 设置阈值
              * -XX:PretenureSizeThreshold=xxx (字节)
    * -XX:MaxTenuringThreshold=n   
        * 设置在新生代中那些能晋升到老年代对象的年龄
        * 年龄：就是存活在新生代中，经历了的gc次数+1（即默认年龄是0）
        * 当年龄大于n时就100%晋升为老年代
        * 注: jvm可以自动调节晋升的年龄，不一定要超过n才晋升，但是超过n必定晋升
            * 与-XX:TargetSurvivorRatio=n有关
        * 该参数默认是15，CMS收集器默认是6，G1收集器默认是15，（由于jvm中用4bit标识，故最大为15）
    * -XX:+PrintTenuringDistribution 打印年龄对象的情况
    * -XX:TargetSurvivorRatio=n 表明当to space中存活的空间达到其n%的时候，就会重新计算潜在的
        MaxTenuringThreshold这个值(该值可能会减少或增加但不会大于MaxTenuringThreshold的值)。
* 编译运行有关参数
    * -XX:CompileThreshold=n 设置方法/回边计数器的阈值，当一个方法或者循环次数到达这个阈值，则这个方法的代码就是热点代码
        交给jit编译器编译尝试编译为本地机器码
    * -server/client 将jvm启动为何种模式，server模式采用server（c2）jit编译器，cli模式采用client（c1）jit编译器
    * -Xint 强制jvm只进行解释执行
    * -Xcomp 强制jvm尽全力做编译执行，若出现激进编译优化的时候会换为解释执行
    * -XX:-UseCounterDecay 默认是开启方法计数器的衰减的，即每到一段时间将还不是热点代码的函数计数器减半（与下一个有关）
    * -XX:CounterHalfLifeTime参数设置方法计数器半衰周期的时间（s）（与上一个有关）

