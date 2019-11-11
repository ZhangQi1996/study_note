#### hadoop中的安全认证（对hdfs与yarn）
```
user1 \
user2 - superuser - hadoop
user3 /
// 由于对hadoop的访问存在安全认证机制，故userx通过已经认证的superuser来简介访问hadoop
// 在简单模式下，superuser就是运行namenode，RM进程的用户，比如是root
// 认证只是多了一个门槛限制，对hadoop里面的访问其实hadoop是认为userx在操作
```
* 通过设置**namenode与RM所在机器上的core-site.xml**文件进行配置代理
    * **似乎在简单模式下，jar下简单访问只要hadoop中有相关mod权限既可以操作**
    * **但是在hive2 通过beeline连接server时候，尽管是在simple模式下，任然会碰到中间安全认证拦截，故需要配置代理**
    * 配置如下：
    ```
    // 相关参见https://www.jianshu.com/p/a27bc8651533
    // 在API下通过认证（暂时用不到）
    // ProxyUser对象通过UserGroupInformation.createProxy(“proxyUser”,superUgi)来创建，访问集群时通过proxyUser.doAs方式进行调用。
    // 示例代码：
    
    // 创建superUser用户
    UserGroupInformation superUser = UserGroupInformation.getCurrentUser();
    //创建proxyUser用户
    UserGroupInformation proxyUgi = UserGroupInformation.createProxyUser(“proxyUser”, superUser);
    // 使用proxyUser用户访问集群
    proxyUgi.doAs(new PrivilegedExceptionAction<Void>() {
    @Override
    public Void run() throws Exception {
    // 使用proxy用户访问hdfs
    FileSystem fs = FileSystem.get(conf);
    fs.mkdirs(new Path(“/proxyUserDir”));
    // 使用proxy用户提交mr作业
    JobClient jc = new JobClient(conf);

    jc.submitJob(conf);

      return null;
      }
    });
    ```
    ```
    // ***********在xml下配置代理（在简单模式下）*************
    // 配置	                                说明
    // hadoop.proxyuser.$superuser.hosts	配置该superUser允许通过代理访问的主机节点（hadoop相关节点）
    // hadoop.proxyuser.$superuser.groups	配置该superUser允许代理的用户所属组
    // hadoop.proxyuser.$superuser.users	配置该superUser允许代理的用户
    
    // 对于每个superUser用户，hosts必须进行配置，而groups和users至少需要配置一个。
    // 这几个配置项的值都可以使用*来表示允许所有的主机/用户组/用户。
    <property> <!-- 必填 -->
        <name>hadoop.proxyuser.superuser.hosts</name>
        <value>*</value>
    </property>
    <property> <!-- -->
        <name>hadoop.proxyuser.superuser.users</name>
        <value>*</value>
    </property>
    <property> <!-- -->
        <name>hadoop.proxyuser.superuser.groups</name>
        <value>*</value>
    </property>
  
    // **将配置信息刷新** 
    hdfs dfsadmin -refreshSuperUserGroupsConfiguration
    yarn rmadmin -refreshSuperUserGroupsConfiguration
    ```