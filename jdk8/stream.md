#### Stream接口
* 3个部分
    1. 源
    2. 另个或多个中间操作
        * 中间操作返回的是新的stream对象
    3. 终止操作
        * 终止操作可能会带来一些副作用(side-effect),比如对于stream.forEach(Function),
            可能会造成对流中元素潜在的状态修改操作。 
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
    
    
    