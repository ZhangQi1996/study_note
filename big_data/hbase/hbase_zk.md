* 分布式HBase依赖于一个运行的ZK集群，所有的HBase节点都应该能够连接访问ZK集群
* 默认情况，HBase内部启动ZK集群，这个属性通过在conf/hbase-env.sh中的HBASE_MANAGE_ZK=true/false来
    控制是否ZK作为HBase启动的一部分
* 当ZK由HBase来管理的时候，ZK的配置项由conf/hbase-site.xml来管理
* 所有的ZK属性配置都由hbase.zookeeper.property打头，关于完整的ZK配置见ZK的zoo.cfg
    * 必须的ZK配置
    1. hbase.zookeeper.quorum
        * 指定在ZK在那几个主机上启动ZK
        * 默认只在localhost上启动一个
        * **一般应该启动多少个ZK**
        ```
        1. 可以启动一个ZK节点，但在生产环境最好部署奇数个(>1)ZK节点
        2. 给ZK节点大概1G内存，对于高负载的集群，最好ZK节点与RS（DataNode/TaskTracker分开） 
        ```
* 独立于HBase启动/停止ZK
    * 注意：确保设置HBASE_MANAGE_ZK=false
    * ${HBASE_HOME}/bin/hbase-daemons.sh {start,stop} zookeeper
 