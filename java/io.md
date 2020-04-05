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
    