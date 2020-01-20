* echo -n xxx
    * 不换行输出
* echo -e "xxx"
    * xxx中可包含\t等字符
* echo $var
    * 默认是忽略var中包含的换行符的
* echo "$var"
    * 则会输出其中的换行内容