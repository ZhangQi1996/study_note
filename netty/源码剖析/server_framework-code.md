#### netty server端常见框架代码剖析
```java
public class NettyServer {
    public static void main(String[] args) throws InterruptedException {
        // 用来接收连接请求
        // 就是一个死循环
        // EventLoopGroup就是一个基于selector+channel注册的循环，处理后续的selection
        EventLoopGroup parent = new NioEventLoopGroup(); // 一般为了限制设置nthread=1
        // 用于分发处理连接与请求
        // 不带参默认就是new NioEventLoopGroup(0：Thread nums)
        // 底层有nthreads == 0 ? DEFAULT_EVENT_LOOP_THREADS : nthreads
        // DEFAULT_EVENT_LOOP_THREADS = max(1, 系统属性值 == null ? 处理器个数 * 2)
        // 完成了基本的配置
        EventLoopGroup child = new NioEventLoopGroup();

        try {
            // 服务器启动
            // 是Bootstrap的一个子类，偶那个轻松启动ServerChannel
            // ServerChannel是一个标记接口，也就是仅仅继承一个接口什么都没做，做一个更名的作用
            // ServerChannel用于接收连接请求，并创建一个子channel
            ServerBootstrap serverBootstrap = new ServerBootstrap();
    
            // 采用方法链
            // 就是设置serverBootstrap相关的字段值
            serverBootstrap
                    // 设置parent与child，用于处理所有的对于server channel与channel的事件与IO
                    // 也就是为serverBootstrap实例自身赋值
                    .group(parent, child)
                    // 用处创建channel的一个实例，若所要创建的实例是带参数的，就使用channelFactory(ChannelFactory)来实现
                    // 真正创建的时候在bind(8899)的时候创建,这个代码底层仅仅就是为serverBootstrap赋值一个ChannelFactory实例
                    // 而对于NioServerSocketChannel，其是一个基于NIO Selector的实现用于接收新的连接
                    .channel(NioServerSocketChannel.class)
                    // .handler(null); // deal with sth at parent event loop group, e.g. do logging，用于处理请求
                    // childHandler is that do sth at child event loop group
                    // 设置用于处理channel请求的处理器，也就是serverBootstrap的一个字段的赋值
                    // MySocketServerInitializer实现的顶级接口就是ChannelHandler
                    .childHandler(new MySocketServerInitializer());

            // 表示服务器启动
            // 完成serverBootstrap相关字段的核实
            // 完成相关的初始化与注册：由于在serverBootstrap.channel方法中设置了创建channel的工厂实例，
            //    这里就是创建一个channel，设置channel options（这个也是serverBootstrap中的一个字段）与attr，
            //    然后向这个channel的pipeline中，添加serverBootstrap.handler(...)传入的handler（如果调用了的话）
            ChannelFuture channelFuture = serverBootstrap.bind(8899);
            // 调用sync方法其实就是等待nio server socket channel的启动完成（等价于）
            channelFuture.sync();
            channelFuture.channel().closeFuture().sync();
        } finally {
            parent.shutdownGracefully();
            child.shutdownGracefully();
        }

    }
}
```

        