
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
* 开启hive的执行操作的mr任务的MAP输出阶段压缩
    * 开启map输出阶段压缩可以减少job中map和reduce task间数据传输量
    1. 开启hive中间传输数据的codec功能
        * SET hive.exec.compress.intermediate=true
    2. 开启MR中的map输出压缩功能
        * SET mapreduce.map.output.compress=true
    3. 设置MR中map的压缩方式
        * SET mapreduce.map.output.compress.codec=org.apache.hadoop.io.compress.SnappyCodec; # SnappyCodec进行codec时不占用内存
    4. 进行相关操作
        * SELECT COUNT(*) FROM tn
* 开启hive的执行操作的mr任务的REDUCE输出阶段压缩
    1. 开启hive最终输出数据的压缩功能
        * SET hive.exec.compress.output=true
    2. 开启MR中的reduce输出压缩功能
        * SET mapreduce.output.fileoutput.compress=true
    3. 设置MR中map的压缩方式
        * SET mapreduce.output.fileoutput.compress.codec=org.apache.hadoop.io.compress.SnappyCodec; # SnappyCodec进行codec时不占用内存
    4. 设置数据输出的压缩类型NONE/BLOCK/RECORD
        * SET mapreduce.output.fileoutputformat.compress.type=BLOCK
    5. 操作
        * INSERT OVERWRITE LOCAL DIRECTORY '/root/data' SELECT * FROM tn;
* hive中常见的压缩
    * 行存储
        1. TEXTFILE
            * 可结合gzip, bzip2进行codec，使用的时候系统自动执行codec
            * 不会对数据进行切分，从而无法进行并行操作
        2. SEQUNCEFILE
    * 列存储
        1. ORC （optimized row columnar）
        2. PARQUET
            * 按二进制存储  
