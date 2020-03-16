#### 用于collect的Collector<T, A, R>类
* T就是流中的元素类型，R就是最终返回的容器类型，A就是可变的中间聚集的类型
    * 若finisher()的操作并没有进行类型转换，则A==R
* 它是一个可变的规约操作，将集聚输入元素到可变容器中，此外也可以（可选的）在所有元素累积后
    将最终结果进行转换表示。支持串行/并行。
* 基本组成方法（用于构建基本的Collector实例）
    * 注意以下方法在collect的调用过程中，**除了characteristics都只会被调用一次**，故一般情况将相应的定义定义在
        对应的方法体中。
    1. supplier() -> Supplier<A> (实例方法)
        * 用于创建一个新的结果容器a（返回的是一个创建动作函数）
    2. accumulator() -> BiConsumer<A, T> (实例方法)
        * 用于将新的元素将入到结果容器a中
    3. combiner() -> BinaryOperator<A> (实例方法)
        * 将两个部分结果容器合并成一个同类型的返回容器（用于并发），使用一个部分结果容器中的所有
            元素都追加到另一个容器中，最终见这个容器返回。或者是将两个部分容器中的结果元素放置到一个
            新的结果容器中并返回。
        * 与简单的collect(Supplier<R> s, BiConsumer<R, T> a, BiConsumer<R, R> c)对比，
            s用来提供最终返回的容器，a用来处理所有T类型的元素并将其聚集于返回的容器r中，
            c就是在处理并行时的多路结果归约. 这里的明显区别就是一个是BiConsumer一个是BiOperator，
            由于对于Collector而言，其在规约合并后的结果容器可能还存在一个最终类型转换，而对于
            collect(Supplier<R> s, BiConsumer<R, T> a, BiConsumer<R, R> c)方法而言，其不存在
            最终的类型转换，换句话说就是其比Collector要求更简单.
        * 对于串行处理模式，只会通过supplier创建一个结果容器。而对于并行的，则会根据对输入的分区，创建对应
            数量的中间结果容器，通过使用combiner所提供的合并动作来将所有部分结果进行合并一个结果容器.
        * 为了满足在串行与并发两种情况下的结果一致性，从combiner要保证identity（同一性）与associativity（结合性）
            1. identity（同一性）
                * 也就是满足中介结果a的等式： a == combiner.apply(a, supplier.get())
                * 也就是空容器不影响中间结果的值
            2. associativity（结合性）
                * 就是满足分开计算与单独串行计算的结果一致
    4. finisher() -> Function<A, R> (实例方法)
        * 返回一个将a进行最终的转换的动作函数 (可选操作，也就是可以转换也可以不转换)
    5. characteristics() -> Set<Characteristics> (实例方法)
        * 由于其返回的并非动作且在collect的过程中需要对Collector的相关特征进行过滤判断，
            所以本方法会被调用多次。
* 常用方法
    1. static of(Supplier<R> s, BiConsumer<R, T> a, 
            BinaryOperator<R> c, Characteristics... cs) -> Collector<T, R, R>
        * 创建一个不带finisher的Collector实例
        
* Collector的特征
    1. CONCURRENT
        * 注意使用该字段是在parallel stream的前提下的
            1. 当**没有提供了CONCURRENT特征**，则对并行流对于**每一分区**分别使用一个容器进行处理（即对每一个分区调用一次Supplier动作）
            2. 当**提供了CONCURRENT特征**，则对并行流对于**全部分区之间使用一个容器在并发线程安全的情况下进行处理**
        * CONCURRENT通常与UNORDERED搭配使用
            * 对于输入的源在并发的情形下一般是不要求保证其有序的
    2. UNORDERED
        * 表示Collector的操作并不保证对源输入数据的顺序
    3. IDENTITY_FINISH
        * 表示finisher就是一个identity操作，通常做法就是在finisher方法中抛出一个不支持异常，前提是需要保证A到R可以cast
        * 当定义的Collector中加入了IDENTITY_FINISH特性，则不会调用finisher函数，直接通过强制转换A -> R
    * 通过对特征的设置达到对规约操作的优化
* Collector实例串行使用的等价代码
    ```java
    // Supplier<R>
    R container = collector.supplier().get();
    for (T t : streamData) {
        // BiConsumer<R, T>
        collector.accumulator().accpet(container, t);
    }
    // Function<R, R>
    return collector.finisher().apply(container);
    ```

#### 辅助类Collectors
* 提供了Collector常见特征的集合
    1. CH_CONCURRENT_ID
        * 由于正常情形下CONCURRENT是跟UNORDERED搭配使用的
        * CONCURRENT，UNORDERED，IDENTITY_FINISH
    2. CH_CONCURRENT_NOID
        * CONCURRENT，UNORDERED
    3. CH_ID
        * IDENTITY_FINISH
    4. CH_UNORDERED_ID
        * UNORDERED，IDENTITY_FINISH
    5. CH_NOID
        * 返回一个不带任何特征的空集合
