#### xargs 命令
* 用途：xargs 可以将管道或标准输入（stdin）数据转换成命令行参数，也能够从文件的输出中读取数据。
* xargs 是给命令传递参数的一个过滤器，也是组合多个命令的一个工具。
* xargs 也可以将单行或多行文本输入转换为其他格式，例如多行变单行，单行变多行。
* **xargs 默认的命令是 echo，这意味着通过管道传递给 xargs 的输入将会包含换行和空白，不过通过 xargs 的处理，换行和空白将被空格取代。**
* xargs 是一个强有力的命令，它能够捕获一个命令的输出，然后传递给另外一个命令。
* 之所以能用到这个命令，关键是由于很多命令不支持|管道来传递参数，而日常工作中有有这个必要，所以就有了 xargs 命令
```
E.g.
# 文件del.txt
1.txt
2.txt

// 接下来就是要删除del.txt中列出的文件
cat del.txt | xargs rm -f
// 
pidof nginx | xargs kill -9
```