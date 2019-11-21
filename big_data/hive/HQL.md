## 主要指表内的操作
#### hive的操作语句 1.load 2.insert 3.update 4.delete 5.merge
* LOAD
    * 从本地（hiveserver所在主机的文件系统）加载
        * LOAD DATA LOCAL INPATH 'filepath' [OVERWRITE] INTO TABLE tn [PARTITION (col1=val1, ...)]
        * 是复制文件到warehouse中
    * 从指定的文件系统中加载
        * LOAD DATA INPATH 'filepath' [OVERWRITE] INTO TABLE tn [PARTITION (col1=val1, ...)]
        * 当filepath与warehouse是同一个文件系统时，将执行移动操作
    * OVERWRITE就是覆盖重写
* 将查询结果插入hive表中
```
    * 标准语法
        * INSERT OVERWRITE/INTO TABLE tn [PARTITION (col1=val1, ...) [IF NOT EXISTS]] select_s FROM from_s;
    * 拓展语法（含多表插入）
        * FROM from_s INSERT OVERWRITE/INTO TABLE tn [PARTITION (col1=val1, ...) [IF NOT EXISTS]] select_s1 
            [INSERT OVERWRITE/INTO TABLE tn [PARTITION (col1=val1, ...) [IF NOT EXISTS]] select_s2]         
    * 拓展语法（动态分区插入）
        * INSERT OVERWRITE/INTO TABLE tn [PARTITION (col1[=val1], ...) [IF NOT EXISTS]] select_s FROM from_s; # (select_s 中包含col1)
```
* 将查询结果写入文件系统中
```
// 标准写法
INSERT OVERWRITE [LOCAL] DIRECTORY directory1
  [ROW FORMAT row_format] [STORED AS file_format] (Note: Only available starting with Hive 0.11.0)
  SELECT ... FROM ...
 
// 拓展写法 (多写入):
FROM from_statement
INSERT OVERWRITE [LOCAL] DIRECTORY directory1 select_statement1
[INSERT OVERWRITE [LOCAL] DIRECTORY directory2 select_statement2] ...
 
row_format
  : DELIMITED [FIELDS TERMINATED BY char [ESCAPED BY char]] [COLLECTION ITEMS TERMINATED BY char]
        [MAP KEYS TERMINATED BY char] [LINES TERMINATED BY char]
        [NULL DEFINED AS char] (Note: Only available starting with Hive 0.13)
```    
* 向表中插入数据
```
Standard Syntax:
INSERT INTO TABLE tablename [PARTITION (partcol1[=val1], partcol2[=val2] ...)] VALUES values_row [, values_row ...]
  
Where values_row is:
( value [, value ...] )
where a value is either null or any valid SQL literal


// examples
CREATE TABLE students (name VARCHAR(64), age INT, gpa DECIMAL(3, 2))
  CLUSTERED BY (age) INTO 2 BUCKETS STORED AS ORC;
 
INSERT INTO TABLE students
  VALUES ('fred flintstone', 35, 1.28), ('barney rubble', 32, 2.32);
 
 
CREATE TABLE pageviews (userid VARCHAR(64), link STRING, came_from STRING)
  PARTITIONED BY (datestamp STRING) CLUSTERED BY (userid) INTO 256 BUCKETS STORED AS ORC;
 
INSERT INTO TABLE pageviews PARTITION (datestamp = '2014-09-23')
  VALUES ('jsmith', 'mail.com', 'sports.com'), ('jdoe', 'mail.com', null);
 
INSERT INTO TABLE pageviews PARTITION (datestamp)
  VALUES ('tjohnson', 'sports.com', 'finance.com', '2014-09-23'), ('tlee', 'finance.com', null, '2014-09-21');
  
INSERT INTO TABLE pageviews
  VALUES ('tjohnson', 'sports.com', 'finance.com', '2014-09-23'), ('tlee', 'finance.com', null, '2014-09-21');
```
* update, delete, merge操作只有在满足ACID的事务中才能执行
    * 细节参见https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DML
* export / import：用于将hive中存储的表/分区，以及元数据导出到一个特定的输出位置，这样可以用于再次将数据导入另一个hadoop/hive实例中，导入用import命令
    * 细节参见https://cwiki.apache.org/confluence/display/Hive/LanguageManual+ImportExport
    
#### SELECT
* select语法
```
[WITH CommonTableExpression (, CommonTableExpression)*]    (Note: Only available starting with Hive 0.13.0)
SELECT [ALL | DISTINCT] select_expr, select_expr, ...
  FROM table_reference
  [WHERE where_condition]
  [GROUP BY col_list]
  [ORDER BY col_list]
  [CLUSTER BY col_list
    | [DISTRIBUTE BY col_list] [SORT BY col_list]
  ]
 [LIMIT [offset,] rows]

// [ALL | DISTINCT] 用于查询是否不同的
// DISTRIBUTE BY 按列进行入桶（运行map后的partition进行分区入桶）
// SORT BY 为每个reducer（一个桶就是一个reducer）根据列产生一个排序

// 注：from 字句是可选的
e.g. SELECT 1+1;
```
* 对于聚集函数
    * set hive.map.aggr=true
    * 将会让聚集操作优先在map中运行
* WHERE 句子
    * where语句中不能使用聚集函数
