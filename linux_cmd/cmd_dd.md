#### dd用于从输入文件拷贝一定数量快的内容到输出文件
* dd if=/dev/zero of=./output.txt bs=1024 count=1
    * if: input file
    * of: output file
    * bs: block size (byte)
    * count: num of blocks copied 