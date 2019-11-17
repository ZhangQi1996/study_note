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
    * 标准语法
        * INSERT OVERWRITE/INTO TABLE tn [PARTITION (col1=val1, ...) [IF NOT EXISTS]] select_s FROM from_s;
             