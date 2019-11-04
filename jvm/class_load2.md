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
#### Context Class Loader 上下文类加载器
