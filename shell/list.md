#### 在shell中有序列与数组之分
* 所谓序列不过是以空格之分的字符串
* 对 value_list 的说明
        1) 给出一个取值范围
            ```
            给出一个取值范围的具体格式为：
            {start..end}
            
            start 表示起始值，end 表示终止值；注意中间用两个点号相连，而不是三个点号。根据笔者的实测，这种形式只支持数字和字母。
            
            例如，计算从 1 加到 100 的和：
            #!/bin/bash
            sum=0
            for n in {1..100}
            do
                ((sum+=n))
            done
            echo $sum
            运行结果：
            5050
            
            再如，输出从 A 到 z 之间的所有字符：
            #!/bin/bash
            for c in {A..z}
            do
                printf "%c" $c
            done
            输出结果：
            ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz
    
            可以发现，Shell 是根据 ASCII 码表来输出的。
            ```
        2) 使用命令的执行结果
            ```
            使用反引号``或者$()都可以取得命令的执行结果，我们在《Shell变量》一节中已经进行了详细讲解，并对比了两者的优缺点。本节我们使用$()这种形式，因为它不容易产生混淆。
            
            例如，计算从 1 到 100 之间所有偶数的和：
            #!/bin/bash
            sum=0
            for n in $(seq 2 2 100)
            do
                ((sum+=n))
            done
            echo $sum
            运行结果：
            2550
            
            seq 是一个 Linux 命令，用来产生某个范围内的整数，并且可以设置步长，不了解的读者请自行百度。seq 2 2 100表示从 2 开始，每次增加 2，到 100 结束。
            
            再如，列出当前目录下的所有 Shell 脚本文件：
            #!/bin/bash
            for filename in $(ls *.sh)
            do
                echo $filename
            done
            运行结果：
            demo.sh
            test.sh
            abc.sh
            
            ls 是一个 Linux 命令，用来列出当前目录下的所有文件，*.sh表示匹配后缀为.sh的文件，也就是 Shell 脚本文件。
```