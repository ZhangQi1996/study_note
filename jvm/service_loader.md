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
    
* 代码分析
```
// 通过JDBC驱动加载深刻理解线程上下文类加载器机制
// Class.forName("com.mysql.jdbc.Driver");
// 会完成Driver这个类的初始化
// 会执行Driver类中的那个静态块
Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/db", "userid", "pw");

// 其实现在的jdbc加载驱动的方式是这样的
1. 手动通过Class.forName("...") 进行会在...驱动实现类初始化的时候完成该类的注册
2. 调用DriverManager.xxx时
    DriverManager在初始化的过程中也会完成注册驱动实现类
    首先去注册系统属性jdbc.drivers中指定的驱动实现类
    再去通过ServiceLoader的方式（即Service Provider）也去路径下加载驱动

即导入的jdbc驱动包符合ServiceProvider规范的时候可以不用写上Class.forName("...")这行代码
其实写上DriverManager.xxx就足够了
而getConn()函数就是去注册的驱动列表中
* 判断两个同名的class对象目的就是保证其来此同一命名空间
```