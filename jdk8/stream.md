#### Stream接口
* 3个部分
    1. 源
    2. 另个或多个中间操作
        * 中间操作返回的是新的stream对象
        * 对一个源的输入元素而言，所有的中间操作其实是在一轮处理中完成的。故存在短路现象，即操作串中有一个不通过，则这个元素的
            接下来处理都不会继续。
        
    3. 终止操作
        * 终止操作可能会带来一些副作用(side-effect),比如对于stream.forEach(Function),
            可能会造成对流中元素潜在的状态修改操作。 
        * 只有当终止操作开始的时候，源的数据才会开始被计算消费
* 流的操作分为：
    1. 惰性求值（中间操作）
        * 返回Stream
    2. 及早求值（终止操作）
        * 不返回，返回标量（可能为空）或者返回Optional
    * 尽量使用链式方式处理
* 创建流
    * 数组
        1. Stream.of(T... t)
        2. Stream.of(T[] ts)
        3. Arrays.stream(T[] ts)
    * 集合
        1. Collection.stream()
* 流转其他
    * 流转类中元素类型的数组
        * streamInstance.toArray(ElementType[]::new)
            * 方法参数是IntFunction<A[]> generator, 接收的是一个流中元素长度的int值length，返回元素类型
                长度为length的数组        
    * 流转集合
        * streamInstance.collect(Supplier supplier, BiConsumer accumulator, BiConsumer combiner)
            * supplier用于产生一个新的容器用于盛放所有聚集的元素
            * accumulator用于将数据流中元素取出进行消费处理后生成的新元素放入supplier所产生的容器中
            * combiner则是将在parallel模式下的多个supplier所产生的容器合并汇聚最终返回结果
            ```java
            public class Demo {
                public static void main(String[] args){
                    List<String> asList = stringStream.collect(ArrayList::new, 
                                                                  ArrayList::add,
                                                                  ArrayList::addAll);
                    String concat = stringStream.collect(StringBuilder::new, StringBuilder::append,
                                                                  StringBuilder::append)
                                                                  .toString();
                }
            }
            ```
        * streamInstance.collect(Collector collector)
            * streamInstance.collect(Collectors.toList())
            * streamInstance.collect(Collectors.toCollection(Collection::new))
* 方法
    * static generate(Supplier<T>) -> Stream<T> （源操作）
        * 通过Supplier无限长度的流（即每次调用Supplier的动作）
    * static iterate(T seed, UnaryOperator<T> f) -> Stream<T> （源操作）
        * 通过seed作为初始种子，调用f(seed)为流中第一个值，第二值就是f(f(seed)),第三个就是f(f(f(seed))),..
          从而也产生一个无限流
    * static empty() （源操作）
        * 产生一个空流
    * map （实例方法，中间操作）
    * mapToInt/Long/Double （实例方法，中间操作）
        * 当存在更具体的方法时，尽量使用具体的方法 
    * flatMap(Function<T, Stream<R>> mapper) -> Stream<R>（实例方法，中间操作）
        * 将T类型的实例通过mapper转换为流，然后flatMap会将多个流合并为一个流
    * distinct() -> Stream<T> （实例方法，中间操作）
        * 根据equals方法返回不同元素组成的流
    * limit(long size) -> Stream<T>（实例方法，中间操作）
        * 就是限制流的长度
    * skip(long skipHead) -> Stream<T> (实例方法，中间操作)
        * 就是忽略掉流中前数个元素
    * collect(Collector c/Supplier ...) -> R （实例方法，终止操作）
    * count() -> long （实例方法，终止操作）
        * 得到流中元素个数
    * peek(Consumer) -> Stream<T>
        * 就是对流中每个元素执行consumer动作，但最终仍然返回原始流。
    * findFirst() -> Optional<T>（实例方法，终止操作）
    * findAny() -> Optional<T>（实例方法，终止操作）
    * forEach(Consumer) -> void
    * forEachOrdered(Consumer) -> void
        * 以源中原始的顺序去访问流中元素.  
