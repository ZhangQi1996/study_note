#### 简介
* kafka是一个分布式的消息队列系统(Distributed Message Queue)
#### 安装kafka
1. 下载并解压到目标目录
    * https://mirrors.huaweicloud.com/apache/kafka/1.1.1/kafka_2.12-1.1.1.tgz
2. 配置环境变量
3. 配置$KAFKA_HOME/config/server.properties文件
    1. 将所有作为kafka server的broker.id进行修改
    2. 配置zk选项
3. 启动/停止kafka server
    * sh $KAFKA_HOME/bin/kafka-server-start|stop.sh $KAFKA_HOME/config/server.properties
* 相关操作
    1. topic的相关操作
        * 是否自动创建主题
            * 在server.properties的auto.create.topics.enable=false，默认设置为true。
                如果设置为true，则produce或者fetch不存在的topic也会自动创建这个topic。
              
        * 查看topic
            * sh $KAFKA_HOME/bin/kafka-topics.sh --zookeeper host1:2181,host2:2181 --list
        * 创建topic
            * sh $KAFKA_HOME/bin/kafka-topics.sh --zookeeper host1:2181,host2:2181 --create
                --replication-factor 2 --partitions 3 --topic test
            * 选项的含义
                1. --create: 创建topic
                2. --replication-factor: 指定每个分区中的副本数（默认值1）
                3. --partitions: 指定分区数量（默认值1）
                4. --topic 指定创建的topic名字
        * 删除topic（暂未验证是否删除主题的数据）
            * sh $KAFKA_HOME/bin/kafka-topics.sh --zookeeper host1:2181 --delete --topic topic-name
            * 仅当server.properties下设置了delete.topic.enable=true时，才是真正删除，否则只是标记为删除
        * 删除主题的数据
            1. 删除主题并暴力删除所有broker中的server.properties中的log.dir目录下的数据
            2. （推荐）
            ```
            # 修改保留时间为三秒，但不是修改后三秒就马上删掉，kafka是采用轮训的方式，轮训到这个主题发现三秒前的数据都是删掉。时间由自己在server.properties里面设置
            $KAFKA_HOME/bin/kafka-configs.sh --zookeeper localhost:2181 --entity-type topics --entity-name topic-name --alter --add-config retention.ms=3000
            # 数据删除后，继续使用主题，那主题数据的保留时间就不可能为三秒，所以把上面修改的配置删掉，采用server.properties里面统一的配置。
            $KAFKA_HOME/bin/kafka-configs.sh --zookeeper localhost:2181 --entity-type topics --entity-name test --alter --delete-config retention.ms
            ```            
    3. 创建生产者
        * sh $KAFKA_HOME/bin/kafka-console-producer.sh --broker-list host1:9092,host2:9092 --topic test    
        * 含义
            1. --broker=list: 指定kafka server
            2. --topic: 指定生产的主题
    4. 创建消费者
        * Consumer API允许一个应用订阅一个或多个主题，并处理这些主题所产生的数据
            * http://kafka.apache.org/11/documentation.html#consumerapi
        * (0.x老版本)sh $KAFKA_HOME/bin/kafka-console-consumer.sh --zookeeper host1:9092,host2:9092 --from-beginning --topic test
        * sh $KAFKA_HOME/bin/kafka-console-consumer.sh --bootstrap-server host1:9092,host2:9092 --from-beginning --topic test
        * 含义
            1. --bootstrap-server svr: 指定连接的server，建议给定多个svr
            2. --group group-id: 指定创建的消费者所属的消费组id
    ![](imgs/kafka_old_new.png) 
                  
        