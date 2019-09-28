### hadoop的安装
* 使用wget命令下载二进制包并解压
    * wget http://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz 
    * tar -xzvf hadoop-2.7.7.tar.gz -C /目标目录

* 对于修改master的配置文件
    * hadoop-2.7.7/etc/hadoop/core-site.xml
    ```
    <configuration>
    	<property>
    		<name>fs.defaultFS</name>
    		<value>hdfs://master:9999</value>
    		<description>表示HDFS的基本路径</description>
    	</property>
    </configuration>
    ```
    * hadoop-2.7.7/etc/hadoop/hdfs-site.xml
    ```
    <configuration>
    	<property>
             <name>dfs.replication</name>
             <value>1</value>
             <description>表示数据块备份的数目，不能超过DataNode的数量</description>
    	</property>
        <property>
             <name>dfs.namenode.name.dir</name>
             <value>/home/david/big_data/dfs/name</value>
             <description>表示NameNode存放的地方</description>	
    	</property>
        <property>
             <name>dfs.datanode.data.dir</name>
             <value>/home/david/big_data/dfs/data</value>
             <description>表示DataNode存放的地方</description>	
    	</property>
    
    </configuration>

    ```