#### netty基本介绍
* 介绍
    * netty是一个基于异步事件驱动的网络应用框架，对于服务器以及客户端，其提供了一个高性能协议化的快速开发。
* 特征
    1. 设计
        1. 无论对于阻塞还是非阻塞的各种传输类型，都提供了统一的API
        2. 其基于一个灵活可拓展的事件模型允许将关注分离
        3. 提供了高度定制化的线程模型--单线程，一个或者多个的线程池
        4. 真正的无连接数据报传输支持
    2. 使用方便
        * jdk5(netty3.x), jdk6(netty4.x)
            * 若使用http2则需要更多的要求，详见https://netty.io/wiki/requirements-for-4.x.html
    3. 性能
        1. 更高的吞吐量，更低的延迟
        2. 更少的资源消耗
        3. 最小化不必要的内存复制（零拷贝）
    4. 安全
        1. 提供了SSL/TSL和StartTSL的支持
    5. 社区
* 网址
    1. 官网
        * https://netty.io/
    2. 文档    
        * https://netty.io/4.1/api/index.html   
* 常用来做什么
    1. 用来做http服务器，做类似tomcat容器，做类似springmvc，strust2等等，但是netty在这方面没有自己的规范。
        其是一种底层的，比如连请求路由都没有提供
    2. Socket开发（应用最为广泛），可以在socket之上开发自己的协议
    3. 支持长连接开发，比如websocket
* 编写netty程序的步骤
    1. 编写server
    2. 编写自己定义的Initializer对象，往该对象中添加诸多中间handler（可以理解为中间件），在handler内部重写
        诸多的事件方法
* 中间handler的处理顺序
    * handler added
    * channel registered
    * channel active
    * channel read
        * 出现读多次，是因为netty默认会把一次请求的内容分割成若干段
    * channel read
    * channel read complete
    * channel read complete
    * channel inactive
    * channel unregistered
    * handler removed     
* 长连接中的心跳机制
    * 虽然通信双方建立了通信信道，但是当一个突然中断，另一方是无法知晓其中断了的。
        所以需要引入心跳机制
    
