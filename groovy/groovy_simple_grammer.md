## 介绍groovy编程语言
* 输出
    * println("hello groovy")
##### _ps: groovy中跟python一样可以省略分号,不区分单双引号_
* 变量的定义
    * e.g. def i = 18
        * def是弱类型的，groovy会根据情况自动给变量赋予对应的类型
    * e.g. def str = "hello"
    * 定义一个列表
        * def list = [1, 2, 3]
    * 往列表中添加元素
        * list << '123'
    * 从列表中取出第3个元素
        * list.get(2)
    * 定义一个map
        * def map = ['key': 'val'] **是中括号不是大括号**
    * 获取map中的键值
        * map[xx], map.get(xxx), map.xxx
    * 设置map中的键值对
        * 同Python
    * 定义函数
        * def func(arg1, arg2, args3=default_val) {....}
---
## groovy的闭包
* 闭包就是一段代码块。在gradle中我们主要吧闭包当参数使用
```
// groovy code
def closure = { // define a closure
    println("hello world")
}

def func(Closure c) {   // define a func
    c();    // call a closure
}

func(closure)   // call a func
```
* 闭包传参
```$xslt
def closure = {
    // there's a param named str in the closure defined
    // str -> println("hello ${str}")
    str ->  // attention: there's not a big blanket in a lambda formula
        str += 2
        println("hello ${str}") // injecting params in a str by writing just like ${xxx}

}

def func(Closure c, str=2) {
    c(str)
}

func(closure)

```