* 修改配置文件
    1. cp zoo_sample.cfg zoo.cfg
        * 在zoo.cfg中
            1. 修改dataDir=/var/zk(e.g.)
            2. 增加zk节点
                * server.1=hostname:rpc_port:elect_port
                * server.2=hostname:rpc_port:elect_port
            
* 为所有在zoo.cfg文件中注册的节点均创建编号
    * 注意每个节点的编号文件均要放置在zoo.cfg文件中的dataDir目录下
    1. mkdir -p /var/zk/
    2. echo seq_num > /var/zk/myid
    * 注：同步与创建myid文件可以使用sh sync_zk_settings.sh脚本完成
* 在每个zk节点都要启动
    * zkServer.sh start
    * 注：可以使用sh zk_cluster.sh start
    * 由于不存在事务，故若是同步启动的话，则编号最大的那个server将会成为leader,其余的成为follower

    