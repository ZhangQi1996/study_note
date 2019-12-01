##### LVS 四层 面向数据包
* 四层，即OSI/ISO七层参考模型的下四层
    * 物理层，数据链路层，网络层，传输层
* S_NAT: source NAT 基于修改源地址的NAT（涉及传输层，修改端口号）
    * 场景：内网经过S_NAT设备（也是网关）与外网通信
    * 内网主机(CIP:CPORT),作为网关的S_NAT设备连接内网的网关GIP, 连接外网的公网IP（NIP）,外网主机(SIP:SPORT)
    * 内网主机经过s_nat向外网发送数据包
        1. cip:cport-->sip:sport
        2. 途径s_nat，将cip:cport-->sip:sport更换成nip:nport-->sip:sport发送到外网
    * 外网主机经过s_nat向内网回复数据包
        1. sip:port-->nip:nport
        2. 途径s_nat，将sip:port-->nip:nport还原成sip:port-->cip:cport发送到内网
     
        
* D_NAT: destination NAT 基于修改目的地址的NAT（一般不涉及传输层）
    * 场景: 外网设备经过D_NAT设备与内网服务器通信
    * 内网服务器主机(SIP:SPORT),作为网关的D_NAT设备连接内网的网关GIP, 连接外网的公网VIP,外网主机(CIP:CPORT)
    * 外网主机cip进过D_NAT向VIP发送数据包
        1. cip-->vip 途径D_NAT
        2. D_NAT经数据包转换为cip-->sip发往内网服务器
        3. 内网服务器发送回应包sip-->cip
        4. sip-->cip数据包通过网关GIP途径D_NAT
        5.D_NAT将数据包转换为vip-->cip回应给外网客户端主机
    * **问题：内网中做服务器的请求与相应流量均要通过中间设备，容易形成响应瓶颈**

#### DR direct routing
``` 
                                           |----------------|                                      
                |-------------------|  RIP==>Server1 (VIP')  |
                |      负载均衡      |  /    |----------------|
Client: CIP===>VIP  转发：不做3次握手 DIP
                |   保证整个会话      |  \
                |      不可分割      |  RIP===>Server2 
                |-------------------|
   CIP:客户端IP
   VIP:虚拟IP          保证会话不可分割就是一个主机在与内部一个服务器通信时，始终转发给这个服务器
   DIP:转发IP
   RIP:server对外的真实IP
   VIP': 在server的巡回地址上绑定VIP的数值
```
* 请求过程
    1. CIP-->VIP
    2. 数据包到达支持DR功能的设备，该设备查找不同server在DR设备中绑定的RIP以及对应网卡的MAC地址，选定并绑定RIPx的MACx
    3. 将CIP-->VIP的数据包发往MACx的物理网卡
    4. 物理地址为MACx的网卡得到数据包，看到目的地址为VIP，而自己的ARP路由表存在arp表项VIP--->巡回地址网卡的mac地址
    5. CIP-->VIP的数据包就发给了巡回地址网卡
* 响应过程
    1. VIP-->CIP的数据包直接通过网关发送出去，不走DR设备