* JOIN .. ON ..
    * 在2.2版本之前在ON之后的expr中只支持等值条件，后来支持复杂条件了
    * 注意在执行SELECT .. JOIN .. ON (..) WHERE ..
        1. 先执行ON条件完成合并，然后在合并的结果里面通过WHERE句子完成筛选
    * 若对于表比较小，可以在map中完成可以向如下写法，告诉mr程序用map来完成join
        ```
        SELECT /*+ MAPJOIN(b)*/ a.key, a.val FROM
        a JOIN b on (a.key = b.key);
        // 对加载b表用一个map完成
        ```
        * 参见《hadoop权威指南第三版》P485 or 访问https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Joins
    * 格式如下
    * tn1 [INNER] JOIN tn2 [ON (expr)]
        * 内连接（inner join）：取出两张表中匹配到的数据，匹配不到的不保留
        * 对于内连接，高版本已经支持了SELECT tb1, tn2 [,..]这样的多表内连接的简单表达形式，但是限制条件只能用WHERE语句
    * tn1 LEFT/RIGHT/FULL [OUTER] JOIN tn2 [ON (expr)]
        * 保留左边/右边/全部
    * tn1 LEFT SEMI JOIN tn2 [ON (expr)]
        * 等价于IN/EXISTS的操作
        ```
        // IN
        SELECT a.key, a.val FROM a 
        WHERE a.key IN
        (SELECT b.key FROM b);
        // LEFT SEMI JOIN .. ON ..
        SELECT a.key, a.val FROM 
        a LEFT SEMI JOIN b ON (a.key = b.key);
        ```
    * tn1 CROSS JOIN tn2 [ON (expr)]
        * 即tn1与tn2做笛卡尔积
* GROUP BY col HAVING cond
    * 注意在SELECT语句中，只能包含分组中的列或者聚集函数
    * e.g. SELECT a, SUM(b) from test GROUP BY a; # 有效
    * e.g. SELECT a, b from test GROUP BY a; # 无效,包含了非分组的列b
    * 在多插入中自然就包括了多分组
* LIMIT [offset,] rows
    * off从0开始
* ORDER BY  排序
    * 语法
    ```
    ORDER BY col [ASC(默认) | DESC] [NULLS FIRST | NULLS LAST(默认NULL最小)] [...]
    ```
* SORT BY 排序
    * 语法
    ```
    SORT BY col [ASC(默认) | DESC] [...]
    ```
* **ORDER/SORT BY的区别**
    1. hive仅仅让sort by工作在每个reducer中，即order by是全局有序，而sort by是局部有序
* DISTRIBUTE/CLUSTER BY cols
    * 主要与transform/mr脚本配套使用
    * 对于子查询，对子查询的结构进行分区与排序时用到distribute/cluster by
    * hive使用DISTRIBUTE BY通过cols来将对应rows进行分配到特定的reducer中。（自我感觉有点像分桶）
    * CLUSTER BY就是在每个reducer中进行排序，等价于DISTRIBUTE BY col SORT BY col
    * DISTRIBUTE BY采用的分区模式其实就是%reducers_num
    
#### CTAS
* 语法
    * CREATE TABLE tn AS SELECT ...; (对于fields的分隔符默认使用ctrl+a)
    * 使得创建的表带有格式
    ```
    create table t row format delimited fields terminated by '\t' stored as textfile as select name [as new_name], age [as new_age] from test;    
    ```
* 通过查询的结果创建一张表
#### UNION 结果取并集
* 语法
    * select_s1 UNION [ALL | DISTINCT(默认DIS)] select_s2 ...
#### TABLESAMPLE 表取样
* 语法
    * TABLESAMPLE (BUCKET x OUT OF y [ON col])
        * 在某表中根据col列进行分桶，分为y个桶，取前面x个桶
        * y个桶即y个reducer
        * 分桶采用hashcode%y的值    
    * E.G.
    ```
    SELECT * FROM source
    TABLESAMPLE (BUCKET 3 OUT OF 32 ON rand()) s;
    // 在随机的列上根据列值得hashcode进行分桶 
    ```
    * 还支持 TABLESAMPLE(n PERCENT)
        * 取得n%的样本
    * 还支持 TABLESAMPLE(nb/B/k/K/m/M/g/G)
        * 取得n大小的样本
    * 还支持 TABLESAMPLE(n ROWS)
        * 取得n行的样本
#### 子查询
* 语法
    * SELECT ... FROM (subquery) [AS] name ...
* 注意子查询存在于FROM子句中时候，而且必须取别名
* 在0.13版本以后子查询循序存在于WHERE子句中了，用于WHERE中的IN/NOT IN以及EXISTS/NOT EXISTS
* 限制
    1. 子查询只支持右手表达式
    2. IN/NOT IN的子查询仅仅支持单列选择的子查询
    3. EXISTS/NOT EXISTS必须有一个或多个相关谓语
    4. 引用的父查询只能出现在子查询中的where语句中
#### VIEW 视图(只读)
* 就是将一个查询静态为一个视图，当调用这个视图的时候将执行这个查询，当数据量庞大的时候
    应该最后使用CTAS操作，或者使用CT&ITSF
* 语法
    * CREATE VIEW vn [(new_col1, ...)] AS SELECT ...;
    * CREATE VIEW vn AS SELECT col1 AS new_col1, ... FROM ...;
#### explode以及LATERAL VIEW
* 用于将表中的数组等进行展开
* 参见https://cwiki.apache.org/confluence/display/Hive/LanguageManual+LateralView