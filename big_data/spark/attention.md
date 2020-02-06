* 对于java spark中(k, v)在java中都使用mapToPair算子
* 对于在java scala的算子中使用lambda的表达式
    ```
    // 报Caused by: java.io.NotSerializableException: java.io.PrintStream异常
    foreach(System.out::println)
    // 不报错
    foreach(s -> System.out.println(s))
    ```
