#### 用于collect的Collector<T, A, R>类
* T就是流中的元素类型，R就是最终返回的容器类型，A就是可变的中间聚集的类型
    * 若finisher()的操作并没有进行类型转换，则A==R
* 它是一个可变的规约操作，将集聚输入元素到可变容器中，此外也可以（可选的）在所有元素累积后
    将最终结果进行转换表示。支持串行/并行。
* 基本组成方法（用于构建基本的Collector实例）
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
* 常用方法
    1. static of(Supplier<R> s, BiConsumer<R, T> a, 
            BinaryOperator<R> c, Characteristics... cs) -> Collector<T, R, R>
        * 创建一个不带finisher的Collector实例
        
* Collector的特征
    1. CONCURRENT
    2. UNORDERED
    3. IDENTITY_FINISH
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
* 自实现Collector
```java
package com.zq.jdk8;

import java.util.*;
import java.util.function.BiConsumer;
import java.util.function.Consumer;
import java.util.function.Supplier;
import java.util.stream.Collectors;
import java.util.stream.Stream;


class Stu {
    private String name;

    private int score;

    public Stu() {
        this(UUID.randomUUID().toString(), (int) (Math.random() * 100));
    }

    public Stu(String name, int score) {
        this.name = name;
        this.score = score;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    @Override
    public String toString() {
        return "Stu{" +
                "name='" + name + '\'' +
                ", score=" + score +
                '}';
    }
}

class MutableOptional<T> {
    private T val;

    private static final MutableOptional<?> EMPTY = new MutableOptional<>(null);

    private MutableOptional(T val) {
        this.val = val;
    }

    public T getVal() {
        return val;
    }

    public void setVal(T val) {
        this.val = val;
    }

    public boolean isPresent() {
        return val != null;
    }

    public void ifPresent(Consumer<T> consumer) {
        Objects.requireNonNull(consumer);

        if (isPresent())
            consumer.accept(val);
    }

    public void cover(MutableOptional<T> mo) {
        setVal(mo.getVal());
    }


    public static <T> MutableOptional<T> empty() {
        @SuppressWarnings("unchecked")
        MutableOptional<T> empty = (MutableOptional<T>) EMPTY;
        return empty;
    }

    public static <T> MutableOptional<T> of(T t) {
        if (t == null) return empty();

        return new MutableOptional<>(t);
    }
}

public class Demo {


    public static void main(String[] args) {
        List<Stu> stus = Stream.generate(Stu::new).limit(1000).collect(Collectors.toList());

        // stream的常规方式
        stus.stream().min(Comparator.comparingInt(Stu::getScore)).ifPresent(System.out::println);

        //stream的collect方式
        stus.stream().collect(Collectors.minBy(Comparator.comparingInt(Stu::getScore))).ifPresent(System.out::println);

        // 自实现的Collector
        Supplier<MutableOptional<Stu>> supplier = MutableOptional::empty;

        BiConsumer<MutableOptional<Stu>, Stu> accumulator = (r, t) -> {
            if (!r.isPresent() || t.getScore() < r.getVal().getScore())
                r.setVal(t);
        };

        BiConsumer<MutableOptional<Stu>, MutableOptional<Stu>> combiner = (r1, r2) -> {
            if (!r1.isPresent() ||
                    (r2.isPresent() && r2.getVal().getScore() < r1.getVal().getScore())) {
                r1.cover(r2);
            }
        };

        stus.parallelStream().collect(supplier, accumulator, combiner).ifPresent(System.out::println);
    }
}
```  

#### 辅助类Collectors
* 提供了Collector的常见具体实现，是一个工厂类
* 常用方法
    * 区分Collectors中的reducing方法与Stream中的reduce方法
        1. reducing返回的是Collector，reduce返回的是标量
        2. reducing用于处理可变规约而reduce则是不变规约
    1. minBy, stream.collect(Collectors.minBy(...)) -> Optional
        * min的Collector形式，等价于stream.min(...)
    2. maxBy, 同minBy
    3. averagingInt/Long/Double, stream.collect(Collectors.averagingInt(...)) -> Double
        * 通常在不使用流的mapToInt/Long/Double之类的mapper，从而通过此方法达到求平均。
        * averagingInt/Long/Double值得是所要求的平均的源类型
    4. summingInt/Long/Double，stream.collect(Collectors.summingInt(...)) -> Int/Long/Double
        * 类似averagingInt
    5. summarizingInt/Long/Double, stream.collect(Collectors.summarizingInt(...)) -> Int/Long/DoubleSummaryStatistics
        * 返回包含最大最小平均等的相关总结统计信息
    6. joining
        * 用于将多个字符串拼接
        1. joining()
        2. joining(delimiter)
        3. joining(delimiter, prefix, suffix)
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
    