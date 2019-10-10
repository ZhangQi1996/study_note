```
grep 更适合单纯的查找或匹配文本
sed  更适合编辑匹配到的文本
awk  更适合格式化文本，对文本进行较复杂格式处理
```
* awk
    * awk是逐行处理的，没到新的一行就会执行新的pattern-action
    * 基本使用格式
        * awk [options] 'pattern{action}'file
        * 表示对file文件在经过pattern下进行action操作
    * 举例
    ```
    # 1.txt
    1 2 3 4 5 6
    -1 -2 -3 -4 -5 -6
    ```
    * awk '{printf $2}'1.txt OR cat 1.txt | awk '{printf $2}'
        * $2指的是在1.txt中的经过分隔符后的第2列
        ```
        # 结果
        2
        -2
        ```
    * $0表示整行，NF表示当前行分割开后共有几个字段，$NF表示当前行的分割后的最后一列
    * 要表示倒数第几列就用$(NF-i)
    * df | awk '{print $1, $2}'
        * 将df的输出做输入，输出每行中的第一第二列
    * df | awk '{print $1, 66, 'hello'}'
        * 每行的输出除了df中每行的第一列，还有自己拼接的数字66，还有字符串hello(注意在awk中的字符串要加引号)
    * awk的pattern
        * 两种特殊的模式：BEGIN, END
        * BEGIN模式: 指定了处理文本之前需要执行的op
            * df | awk 'BEGIN{print 'hello',' ', 'world'}'
                * 在处理df的结果之前，先打印hello world
            * df | awk 'BEGIN{print "begin"}{print $1, $2}'
                * {print $1, $2} 才是正在地对数据处理
        * END模式： 指定了处理文本之后需要执行的操作 
            * df | awk '{print $(NF-1)}END{print 'end'}'
                * {print $(NF-1)} 才是真正的对数据进行处理
            * df | awk 'BEGIN{...}{...}END{...}'
        
         
      