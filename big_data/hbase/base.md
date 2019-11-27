#### 创建表
* create 'table_name', 'col_family'
#### 列出所有表
* list
#### 查看某表的详细信息
* describe 'tn'
#### 插入数据
* put 'table_name', 'row_key', 'col_f:col_n', 'col_val'
    * 一次只可以插入/更新一个cell
* 当插入以row_key为行键的一行时，在结构上是根据row_key的字节序升序存储的

#### 查看表中的所有信息
* scan 'tn'
    * 输出是基于cell输出的
#### 获取一行数据
* get 'tn', 'row_key'
#### 使得表不可操作
* 这种情况一般是你要进行删除表前，或者是要对表进行修改设置之前的时候
* disable 'tn'
#### 恢复对表格的操作
* enable 'tn'
#### 删除表
* drop 'tn'
#### 退出hbase shell并中断hbase cluster连接
* exit/quit
#### 启动hbase后台服务
* $HBASE_HOME/bin/start-hbase.sh
#### 停止hbase后台服务
* $HBASE_HOME/bin/stop-hbase.sh