#### AbstractBootstrap::bind(int port)代码梳理
* 作用：用于创建
* server启动代码
```java
public class NettyServer {
    public static void main(String[] args) throws InterruptedException {        // EventLoopGroup就是一个基于selector+channel注册的循环，处理后续的selection
        EventLoopGroup parent = new NioEventLoopGroup(); // 一般为了限制设置nthread=1       // 完成了基本的配置
        EventLoopGroup child = new NioEventLoopGroup();

        try {            // ServerChannel用于接收连接请求，并创建一个子channel
            ServerBootstrap serverBootstrap = new ServerBootstrap();           // 就是设置serverBootstrap相关的字段值
            serverBootstrap                   // 也就是为serverBootstrap实例自身赋值
                    .group(parent, child)                   // 而对于NioServerSocketChannel，其是一个基于NIO Selector的实现用于接收新的连接
                    .channel(NioServerSocketChannel.class)                   // MySocketServerInitializer实现的顶级接口就是ChannelHandler
                    .childHandler(new MySocketServerInitializer());            //    然后向这个channel的pipeline中，添加serverBootstrap.handler(...)传入的handler（如果调用了的话）
            ChannelFuture channelFuture = serverBootstrap.bind(8899);            // 调用sync方法其实就是等待nio server socket channel的启动完成（等价于）
            channelFuture.sync();
            channelFuture.channel().closeFuture().sync();
        } finally {
            parent.shutdownGracefully();
            child.shutdownGracefully();
        }

    }
}
```
* 代码逻辑:serverBootstrap.bind(SocketAddress **localAddress**)
    1. AbstractBootstrap::validate()
        1. 用于核实字段AbstractBootstrap::group字段
            * 判断其非空
            * 该字段就是serverBootstrap.group(parent, child)代码中parent设置的值
        2. 用于核实字段AbstractBootstrap::channelFactory字段
            * 判断其非空
            * 该字段就是serverBootstrap.channel(NioServerSocketChannel.class)底层创建的通道工厂实例的值
    2. 判断localAddress非空
    3. AbstractBootstrap::doBind(SocketAddress localAddress) -> ChannelFuture
        1. AbstractBootstrap::initAndRegister() -> ChannelFuture
            1. 通过创建AbstractBootstrap::channelFactory字段新建**channel**实例（该
                实例用于处理parent接收的连接请求，NioServerSocketChannel的实例）
            2. 调用AbstractBootstrap::init(channel)
                1. 完成对channel（对应于nio server socket channel）的options与attrs进行赋值
                2. 给channel的管道末尾添加一个channel handler（ChannelInitializer，
                    完成一些诸如通道管道追加处理器的功能），这个处理器完成将config.handler()
                    （也就是serverBootstrap.handler(xxx)所指定的handler）追加到这个channel的管道最后。
                    再由channel绑定过的事件循环去执行：再在末尾添加一个用于channel接收连接并传给
                    childGroup的handler（ServerBootstrapAcceptor）
                    ```
                    p.addLast(new ChannelInitializer<Channel>() {
                        @Override
                        public void initChannel(final Channel ch) throws Exception {
                            final ChannelPipeline pipeline = ch.pipeline();
                            ChannelHandler handler = config.handler();
                            if (handler != null) {
                                pipeline.addLast(handler);
                            }
            
                            ch.eventLoop().execute(new Runnable() {
                                @Override
                                public void run() {
                                    pipeline.addLast(new ServerBootstrapAcceptor(
                                            ch, currentChildGroup, currentChildHandler, currentChildOptions, currentChildAttrs));
                                }
                            });
                        }
                    });
                    ```
                    
            3. 将channel注册给EventExecutorGroup中的一个EventExecutor，返回注册结果ChannelFuture实例**regFuture**并返回
                * ChannelFuture这个主要用于
                    1. 封装executor的处理结果以及保留channel实例，
                    2. 还有就是可以添加若干监听器在executor处理（一般异步处理）完成后触发这些监听器
                    3. 其sync与await方法用于阻塞等待executor处理处理结束
                        * sync与await的区别就是sync会多一个抛出异常就是将IO异常
                            以UNSAFE.throwException抛出或者runtime exception抛出，
                            他们都会将发生的IO异常保存在course中
                * ChannelPromise继承ChannelFuture与Promise，其实就是一个可写result的ChannelFuture
                1. 在register过程中，传入一个ChannelPromise实例(new，这是实例就是最终返回regFuture), 然后会在事件循环组中
                    选中一个事件循环（其实就是一个执行循环的executor）将其赋值给channel的eventLoop字段
                    ```
                    // 然后执行
                    // eventLoop就是channel绑定的一个执行循环的executor
                    eventLoop.execute(new Runnable() {
                        @Override
                        public void run() {
                            // 在这里完成之前
                            register0(promise);
                        }
                    });
                    ```
                  
        2. 当channel成功注册到事件循环组中时，通过channel.newPromise()创建一个ChannelPromise **promise**
            （其就是一个可写的也就是可以设置rst等）
        3. 调用AbstractBootstrap::doBind0(regFuture, channel, localAddress, promise)
            * 其完成channel到port的真正绑定
             
            
