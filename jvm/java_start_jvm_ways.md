* java -cp /home/david/../xxx.jar -Dname=yellow -DsleepDuration=10 -Xxm300m com.zq.demo.Main
    * -cp: classpath 后面跟着要加载的字节码的路径
    ```
    在java代码中获取传入的参数
    String val0 = System.getProperty("name");
    String val1 = System.getProperty("sleepDuration");  
    ```
    * -Xxm300m: 指定jvm的堆内存为300M
    * com.zq.demo.Main: main函数主入口所在的类全限定名
    ```
    package com.zq.demo
    public class Main {
        public static void main(String[] args) {
            ...
        }
    }
    ```
    
    