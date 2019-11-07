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
