#### 对于beeline与server的启动以及先关的内容参见1.md
* beeline中使用的命令：
    * 所有命令均是以!开头（即这些命令都是在本地cli执行）
    * 注意使用cli命令时候最后不用;
    * cli命令全部写在同一行
    * 常见命令如下：
    0. !help 打印相关cli命令
    1. !autocommit 设置是否自动提交
    2. !close: 设置关闭当前db连接
    3. !commit 提交当前事务
    4. !connect 连接db
    5. !reconnect 重连db
    6. !quit 退出cli
    7. !delimiter x 将x设置为查询的终结符，默认值为分号
    8. !sh 执行shell，由于是使用java来执行shell cmd故后面仅能做一些简单的shell
    9. !outputformat cli输出内容的组织类型
* 连接到jdbc:hive2://host:port其实是连接到hiveserver（也是连接到default数据库）
    * 在连接后，就可以创建数据库了
    * create database xxx;
* beeline的自动连接
    * 在${user.name}/.beeline/beeline-hs2-connection.xml(自己新建)写入
    ```
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
    <configuration>
        <property>
            <name>beeline.hs2.connection.hosts</name>
            <value>master:10000</value>
        </property>
        <property>
            <name>beeline.hs2.connection.user</name>
            <value>david</value>
        </property>
        <property>
            <name>beeline.hs2.connection.password</name>
            <value>000000</value>
        </property>
    </configuration>
    ```
    * 这种只支持连接default数据库
    * 单可以通过use db 来切换数据库

        