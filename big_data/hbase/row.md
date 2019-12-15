* HBase以表的形式存储数据。表有行和列组成。列划分为若干个列族(row family)
#### Row Key
* 与nosql数据库们一样,row key是用来检索记录的主键。访问hbase table中的行，只有三种方式：
    1. 通过单个row key访问
    2. 通过row key的range
    3. 全表扫描
    * Row key行键 (Row key)可以是任意字符串(最大长度是 64KB，实际应用中长度一般为 10-100bytes)，在hbase内部，row key保存为字节数组。   
    * 存储时，数据按照**Row key的字典序(byte order)排序存储**。设计key时，要充分排序存储这个特性，将经常一起读取的行存储放到一起。(位置相关性)
    * 注意：
    * 字典序对int排序的结果是1,10,100,11,12,13,14,15,16,17,18,19,2,20,21,…,9,91,92,93,94,95,96,97,98,99。要保持整形的自然序，行键必须用0作左填充。  
    * **行的一次读写是原子操作** (不论一次读写多少列)。这个设计决策能够使用户很容易的理解程序在对同一个行进行并发更新操作时的行为。
#### 列族
* 一列 => col_family: col_qualifier
    * 列族名: 列限定符
* hbase表中的每个列，都归属与某个列族。列族是表的schema的一部分(而列不是)，必须在使用表之前定义。列名都以列族作为前缀。
    * 例如courses:history ， courses:math 都属于 courses 这个列族。
* 访问控制、磁盘和内存的使用统计都是在列族层面进行的。实际应用中，列族上的控制权限能 帮助我们管理不同类型的应用：
    * 我们允许一些应用可以添加新的基本数据、一些应用可以读取基本数据并创建继承的列族、一些应用则只允许浏览数据（甚至可能因 为隐私的原因不能浏览所有数据）。
* **自我理解**
    * 一个列族中放置的放置的都是类似属性的列
    * hbase可能为了减少连接操作，比如学生表含有两个列族一个是person一个是relation
    * person: name, age, gender
    * relation: class, teacher_id, degree
#### 时间戳
* HBase中通过row和columns确定的为一个存贮单元称为cell。
    * Cell
    * 由{row key, column( =<family> + <label>), version} 唯一确定的单元。cell中的数据是没有类型的，全部是字节码形式存贮。
* 每个 cell都保存着同一份数据的多个版本。版本通过时间戳来索引。时间戳的类型是 64位整型。
    * 时间戳可以由hbase(在数据写入时自动 )赋值，此时时间戳是精确到毫秒的当前系统时间。时间戳也可以由客户显式赋值。如果应用程序要避免数据版本冲突，就必须自己生成具有唯一性的时间戳。每个 cell中，不同版本的数据按照时间倒序排序，即最新的数据排在最前面。
* 为了避免数据存在过多版本造成的的管理 (包括存贮和索引)负担，hbase提供了两种数据版本回收方式。
    1. 一是保存数据的最后n个版本
    2. 二是保存最近一段时间内的版本（比如最近七天）。用户可以针对每个列族进行设置。