* 流操作的注意点
    * 由于流的并行/并发性，所以流主要是面向无状态的，不中途修改的。若中途发生状态变化，可能导致并发异常。
        这个并发异常状态是跟源相关的，比如原为ConcurrentHashMap则不存在并发问题。所以在并发状态下，尽量不
        要去对流元素进行状态修改。（即流管道的结果是不依赖与流中途的状态修改的）
    * stream是继承了AutoClosable接口的，故使用try with resource的方式对资源进行close。但一般情况下
        是不用close的，当源是IO channel（e.g. Files(Path, Charset)）时是需要close的  
    * stream的串行/并行处理是通过底层的一个bool类型维护的。串行/并行由最后一个sequential/parallel()来决定,
        通过stream.isParallel()来判断
    
    
    

#### IntStream接口
* 注意：该流中包含的均是原子类型的int
* 生成int流的其他方法
    1. IntStream.range(startInclusive, endExclusive)
    2. IntStream.rangeClosed(startInclusive, endInclusive)
#### 流的相关概念
* 流与集合的差别
    * 流：不提供直接的元素访问或者操作，而关注于与数据源声明式的描述以及在聚合中的**计算操作**。
        若提供的流并未提供预想的功能，可以通过stream.iterator/spliterator()来提供一个可控的遍历操作
    * 集合：关注的是高效的**数据管理与访问**
* 流的相关操作
    1. 两个流的笛卡尔积
        * stream1.flatMap(item1 -> stream2.map(item2 -> new Pair(item1, item2)))
    2. 一个流中的groupBy
        * stream.collect(Collectors.groupingBy(Function<T, K> classifier)) -> Map<K, List<T>>
            * 通过传入同一个分类的动作函数，T就是流中的每一个元素，R就是根据分类的依据
            * 使用场景select * from stu group by name
        * stream.collect(Collectors.groupingBy(Function<T, K> classifier, Collector<V, T, A> downstream)) -> Map<K, V>
            * downstream这个collector其实就是将属于特定类别的子流进行collect动作
            ```java
            import java.util.stream.Collectors;
            public class Demo {
                public static void main(String[] args){
                    // select name, count(*) from stu group by name;
                    stuStream.collect(Collectors.groupingBy(Student::getName, Collectors.counting()));  
                    // select name, avg(score) from stu group by name;
                    stuStream.collect(Collectors.groupingBy(Student::getName, Collectors.averagingDouble(Student::getScore)));  
                }
            }
            ```
        * stream.collect(Collectors.groupingBy(Function<T, K> classifier, Supplier<M> s, Collector<V, T, A> downstream)) -> M<K, V>
            * 仅仅多一个Supplier用于返回何种类型的map容器
            * collect(Collector) -> R 详解
            ```java
            // A 中间容器， R结果容器
            public final <R, A> R collect(Collector<? super P_OUT, A, R> collector) {
                A container;
                if (isParallel()
                        && (collector.characteristics().contains(Collector.Characteristics.CONCURRENT))
                        && (!isOrdered() || collector.characteristics().contains(Collector.Characteristics.UNORDERED))) {
                    // 当stream是无序并行流且标记为并发时
                    // 调用supplier，accumulator
                    // 由于是并发处理所以用不到combiner
                    container = collector.supplier().get();
                    BiConsumer<A, ? super P_OUT> accumulator = collector.accumulator();
                    forEach(u -> accumulator.accept(container, u));
                } else {
                    // 是 串行流 或者 非并行无序 时
                    container = evaluate(ReduceOps.makeRef(collector));
                }
                return collector.characteristics().contains(Collector.Characteristics.IDENTITY_FINISH)
                       ? (R) container
                       : collector.finisher().apply(container);
            }
            ```
    3. 一个流中的分区(目前jdk8仅支持true/false两种分区)
        * **其实分区是分组的一个特例，分区可以通过分组实现**
        * stream.collect(Collectors.partitioningBy(Predicate<T> pred)) -> Map<Boolean, List<T>>
        * stream.collect(Collectors.partitioningBy(Predicate<T> pred, Collector<V, T, A> downstream)) -> Map<Boolean, List<T>>
            * downstream这个collector其实就是将属于特定分区的子流进行collect动作

