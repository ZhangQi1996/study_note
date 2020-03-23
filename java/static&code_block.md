#### static块
```
class A {
    static {
        ...
    }
}
```
* 静态块代码仅仅执行一次，而且在主动使用的时候执行（若是创建实例的主动使用，也是先执行static代码在执行构造器代码）
#### 代码块
```
class A {
    {
        System.out.println("code block");
    }

    A() {
        System.out.println("constructor");
    }
}
```
* 对于代码块代码，他是每次实例化一个对象实例的时候就会执行这个代码块的代码（先执行代码块的代码再执行构造器的代码）