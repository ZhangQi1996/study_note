#### 先初始化schema
* 就是初始化metastore db中的存储结构schema
    * 比如
    1. derby 使用在本地的store db存储
    2. mysql 可以支持远程存储
    * $HIVE_HOME/bin/schematool -dbType <db type> -initSchema
#### hiveserver 2
* 在hive2中，driver是hive server2，而hive cli升级成了beeline
* 可以让server与beeline运行在同一个主机中个也可以分开运行
    1. 分开运行
        * 启动hive server2： $HIVE_HOME/bin/hiveserver2
        * 启动beeline： $HIVE_HOME/bin/beeline -u jdbc:hive2://$HS2_HOST:$HS2_PORT
        * 其中HS2_PORT默认值10000
    2. 同传统的hive cli一样，让客户端与服务器一同运行
        * $HIVE_HOME/bin/beeline -u jdbc:hive2://
* 通过beeline登录hiveserver2
    * 方式一 beeline -u jdbc:hive2://host:port -n username -p pw
        * 通过用户username来登录hs，这个用户信息需要在hs所在的hive-site.xml配置，参见hive-site.xml文件
        * 同时涉及安全认证问题，通过在namenode与RM所在的host上配置core-site.xml的代理来解决，参见hadoop/s_a.md
    * 方式2: 先键入beeline，登录到无连接状态，再通过键入!connect jdbc:hive2://host:port登录   
        
* 在通过beeline进行操作，对涉及资源都是在hiveserver2所在的机器上或者hdfs上
