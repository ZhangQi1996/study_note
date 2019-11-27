#### 全分布式模式
* 包括一个主HMaster与多个备份的HMaster实例
* 包括多个ZooKeeper实例
* 包括多个RegionServer实例
* 1个主节点2个RS分布式架构
```
Table 1. Distributed Cluster Demo Architecture
========================================================
Node_Name	            Master	ZooKeeper	RegionServer
--------------------------------------------------------
node-a.example.com      yes     yes         no
node-b.example.com      backup  yes         yes
node-c.example.com      no      yes         yes
========================================================
```
* 配置
    1. 在conf/regionservers文件中清空并写入你要部署RS的主机名或者IP
        * $ echo slave1$'\n'slave2 > conf/regionservers
        * 将slave1与slave2添加到文件中
    2. 配置另一个主机为备份Master
        1. 若conf文件夹下没有backup-masters文件则在其下新建这个文件
        2. 在conf/backup-masters文件中添加xxx一行，意思将xxx主机作为备份Master的地方
* 启动
    1. 保证没有节点启动了HBase
    2. 通过start-hbase.sh来启动所有相关进程
        * master节点上的HMaster, HQuorumPeer
        * region_server节点上HQuorumPeer, RegionServer进程
        * 注1: HQuorumPeer进程在哪个节点上启动由master节点上的hbase-site.xml文件中的属性决定
        * 注2: 对于ZooKeeper的QuorumPeer进程是在HBase内启动还是外部启动
        * 内部启动时，jps显示HQuorumPeer，外部启动显示QuorumPeer
        