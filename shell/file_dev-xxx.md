#### /dev/null
* 指的是一个空文件，理解为一个黑洞
* 常用法就是将无用的输出放入其中
* 将报错放入
    * cat 1.txt 2> /dev/null | wc -l
        * 2> /dev/null: 将之前cmd执行产生的错误信息输出到null文件中（既没有错误输出）
        * 将标准输出通过管道传给cmd(wc -l)以统计行数
#### /dev/zero
* “零”设备，可以无限的提供空字符（0x00，ASCII代码NUL）。常用来生成一个特定大小的文件。
* eg
    * dd if=/dev/zero of=./output.txt bs=1024 count=1 见dd.md
#### /dev/random与/dev/urandom
**随机数设备，提供不间断的随机字节流。二者的区别是**
* /dev/random产生随机数据依赖系统中断，当系统中断不足时，/dev/random设备会“挂起”，因而产生数据速度较慢，但随机性好；
* /dev/urandom不依赖系统中断，数据产生速度快，但随机性较低。
```
$ cat /dev/random | od -x
0000000 34fa b5ea 0901 b7e0 27a9 623a 0879 d9eb
0000020 d212 4f6f d928 6637 84a4 8ec5 fc2c 4896
$ cat /dev/urandom | od -x | head -n 5
0000000 8048 4dbd 07c9 2119 02d0 221b 89ba af7f
0000020 3d6f 6a72 3752 4a09 5a47 a3fb dc98 ed9f
0000040 f3e8 e82d 6748 2e14 de80 7554 bb52 f56c
0000060 de73 0e51 262f 5a63 af69 b45c ee49 c1bf
0000100 76b4 6db5 4e5b e438 70fb d207 a28c 04a8

利用/dev/urandom设备产生一个128位的随机字符串：
$ str=$(cat /dev/urandom | od -x | tr -d ' ' | head -n 1)
$ echo ${str:7}
17539187d2e8b8e26d49bec90465c14d 
```