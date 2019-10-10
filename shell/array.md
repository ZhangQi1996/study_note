* 定义： 用括号( )来表示数组，数组元素之间用空格来分隔
    * array_name=(ele1  ele2  ele3 ... elen)
    ```
    nums=(29 100 13 8 91 44)
    # Shell 是弱类型的，它并不要求所有数组元素的类型必须相同，例如：
    arr=(20 56 "http://c.biancheng.net/shell/")
    
    echo $arr # 是打印arr的第一个元素
    ```
* 数组append
    * 假设arr的长度为len，则追加为arr[len]=new_elem
    * 常用方法： arr[${#arr[@]}]=new_elem
* 获取数组元素 ${array_name[index]}
* 使用@或*可以获取数组中的所有元素
    * ${nums[*]}
    * ${nums[@]}
    * 两者都可以得到 nums 数组的所有元素。
    * 这里的*与@没有区分，注意$@与$*的区别
* 获取arr的长度
    * ${#arr[@]} or ${#arr[*]}
* 数组拼接
    ```
    先利用@或*，将数组扩展成列表，然后再合并到一起。具体格式如下：
    array_new=(${array1[@]}  ${array2[@]})
    array_new=(${array1[*]}  ${array2[*]})
    
    两种方式是等价的，选择其一即可。其中，array1 和 array2 是需要拼接的数组，array_new 是拼接后形成的新数组。
    
    #!/bin/bash
    array1=(23 56)
    array2=(99 "http://c.biancheng.net/shell/")
    array_new=(${array1[@]} ${array2[*]})
    echo ${array_new[@]}  #也可以写作 ${array_new[*]}
    ------------------------------------------------
    运行结果：
    23 56 99 http://c.biancheng.net/shell/
    ```
* 删除数组元素
    * 删除某个元素
        * unset arr[index]
    * 删除数组
        * unset arr
* 获取数组某范围的元素 
    * ${arr[@]: start: len}
    * ${arr[@]: start}
    * ${arr[@]: 0-start: len}
    * ${arr[@]: 0-start}
* 临时替换
    * ${数组名[@或*]/查找的第一个字符串/替换字符串} 该操作不会改变原先数组内容，如果需要修改则用赋值
    * ${数组名[@或*]//查找的字符串/替换字符串} 该操作不会改变原先数组内容，如果需要修改则用赋值
    ```
    arr=(1 0 3)
    echo ${arr[@]/0/2}
    -------------------
    1 2 3
    ```