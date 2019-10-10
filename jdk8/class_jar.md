* 生成.class文件
    * 生成单一的不带外部导入的class文件
        * javac xxx.java
    * 将生成的class文件放到目标目录
        * javac xxx.java -d /target_dir
    * xxx.java中引入了非CLASS_PATH下的第三方jar包，则需要自行导入
        * javac -cp/classpath xxx.jar:yyy.jar:zzz.jar xxx.java
    ```
    # 对于hadoop
    javac -cp $(hadoop classpath) xx/*.java -d /target_dir
    ##### 注意 ###### xx/*.java -d /target_dir -> /target_dir/xx/*.class
    # 故常见写法是cd到com同一级目录，然后javac -cp $(hadoop classpath) com/zq/demo/*.java -d /target_dir => /target_dir/com/zq/demo/*.class
    1. 命令hadoop classpath用来获取与hadoop程序相关的所有jar包以及配置文件
    2. 将xx/*.java文件编译为.class文件放置在/target_dir目录下
    ```
* 生成jar包
    ```
    # 目录结构
    /javaProj
        /com/zq/demo
            - Main.class
            - ...
    ```  
    * 将com.zq.demo整个打包成jar
        1. cd /javaProj
        2. jar -cvf xxx.jar . # 将当前目录压缩到xxx.jar
        3. jar -cvf xxx.jar com # 就是从com目录打起
        4. 注意：要是写的jar -cvf xxx.jar ~/com 将会打成含有/home/david/com/..的jar包
* 解压jar包
    * 虽然有 jar -xvf 用来解压但是不能解压到指定目录， -C这个参数用来生成或者更新jar包的
    * 故我们用unzip xx.jar -d /target_dir来解压
* 通过hadoop jar命令运行
    * 格式
        * hadoop jar xxx.jar [main_class] [arg1 arg2..]
    * 执行xxx.jar中从MainClass类的main函数进入        