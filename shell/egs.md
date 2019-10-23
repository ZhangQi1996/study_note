* shell统计当前文件夹下的文件个数、目录个数
```
1、 统计当前文件夹下文件的个数
　　ls -l |grep "^-"|wc -l
2、 统计当前文件夹下目录的个数
　　ls -l |grep "^d"|wc -l
3、统计当前文件夹下文件的个数，包括子文件夹里的 
　　ls -lR|grep "^-"|wc -l
4、统计文件夹下目录的个数，包括子文件夹里的
　　ls -lR|grep "^d"|wc -l
grep "^-" # 用^ 或者 $时，则匹配每行
　　这里将长列表输出信息过滤一部分，只保留一般文件，如果只保留目录就是 ^d
wc -l 
　　统计输出信息的行数，因为已经过滤得只剩一般文件了，所以统计结果就是一般文件信息的行数，又由于一行信息对应一个文件，所以也就是文件的个数。
```
* 打印每个目录下的文件数量
    ```
    # 目录结构
    /NB
        /Country
            /CHINA
                -xxx.txt
                -yyy.txt
                ...
            ...
        /Industry
            ...
        1.sh
    # 1.sh的功能就是查找Country或者Industry目录中每个子目录中的文件数量
    #执行bash 1.sh Country/ -p
    # 输出 e.g.
    ...
    USA: 3137
    UZBK: 1
    VCAN: 1
    VEN: 28
    VIETN: 13
    YEMAR: 5
    YUG: 31
    ZAIRE: 32
    ZAMBIA: 10
    ZIMBAB: 17
    ...
    ```
    * 代码
    ```
    #!/bin/bash
    # Usage: bash 1.sh [Country/ | Industry/] [-p]
    # 一定要到Country的同级目录运行, -p表示是否带前缀
    dir=$1
    # 判断输入的第一个参数末尾是否有/
    if [[ ${dir: 0-1: 1} == '/' ]]; then
        # 有/则去除/
        dir=${dir: 0: ((${#dir}-1))}
    fi
    # 将Country目录的ls结果（传给后就是一行一个结果）管道给awk，然后一个个取出来为i 
    for i in $(ls $1 | awk '{print $1}'); do
        # == 左右要空格，是否要打印前缀
        if [[ $2 == '-p' ]]; then
            printf $i': '
        fi
        # 得出每个子目录中的文件数目
        echo $(ls -l $(pwd)/$dir/$i | grep '^-' | wc -l)
    done

    ```
    
