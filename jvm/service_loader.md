#### ServiceLoader类
* service：包括一些定义服务接口/抽象类
* service provider：包括实现/继承服务接口/抽象类的类
* 举例：
    * service: java.sql.Driver
        * 定于驱动的服务接口
    * service provider: com.mysql.jdbc.Driver/com.mysql.fabric.jdbc.FabricMySQLDriver
        * 实现服务接口的服务提供者类
* 而ServiceLoader用于加载那些实现了服务接口/抽象类的类
* e.g.
```
// 加载所有实现了Driver服务的子类
ServiceLoader<Driver> serviceLoader = ServiceLoader.load(Driver.class);
Iterator<Driver> iterator = serviceLoader.iterator();
while (iterator.hasNext()) {
    Driver driver = iterator.next();
    System.out.println(driver.getClass());
}
```
* 注意想通过ServiceLoader来加载提供者类有以下要求
    1. 提供者类有一个无参数的构造函数
    2. 在所在包的META-INF/services/目录下，提供一个名为服务接口/抽象类的全限定名文件
        * e.g. META-INF/services/java.sql.Driver
    3. 在该文件中提供对服务接口实现的类的全限定名
    ```
    # 在META-INF/services/java.sql.Driver文件中
    com.mysql.jdbc.Driver
    com.mysql.fabric.jdbc.FabricMySQLDriver
    ```
    4. 该文件中忽视空格与tab，注释用#，采用UTF-8编码