#### BaseStream解析
* 是Stream，Int/Long/DoubleStream等的父接口
* 基本接口方法
    1. Iterator<T> iterator()
    2. Spliterator<T> spliterator()
    3. boolean isParallel()
        * 该方法需要在调用终结操作之前调用，否则结果无法预料
    4. S sequential()
        * S extends BaseStream<T, S>
        * 返回串行流
    5. S parallel()
        * 返回并行流
    6. S unordered()
        * 返回无需流
    7. S onClose(Runnable closeHandler)
        * 返回一个包含关闭处理器的stream，当stream的close方法被调用过的时候，close方法中就会去调用
            这些closeHandler。这些closeHandler是按照添加顺序执行的，若在执行closeHandler时，抛出异常，其后的
            closeHandler也会执行。
        * 在多个closeHandler中抛出的异常，只会抛出第一个异常给close方法的调用者，其后出现的异常都会被压制。若出现其后的异常
            与第一个异常相同(Objects.equals(o1, o2))，则不会压制这个异常。
        ```java
        import java.util.Arrays;import java.util.List;import java.util.stream.Stream;public class Demo {
           public static void main(String[] args){
               List<String> list = Arrays.asList("hello", "world", "hello world"); 
               try (Stream<String> stream=list.stream()) {
                   stream.onClose(() -> System.out.println("first close"))
                       .onClose(() -> {
                           throw new RuntimeException();
                           System.out.println("first close");
                       }).onClose(() -> System.out.println("first close"))
                       .forEach(System.out::println);
                   
               }
           }
       
       }
        ```
    
#### Spliterator解析
* 介绍
    * 是一个对源元素进行遍历和分区的对象，源可以是数组，集合，IO channel，生成器函数
    * 对源的修改应早于分割迭代器与源的的绑定，否则会抛出并发修改异常  
* spliterator的特征
    1. ORDERED
        * 比如list就是ordered，而set就是unordered
    2. DISTINCT
        * 元素各不相同
    3. SORTED
        * 有序的（比如增序降序）
    4. SIZED
        * 知道本spliterator的控制大小
    5. NONNULL
        * 非空
    6. IMMUTABLE
        * 内容不可修改
    7. CONCURRENT
        * 在没有外部同步的情况下，支持并发修改
        * 顶级的Spliterator不应该包含特征CONCURRENT与SIZED，因为标记为并发说明Spliterator支持并发修改（包括增删元素），
            故就不能保证Spliterator中的元素数目固定了。
    8. SUBSIZED
        * 知道trySplit返回的新的Spliterator的控制大小
        * 从trySplit返回的子spliterator都是SIZED与SUBSIZED的
        
* 接口方法
    * 通常对于一个spliterator所处理的一个分块中，有origin与fence，其实就等价于array中的当前索引i与边界array.length
    1. abstract tryAdvance(Consumer) -> boolean
        * 就是若当前分块中存在的下一个元素进行action动作，并伴随指针后移
    2. default forEachRemaining(Consumer) -> void
        * 就是若当前分块中剩余的所有元素就对其进行action动作，并伴随指针移到fence
    3. abstract trySplit() -> Spliterator<T>
        ```    
        //  spliterator.trySplit() -> true的情形     
        spliterator  -> spliterator' 
                     -> spliterator1 (分割出来的新spliterator)
        ```
        * 若当前分割迭代器所控制的能分区，则分区
        * 以源为array举例，比如本spliterator控制array\[l,r\]，常见的动作就是返回一个new spliterator
            ，其控制着array\[l, (l+r)/2\],而返回新的之后，本spliterator则控制array\[(l+r)/2+1, r\\].
        * 除了输入源是无限的，必须保证一直调用trySplit()最终会返回null（比如设置一个分割阈值）
        * 需要保证spliterator.estimateSize() >= spliterator'.estimateSize()，
            spliterator.estimateSize() >= spliterator1.estimateSize()
        * 当本spliterator包含SUBSIZED特征，则要保证
            spliterator.estimateSize() = spliterator'.estimateSize() + 
            spliterator1.estimateSize()
    4. abstract estimateSize() -> long
        * 返回本spliterator中的可遍历的元素估计数量，当元素个数为无限/未知（比如迭代器），或者计算成本太高的情况下就返回Long.MAX_VALUE
        * 以下两种情况必须返回精确值
            1. 当本spliterator是包含SIZED特征，且尚未部分遍历或split时
            2. 当本spliterator是包含SUBSIZED特征，且尚未部分遍历时
    5. default getExactSizeIfKnown() -> long
        * 若本spliterator包含SIZED特征，就返回其精确可遍历大小否则返回-1
    6. abstract characteristics() -> int
    7. default hasCharacteristics(int characteristics) -> boolean
    8. default getComparator() -> Comparator<T>
        1. 源是通过Comparator排序的就返回这个Comparator
        2. 源是通过Comparable自然排序的就返回null
        3. 其他情况抛出非法状态异常
