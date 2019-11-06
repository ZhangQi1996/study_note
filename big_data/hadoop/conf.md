## hadoop中的一些参数配置
#### hadoop-env.sh中的参数配置
* HADOOP_HEAPSIZE   (默认值1000)
    * 设置每个守护进程的内存大小
    * 包括namenode, datanode, jobtracker, tasktracker
    * 注意在tasktracker中启动的子进程用来处理MR的内存大小不受该参数限制
* HADOOP_NAMENODE_INIT_HEAPSIZE (默认值1000)
    * 设置hdfs中的namenode守护进程的内存大小（覆盖HADOOP_HEAPSIZE对与namenode设置的值）
#### mapred-env.sh中的参数配置
* HADOOP_JOB_HISTORYSERVER_HEAPSIZE (默认值1000)
    * 对job历史服务器分配的内存大小
#### yarn-env.sh
* YARN_HEAPSIZE (默认值1000)
    * 设置yarn中每个守护进程的内存大小
    * 该数值会重置JAVA_HEAP_MAX的数值=YARN_HEAPSIZE
    * 包括resource manager, node manager, timeline server(它是MR1的job history server的一个升级版本)
* YARN_TIMELINESERVER/RESOURCEMANAGEER/NODEMANAGER_HEAPSIZE (默认值1000)
    *  覆盖YARN_HEAPSIZE对与xxx设置的值
#### core-site.xml (常见配置)
```
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://master:9000</value> <!--默认值: 9000-->
        <description>表示HDFS的基本路径</description>
    </property>

    <property>
        <name>io.file.buffer.size</name>
        <value>131072</value><!--默认值: 4096 （4k）-->
        <description>128k的缓冲区辅助</description>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/big_data/tmp</value>    <!--默认值: /tmp/hadoop-${user.name}-->
        <description>临时文件存放的地方</description>
    </property>
</configuration>
```
#### hdfs-site.xml
```
<configuration>
    <property>
        <name>dfs.namenode.http-address</name>
        <value>master:50070</value> <!--默认值: 50070-->
    </property>
    <property>
        <name>dfs.namenode.secondary.http-address</name>
        <value>master:50090</value> <!--默认值: 50090-->
    </property>
    <property>
        <name>dfs.replication</name>
        <value>1</value> <!--默认值: 1-->
        <description>表示数据块备份的数目，不能超过DataNode的数量</description>
    </property>
    <property>
        <name>dfs.blocksize</name>
        <value>64m</value>  <!--默认值: 128m-->
        <description>块的大小</description>
    </property>
</configuration>
```
#### mapred.xml （用于配置MR任务的公共配置）
```
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value> <!--默认值: local-->
        <!--表示启动MR程序的框架类型：有local，classic，yarn-->
        <!--1. local模式：采用本地单机运行MR程序，client，jobtracker，tasktracker均在本主机上，而且单进程，不管如何设置mapper与reducer数量都会重新设置为1-->
        <!--2. classic模式：即采用分布式MR1模式，采用jobtracker+tasktracker-->
        <!--3. yarn模式：即采用基于yarn资源管理的MR2模式（即表示MR2与yarn密切相关），采用resource manager+app master+node manager-->
    </property>
    <property>
        <name>mapreduce.map.java.opts</name> <!--默认值: -Xmx200m-->
        <value>-Xmx200m</value>
        <!--1. 用于配置在MR1中每个运行MR程序的java子进程或者MR2中容器中java进程所需的内存（分配java的堆栈大小）-->
        <!--2. 他的数值推荐为mapreduce.map/reduce.memory.mb的0.75倍-->
    </property>
    <property>
        <name>mapreduce.reduce.java.opts</name> <!--默认值: -Xmx200m-->
        <value>-Xmx200m</value>
        <!--1. 用于配置在MR1中每个运行MR程序的java子进程或者MR2中容器中java进程所需的内存（分配java的堆栈大小）-->
        <!--2. 他的数值推荐为mapreduce.map/reduce.memory.mb的0.75倍-->
    </property>
    <property>
        <name>mapreduce.map.memory.mb</name>
        <value>256</value>  <!--默认值: 1024-->
        <!--1. 在MR1中是指的是对于在tasktracker中，分配给这个MR的总内存-->
        <!--2.1. 在YARN/MR2中，由于MR程序是运行在容器中的，而这个容器是于AM在RM申请再来分配的给MR容器，即MR容器的内存-->
        <!--2.2. 注意，在yarn模式中，设置该数值是收到yarn.scheduler.minimum-allocation-mb（rm的最小分配数量）的整数倍的限制-->
        <!--     比如，该数值为400，然而最小分配数量为256，则真实的分配数值为512（即256的2倍），-->
        <!--        但是这个数值要小于yarn.scheduler.maximum-allocation-mb-->
        <!--3. 由于除了java的堆栈外，还仍需一些空间存放其他的如java代码，一些其他资源，故这个值必须大于mapreduce.map/reduce.java.opts-->
    </property>
    <property>
        <name>mapreduce.reduce.memory.mb</name>
        <value>256</value>  <!--默认值: 1024-->
    </property>
    <property>
        <name>yarn.app.mapreduce.am.command-opts</name> <!--默认值:-Xmx1024m -->
        <value>-Xmx200m</value>
        <description>java heap size for AM processes</description>
        <!--1. 分配给App Master的java进程所需的堆栈大小-->
        <!--2. 其数值应该小于分配给AM容器的内存大小 常见比例为0.75-->
    </property>
    <property>
        <name>yarn.app.mapreduce.am.resource.mb</name>
        <value>256</value>  <!--默认值: 1536 -->
        <description>mb allocated to AM Container</description>
        <!--1. 分配给App Master容器的内存大小-->
        <!--2. 其数值应该大于分配给AM的java进程heap大小 常见比例为1: 0.75-->
    </property>
    <property>
        <name>mapreduce.job.ubertask.enable</name>
        <value>false</value> <!--默认值: false -->
        <!--1. 是否采用uber模式，所谓uber模式就是指使得多个MR程序运行在同一个jvm中-->
        <!--2. 运用场景：MR数量较少-->
        <!--3. uber模式仅仅支持MR2-->
    </property>
</configuration>
```
#### yarn-site.xml
```
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
        <!--shuffle的必添加选项-->
    </property>

    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>256</value>  <!--默认值: 1024-->
        <!--AM申请的最小内存单元，每次RM分配的内存斗志该最小分配的倍数值-->
    </property>

    <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>1024</value> <!--默认值: 8196-->
        <!--申请容器的最大内存单元，每次RM分配的内存都应该小于等于该数值-->
    </property>

    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>768</value> <!--默认值: 8196-->
        <!--1. nodemanager能分配所有容器的总的内存值：比如包含AM容器，MR容器-->
        <!--2. 该值必须>=max{AM容器, Map容器， Reduce容器}-->
    </property>
    <property>
        <name>yarn.nodemanager.vmem-pmem-ratio</name>
        <value>2.1</value>  <!--默认值: 2.1-->
        <!--设置在nodemanager中的虚拟内存与实际物理内存的比率-->
    </property>
</configuration>
```
 
    