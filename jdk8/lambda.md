#### 函数式接口
* 使用@FunctionInterface
* 什么是函数式接口
    1. 接口中只有一个抽象方法
    2. 除了一个抽象方法外可以有其他的默认实现方法（默认方法不是抽象方法）
        * 对于默认方法，若继承的两个接口中都由同名的默认方法，则实现类，不重载就会报错。
            在实现类中通过重载来编译不通过的问题
        ```java
        interface A {
            
            default void func() { // 就算这方法是一个抽象方法，对于实现AB的类Demo来说仍然需要覆盖func方法
                System.out.println("A");
            }
        }
        
        interface B {
            
            default void func() {
                System.out.println("B");
            } 
        }
        
        public class Demo implements A, B {
        
            @Override
            public void func() {
                B.super.func(); // 通过这种方式使用多个同名方法中的一个默认方法
            }
        }
        ```
        * 对于一个类，其继承的一个类与其实现的接口的一个默认方法同名，则使用继承中的同名方法
        ```java
        interface A {
        
            default void func() {
                System.out.println("A");
            }
        }
        
        class AA implements A {
        
            @Override
            public void func() { // 若未覆盖在Demo中仍会报错
                System.out.println("AA");
            }
        }
        
        interface B {
        
            default void func() {
                System.out.println("B");
            }
        }
        
        public class Demo extends AA implements B {
            // 使用继承中AA的func方法，由于继承的优先级高于需要实现的接口的优先级
        }
        ```
    3. 定义包含在Object中声明的方法，则函数接口中的抽象方法不会+1（由于定义的方法肯定会被实现（由于类肯定继承自Object））
        ```java
        @FunctionalInterface
        interface A {
           void test();
           String toString(); // 由于toString中的方法是在Object类中的实现的，故此时抽象方法的数量仍为1，不会报错
        }
        ```
    * 若一个接口只有一个抽象方法且满足以上要求，则其就是一个函数接口（不加@FunctionInterface）
* 函数式接口实例化的途径
    1. lambda表达式
        * () -> {}
    2. 方法引用
        * 可以理解为是一个函数指针
        * 当函数接口定义的返回类型是void时，则使用的函数引用的返回类型没有要求，可以为任意类型，但是参数类型，异常捕获必须一致
        1. 类名::实例方法名（className::instanceMethodName）
            * 若lambda的参数为(arg1, arg2 ..)
            * 则等价于arg1.instanceMethodName(arg2 ..)动作
            * 也就是传入的第一个作为调用方，其他作为调用方法的参数
        2. 类名::静态方法名（className::staticMethodName）
            * 若lambda的参数为(arg1, arg2 ..)
            * 则等价于className.staticMethodName(arg1, arg2 ..)动作
            * 也就是调用静态方法
        3. 实例引用名::实例方法名（instanceRefName::instanceMethodName）
            * 若lambda的参数为(arg1, arg2 ..)
            * 则等价于instanceRefName.instanceMethodName(arg1, arg2 ..)动作
            * 特征就是会跟instanceRefName这个实例产生关联，比如利用instanceRefName这个实例对后面传入的参数做处理
        4. 类名::new (className::new)
            * 若lambda的参数为(arg1, arg2 ..)
            * 则等价于new className(arg1, arg2 ..)动作
                        
    3. 构造器引用

