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
* WHERE 句子
    * where语句中不能使用聚集函数
* tn1 JOIN tn2 ON cond
* GROUP BY col HAVING cond
* LIMIT [offset,] rows
    * off从0开始
* 对列的正则（使用的是java的正则语法）
    * e.g.
    * SELECT \`(ds|hr)?+.+\` FROM sales
    * 使用单反引号将regex引起来
    * 类似WHERE .. LIKE ..

