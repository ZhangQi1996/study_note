#### 类加载的双亲委托机制
```
Bootstrap classloader  --> load JRE/lib/rt.jar or -Xbootclasspath选项来加载jar包
Extension classloader  --> load JRE/lib/ext/*.jar or -Djava.ext.dirs指定目录下的jar包
App classloader --> load CLASS_PATH or -Djava.class.path所指定的目录下的类和jar包
Custom classloader --> 通过java.lang.ClassLoader的子类自定义加载class
```
* 若有一个类加载去能够成功加载目标类，那么这个类就叫做**定义类加载器**，所有能成功返回Class对象引用的李加载器
    （包括定义类加载器）都被称为初始类加载器。
    
* 调用classloader的loadClass加载一个类，并不会初始化该类，反射会初始化
* 通过ClassLoader.getSystemClassLoader来获得应用加载器

-----
#### 获得CLassLoader的途径
* 获得当前类的classloader
    * cls.getClassLoader()
* 获得当前线程上下文的ClassLoader
    * Thread.currentThread().getContextClassLoader()
    * 一般就是一个系统/App类加载
    ```
    // 通过类加载器来获取外部资源
    ClassLoader clsLoader = Thread.currentThread().getContextClassLoader(); // 获取当前线程的上下文类加载
    String resourcePath = "com/zq/resource/xxx.xml";
    Enumeration<URL> = urls = clsLoader.getResources(resourcePath);
    while (urls.hasMoreElements()) {
        URL url = urls.nextElement();
        System.out.println(url);
    }
    ```
* 获取系统的类加载ClassLoader
    * ClassLoader.getSystemClassLoader()
* 获取调用者的ClassLoader 
    * ClassLoader.getSystemClassLoader()
-----------------
* 传递给class loader的类名，e.g.
    * java.lang.String
    * javax.swing.JSpinner$DefaultEditor $ 间隔外部类与内部类
    * xxx.xxx.xxx$yyy$1 $1表示是yyy类中的第1个匿名内部类（由于匿名内部类没有名字所以用数字标识）
* 通过类的全限定名来加载class的常用策略就是
    1. 通过将类的全限定名转换为类的文件路径名，然后从文件系统中读取这个class文件
* 由于每个Class对象都是由某个ClassLoader来加载的，故每个Class对象都会有对应的ClassLoader对象的引用
    * 通过cls.getClassLoader()来获取
* **对于数组类（e.g. String[]）的Class对象并不是由classloader来创建的**
    * 其的Class对象是由jvm在runtime动态创建的
    * 标识为[Lxxxx.xxx.xxx.xx
    * 对于数组，得到其Class对象，在调用其getClassLoader()得到的类加载器与其数组元素的类加载器是一致的
    * 对于数组，若其元素是原子类型，则其没有类加载器。原子类型其实也没有类加载器
* ClassLoader的每一个实例都有一个与之关联的父类加载器
* ClassLoader类是支持并发加载类的，但其子类要实现并发加载类的话就需要进行注册
    * 调用ClassLoader.registerAsParallelCapable()
    * 在非严格类加载层次结构上（非jvm内建层次，常见也就是自定义类加载方式），类加载需要有并发加载类的能力
        由于加载锁是在类加载期间是加锁的，所以要是没有并发能力，则会导致死锁问题。
* 通常，类的加载是通过在本地文件系统中以一种平台相关的方式进行类加载，但是还有其他方式
    1. 网络
    2. 应用自建的类 （动态代理）
    * defineClass方法通过将字节串转换成一个class Class的实例，然后在通过Class.newInstance得到这个类的实例。
    ```
    class NetworkClassLoader extends ClassLoader {
        String host;
        int port;
        
        public Class findClass(String name) {
           byte[] b = loadClassData(name);
           return defineClass(name, b, 0, b.length);
        }
        
        private byte[] loadClassData(String name) {
           // load the class data from the connection
            . . .
        }
    }
    ```         
* 复杂类的加载
    * 比如一个类的里面包含其他类的加载（例如主动使用之前的加载），则包含的类是使用本类的类加载器进行加载
    * **注意：一个类的类加载器是成功加载其的那个类加载器实例**
    ```
    
    ```
