```
Thread.currentThread().getContextClassLoader() --> App ClassLoader
Thread.class.getClassLoader() --> null == bootstrap classloader
```
* current classloader（当前类加载器）
    * 每个类都会用加载自身类的那个类加载器去加载其他引用的类，例如
        ClassA引用了ClassB，则加载了ClassA的那个类加载就会去加载ClassB，前提是
        ClassB尚未被加载
    ```
    class ClassA {
        void func() {
            int a = ClassB.CONTANT_VAL;
        }
    }
    // 若ClassB尚未加载，则此时加载ClassB的类加载器与加载ClassA的类加载器相同
    ```
* context classloader（线程上下文加载器）
    * 线程的上下文类加载器是从jdk1.2引入的，类Thread中的getCurrentClassLoader()
        与setCurrentClassLoader(ClassLoader cl)方法分别来获取/设置线程的上下文类加载器
    * 如果没有通过set来设置上下文类加载器，则线程将会继承父线程的类加载器，java app运行时的
        初始线程的上下文类加载器是**app classloader**，在线程中运行的代码可以通过该类加载器来加载类
        与资源。
    * 线程上下文的类加载器的重要性
        ```
        SPI(Service Provider Interface)
        这个摆脱双亲委托机制的局限性
        比如讲ClassA类扔到ext加载的目录下，而ClassA引用的ClassB是在class path下的
        当调用ClassA时，由于加载ClassB使用加载ClassA的类加载器也就是Ext classloader这样
        就导致了加载ClassB的失败
        所以解决这个问题
        使用
        class ClassA {
            void func() {
                ClassLoader cl = Thread.currentThread().getContextClassLoader();
                Class clsB = cl.load("ClassB");
                // 若是使用Class.forName("ClassB"); 则使用的是Ext ClassLoader进行加载，且加载失败
            }
        }
        ```
    * 基本使用模式（获取-使用-还原）
        ```
        // 获取
        ClassLoader loader = Thread.currentThread().getContextClassLoader();
        try {
            Thread.currentThread().setContextClassLoader(targetClassLoader);
            // 使用
            myMethod(); // 在其中使用targetClassLoader作为类加载器
        } finally {
            // 还原
            Thread.currentThread().setContextClassLoader(loader);
        }
        ```    
        * 当高层提供了同一的接口让底层去实现，同时又要让高层加载（或实例化）底层的类时，就必须
            要通过线程上下文类加载器来帮助高层的ClassLoader找到并加载该类。
            主要原因就是高层与低层的类加载器不一样。
    