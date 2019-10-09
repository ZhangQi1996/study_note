### hadoop的安装
* 使用wget命令下载二进制包并解压
    * wget http://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz 
    * tar -xzvf hadoop-2.7.7.tar.gz -C /目标目录

* 修改云服务器上的host映射
    * vim /etc/hosts
    ```
    x.x.x.x master (内网)
    x.x.x.x slave1  (外网)
    x.x.x.x slave2  （外网)
  ```
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
            <name>dfs.namenode.http-address</name>
            <value>master:50070</value>
        </property>
        <property>
            <name>dfs.namenode.secondary.http-address</name>
            <value>master:50090</value>
        </property>
        <property>
            <name>dfs.replication</name>
            <value>1</value>
            <description>表示数据块备份的数目，不能超过DataNode的数量</description>
        </property>
        <property>
             <name>dfs.namenode.name.dir</name>
             <value>/big_data/dfs/name</value>
             <description>表示NameNode存放的地方</description>	
        </property>
        <property>
             <name>hadoop.tmp.dir</name>
             <value>/big_data/dfs/tmp</value>
             <description>表示NameNode存放的地方</description>
        </property>
        <property>
             <name>dfs.datanode.data.dir</name>
             <value>/big_data/dfs/data</value>
             <description>表示DataNode存放的地方</description>	
        </property>
    </configuration>


    ```
* 将java与hadoop配置到环境变量中
    * vim ~/.bashrc
    ```
    export JAVA_HOME=/usr/local/openjdk-8
    export JRE_HOME=${JAVA_HOME}/jre
    export CLASS_HOME=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
    export HADOOP_HOME=/home/david/big_data/hadoop-2.7.7  # 为了方便将其均设为共同前缀
    export PATH=${PATH}:${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin
    ```
* 在master下格式化hdfs
    * hdfs namenode -format
* 将master上的结构复制到slave上
    * scp -r big_data root@slave1:/  就是将当前目录下的big_data目录复制到slave1的根目录下，
    使用的是ssh连接
* 若不能连接上目标的ssh
    * 考虑目标主机是否安装openssh-server 以及 openssh-client
    * 考虑是否开启ssh服务  service sshd start
    * 若是Permitted confused 考虑在/etc/ssh/ssh_config文件下解注释PermitRootLogin yes
        * 再通过service sshd restart 重启服务
    * 考虑是否因为防火墙拦截
* 通过使用ssh-keygen 命令生成rsa秘钥对位于~/.ssh目录下，将公钥文件通过cat xx >> ~/.ssh/auth_keys（文件名为简写的）追加到服务器端的keys文件中
```
云服务器无法绑定公网IP的地址，即在 /etc/hosts 需要这样设置（集群每台都设置）

内网IP地址  你的hostname
公网IP地址  别的hostname
**即要将你绑定的东西绑定在内网ip、上而不是公网ip上**
```
* 若启动datanode失败有可能是多次格式化namenode造成的
    * 解决方法：将namenode下的/name/current/VERSION中的clusterID覆盖掉
                datanode下的/data/current/VERSION中的clusterID
* 在namenode与datanode节点上一定要配置core-site.xml文件与hdfs-site.xml文件与slaves文件
    * 在namenode上core-site.xml文件用于启动namenode进程
    * 在datanode上core-site.xml用于定位向namenode发送心跳
