#### RMI (remote method invocation)
* client: Stub
* server: Skeleton
* 只针对JAVA
#### RPC (remote procedure call)
* 跨语言的
1. 定义一个接口说明文件：描述了对象（接口体），对象成员，接口方法等一系列信息
2. 通过rpc框架所提供的编译器，将接口说明文件编译后才能具体语言文件
3. 在客户端与服务器端分别引入RPC编译器生成的文件，即可像调用本地方法一样调用远程方法
* protobuf
    * 对于netty的msg泛化手段
        1. 使用基于netty的自定义协议（在消息首部添加标志位等手段）
        2. 通过.proto文件的定义方式来完成的
    * 对于多个终端需要引用同一份protobuf编译的class文件，如何较好的解决：
        1. 使用git submodule(git repo中的sub repo)（不建议）
            * 比如三个项目server-proj, cli-proj, 最后一个就是protobuf-proj, 其中
                protobuf-proj是server-proj和cli-proj的子repo, 当父repo repo进入子
                repo protobuf-proj进行pull的时候，父项目就是同时更新pull子repo：protobuf-proj的内容
            * 缺陷：一般git分支有: develop, test, master. 在dev分支上进行开发，开发到一定阶段，在test分支上
                由测试人员进行测试，最后校验通过后发布推送到master分支上，一般test分支与master分支应该环境
                是一样的。由于外层repo与内层sub repo分支并不是自动维持同步的，比如外层repo由dev->test，而sub repo
                不会自动切换，这就很麻烦
        2. 使用git subtree（推荐），与git submodule类似，但是不会有sub repo，它会将中间repo的代码与
            所要引用的repo进行代码合并。