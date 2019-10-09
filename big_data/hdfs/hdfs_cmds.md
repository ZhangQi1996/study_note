* 浏览hdfs下的文件目录
    * hadoop fs -ls /
        * hadoop fs： HADOOP下的文件系统
        * -ls 浏览
        * / 详细目录
        * 等价于hadoop fs -ls hdfs://master:9999/
        * -ls -d 只列出文件名，不列出详细目录
        * -ls -R 递归列出详细目录信息
* 创建目录
    * hadoop fs -mkdir /user
        * 在hadoop指定的文件系统下创建/user目录
        * 也支持递归创建： hadoop fs -mkdir -p xxx
* 将文件从本地文件系统中复制到hdfs中(支持目录操作)  仅支持单一目标
    * hadoop fs -copyFromLocal xx.xx /xx/xx
    * 若是覆盖则在 -copyFromLocal -f
* 从hdfs到本地
    * -copyToLocal <src> <localDisk>  (支持目录操作)  仅支持单一目标
* 打印文件
    * hadoop fs -cat /xx/xx.xx
* put指令 (支持目录操作)  支持多目标
    * 将本地文件（多个隔开）上传到hdfs的目录中
        * hadoop fs -put 1.txt 2.txt /hdfs的目录
    * 将本地输入流上传到hdfs的文件中 仅支持单一文件
        * hadoop fs -put - /hdfs的文件
* get (支持目录操作)  支持多目标
    * -get <src> <localDisk>
* 创建文件
    * -touchz
* 移动： -mv
* 删除： -rm
* 修改权限 -chmod
    * 修改文件权限 -chmod xxx
    * 修改目录权限 -chmod -R xxx

---
**hadoop fs <-> hdfs dfs**
---

* -du 查看目录文件大小
    * -du -h 可读形式的展示
* -df 查看hdfs总共有多大


