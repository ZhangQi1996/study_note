#### EventLoop相关
* interface EventExecutorGroup extends ScheduledExecutorService, Iterable<EventExecutor>
    * EventExecutorGroup是通过调用其next方法来提供EventExecutor。此外，他们还负责EventExecutor的
        整个生命周期，以及以一个全局的方式去停止EventExecutor。
    * 注意到EventExecutorGroup管理着EventExecutor
    * 抽象方法
        1. EventExecutor next()
            * 用于返回EventExecutorGroup中的一个EventExecutor
* interface **EventLoopGroup** extends EventExecutorGroup
    * 是EventExecutorGroup的一个特化，用于channel的注册，当在event loop
        中执行selection操作的时候，channel就会的到处理。
    * EventLoopGroup管理着EventLoop
    * 抽象方法
        1. EventLoop next()
            * 用于返回下一个EventLoop
        2. ChannelFuture register(Channel ch)
            * 将一个通道注册到evt loop，返回的ChannelFuture将在注册完成时立刻得到通知。（非阻塞）
        3. ChannelFuture register(ChannelPromise cp)
            * interface **ChannelPromise** extends ChannelFuture, Promise<Void>
            * ChannelPromise实现类包含一个Channel的引用
            * 使用ChannelFuture将一个通道注册到evt loop，传入的ChannelFuture将在注册完成时立刻得到通知，
                它也会被返回。 
* class NioEventLoopGroup extends MultithreadEventLoopGroup
    * 基于MultithreadEventLoopGroup的一个实现基于NIO Selector的Channels
    * 对其创建实例，底层使用NioEventLoopGroup(int nThreads, Executor e, SelectorProvider sp, SelectStrategyFactory ssf)
        * SelectorProvider（参见java/nio/Selector.md####SelectorProvider）