#### 流式与批处理式框架
* 流式处理框架
    * e.g. storm
    * 连续不断的处理，做实时处理，像是扶梯
* 微批处理
    * e.g. spark-streaming
    * 将RDD做得很小
* 批处理式框架
    * e.g. hadoop-mr
    * 分批次处理，做离线处理，像是电梯
#### storm特征
* 实时，分布式，具有高容错
* 进程是常驻内存中的，而hadoop的进程是根据job任务到来而创建的
* storm数据不经过磁盘，在内存中处理
#### storm架构（主从）
![](storm-DAG.png)
![](storm-hadoop.png)
* 工作流程
![](workflow.png)
* storm的本地目录树
![](storm_local_dir-tree.png)
* storm-zk的目录树
![](storm-zk_dirtree.png)
* 组件
    ![](storm_core-component.png)
    * Nimbus （主节点） 类似jobtracker
        1. 资源控制
        2. 任务分配
        3. jar包上传
    * Supervisor（从节点） 
    * Worker （从节点上的工作进程）
    ![](storm-worker.png)
#### 高可靠
1. 异常处理
2. 消息可靠性保障机制ACK
    ![](storm-acker.png)
    * storm的ack容错机制，是一般某个bolt处理出现问题，发送给acker一个fail ack后
        acker会通知spout，然后spout会重新发送原来发过的流数据，这就存在一个问题，
        拓扑图中，存在重复的数据处理。
#### Grouping 指定Tuple发往那个bolt进行处理，类似hadoop中的partition操作
1. shuffleGrouping，将Tuple随机发给任意一个下游bolt，保证每个数目大致相同
2. globalGrouping，将Tuple全部发给一个下游task id最低的bolt
3. allGrouping，将Tuple复制n份分发给下游n个bolt
4. fieldsGrouping，将Tuple根据给定的Fields字段来分发给下游bolt
5. noneGrouping，类似shuffle
6. directGrouping，指定特定的bolt来处理。只有声明为DirectStream的流才可以使用这个方法，
    且必须通过directEmit方法来传递给下一个bolt
7. customGrouping，自定义grouping

