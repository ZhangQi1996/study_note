* range
    * var a = 1 to 10   [0, 10]
        1. 等价于 1 to (10, 1)
        2. 等价于 1.to(10)
        3. 等价于 1.to(10, 1)
    * var a = 1 until 10 [0, 10)
* for (i <- 1 to 10) {...}
```
for (i <- 1 to 10) {
  for (j <- 1 to 10) {
    print(i * j)
  }
}
// 等价于
for (i <- 1 to 10; j <- 1 to 10) {
  print(i * j)
}
for (i <- 1 to 10; if (i == 0); j <- 0 until 100) {
    
}
// 即for后面的语句相当于多层嵌套
```
* 类似py的生成器
    * var vec = for (i <- 1 to 10) yield i + 1
    ```
    等价于py：vec = [i + 1 for i in range(1, 11)]
    ```
* scala的string format类似shell
```
def main(args: Array[String]): Unit = {
    val name = "david"
    val age = 23
    print(s"name is $name, age is $age") // 当字符串前面加了s表明后面要解释
}
```
* 函数多参数
    * def func(arg1: Int, args: String*): Unit = {...}
    * 等价于[java] void func(int arg1, String... args) {...}
* 函数的返回值
    当定义函数的时候，逻辑最后一行返回的可以不用返回值
    ```
    def max(a: Int, b: Int): Int = {
      if (a > b)
        a
      else
        b
    }
    ```
* 偏应用函数
    * 运用场景
        * 在业务代码中，当调用一个函数，其仅仅只有若干个参数是变化的，为了简便起见，定义偏应用函数，简化书写。
    * e.g.
    ```
    def func(a: Date, b: Int, c: String): Unit = {               
      println(s"$a $b $c")                                       
    }                                                            
    def main(args: Array[String]): Unit = {                      
      val funcPrtApp0 = func(new Date(), 1, _)                   
      def funcPrtApp1 = func(_, 2, _)                            
                                                                 
      funcPrtApp0("hello")                                       
      funcPrtApp1(new Date(), "world")                           
    }                                                            
    ```
* 高阶函数
    1. 函数做参数
    ```
    def main(args: Array[String]): Unit = {
      println(func2(func1, 1, "2"))
    }
    
    def func1(a: Int, b: String): Int = {
      a + b.toInt
    }
    // 函数做参数童谣需要指明返回类型(T1, T2) => R这样的函数类型
    def func2(f: (Int, String) => Int, a: Int, b: String): Int = {
      f(a, b)
    }
    ```
    2. 函数做返回同理
* 数组
    * 长度固定的
    ```
    def main(args: Array[String]): Unit = {
      // 固定的
      var l = new Array[Int](3) // class Array 泛型Int
      l = Array[Int](1, 2, 3) // object Array 使用了apply[T](args: T*)方法
      l(0) = 100
      l(1) = 200
      l(3) = 300
    }
    ```
    * 变长的
    ```
    val arr = ArrayBuffer[Int](1, 2, 3)
    arr.+=(4)   // +=是从尾部加
    arr.+=:(4)  // 从头部加
    arr.append(4)
    ```
* Trait(等价于java中的抽象类或者接口)
    * 第一个使用extends，后面使用with
* 类型装换
    * o.asInstanceOf[T]
* 隐式值与隐式参数
    * e.g.
    ```
    object Base {
      // 定义所有参数均为隐式参数
      def func(implicit arg1: Int, arg2: String): Unit = {
        println(s"arg1=$arg1, arg2=$arg2")
      }
    
      def main(args: Array[String]): Unit = {
        // 调用隐式函数的作用域只能有隐式函数所定义的隐式值个数
        implicit var a: Int = 1
        implicit var b: String = "123"
        func
      }
    }
  
    object Base {
      // 隐式函数含有非隐式参数的时候，需要分开定义，采用柯里化方式
      def func(arg1: Int)(implicit arg2: String): Unit = {
        println(s"arg1=$arg1, arg2=$arg2")
      }
    
      def main(args: Array[String]): Unit = {
        implicit var b: String = "123"
        func(1)
      }
    }
    ```
* 隐式函数
    * 目的就是调用某实例不存在的方法
    * 场景，比如对于某个确定的类，其没有实现某方法，但是不去修改其源码。做到该类的对象实例可以调用某个方法
    * e.g.
    ```
    object Base {
      class A {
        def func(): Unit = {
          println("the func in class A is called")
        }
      }
      class B {
    
      }
      def main(args: Array[String]): Unit = {
        // 隐式函数
        implicit def f(b: B): A = {
          new A   // 也可以写成 new A()
        }
        
        // 在B实例中调用A的方法，通过隐式函数
        // 在其能访问的作用域中(比如main函数中，Base{...}中)寻找隐式函数
        new B().func()
      }
    }
    ```  
* 隐式类
    * 仅能为内部类
    * e.g.
    ```
    object Base {
      class B {
    
      }
    
      implicit class A(b: B) {
        def func(): Unit = {
          print("extra func is called...")
        }
      }
      def main(args: Array[String]): Unit = {
        // 在B实例中调用其不存在的方法，通过隐式类
        // 在其能访问的作用域中寻找隐式类
        new B().func()
      }
    }
    ```
