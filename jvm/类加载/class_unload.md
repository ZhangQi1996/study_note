#### 类的卸载
* 当Sample类被加载，连接，初始化后，它的生命周期就开始了。当代表Sample类的Class对象(Sample.class)
    不再被引用，即不可触及时，Class对象就会结束生命周期，Sample类的方法区内的数据就也会被卸载，从而
    结束Sample类的生命周期。
* **一个类何时结束生命周期，仅仅取决于代表的Class对象何时结束生命周期**
```
由jvm自带类加载器所加载的类，在jvm生命周期中，始终不会被卸载，前面已经介绍过，jvm自带的类加载器包括
boot，ext，sys/app 三类类加载器。jvm会始终引用这些类加载器，而这些类加载器则又会始终引用其所加载的类的Class对象，
因此这些Class对象始终都是可触及的。
```
* 故由用户自定义的类加载所加载的Class对象是可以卸载的
* 类的Class实例与该类的类加载器可以理解为N:1的关系，也是双线关联关系。
    同时类的实例与类的Class实例之间又是N:1的关系

