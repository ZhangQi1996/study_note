#### Unsafe源码分析
* 简介
    * Unsafe类提供了一系列诸如低层次不安全操作的方法集合，虽然这个类与这个类的所有方法都是
        公共的，但是这个类的使用是受限制的，因为这个类的实例仅仅被用于安全代码中。
* 常用方法
    1. getUnsafe() -> Unsafe
        * 提供给这个方法的调用者能够执行非安全操作的能力（诸如低层次不安全操作），
            这个方法返回的Unsafe实例应该由调用者小心保护，由于这个实例能够从任意的内存地址上读写
            数据，故其一定不能暴露给非安全的代码。
        * 这个类的大多数方法都是非常低层次的，即对应于一些硬件指令。因此，编译器应当去优化这些方法。
        * 对于使用不安全操作，这里给出一个使用案例
            ```java
            class MyTrustedClass {
              private static final Unsafe unsafe = Unsafe.getUnsafe();
              // ...
              private long myCountAddress = 0x0; // 某地址
              public int getCount() { return unsafe.getByte(myCountAddress); }
            }    
            // 这也许用来协助编译器使得一个本地变量地址不可变（make the local var be final）
            ```    
        * 当一个安全管理器（SecurityManager）退出以及他的checkPropertiesAccess方法不允许去访问
            系统属性的时候就抛出SecurityException
        ```java
        public class Unsafe {
            // ...
            @CallerSensitive
            public static Unsafe getUnsafe() {
                Class caller = Reflection.getCallerClass();
                // 表明要求调用者的类加载器为根加载器
                if (!VM.isSystemDomainLoader(caller.getClassLoader())) {
                    throw new SecurityException("Unsafe");
                } else {
                    return theUnsafe;
                }
            }
            // ...
        }      
        ```
    2. native getInt(Object o, long offset) -> int
        * 参数
            1. o：int变量所在的那个位于java堆中的对象（如果有的话），否则为空
            2. offset：o中int变量所处的偏移位置，若o为空，则offset表示绝对内存地址。
        * 这是一个**peek and poke操作**（编译器应该优化这些内存操作），在java堆中这些操作工作在对象字段上。
            它不会工作在打包数组的元素上。
            * 在计算机领域中，PEEK and POKE是若干用于高级编程语言的命令，这些命令用于访问一个内存地址所指向的
                特定内存单元中的内容。    
        * 从一个给定的java变量中获取值：更特别地，对于一个给定的对象o，从其的偏移量位置offset上获取一个
            字段值(field)或者数组元素。若当o为null的时候，则将offset视为内存地址，直接在这个位置上获取值。
        * 当如下情况**都为假**的时候，则结果为**未定义（也就是结果不正确）**：
            1. 偏移量是从某个Java**实例**字段的字段上的objectFieldOffset获得的，而o所引用的对象是与该字段的类兼容的类。
                * 比如o的offset对应的field为F，而unsafe.objectFieldOffset(F)==offset
            2. 类字段偏移量和对象引用o（null或non-null）都分别通过staticFieldOffset和staticFieldBase
                从某个Java字段的反射Field表示中获得。
                * 比如o的offset对应的**类**字段field为F，而unsafe.staticFieldBase(F)==o的内存地址，
                    unsafe.staticFieldOffset(F)==offset
            3. 当o是一个数组引用时，offset=B+N*S
                * B: 等于unsafe.arrayBaseOffset(o.getClass())也就是这个数组对象在内存中偏移基地址
                * N: 也就是所要获取元素的index
                * S: 等于unsafe.arrayIndexScale(o.getClass())也就是返回每个元素的大小
            * 由于其提供了两个参数，故其提供了两种方式访问类/对象字段or数组元素
                1. 参数(Objects.requireNonNull(o), offset)为java变量（字段/元素的绝对地址）寻址
                    有效的提供了双寄存器寻址模式(double-register)
                2. 参数(null, offset)则offset就是绝对地址，类似于调用unsafe.getInt(offset)(单寄存器寻址模式, single-register，用来
                    常用于访问非java变量`也就是不位于java heap中的变量(自我理解)`)
                * 但是，由于**Java变量在内存中的布局可能与非Java变量不同**，因此程序员不应假定这两种寻址模式是相同的。
                    所以，程序员不应该将双寄存器寻址模式与单寻址模式相混淆。
        * 类似方法
            * getObject/...(Object, long)
    3. native putInt(Object o, long offset, int x) -> void
        * 参数
            * 类见getInt
        * 将一个int值存储到给定的int变量（由双寄存器寻址模式所指向的那个变量）中
    4. native putObject(Object o, long offset, Object x) -> void
        * 将参考值存储到给定的Java变量中。除非要存储的引用x为null或与字段类型匹配，否则结果是不确定的。
            如果参考o不为空，则更新该对象的汽车标记或其他存储障碍（如果VM要求）。
    5. native getByte(long addr) -> byte
        * 从所给定的内存地址获取一个值，若地址为空或者指向一个非分配的内存空间中时，其返回的
            结果是不确定的
        * 类似方法
            * getInt/...(long)
    6. native getAddress(long address) -> long
        * 从所给定的内存地址获取一个原生的指针，若地址为空或者指向一个非分配的内存空间中时，其返回的
              结果是不确定的
        * 若这个指针小于2^64的范围，则被转换为不带符号的java long类型值。简单地通过将一个offset
            加到这个long的pointer值上，来完成任何给定的字节偏移量索引。从目标指针上读取字节的数量
            可能由unsafe.addressSize()（返回一个指针所占的字节数量，也就是OS的位数，比如32bit，64bit）来决定
    7. native putAddress(long address, long pointer) -> void
        * 将pointer值存储到给定内存地址address所指向的位置上，当address为空或者非分配的位置上时则
            结果是不确定的。写入的字节数由unsafe.addressSize()（返回一个指针所占的字节数量）来决定
    8. native allocateMemory(long bytes) -> long
        * 分配一块给定字节大小bytes的原生内存块（堆外内存），这块内存的内容是未初始化的，这块内存通常总要回收。
            该方法返回的结果指针非0，且指向的内存地址起始可与所有类型对齐。通过调用unsafe.freeMemory(pointer)
            来丢弃回收这块内存，通过unsafe.reallocateMemory(addr, bytes)来完成重新分配大小
    9. native reallocateMemory(long oldAddress, long bytes) -> long
        * 重新分配一个新的原生内存块为给定大小，并将旧内存块中内容全部复制到新的内存块中，当新的
            内存块大小大于旧的，则超过的部分就是未初始化的。它通常也是要被回收的。当传入的新的大小为0时，则返回
            的指针就是0x0，结果指针指向的内存地址起始可与所有类型对齐。若传入的旧地址为空时（不存在），就相当于调用
            unsafe.allocateMemory(bytes)方法
        * 若bytes的数值为负值或者过大时就抛出IllegalArgumentException
        * 系统拒绝分配内存就抛出OutOfMemoryError
    10. native setMemory(Object o, long offset, long bytes, byte value) -> void
        * 将o的偏移位置offset开始的数量为bytes的字节全部置为val固定值，此方法通过两个参数确定块的基地址，
            因此它（实际上）提供了双寄存器寻址模式，如getInt（Object，long）中所述。
            当对象引用为空时，偏移量提供绝对基地址。
        * 存储以连贯的（原子的）单位表示（即连续存储），其大小由地址和长度参数确定。
            如果有效地址和长度均为8的倍数，则存储以“long”单位进行。
            如果有效地址和长度为4或2的倍数，则存储将以“ int”或“ short”为单位。
        * 类似setMemory(addr, bytes, val)采用的绝对地址
    11. native copyMemory(Object srcBase, long srcOffset, 
            Object destBase, long destOffset, long bytes) -> void
        * 存储以连贯的（原子的）单位表示（即连续存储），其大小由地址和长度参数确定。
            如果有效地址和长度均为8的倍数，则存储以“long”单位进行。
            如果有效地址和长度为4或2的倍数，则存储将以“ int”或“ short”为单位。
        * 类似copyMemory(long srcAddress, long destAddress, long bytes)
    12. native void freeMemory(long address)
        * 丢弃由allocateMemory与reallocateMemory分配的内存
    13. native long staticFieldOffset(Field f)
        * 返回类字段在所在的类的存储位置偏移量，这个偏移量仅仅传递给unsafe的堆内存访问器
        * 对于一个特定的字段，其只有固定的offset与base位置，base可以理解为这个类的首位置，
            而这个offset就是该字段在该类中存储的偏移位置
        * 对于类字段（静态字段由于存储在方法区，通常使用绝对地址获取）
        * 类似
            * native long objectFieldOffset(Field f)
                * 用于对象字段,用于返回实例字段f在对象实例中的偏移
            * native Object staticFieldBase(Field f)
                * 返回类字段f基于的这个class对象（这个对象封装这个类字段）
        ```java
        // 对于静态字段（类字段）
        // 比如类Demo，有一个类字段int a，一个实例字段int b（实例依附于对象demo）
        
        public class Demo {
            static int a = 0;
            int b = 1;
        
            public static void main(String[] args) throws NoSuchFieldException {
                Demo demo = new Demo();
                Field a = Demo.class.getDeclaredField("a");
                Field b = Demo.class.getDeclaredField("b");
                // 获取类字段a
                System.out.println(unsafe.getInt(unsafe.staticFieldBase(a), unsafe.staticFieldOffset(a)));
                // 获取实例字段b
                System.out.println(unsafe.getInt(demo, unsafe.objectFieldOffset(b)));
            }
        }
        ```
    14. native boolean shouldBeInitialized(Class<?> c) 与
        native void ensureClassInitialized(Class<?> c)
        * 前者用来检测所给的class是否可能需要初始化，后者确保所给的class已经初始化
        * 二者方法通常都是搭配获取类字段的base所用的
    15. native int arrayBaseOffset(Class<?> arrayClass)
        * 返回存储在数组class中的第一个元素的偏移量
        * 类似
            * native int arrayIndexScale(Class<?> arrayClass)
                * 获取数组中一个元素中所占的范围因子数（比如字节数）
        * 故锁定一个元素的绝对地址为：B + N * S（参见方法2）
    16. native int pageSize()
        * 返回原生内存中的页大小（字节），其数值是2指数次幂
    17. native Class<?> defineClass(String name, byte[] b, int off, int len,
            ClassLoader loader, ProtectionDomain protectionDomain)
        * 告知VM去定义一个不经过安全检查的class，默认情况下，类加载器与保护域来自调用者的类
        * 类似ClassLoader::defineClass1
    18. native Class<?> defineAnonymousClass(Class<?> hostClass, byte[] data, Object[] cpPatches)
        * 定义一个类加载器或者系统字典不知道的class（匿名class），
        * 定义一个类，但不要让他们知道的类加载器或系统字典。
            对于每一个CP条目，相应的CP补丁必须是空或有其标签匹配的格式：
            * 为Integer，Long，Float，Double等：从相应的包装对象类型的java.lang
            * UTF8：一个字符串（如果用作签名或名称必须采用合适的语法）
            * 类：任何java.lang.Class对象，
            * 字符串：任何对象（而不仅仅是一个java.lang.String）
            * InterfaceMethodRef：（NYI）的方法处理，以便调用该调用网站的观点  
    19. native Object allocateInstance(Class<?> cls)
        * 分配一个不运行任何构造器的实例，若其没有初始化则初始化
    20. native void throwException(Throwable ee)
        * 抛出一个异常的同时不告知核实器
    21. final native boolean compareAndSwapObject(Object o, long offset,
             Object expected, Object x)
        * 一个原子操作，若一个java变量当前的值为expected，则将其更新为x，成功返回true
        * 类似
            1. compareAndSwapInt/Long（没有short等等）
    22. native Object getObjectVolatile(Object o, long offset)
        * 从一个java变量中获取一个引用值，这个过程是符合volatile load语义的，否则等价于
            unsafe.getObject(Object, long)
        * 其实就是线程安全的
        * 类似
            * getIntVolatile，getBooleanVolatile，...
            * putObjectVolatile(Object o, long offset, Object x) ...
    23. native void    putOrderedObject(Object o, long offset, Object x)
        * 是putObjectVolatile的不支持线程立即可见的版本，通常用于offset那个字段本身就是
            volatile标识的。对于数组中的单个元素的访问/设置仍需通过volatile accesses
        * 类似
            * putOrderedInt/Long(Object o, long offset, long x)
    24. native void park(boolean isAbsolute, long time)
        * 阻塞当前的线程，当unpark这个线程被调用或者这个线程被中断则从这个方法返回。
            若isAbsolute为false且time不为0则time以纳秒为单位，若isAbsolute为true
            则time表示deadline（从1900年开始计时的毫秒值）。同时，这个park方法也可能无缘无故的
            返回。注释：由于unpark操作在Unsafe类中，故park也放在这个类中了。
    25. native void unpark(Object thread)
        * 将通过park操作而阻塞的线程unblock，若这个线程本身就没有通过park处于阻塞态，则下一个对
            本线程的park操作不会引起阻塞。
        * 注意：此操作是“不安全的”，仅是因为调用者必须以某种方式确保未破坏线程。 
            从Java调用时（通常会实时引用该线程），通常不需要什么特别的操作来确保这一点，
            但是从本地代码调用时，这几乎不是自动的。
        ```java
        public class Demo {
            public static void main(String[] args) throws NoSuchFieldException, InterruptedException {
                Thread thread = Thread.currentThread();
                unsafe.unpark(thread);
                // 不会阻塞
                unsafe.park(false, TimeUnit.SECONDS.toNanos(2));
                // 立即执行
                System.out.println(123);
            }
        }       
        ```
    26. native int getLoadAverage(double[] loadavg, int nelems)
        * 获取在系统运行队列中，分配给平均每个时间段内每那些可用进程的平均负载。
            这个方法检索给定的nelems个样本，并给其loadavg（平均负载数组），
            系统最多施加3个样本，分别代表最近1分钟，5分钟和15分钟的平均值。
        * 参数
            1. loadavg：nelems大小的double数组
            2. nelems：将要被检索的数量，其值为1,2,3
        * 返回值
            * 返回的整数值表示成功检索的样本数量，-1表示不能获取平均负载
    27. final int getAndAddInt(Object o, long offset, int delta)
        * 一个原子操作，先获取原始值再加。
        * 类似
            * final long getAndAddLong(Object o, long offset, long delta)
            * final int getAndSetInt(Object o, long offset, int newValue)
            * final long getAndSetLong(Object o, long offset, long newValue)
            * final Object getAndSetObject(Object o, long offset, Object newValue)
    28. native void loadFence()
        * 确保在栅栏之前没有重新排列负载，而在栅栏之后放置负载或存储。
        * load就是将从主存值载入的值在local mem进行副本拷贝，
            store就是将本地内存中副本复制到主存中
        * 即在执行load操作之前进行load fence
        * 类似
            * native void storeFence()
            * native void fullFence()
                * 确保fence之前不会有loads与stores的重排序
    29. static void throwIllegalAccessError()
        * 用于VM来抛出非法访问错误
        
        
    
                
    