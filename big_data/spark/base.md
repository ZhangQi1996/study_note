#### RDD（resilient distributed dataset）弹性分布式数据集
* RDD的5大特性
    1. RDD由一系列partition组成
    2. 算子（函数）作用在RDD的partition上的
    3. RDD之间有依赖关系
    4. 分区器是作用在k,v格式的RDD上的
    5. partition提供数据计算的最佳位置，有利于数据处理的本地化
* 问题
    1. spark读取hdfs中的数据的方法是调用底层的MR读取HDFS文件的方法，首先会split，每个split对应一个block，
        每个split对应生成rdd的每个partition
    2. 什么是k,v格式的RDD
        * RDD中的数据格式是一个个的tuple2，name这个RDD就是k,v格式的RDD
    3. 哪里体现了RDD的弹性（容错）？
        1. rdd之间的有依赖关系
        2. rdd的partition可多可少
* spark运行模式
    1. local
        * 用于本地测试，基于ide
    2. standalone
        * 使用spark自带的资源调度框架，支持完全分布式
    3. yarn
        * 使用基于yarn的资源调度框架，支持完全分布式
        * 要基于yarn来搭建，必须实现ApplicationMaster接口 
    4. memos
        * 略

