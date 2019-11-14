#### 原子类型
* 整形
    * TINYINT 1B
    * SMALLINT 2B  -> java short
    * INT 4B  -> java int
    * BIGINT 8B  -> java long
* 布尔类型
    * BOOLEAN TRUE/FALSE
* 浮点类型
    * FLOAT  4B -> java float
    * DOUBLE 8B -> java double
* 小数类型
    * DECIMAL
    * 默认DECIMAL(10, 0)
    * DECIMAL(P, S): P是有数数字位数，S：是小数位
* 字符串
    * STRING 不能限定长度
    * VARCHAR(len) 限定最大长度
    * CHAR(len) 定长
* 日期时间类型
    * TIMESTAMP 时间类型
    * TIMESTAMP WITH LOCAL TIME ZONE
    * DATE 日期
* 二进制类型
    * BINARY 字节数组
#### 复杂类型
* 结构体struct
    * STRUCT<a INT, b VARCHAR(16)>
    * e.g. struct.a  struct.b
* 映射map
    * MAP<INT, VARCHAR(16)>
    * e.g. map['a']
* 数组array
    * ARRAY<INT>
    * e.g. arr[0]
* 联合类型
    * UNIONTYPEM<INT, STRING, DATE>
    * 略
 
