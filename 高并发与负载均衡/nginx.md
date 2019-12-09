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
* nginx处理连接的过程
    ```
    # URI
     foo://example.com:8042/over/there?name=ferret#nose
     \_/   \______________/\_________/ \_________/ \__/
      |           |            |            |        |
    scheme     authority       path        query   fragment
    ```
    1. nginx收到请求头，取出header部分的host字段值与port，跟server中的每一个server_name与port向匹配
    2. 找到特定的server后，拿到请求URI的path部分,进行location匹配
        * 一个server中只能有一个root配置
        * location匹配
            * location [=|~|~*|^~] path {...}
            1. location path {...}
                * 对path路径与path的子路径均匹配成功
                * e.g. path/   path/f/xx/
                * 当有多个普通匹配成功选择匹配成功最大前缀的那个location进行处理
            2. location = path {...}
                * 精确匹配，只有完全相等才匹配成功
            3. location ~/~* path {...}
                * ~是区分大小写 ~*不区分大小写
                * 对path采用正则匹配
                * 按顺序第一个匹配成功的
            4. location ^~ path {...}
                * 不使用正则表达式
                * 当匹配成功时不再使用后面的正则匹配location了
            * 优先级顺序
                * =     ^~      ~|~*    /|/dir
        * location 代理
            ```
            location /hello {
                proxy_pass https://www.baidu.com/
            }
          
            location ~* ^/s {
                proxy_pass https://www.baidu.com
            }
            ```
            * **对于proxy_pass中的代理最后带了path，比如/，直接连接proxy_pass/path，不带的时候则连接proxy_pass/s.\*的内容**
            
                 
                
    

    