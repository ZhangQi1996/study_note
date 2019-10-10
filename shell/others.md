* if-else
    * if
    ```
    if  condition
    then
        statement(s)
    fi
    
    or
  
    if  condition;  then
        statement(s)
    fi
    ```
    * if else 语句
    ```
    如果有两个分支，就可以使用 if else 语句，它的格式为：
    if  condition
    then
     statement1
    else
     statement2
    fi
    ```
    * if elif else 语句
    ```
    Shell 支持任意数目的分支，当分支比较多时，可以使用 if elif else 结构，它的格式为：
    if  condition1
    then
       statement1
    elif condition2
    then
        statement2
    elif condition3
    then
        statement3
    ……
    else
       statementn
    fi
    
    注意，if 和 elif 后边都得跟着 then。
    ```
    
* case-in
    ```
    case expression in
        pattern1)
            statement1
            ;;
        pattern2)
            statement2
            ;;
        pattern3)
            statement3
            ;;
        ……
        *)
            statementn
    esac
  ```
* while
    ```
    #!/bin/bash
    i=1
    sum=0
    while ((i <= 100))
    do
        ((sum += i))
        ((i++))
    done
    echo "The sum is: $sum"
  ```
* util
    ```
    unti 循环和 while 循环恰好相反，当判断条件不成立时才进行循环，一旦判断条件成立，就终止循环。
    
    until 的使用场景很少，一般使用 while 即可。
    
    Shell until 循环的用法如下：
    until condition
    do
        statements
    done
  ```
* for
    ```
    for((exp1; exp2; exp3))
    do
        statements
    done
    
    #!/bin/bash
    sum=0
    for ((i=1; i<=100; i++))
    do
        ((sum += i))
    done
    echo "The sum is: $sum"
    
  ```
* foreach
    ```
    for variable in value_list
    do
        statements
    done
    
    #!/bin/bash
    sum=0
    for n in 1 2 3 4 5 6
    do
        echo $n
         ((sum+=n))
    done
    echo "The sum is "$sum
    ```
    * 对 value_list 的说明
        *取值列表 value_list 的形式有多种，你可以直接给出具体的值，也可以给出一个范围，还可以使用命令产生的结果，甚至使用通配符，下面我们一一讲解。
        1) 直接给出具体的值
            ```
            可以在 in 关键字后面直接给出具体的值，多个值之间以空格分隔，比如1 2 3 4 5、"abc" "390" "tom"等。

            上面的代码中用一组数字作为取值列表，下面我们再演示一下用一组字符串作为取值列表：
            #!/bin/bash
            for str in "C语言中文网" "http://c.biancheng.net/" "成立7年了" "日IP数万"
            do
                echo $str
            done
            运行结果：
            C语言中文网
            http://c.biancheng.net/
            成立7年了
            日IP数万
            ```
        2) 给出一个取值范围
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
        3) 使用命令的执行结果
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
        4) 使用 Shell 通配符
            ```
            Shell 通配符可以认为是一种精简化的正则表达式，通常用来匹配目录或者文件，而不是文本，不了解的读者请猛击《Linux Shell 通配符（glob 模式）》。
            
            有了 Shell 通配符，不使用 ls 命令也能显示当前目录下的所有脚本文件，请看下面的代码：
            #!/bin/bash
            for filename in *.sh
            do
                echo $filename
            done
            运行结果：
            demo.sh
            test.sh
            abc.sh
            5) 使用特殊变量
            Shell 中有多个特殊的变量，例如 $#、$*、$@、$?、$$ 等（不了解的读者请猛击《Shell特殊变量》），在 value_list 中就可以使用它们。
            #!/bin/bash
            function func(){
                for str in $@
                do
                    echo $str
                done
            }
            func C++ Java Python C#
            运行结果：
            C++
            Java
            Python
            C#
            
            其实，我们也可以省略 value_list，省略后的效果和使用$@一样。请看下面的演示：
            #!/bin/bash
            function func(){
                for str
                do
                    echo $str
                done
            }
            func C++ Java Python C#
            运行结果：
            C++
            Java
            Python
            C#
            ```
* break
    * break n 跳出n层循环
    * break 跳出当前循环
* continue
    * continue n 跳过n层循环
    * continue 跳过本轮循环

* function
    * 定义：
    ```
    # define
    function func() {
        statement...
        [return ..]
    } 
    # call
    func [arg1 arg2 ...]
    ```