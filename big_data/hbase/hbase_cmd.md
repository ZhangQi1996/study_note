* hbase shell
    * 进入shell
    * flush
        * 将mem store的数据写入storefile中
* hbase hfile
    * -f 查看storefile文件
    * -m 打印meta 配套-f使用
    * -p 打印k-v  配套-f使用
* 启动hbase的REST server
    1. 前台启动
        * hbase rest start [-p port]
    2. 后台启动
        * hbase-daemon.sh start rest [-p port]
        * 关闭 hbase-daemon.sh stop rest
        