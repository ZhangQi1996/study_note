#### 对hadoop集群的操作
* start-dfs.sh 启动HDFS
* stop-dfs.sh

* start-yarn.sh 启动yarn
* stop-yarn.sh

* mr-jobhistory-daemon.sh start/stop JobHistoryServer
* 格式化hdfs
    1.停集群
    2.清空各个节点配置的hadoop tmp目录、name目录、data目录、以及hadoop logs目录
    3.格式化namenode
    ```
    # 辅助命令，用于清空上述内容
    sh dis_op.sh -e 'qc,slave1,master' -c '[[ -d /tmp/hadoop ]] || mkdir -p /tmp/hadoop; rm -rf /tmp/hadoop/* $HADOOP_HOME/logs/*; mkdir -p /tmp/hadoop/dfs/name /tmp/hadoop/dfs/data /tmp/hadoop/dfs/namesecondary; exit;'
    ```