#### 基本语法
1. 当只有一个参数的时候，且该参数是可以类型推导的，圆括号()是可以省略的
    * arg -> { // body }
2. lambda表达式的主题只有一条语句(该语句的返回就是lambda的返回)的时候，{}可以省略

#### Function<T, R>函数接口
0. apply(T t) -> R (抽象方法)
1. compose(Function before) -> Function方法 (默认实现方法)
    * 就是先通过调用before函数，使用其结果再调用本函数（返回一个实现前面所述的函数）
2. andThen(Function after) -> Function (默认实现方法)
    * 就是先通过调用本函数，使用本结果再调用after函数（返回一个实现前面所述的函数）
3. identity() -> Function (默认实现方法)
    * 输入什么返回什么（返回一个实现前面所述的函数）
#### BiFunction<T, U, R>函数接口
1. andThen(Function after) -> BiFunction (默认实现方法)
    * 就是先通过调用本函数，使用本结果再调用after函数（返回一个实现前面所述的函数）

#### Consumer<T>函数接口
* 使用场景：
    * 用于消费
    
#### Predicate<T>函数接口
* 断定/谓词
* 方法
    1. test(T t) -> boolean (抽象方法)
    2. and(Predicate<T> p) -> Predicate<T> (默认实现方法)
        * 返回一个实现评估两个Predicate的与操作的Predicate
    3. negate() -> Predicate<T> (默认实现方法)
        * 返回一个实现取反操作的Predicate
    4. or(Predicate<T> p) -> Predicate<T> (默认实现方法)
        * 取或的Predicate
    5. isEqual(Object tRef) -> Predicate<T> (静态方法)
        * 得到一个判断另一个引用是否与tRef引用equal的断定
        ```java
        Integer i = 127, j = 127;
        // 返回一个用于断定一个obj与另一个obj是否equal的断言函数
        System.out.println(Predicate.isEqual(i).test(j)); // 由于int的缓存池，true
        ```
#### Supplier<T>函数接口
* 提供者
* 方法
    1. get() -> T (抽象方法)

#### BinaryOperator<T>函数接口继承自BiFunction<T, T, T>
* 将二元操作抽象成一个函数接口
* 方法
    1. apply(T t1, T t2) -> T (抽象方法)
        * 用于对两个操作数进行操作，返回一个同类型的
    2. minBy(Comparator c) -> BinaryOperator<T> (静态方法)
        * 通过注入一个比较器，返回一个BinaryOperator<T>用于比较的函数（动作）
    3. maxBy(Comparator c) -> BinaryOperator<T> (静态方法)
        * 通过注入一个比较器，返回一个BinaryOperator<T>用于比较的函数（动作）
    ```java
    public class Demo {
    
        public static void main(String[] args) {
            // 两个int之和
            System.out.println(op(1, 2, Math::addExact));
            // 两个int最小值
            System.out.println(op(1, 2, BinaryOperator.minBy(Integer::compareTo)));
        }
    
        public static Integer op(Integer a, Integer b, BinaryOperator<Integer> integerBinaryOperator) {
            return integerBinaryOperator.apply(a, b);
        }
    }   
    ```
#### Optional类
* 一个容器对象，主要用来处理null的包装，其是一个基于值的类(value-based class)
* 注意其中包含的值是不可变的，即val被final修饰
* optional的equals以及hashcode是基于其val的
* Optional没有实现序列化
    1. 不要将Optional定义为方法参数
    2. 不要将Optional定义为类/实例变量
    3. 一般将Optional作为方法的返回值（用来规避null）
    4. 使用Optional尽量使用函数式编程
* 方法
    * 构造器时私有的，仅通过静态工厂方法创建实例
    1. static empty() -> Optional<T>
        * 创建一个包含空值的Optional实例
        ```java
        // 由于静态方法empty没有参数不能根据参数类型推断出泛型，故通过定义的形式来推断泛型
        Supplier<Stu> supplier = Optional::empty;
        ```
    2. static of(T t) -> Optional<T>
        * 传入的值t必须是非空的
    3. static ofNullable(T t) -> Optional<T>
        * 传入的值t必须是可空的
    4. isPresent() -> boolean (实例方法)
        * 判断val是否为空
    5. get() -> T (实例方法)
        * 返回val，若val为空则抛出异常，故应该搭配使用
        ```java
        if (optional.isPresent()) {
           optional.get(); // 获取值
        }
        ```    
    6. ifPresent(Consumer<? super T> consumer) (实例方法)
        * 传入一个消费动作函数，当val不为空的时候就进行消费动作
    7. filter(Predicate<? super T> predicate) -> Optional<T> (实例方法)
        1. 首先predicate不能为空
        2. 若val为空或者本optional实例经过断言不通过，则返回val为空的optional实例
        3. 否则返回this
    8. orElse(T t) -> T (实例方法)
        * 若实例的val为空则返回t否则返回val
    9. orElseGet(Supplier<? super T> other) -> T (实例方法)
        * 若实例的val为空则返回other.get()否则返回val
    10. \<X extends Throwable\> orElseThrow(Supplier<? super X> other) -> T (实例方法)
        * 若实例的val为空则抛出other.get()的异常否则返回val 
    11. map(Function<T, R> func) -> Optional<R> (实例方法)
        * 本实例的val为空则返回空val的Optional实例，否则调用map动作对源val进行操作得到新val并封装到新的Optional实例中
        ```java
        // 若一个列表为空则返回一个空列表
        Optional.ofNullable(list).orElseGet(Collections::emptyList);
        ```

