#### 按一定格式输出文件内容
* -t c          printable character or backslash escape
    * od -c 1.txt
* -t d[SIZE]    signed decimal, SIZE bytes per integer
    * od -t d[SIZE]
* -t f[SIZE]    floating point, SIZE bytes per float
* -t o[SIZE]    octal, SIZE bytes per integer
* -t u[SIZE]    unsigned decimal, SIZE bytes per integer
* -t x[SIZE]    hexadecimal, SIZE bytes per integer