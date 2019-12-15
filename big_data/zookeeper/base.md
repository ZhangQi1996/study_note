* 修改配置文件
    1. cp zoo_sample.cfg zoo.cfg
        * 在zoo.cfg中
            1. 修改dataDir=/var/zk(e.g.)
            2. 增加zk从节点
                * server.1=hostname:rpc_port:elect_port
                * server.2=hostname:rpc_port:elect_port
            
* 为所有zk创建编号
    1. mkdir -p /var/zk/
    2. echo 1 > /var/zk/myid
    