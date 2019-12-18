#### 实例化zk cli时候传入的watcher对象
```
zk = new ZooKeeper("master:2181,qc:2181,slave1:2181", 30000,
    (e)->{LOGGER.info("zk: {}, {}", e.getState(), e.getType());});
// wachter会因为zk cli状态的变化而触发，(也可能会因为节点时间而触发【一般不触发】)
// 可以通过"SyncConnected".equals.(e.getState) 来判断zk的连接成功
// 通过"Closed".equals.(e.getState) 来判断zk的成功关闭连接
```
#### zookeeper观察机制
* **服务端只存储事件的信息**,**客户端存储事件的信息和Watcher的执行逻辑**.
* zk cli是线程安全的,每一个应用只需要实例化一个zk cli即可，同一个zk cli实例可以在不同的线程中使用。
* **zk cli会将这个Watcher对应Path路径存储在ZKWatchManager中**（以此来保证线程安全）
* 同时通知zk svr记录该Client对应的Session中的Path下注册的事件类型
    * 即每个cli都可以根据自己的需求向znode绑定一个观察
* 当zk svr发生了指定的事件后,zk svr将通知zk cli哪个节点下发生事件类型，zk cli再从ZKWatchManager
    中找到相应Path，取出相应watcher引用执行其回调函数process
#### 为节点设置监听与触发监听（观察）
* 可以设置观察的操作：
    * 一下三种都是可以带观察或者不带观察，不带观察就是单纯为了查看状态
    * **注意以下的注册的观察在以此触发后就失效了，故需要在每次成功触发后再次注册**
    * **注意若只是单纯的使用，则不要用watcher**
    1. exists 判断path这个znode是否存在
    2. getChildren 返回path这个znode下的children znode
        * 返回孩子节点列表（List<String>），不保证有序
        * 当本path的znode被删除，或者孩子节点的create/del都会触发事件
    3. getData 返回path这个znode的byte数组形式的数据
        * set/del 触发
* 可以触发观察的操作：
    1. create
    2. delete
    3. setData
#### watch机制用来监控集群
* 集群状态监控示例
    * 为了确保集群能够正常运行，ZooKeeper 可以被用来监视集群状态，这样就可以提供集群高可用性。使用 ZooKeeper 的瞬时（ephemeral）节点概念可以设计一个集群机器状态检测机制：
    ```
    # znode tree
    /
    |------/zookeeper
    |------/hdfs
           |-------/nn1
           |-------/nn2
           |-------/dn1
           |-------/dn2
           |-------/dn3                
    # /hdfs/xxx均是临时节点
    ```
    1. 每一个运行了zk cli的生产环境机器都是一个终端进程，我们可以在它们连接到zk svr后在zk cli创建一系列对应的瞬时节点，
        可以用/hdfs来进行区分。
    2. 这里还是采用监听（Watcher）方式来完成对节点状态的监视，通过对/hdfs节点的NodeChildrenChanged事件的监听来完成这一目标。
        监听进程是作为一个独立的服务或者进程运行的，它覆盖了process方法来实现应急措施。
    3. 由于是一个瞬时节点，所以每次客户端断开时znode(也就是/hdfs/xxx)会立即消失，这样我们就可以监听到集群节点异常。
    4. NodeChildrenChanged事件触发后我们可以调用getChildren方法来知道哪台机器发生了异常。
    ```
    # 对于server cluster(e.g. cluster)
    1. 每次启动一个server，就在其进程中向zk的/cluster集群目录下注册临时序列化的znode(e.g. /cluster/server0000x)
    2. 并且每个注册的znode带有的数据都是各个server的位置信息
    # 对于client
    1. 在启动cli的时候就通过zk cli实例调用zk.getChildern("/cluster", watcher);
    2. 这样就得到了最新可用的server列表znode信息，再通过遍历用zk.getData的方式获得准确的各个可用节点的位置信息。
    ```
