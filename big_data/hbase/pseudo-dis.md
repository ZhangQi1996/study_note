#### 伪分布模式的HBase，顾名思义HBase的所有组件都位于一台host上
* 使用pseudo-dis_hbase-site.xml作为conf文件
    * 可以使用本地的文件系统作为root-dir
* 使用start-hbase.sh启动后台hbase
* 使用stop-hbase.sh关闭后台hbase
* 伪分布式模式
    * HMaster, RegionServer, ZooKeeper均启动在不同进程中
    * HMaster占据着端口16000与16010
    * RegionServer占据着端口16020与16030
* 备份HMaster
    * 启动所有备份的HMaster
        * $ ./bin/local-master-backup.sh start 2 3 5
        * 意思是启动其他三个备份的HMaster
        * backup1: 10602, 10612
        * backup2: 10603, 10613
        * backup3: 10605, 10615
    * 停止所有备份的HMaster
        * $ cat /tmp/hbase-testuser-1-master.pid | xargs kill -9
            * 关于xargs命令参见shell目录下的cmd_xargs.md
* 额外的区域服务器
    * 启动额外的RegionSvr
        * $ .bin/local-regionservers.sh start 2 3 5
        * 意思是启动其他三个备份的HMaster
        * backup1: 10622, 10632
        * backup2: 10623, 10633
        * backup3: 10625, 10635
    * 停止所有额外的RegionSvr
        * $ .bin/local-regionservers.sh stop 3
            * 删除偏移为3的那个RS
            * 故这个需要执行多次但偏移不同
        
    