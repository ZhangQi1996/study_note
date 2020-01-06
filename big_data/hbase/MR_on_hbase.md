* 参考网址
    * http://hbase.apache.org/book.html#mapreduce
* 官网所给示例MR on hbase
    * 计算出所给定的表在条件下的行数
    ```
    # shell 输入
    // 由于hbase2.x版本中hbase classpath输出默认是不包含$HBASE_HOME/lib/*.jar
    // 故要在HADOOP_CLASSPATH中加入相关jar包
    export HADOOP_CLASSPATH=$(hbase classpath)  # (1)
    hadoop jar $HBASE_HOME/lib/hbase-mapreduce-VERSION.jar \  # (2)
        rowcounter \
        tablename \     # (3)
        [--range=rangeSwitch] \     # (4)
        [--starttime=startTime] \   # (5)
        [--endtime=endTime] \   # (6)
        [--expected-count=EXPECTED_COUNT_KEY]   # (7)
        cf1:[col1] [cf2:[col2] ...]     # (8)
    或者
    hbase rowcounter [options] <tablename> [--starttime=<start> --endtime=<end>] [--range=[startKey],[endKey][;[startKey],[endKey]...]] [<column1> <column2>...]
    ```
    1. (1)为使用hadoop jar来运行MR on hbase提供所需的hbase的依赖
    2. (2)hbase-mapreduce-VERSION.jar这个文件是hbase2.x版本之后才有的
    3. (3)hbase表名
    4. (4)给定的row-key的范围，像
        1. --range=a,b
        2. --range=a,
        3. --range=,b
        * 注这里的a,b均为字符串类型的row-key
    5. (5)(6)是哟怒来限定timestamp的类型为字符串标识的long的timestamp
    6. (7)是判断输出结果的行数是否符合预期
    7. (8)给定若干col-family:qualifier(可以只给列族不给列名)
    * 注：这里获取hbase的相关配置以及zk是通过读取hadoop_classpath中的hbase-site.xml文件来隐匿实现的
    * 当计算结果不匹配
        ```
        // 匹配则无输出，不匹配则会打印类似如下
        2020-01-05 17:02:33,998 ERROR [main] mapreduce.RowCounter: Failing job because count of '10000' does not match expected count of '9999'
        ```