* 实现举例
    1. IteratorSpliterator类
        * 用于处理可以迭代类型的源输入比如：Collection，Iterator等等
        * 它的split策略就是根据batch大小trySplit出一个Array
#### Spliterator.OfPrimitive子接口
* 对于原生类型的Spliterator，OfPrimitive<T, T_CONS, T_SPLITR>
    * T就是原生类型的包装类型，T_CONS就是Consumer对于原生类型的特化，
        T_SPLITR就是Spliterator对于原生类型的特化(Spliterator.ofInt)
    ```java
    public interface OfInt extends OfPrimitive<Integer, IntConsumer, OfInt> {
        @Override
        default boolean tryAdvance(Consumer<? super Integer> action) {
            // 注意Consumer与IntConsumer不存在继承关系
            // 下面的判定可能成立呢？暂时未知
            if (action instanceof IntConsumer) {
                return tryAdvance((IntConsumer) action);
            }
            else {
                if (Tripwire.ENABLED)
                    Tripwire.trip(getClass(),
                                  "{0} calling Spliterator.OfInt.tryAdvance((IntConsumer) action::accept)");
                // 由于在原生类型与其包装类型存在装箱拆箱，故
                // 可以有这种写法
                /*
                Consumer<Integer> c = System.out::println;
                IntConsumer ic = c::accept;
                */    
                return tryAdvance((IntConsumer) action::accept);
            }
        }
    }
    ```
#### stream的构建
* StreamSupport辅助类
    * 用与生产stream实例
* Sink接口
    * 继承自Consumer接口
    * 方法
        1. default begin(long size) {}
            * 将sink状态重置一接收最新的数据集，这个方法必须在sink收到数据之前被调用，
                在调用end方法之后，你可能会调用跟这个begin方法来重置这个sink以用来完成另一个计算操作，
                参数size是会为推送到下游的准确数据大小，若数据大小未知或者无线则设置此值为-1。
            * 调用此方法之前sink为initial state，调用之后sink为active state
        2. accept
            * 消费动作处于active state
        2. default end() {}
            * 当所有数据都被推送到下游的时候，若sink是有状态的，则end方法应该在调用的时候将若干存储的状态发送给下游，
                并且应该清理一些集聚状态以及相关资源。
            * 调用之前sink为active state，调用此方法之后sink为initial state
    * 作用
        1. 用来封装中间阶段的相关操作
