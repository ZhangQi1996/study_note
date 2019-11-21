#### 关于操作数以及UDF更多参见https://cwiki.apache.org/confluence/display/Hive/LanguageManual+UDF
* 通过SHOW FUNCTIONS查看内置的所有函数
* 通过DESCRIBE FUNCTION func_name获得函数的描述
* 通过DESCRIBE FUNCTION EXTENDED func_name获得函数的详细描述

#### 操作符
* A || B
    * 表示字符串的连接操作，注意不是OR
* A [NOT] BETWEEN B AND C
* A [NOT] LIKE B
    * 采用的是sql的正则
    * AB中只要又一个为空则返回NULL，当匹配则返回TRUE否则返回FALSE
* A RLIKE/REGEXP B
    * B采用的是java的正则
    * 只要A中的任意子串满足B的表达就返回TRUE
    * AB中只要又一个为空则返回NULL，当匹配则返回TRUE否则返回FALSE
    * 其实就是java中的A match B
* A / B 浮点除法， A DIV B 整除
* 常见构造器
```
构造器函数 参数形式 解释
map (key1, value1, key2, value2, ...) Creates a map with the given key/value pairs.

struct (val1, val2, val3, ...) Creates a struct with the given field values. Struct field names will be col1, col2, ....

named_struct (name1, val1, name2, val2, ...) Creates a struct with the given field names and values. (As of Hive 0.8.0.)

array (val1, val2, ...) Creates an array with the given elements.

create_union (tag, val1, val2, ...) Creates a union type with the value that is being pointed to by the tag parameter.
```

## UDF: user defined function
* 适用场合：
    * 通过hive内置的函数无法完成所需的查询，这个时候，通过在查询中调用UDF来完成目标操作。
    * UDF必须是用java编写的, 对于其他编程语言使用SELECT TRANSFORM(col1, ..) USING file AS ..
    * 其操作基于单个数据行，且产生一个数据行作为输出
    
* 编写属于自己的UDF
    1. 编写一个UDF的子类
    2. 这个子类必须至少实现了evaluate方法
    3. UDF中的field类型可以是hadoop的Writable也可以是Java的基本类型以及一些集合类
    4. 将UDF打成jar包
    5. 在hive中注册：ADD JAR xx/xx/xx.jar // (这个jar包是位于hiveserver的主机上的)
    6. 给自定义的UDF取一个别名：(以下的方式只在当前会话有效)
        CREATE TEMPORARY FUNCTION my_udf AS 'com.zq.udf.MyUDF'; 
    7. 运行自定义的UDF：
        SELECT my_udf(col1, ..) FROM tn;
    8. 其中自定义的函数可以用大写
    9. 注意函数中列的引用不带引号，对于UDF函数的执行是每行执行一次

* 也可以用reflect(class, method[,arg1[, arg2 ..]])或者java_method()在查询中调用
    * 参见https://cwiki.apache.org/confluence/display/Hive/LanguageManual+UDF
    

## UDAF: user defined aggregate function
* 接受多个输入数据行，并产生一个输出数据行
* 比如COUNT, MAX
* 编写一个属于自己的UDAF
    1. 编写一个UDAF的子类
    2. 该子类至少包含一个实现UDAFEvaluator的静态内部类
    3. 每个内部类必须实现
        * init: 初始化工作
        * iterate: 用于聚集每一项
        * terminatePartial: 得到当前进度的聚集结果
        * merge: 合并另一部分的聚集结果
        * terminate: 返回最终的聚集结果
    4. 当本聚集函数对于不同的数据类型进行聚集则就需要多个实现了UDAFEvaluator的静态内部类  
    5. 后面的步骤与自定义UDF后面的步骤一致

## UDTF: user defined table-generating function
* 操作单个数据行，而产生多个数据行--一个表--作为输出。
    