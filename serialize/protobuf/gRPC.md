#### gRPC
* 简介
    * 基于protobuf定义你的服务，是一个功能强大的二进制序列化工具集和语言
    * 为你的服务在不同的语言平台上自动生成符合习惯的客户端以及服务端的stubs
    * 支持双向的流传输以及基于http2的完全可插拔的认证组件
* protobuf版本
    * 在grpc中推荐使用proto3的语法，proto3支持更多的编程语言
* service
    * 定义方式
        ```proto
        service Service {
          rpc func1(MessageType[...]) returns ([stream] MessageType) {}
        }   
        // 参数类型必须是message类型，而thrift则没有这个要求
        ```
    * 类别
        1. 一次性的rpc，就是cli发送一个请求，server返回一个回应，就像调用一个普通函数一样。
        2. 服务器基于流的rpc，cli发送一个请求，服务器返回一个stream消息，cli一致从stream中读取
            消息，直到流中没有更多的消息为止。
        3. 客户端基于流的rpc，cli向流中不断的写入一系列的msg，一旦完成了写入就等待server的读取以及
            返回结果
        4. 双向的流读写模式，cli与server双向的流读写是彼此独立的
* grpc的三种传输实现
    1. 基于netty的传输，是主要基于netty的在cli与svr上的实现
    2. 基于OkHttp的一个轻量级传输实现仅仅面向安卓cli端
    3. 以及用于测试的基于进程的，即svr与cli在同一个进程中