#### ClassLoader中的一些重要的方法
* findClass
    * 通过特定的binary name来寻找class，子类应该重载该方法，其应该遵循双亲委托机制
    * 在父加载器对该类加载检查后，该方法会由loadClass方法调用。
    ```
    MyClassLoader loader; // 一个自定义的类加载器
    loader.loadClass("xxx");
    1. 加载时，先判断class是否已经加载过，若是则直接返回，否则先通过双亲委托机制，
        由双亲一直往上来加载类，若加载成功则直接返回，若失败，则调用自己重载的findClass来返回class
    ```
    * **故实质就是重载findClass函数**
#### 命名空间
* 每个类加载器都有自己的命名空间，**命名空间由成功加载该类的加载器及所有其父加载器所加载的类组成**
* 自我理解：每个真正实现类加载的**加载器实例**就维持一个命名空间
* 在同一命名空间中，不会出现类的完整名字（包括类的包名）相同的两个类
* 在不同的命名空间中，可能会出现类的完整名字（包括类的包名）相同的两个类
```
// 示例1
    ClassLoader loader1 = new MyClassLoader();
    ClassLoader loader2 = new MyClassLoader();
    Class cls1 = loader1.loadClass("com.zq.jvm.Test");
    Class cls2 = loader2.loadClass("com.zq.jvm.Test");
    // 当Test.class文件在CLASSPATH下时，结果： cls1与cls2是同一个对象
    // 当Test.class文件不在CLASSPATH下时，结果： cls1与cls2不是同一个对象
    
    // System/Ext/Bootstarp ClassLoader都是单例模式，都是对于每个成功加载的类都会在命名空间记录下来（即被findLoadedClass函数拦截下来），
    // 下次再通过这些加载器加载时，直接使用历史记录，另一方面，由于是单例，故两次的调用都是同一样的命名空间
    分析：当Test.class文件在CLASSPATH下时，加载用的都是系统加载器，在第二次加载的时候，由于有了第一次加载，故第二次直接复用结果
    分析：当Test.class文件不在CLASSPATH下时，加载用的是自定义加载器，即此时有两个自定义加载器实例，故是两个命名空间，故cls1与cls2不一致
```
