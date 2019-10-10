## 关联数组
### Bash支持关联数组，它可以使用字符串作为数组索引，有时候采用字符串索引更容易理解。
1. 声明关联数组
    * declare -A ass_arr
2. 将元素添加到关联数组
    * 利用内嵌索引-值列表的方法
    ```
    declare -A ass_arr
    ass_arr=([lucy]=beijing [yoona]=shanghai)
    echo ${ass_arr[lucy]}
    -----------------------------
    beijing
    ```
    * 使用独立的索引-值进行赋值
    ```
    declare -A assArray
    assArray[lily]=shandong
    assArray[sunny]=xian
    echo ${assArray[sunny]}
    --------------------------------
    xian
    --------------------------------
    echo ${assArray[lily]}
    --------------------------------
    shandong
    ```
* 列出数组索引
    * ${!assArray[*]} or ${!assArray[@]}
* 获取所有键值对
    ```
    #! /bin/bash
    declare -A cityArray
    cityArray=([yoona]=beijing [lucy]=shanghai [lily]=shandong)
    for key in ${!cityArray[*]}
    do
     echo "${key} come from ${cityArray[$key]}"
    done
    ```