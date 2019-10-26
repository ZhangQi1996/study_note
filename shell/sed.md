#### 用sed完成对文件的增删改查
* sed遵循简单的工作流：
    * 读取（从输入中读取某一行）
    * 执行（在某一行上执行sed命令）
    * 显示（把结果显示在输出中）
    * 注意：默认是显示修改后内容，**不会修改原文件**，除非使用-i 参数。
* 常用参数及命令
    * sed [-nefri]  'command' test.txt  （尽量按照标准格式使用单引号）
        * sed -e 'cmds'
            * sed -e 's/系统/00/g' -e '2d' test.txt： 执行多个指令
        * sed -f cmd文件名
            * sed -f ab.log test.txt： 多个命令写进ab.log文件里，一行一条命令，效果同-e
        * sed -n: 取消默认控制台输出，与p一起使用可打印指定内容
        * sed -i: 输出到原文件，静默执行（修改原文件的意思）
    * cmd
        * a: 新增（行后面追加）
            1. sed '2a testContent' test.txt: 在第 2 行后面新增一行内容
            2. sed '1,3a testContent' test.txt: 在原文的第 1~3 行后面各新增一行内容
        * c: 替换 (替换整行)
            1. sed '2c testContent' test.txt: 将第 2 行内容整行替换
            2. sed '1,3c testContent' test.txt: 将第 1~3 行内容替换成一行指定内容
        * s: 替换（行中匹配局部替换）
            1. sed 's/old/new/' test.txt: 匹配每一行的第一个old替换为new
            2. sed 's/old/new/gi' test.txt: 匹配所有old替换为new，g 代表一行多个，i 代表匹配忽略大小写
            3. sed '3,9s/old/new/gi' test.txt: 匹配第 3~9 行所有old替换为new
        * d: 删除
            1. sed '2d' test.txt: 删除第 2 行
            2. sed '1,3d' test.txt: 删除第1~3行
        * i: 插入(在行之前插入)
            1. sed '2i testContent' test.txt: 在第 2 行前面插入一行内容
            2. sed '1,3i testContent' test.txt: 在原文的第 1~3 行前面各插入一行内容
        * p: 打印，要和-n参数一起使用
            1. sed '2p' test.txt： 重复打印第 2 行
            2. sed '1,3p' test.txt： 重复打印第1~3行
            3. sed -n '2p' test.txt： 只打印第 2 行
            4. sed -n '1,3p' test.txt： 只打印第 1~3 行
            5. sed -n '/user/p' test.txt： 打印匹配到user的行，类似grep
            6. sed -n '/user/!p' test.txt： ! 反选，打印没有匹配到user的行
            7. sed -n 's/old/new/gp' test： 只打印匹配替换的行
    * 温馨提示
        * 若不指定行号，则每一行都操作。
            * sed 's/1/2/' test.txt: 每行
        * $代表最后一行
            * sed -n '$p' test.txt: 打印最后一行
        * 若要在cmd的script中使用环境变量等等，利用拼接
            * sed '$a '$PATH t.txt: 在最后一行追加$PATH的值
             
    