#### nginx 七层 面向请求
* 即包含OSI/ISO的七层
    * 物理层，数据链路层，网络层，运输层，表示层，会话层，应用层
```
// 基本架构
                                             / servers
clients     \                       / nginxs - servers
...         - LVS（做负载均衡直接转发） -  nginxs（做静态资源请求与负载均衡与查看请求做反向代理转发）
clients     /                       \ nginxs - servers
                                             \ servers

// 比如一个整个系统按服务拆分多个模块服务
// 当一个请求到达nginx，nginx去读判断若是静态资源请求则直接返回
// 若是请求服务，则根据规则反向代理转发给后台对应的服务器
```
* 安装tengine（nginx的优化版本）
    * wget http://tengine.taobao.org/download/tengine-2.3.2.tar.gz
    * tar -xzf tengine-2.3.2.tar.gz -C /target-dir
    * cd /target-dir/tengine-2.3.2
    * yum install -y gcc pcre-devel openssl-devel
    * ./configure --prefix=/install-dir
    * make && make install &   # make成功并安装
* nginx分为两部分
    1. 一个master进程 root权限
        * 支持热加载
        * 当修改了配置文件，通过service nginx reload
        * master会fork若干个符合新配置的worker子进程，处理来的新连接
        * 而在运行的旧worker进程保持原来的配置继续运行，当当前周期运行完毕，则回收这个旧worker进程
        * **当涉及临界区资源时，比如新旧worker可能涉及对共享资源的操作时候，可能涉及不一致，所以这个时候就不能采用热加载，只能停服再开**  
         
    2. 若干个worker进程  nobody权限（低权限）
    

    