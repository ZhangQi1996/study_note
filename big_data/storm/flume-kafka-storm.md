#### 版本
1. flume 1.9.0
2. kafka 1.1.0
    * https://mirrors.huaweicloud.com/apache/kafka/1.1.1/kafka_2.12-1.1.1.tgz
3. storm 1.2.3
#### 搭建flume-kafka-storm架构
1. 启动zookeeper
    * sh zk_cluster.sh start
2. 启动kafka broker servers
    * sh kafka_op.sh -b 'master,slave1,qc' start
        * 在主机master,slave1,qc上启动broker svr
    * [可有可无]注册topic
        * sh $KAFKA_HOME/bin/kafka-topics.sh --zookeeper qc:2181 --create
            --replication-factor 2 --partitions 3 --topic flume-kafka
3. 启动        