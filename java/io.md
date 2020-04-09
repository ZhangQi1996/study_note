#### java IO
* 读数据的逻辑
    1. open a stream
    2. while more info 
    3. read info
    4. close the stream
* 写数据的逻辑
    1. open a stream
    2. while more info 
    3. write info
    4. close the stream
* 流的分类
    1. 节点流
        * 从特定的地方开始读写的流类，e.g. 磁盘或者一块内存区域
    2. 过滤流
        * 使用节点流作为输入/输出，过滤流是使用一个已经存在的输入或者输出流连接而创建的
    ```
                   |- FileInputStream         |- DataInputStream
                   |  ByteArrayInputStream    |  BufferedInputStream
                   |  FilterInputStream <=====|  LineNumberInputStream
    InputStream <==|  ObjectInputStream       |- PushbackInputStream
                   |  PipedInputStream
                   |  SequenceInputStream
                   |- StringBufferInputStream
  
    
                    |- FileOutputStream         
                    |  ByteArrayOutputStream    |- DataOutputStream     
    OutputStream <==|  FilterOutputStream <=====|  BufferedOutputStream 
                    |  ObjectOutputStream       |- PrintStream
                    |  PipedOutputStream
    ```
* 常见方法
    1. skip(long) -> long
        * 跳过若干字节，返回成功跳过的字节数
    2. available() -> boolean
        * 还可以读取或者跳过的估计字节数
    3. synchronized mark(int) -> void
        * 标记当前位置，并设置标记后最多可以读取的字节数
    4. synchronized reset() -> void
        * 回到上次标记的位置
    5. markSupported() -> boolean
        * 流是否支持标记
* 装饰模式(继承对类进行扩展，装饰模式对对象进行扩展)
    1. 抽象构建角色（Component） e.g. InputStream
    2. 具体构建角色（Concrete Component） e.g. FileInputStream
        * 继承/实现Component
    3. 装饰角色（Decorator）: 持有一个对象的引用 e.g. FilterInputStream
        * 继承/实现Component，同时持有一个Component c = new ConcreteComponent(...)
    4. 具体装饰角色（Concrete Decorator） e.g. BufferedInputStream
    ```java
    interface Component {
        void doSomething();
    }
    
    class ConcreteComponentA implements Component {
        @Override
        public void doSomething() {
            System.out.println("DO A");
        }
    }
    
    class Decorator implements Component {
    
        private Component c;
    
        Decorator(Component c) {
            this.c = Objects.requireNonNull(c);
        }
    
        @Override
        public void doSomething() {
            c.doSomething();
        }
    }
    
    class ConcreteDecoratorA extends Decorator {
    
        ConcreteDecoratorA(Component c) {
            super(c);
        }
    
        @Override
        public void doSomething() {
            super.doSomething();
            doAnotherThing();
        }
    
        void doAnotherThing() {
            System.out.println("DO B");
        }
    }
    ```
* 文件
    * 常见类
        1. class File
        2. class RandomAccessFile implements DataOutput, DataInput, Closeable
            * 构造方法
                1. RandomAccessFile(String filePath, String mode)
                2. RandomAccessFile(File file, String mode)
            * 这个类的实例支持对于一个随机访问文件读写操作，一个随机访问文件就类似于存储在文件系统中的一个大的字节数组，
                对于这种文件有一种游标（也就是对那个字节数组的索引）叫做文件指针，输入操作则从文件指针处开始进行读操作，
                并逐字节移动前进文件指针。若随机访问文件以rw模式创建，那么也将支持输出操作（也就是往文件中写，写的过程与read同理）。
                当对文件（由于对应文件系统的一个字节数组）过度写就会导致那个字节数组的扩张，通过getFilePointer方法获取file pointer，
                通过设置seek方法来设置file pointer。
            * 通常，对于此类中的所有读取例程，如果在读取所需字节数之前已到达文件末尾，则将引发EOFException（这是IOException的一种）。
                若由于非EOF的原因导致不能read则抛出IOException异常而不是EOFException，比如当流关闭的时候就抛出IO异常。
            * 用于
                * 细致的操作，不想创建文件流等
* 文件锁（对FileChannel）
    * 是细粒度的锁（支持锁定为位置，长度，锁的类别）
        * fileChannel.lock(long pos, long size, boolean shared)
    1. 文件的共享锁（读）
    2. 文件的排它锁（写）
    ```java
    public class Test5 {
        public static void main(String[] args) throws IOException {
            String path = Util.getFilePathByClassLoader("nio_test.txt");
            RandomAccessFile file = new RandomAccessFile(path, "rw");
    
            FileChannel channel = file.getChannel();
            // 获得文件锁
            FileLock fileLock = channel.lock(0, 2, true);
    
            System.out.println("Valid: " + fileLock.isValid());
            System.out.println("Lock type: " + fileLock.isShared());
            
            fileLock.release(); // 释放锁
            file.close();
        }
    }
    ```