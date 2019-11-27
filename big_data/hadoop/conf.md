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