#### 基本流程
```
# 一个java进程中一个zk cli对象就够了
1. 创建zk cli对象，包含连接
   ZooKeeper zk = new ZooKeeper("hostname1:2181,hostname2:2181", SESSION_TIMEOUT, new Watcher() {...});
2. 执行事务逻辑（包含exists,getData,getChildren,set,create,delete）
3. 关闭zk
    if (null != zk)
        zk.close();
    // 注意zk是实现AutoClosable接口的实例，而不是实现Closable接口的实例
```