* 注意点
    1. 物理地址为MACx的网卡的ARP路由表只有VIP到内部巡回地址mac的映射，即内部环回接口ip地址到mac的映射对外部是不可见的
        * 关于lo (loopback接口)
            1. 传给环回地址(一般是127.0.0.1 )的任何数据均作为IP输入。
            2. 传给广播地址或多播地址的数据报复制一份传给环回接口,然后送到以太网上。这是因为广播传送和多播传送的定包含主机本身。
            3. 任何传给该主机I P地址的数据均送到环回接口 。
        ```
                    _______________________________
                    |                             |
             DIP-->RIP(ethx)--->VIP/127.0.0.1(lo) |
                    |     **SERVER**              |
                    -------------------------------
        ```
        * 基本每个主机有两个网卡，一是外部网卡（ethx），二是内部环回接口（lo）
        * 将VIP绑定到lo上，且内部VIP对外界不可见
        * 修改linux对于arp的默认配置
        ```
        arp_ignore
            0: 本网卡/接口当要收到对本机的任意一个ip的arp请求，则对其进行响应
            1: 本网卡/接口仅当收对自身网卡/接口ip的arp请求时，才做响应
        arp_announce
            0: 允许使用任意网卡上的IP地址作为arp请求的源IP，通常就是使用数据包a的源IP
            1: 尽量避免使用不属于该发送网卡子网的本地地址作为发送arp请求的源IP地址。
            2: 哪个网卡发送的arp请求，则源ip就是哪个ip
        conf中包含all和eth/lo（具体网卡）的arp_ignore/arp_announce参数，取其中较大的值生效。
        即对于任意接口/网卡，响应/发送请求的处理方式看对应的max{all, interface}
        ```
    2. DIP与RIPx必须在同一子网
        * 即对于DR设备一般有两个网卡，一个连接外网一个链接内网
        
* LVS linux virtual service
    * linux将lvs嵌入到内核中，模块ipvs
    * 该模块的管理工具 ipvsadm
    * ipvs支持的类型
        1. NAT 地址转换
        2. DR 直接路由
        3. TUN  隧道
    * lvs的调度算法
        * 静态
            1. rr轮训
            2. wrr基于权重的轮训
            3. dh
            4. sh
        * 动态
            1. lc最少连接
            2. wlc加权最少连接
            3. sed最短期望延迟
            4. nq：never queue
            5. LBLC基于本地的最少连接
            6. DH
            7. LBLCR基于本地的带复制功能的最少连接
        * 默认是wlc
    * 使用lvs
        * 安装
            * yum install -y ipvsadm
        * Usage:
            1. 设置lvs节点
                * 添加lvs监视
                * ipvsadm -A -t|u|f service-addr [-s scheduler]  
                * -t TCP 
                    * service-addr: ip:port
                * -u UDP 
                    * service-addr: ip:port
                * -f FWM 防火墙标识 
                    * service-addr: MARK NUM
                * e.g. ipvsadm -A -t 192.168.1.10:80 -s rr
            2. 管理集群中的real server
                * 添加RS
                    * ipvsrdm -a -t|u|f service-addr -r server-addr [-g|i|m] [-w weight]
                    * -r server-addr 添加的real server 是server-ip[:new-port]
                    * [-g|i|m]指定lvs类型 -g DR， -i TUN， -m NAT
                    * [-w weight]指定server的权重
                * 修改
                    * ipvsrdm -e ...
                * 删除
                    * ipvsrdm -d ...
                * 查看
                    * -L/l
                    * -n 以数字的格式显示主机地址和端口
                    * --stats 统计数据
                    * --rate 速率
                    * --timeout 显示超时时常
                    * -c 显示当前ipvs的连接状况
            3. 删除所有的集群服务
                * ipvsadm -C
            4. 保存规则
                * ipvsadm -S
                * ipvsadm -S > file # 保存到文件
            5. 载入规则
                * ipvsadm -R
                * ipvsadm -R < file       
    
#### 基于lvs的DR流程
* 1台能上网的作为lvs节点的也可连接到内网主机，若干台内网作为server的主机
* 对于内网server节点
    1. 调整每个server的通告级别
        * echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
        * echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
        * ps: 即对于任意接口/网卡，响应/发送请求的处理方式看对应的max{all, interface}
    2. 为每个server的lo绑定VIP（即利用lo的子接口绑定ip）
        * ifconfig lo:x VIP/netmask_num
* 对于作为DR的lvs节点
    1. 开启转发功能
        * echo 1 > /proc/sys/net/ipv4/ip_forward
    2. 设置lvs监视
        * ipvsadm -A -t VIP:port [-s scheduler]
    3. 对于每个svr添加server绑定
        * ipvsadm -a -t VIP:port -r SERVER-IP[:port] -g [-w weight]
        