* AbstractPipeline抽象类
    * 继承抽象类PipelineHelper
        * 用来捕获stream pipeline中的相关信息，比如输出状态（T是ref, int, long, double?）, 
            若干中间操作, 流的标志（并发，有序，非空等）, 是否流并行等
    * 实现接口BaseStream
        * BaseStream负责一些iterator(), spliterator(), isParallel(), close(), onClose()
    * 功能
        1. 实现stream pipeline中的source初始化创建
            * 使用AbstractPipeline(Supplier<? extends Spliterator<?>> source, int sourceFlags, boolean parallel)
                或AbstractPipeline(Spliterator<?> source, int sourceFlags, boolean parallel)构造器完成source stage的创建  
            * 变现为实例化ReferencePipeline.Head         
        2. 实现本中间阶段实例化与上一阶段（pipeline）的拼接
            * 使用AbstractPipeline(AbstractPipeline<?, E_IN, ?> previousStage, int opFlags)构造器完成拼接
            * 比如设置当前阶段的前一阶段，本阶段的流操作标志，将前一阶段的后阶段设置为本阶段，
                设置当前阶段的深度（距离源阶段的距离），设置源阶段等等
            * 通过双向链表的机制完成不同阶段的链接（previousStage，nextStage）
            * 变现为实例化ReferencePipeline.Stateless抽象类的子类（一般重写opWrapSink方法）
        3. 由于实现了BaseStream接口，实现了BaseStream中的诸如iterator, spliterator, close等抽象方法
        4. 定义了若干中间操作的封装抽象方法，比如：
            1. opWrapSink(Sink downStreamSink) -> Sink
                * Sink继承自Consumer
                * 返回的一般就是本层Sink，由本层Sink封装下游Sink，由于中间操作一般会提供相应的Function f （Input -> Output）,
                    所以返回的就是here_sink( downstream_sink( downstream_downstream_sink( ... ) ) ), 也就是说本层的sink
                    包含了有下层的sink，有here_sink.accept(INPUT)就是
                    调用downstream_sink.accept( here_function.apply(INPUT) )也就是
                    downstream_downstream_sink.accept( downstream_function.apply( here_function.apply(INPUT) ) )
                * 比如：当输入的STREAM中的元素包含DISTINCT特征，当追加stream::distinct()的中间操作的时候就直接返回downStreamSink即可，
                    因为本层的distinct sink是多余的。
        5. 实现了终止操作的调用方法evaluate(TerminalOp) -> R
    * 子类
        1. ReferencePipeline抽象类
            * 继承AbstractPipeline抽象类
            * 实现Stream接口
            * 功能
                1. 实现stream的相关操作（包括中间，终结操作）
                2. 由于继承AbstractPipeline抽象类，故自带实现stream pipeline中的source和intermediate stage的初始化创建
            * 子类
                1. ReferencePipeline.Head内部静态类
                    * 继承ReferencePipeline抽象类
                    * 作用
                        1. 用来表示stream pipeline的source stage
                        2. source阶段主要就是完成数据源的spliterator动作
                        3. 为forEach提供了优化方案（当直接在source stage后面接forEach的终止操作，直接调用Head中的forEach实现）
                2. ReferencePipeline.StatelessOp内部抽象静态类
                    * 继承ReferencePipeline抽象类
                    * 作用
                        1. 用来表示stream pipeline的intermediate stage
                        2. intermediate stage主要就是完成中间操作，中间操作用Sink封装
                            * 这也侧面的表示了为什么stream.mid_op1().mid_op2()是不会执行计算的，是因为这样的链式
                                书写只是**完成了计算动作链的封装**，并没有真正执行计算。

* TerminalOp接口
    * 封装着终止操作
    * 方法
        1. default inputShape() -> StreamShape（默认返回REF）
            * 返回流封装的类型是原生类型还是引用类型
        2. default getOpFlags() -> int（默认返回0）
            * 获得本流操作特征参见StreamOpFlag枚举
        3. default evaluateParallel(PipelineHelper<E_IN> helper, Spliterator<P_IN> spliterator) -> R
            默认执行串行实现
            * 并行执行终结操作
        4. abstract evaluateSequential(PipelineHelper<E_IN> helper, Spliterator<P_IN> spliterator) -> R
            * 串行执行终结操作
    * 实现类
        1. FindOp
            * 位于FindOps工厂类中
        2. MatchOp
            * 位于MatchOps工厂类中
        3. ForeachOp
            * 位于ForeachOps工厂类中
        4. ReduceOp
            * 位于ReduceOps工厂类中
    * 使用
        * 通过在stream的终结方法中调用evaluate(TerminalOp) （也就是ReferencePipeline子类实例.evaluate(TerminalOp)）
* XXXOps工厂类
    * 这些工厂类都是用来产生对应所需的TerminalOp实现类实例的（诸如ReduceOp）
    * 常见工厂方法
        1. static makeRef(Consumer c, boolean ordered) -> TerminalOp
            * ref的意思就是产生面向处理元素为引用类型的TerminalOp实现类实例
            * 常见的还有makeInt, makeDouble, makeLong
    
        
        
                        
    
