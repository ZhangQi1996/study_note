#### 版本
1. flume 1.9.0
2. kafka 1.1.0
    * https://mirrors.huaweicloud.com/apache/kafka/1.1.1/kafka_2.12-1.1.1.tgz
3. storm 1.2.3
#### 搭建flume-kafka-storm架构
0. 基本组织架构
    * 3台机器
    ```
    host |      master     |        slave1          |   qc(slave2)
    ---------------------------------------------------------------------------
         |   storm_nimbus1     storm_supervisor1          zk_node1 
         |   kafka_broker1     storm_logviewer            storm_ui
         |   flume_agent       kafka_broker2              kafka_console_consumer            
    ---------------------------------------------------------------------------    
    ```
1. 启动zookeeper
    * 在hosts: qc
    * sh zk_cluster.sh start
        * 按zoo.cfg中的server.x选项启动
2. 启动kafka broker servers
    * sh kafka_op.sh -b 'master,slave1' start
        * 在主机master,slave1上启动broker svr
    * 其他
        * 操作topic
        ```
        # 查看topic
        sh $KAFKA_HOME/bin/kafka-topics.sh --zookeeper qc:2181 --list
        # 删除topic
        sh $KAFKA_HOME/bin/kafka-topics.sh --zookeeper qc:2181 --delete --topic topic-name
        # kafka注册flume-kafka-storm主题
        sh $KAFKA_HOME/bin/kafka-topics.sh --zookeeper qc:2181 --create
            --replication-factor 2 --partitions 3 --topic flume-kafka-storm
        # kafka注册filtered-logs主题
        sh $KAFKA_HOME/bin/kafka-topics.sh --zookeeper qc:2181 --create
            --replication-factor 2 --partitions 3 --topic filtered-logs
          
        ```
3. 启动storm nimbus, supervisors, ui
    * sh storm_op.sh cl --no-drpc start
        * 根据server.properties文件中的nimbus.seeds项启动nimbus
            * 设置为nimbus.seeds: ["master"]
        * 根据supervisors文件内容来启动supervisors
            * 设置为slave1
        * --no-drpc设置为不启动drpc
    * sh storm_op.sh ui start
        * 默认是在本地启动
        * host: qc
    * 放置作业
        * storm jar fks.jar com.zq.main.LogFilterTopology fks 
            --artifacts "org.apache.storm:storm-kafka-client:1.2.3,org.apache.kafka:kafka_2.12:1.1.1" 
            --artifactRepositories "AliRepo1^http://maven.aliyun.com/nexus/content/groups/public/,AliRepo2^http://maven.aliyun.com/nexus/content/repositories/jcenter"
4. 启动flume agent
    * 使用代理文件kafka-agent.conf
    * sh flume_agent_op.sh -n kafka-agent start
        * 在哪个主机上执行这条脚本就是在哪个主机上启动
        * 在host: master上启动       
5. 代码
    * https://github.com/ZhangQi1996/flume-kafka-storm