* 提供了Collector的常见具体实现，是一个工厂类
* 常用方法(均为静态方法)
    * 区分Collectors中的reducing方法与Stream中的reduce方法
        1. reducing返回的是Collector，reduce返回的是标量
        2. reducing用于处理可变规约而reduce则是不变规约
    1. minBy, stream.collect(Collectors.minBy(...)) -> Optional
        * min的Collector形式，等价于stream.min(...)
    2. maxBy, 同minBy
    3. averagingInt/Long/Double, stream.collect(Collectors.averagingInt(...)) -> Double
        * 通常在不使用流的mapToInt/Long/Double之类的mapper，从而通过此方法达到求平均。
        * averagingInt/Long/Double值得是所要求的平均的源类型
        * 同summingInt/Long/Double
            * 比如int，使用new int\[2\]充当容器，其中\[0\]是总和，\[1\]是存储个数
    4. summingInt/Long/Double，stream.collect(Collectors.summingInt(...)) -> Int/Long/Double
        * 类似averagingInt
        * **其中的容器实现是通过构造相应类型的数组实现的，由于不是包装类型，若不通过构造容器，则由于形参的原因，
            修改的数值并非原来的数值**
            * 比如对于int，通过构造new int\[1\]充当容器
            * 比如对于double，通过构造new double\[3\]充当容器, 3是为了保证精度的计算处理，详见文档
    5. summarizingInt/Long/Double, stream.collect(Collectors.summarizingInt(...)) -> Int/Long/DoubleSummaryStatistics
        * 返回包含最大最小平均等的相关总结统计信息
    6. joining
        * 用于将多个字符串拼接
        1. joining()
            * 基于StringBuilder为中间容器，String为结果容器，通过append操作完成聚集/合并操作的Collector，特征为CH_NOID
        2. joining(delimiter)
        3. joining(delimiter, prefix, suffix)
            * 基于StringJoiner为中间容器，String为结果容器，通过add操作完成聚集，merge操作合并操作的Collector，特征为CH_NOID
    7. groupingBy
        1. stream.collect(Collectors.groupingBy(Function<T, K> classifier)) -> Map<K, List<T>>
            * 通过传入同一个分类的动作函数，T就是流中的每一个元素，R就是根据分类的依据
            * 使用场景select * from stu group by name
        2. stream.collect(Collectors.groupingBy(Function<T, K> classifier, Collector<V, T, A> downstream)) -> Map<K, V>
            * downstream这个collector其实就**是将属于特定类别的子流进行collect动作**
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
        3. stream.collect(Collectors.groupingBy(Function<T, K> classifier, Supplier<M> s, Collector<V, T, A> downstream)) -> M<K, V>
            * 仅仅多一个Supplier用于返回何种类型的map容器
    8. partitioningBy
        * 一个流中的分区(目前jdk8仅支持true/false两种分区)
        * **其实分区是分组的一个特例，分区可以通过分组实现**
        * stream.collect(Collectors.partitioningBy(Predicate<T> pred)) -> Map<Boolean, List<T>>
        * stream.collect(Collectors.partitioningBy(Predicate<T> pred, Collector<V, T, A> downstream)) -> Map<Boolean, List<T>>
            * downstream这个collector其实就是将属于特定分区的子流进行collect动作
    9. counting
        * 类似stream中的count
    10. collectingAndThen(Collector<T, A, R> downstream, Function<R, RR> finisher) -> Collector<T, A, RR>
        * 通过downstream得到的结果R，通过finisher进一步处理得到RR
        * 其仍然基于new CollectorImpl实例， 通过将downstream.finisher().andThen(finisher)传递
            给CollectorImpl来完成。其次在过程中，确保传给CollectorImpl的characteristics必须不带IDENTITY_FINISH特征
    11. toList()
        * 返回一个基于ArrayList特化的Collector，仅仅提供CH_ID特征
    12. toSet()
        * 返回一个基于HashSet特化的Collector，仅仅提供CH_UNORDERED_ID特征
    13. toCollection(Supplier<C> collectionFactory)
        * 是toList/Set的泛化版本，通过collectionFactory来具体化Collection的具体实现，仅仅提供CH_ID特征
    14. mapping(Function mapper, Collector downstream)
        * 对流中过的输入先进行mapper操作得到新的输入流，然后通过downstream进行处理的动作
        ```java
        return new CollectorImpl(
            downstream.supplier(),  // supplier
            (a, t) -> downstream.accumulator().accept(a, mapper.apply(t)), // accumulator
            downstream.combiner(), // combiner
            downstream.finisher(), // finisher
            downstream.characteristics() // characteristics
        );
        ```
        
* 静态内部类CollectorImpl（是接口Collector的实现）
    * 有两个构造方法：一个带finisher一个不带finisher，原因就是有些Collector的中间容器就是结果容器
* Collectors中的Collector获取实现：
    1. 通过实例化CollectorImpl实现
    2. 通过Collectors中的静态方法reducing实现，而reducing优势通过实例化CollectorImpl实现的
* reducing(U identity, Function<T, U> mapper, BinaryOperator<U> op) -> Collector<T, ?, U>
    * 
    
        