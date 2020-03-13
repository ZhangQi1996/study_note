#### 比较器接口Comparator
* 在jdk1.8开始对Comparator函数接口进行了增强
* 抽象方法
    * int compare(T o1, T o2)
* 默认方法
    1. default Comparator<T> reversed()
        * 也就是获得与本比较器相反顺序的比较器
    2. thenComparing
        * 通常用于串行比较，比如先比较学生的总成绩，若总成绩相同则再比较其数学成绩
        * 其只在上调用中比较不为0是才会调用本thenComparing，目的就是对前一条件相同的情况下进行比较
        1. default Comparator<T> thenComparing(Comparator<T> cmpr)
        2. default Comparator<T> thenComparing(Funciton<T, U> keyExtractor)
            * 使用keyExtractor产生的U类型的compareTo进行比较
        3. default Comparator<T> thenComparing(Funciton<T, U> keyExtractor, Comparator<U> keyCmpr)
            * 等价于thenComparing(comparing(keyExtractor, keyCmpr))
        4. default Comparator<T> thenComparingInt/Long/Double(ToIntFunction<T> keyExtractor)
        ```java
        // 获取基于学生成绩的比较器,先比较学生的总成绩，若总成绩相同则再比较其数学成绩
        Comparator<Stu> cmpr = Comparator.comparaingInt(Stu::getSumScore).thenComraringInt(Stu::getMathScore);
        ```
        
        
* 静态方法
    1. comparing
        1. static Comparator<T> comparing(Function<T, U> keyExtractor, Comparator<U> keyCmpr)
            * 返回一个将o1, o2两个需要比较的源元素先做keyExtractor处理后在通过keyCmpr进行比较的动作
            * 返回(o1, o2) -> keyCmpr.compare(keyExtractor.apply(o1), keyExtractor.apply(o2))
            ```java
            // 获取基于学生成绩的比较器
            Comparator<Stu> cmpr = Comparator.comparaing(Stu::getScore, Interger::compareTo);
            ```
        2. static Comparator<T> comparing(Function<T, U> keyExtractor)
            * 使用keyExtractor动作后得到U类型结果的自身的compareTo的方法进行比较，所以U类型必须实现Comparable接口
            ```java
            // 获取基于学生成绩的比较器(使用Integer自带的compareTo方法)
            Comparator<Stu> cmpr = Comparator.comparaing(Stu::getScore);
            ```
    2. static Comparator<T> comparingInt/Long/Double 是对基本类型的具体刻画
        * **注意当调用方法的时候，若存在具体的方法，优先调用具体的方法而不去调用通用的方法，由于一般具体方法的速度更快**
        ```
        // 获取基于学生成绩的比较器
        Comparator<Stu> cmpr = Comparator.comparaingInt(Stu::getScore);
        ```
    3. static <T extends Comparable<? super T>> Comparator<T> reverseOrder()
        * 返回一个自然排序（就是使用实现了Comparable接口的o1.compareTo(o2)）的逆序比较器,
            故使用本比较器的类必须实现了Comparable接口