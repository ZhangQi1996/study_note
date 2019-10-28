### 拆分文件
* split [OPTION]... [FILE [PREFIX]]
    * Output pieces of FILE to PREFIXaa, PREFIXab, ...;
    * default size is 1000 lines, and default PREFIX is 'x'.
    * 如果没有指定文件，或者文件为"-"，则从标准输入读取。
* OPTS
    * -a: 后缀长度 == --suffix-length, 默认值为2(默认的后缀是字母)
        * -a 3 == --suffix-length=3
    * --additional-suffix: 而外的后缀名
        * split -a 3 --additional-suffix=.txt: 则真正的后缀外 xxx.txt
    * -b: 按字节数分割文件
        * -b 10K
    * -d: 设置后缀为数字（从0开始递增）
        * --numeric-suffixes[=FROM]： 从from开始
    * -l: 按多少行分割
    * -n: 将文件分成多少块
        * N       split into N files based on size of input
        * K/N     output Kth of N to stdout
        * l/N     split into N files 基于行或者记录
        * l/K/N   output Kth of N to stdout 基于行或者记录
* eg
    * split --additional-suffix=.txt --numeric-suffixes=1 -n l/$DIV_NUMS  train_$2_all.txt train_$2
        * 而外的后缀为.txt
        * 后缀开始至为1
        * 基于行的文件分割
        * 对train_$2_all.txt进行拆分

