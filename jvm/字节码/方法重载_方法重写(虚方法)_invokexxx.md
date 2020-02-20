#### 静态解析
* 有些符号引用在类加载的阶段或者是第一次使用时就会装换成直接引用
* 静态解析的四种情形
    1. 静态方法 invokestatic
        * 静态方法不可以重写(override)，唯一确定，不存在多态性
    2. 父类方法 invokespecial
    3. 构造方法 invokespecial
    4. 私有方法 invokespecial
        * 因为私有方法不允许重写(override)，唯一确定，不存在多态性
    * 以上四种方法称为非虚方法，在类加载阶段就可以从符号引用转换为直接引用
    
#### 动态链接
* 一些符号引用时在runtime的时候转换为直接引用，这种转换叫做动态链接
#### invokexxx
* invokeinterface
    * 调用接口中的方法，实际上是在运行期上决定的，决定调用实现该接口的那个对象的特定方法
    ```java
    interface A {
        void func();
    }
    public class Demo implements A {
    
        public static void main(String[] args) {
            A a = new Demo();
            a.func(); // invokeinterface
            new Demo().func(); // invokevirtual
        }
    
        @Override
        public void func() {
            
        }
    }
    ```
* invokestatic
    * 调用静态方法
* invokespecial
    * 调用自己的私有/构造方法<init>，以及父类的方法
* invokevirtual
    * 调用虚方法，运行期，动态查找的过程。（常见于调用重写的方法-方法动态分配）
* invokedynamic
    * 调用动态方法
#### 方法的重载-方法的静态分派
* 方法重载（overload）是一种**静态**的行为，编译期就可以完全确定，是**编译期行为**
* 重载的方法接受的参数，是根据其静态的类型来分派的
```java
// 示例代码
public class Demo {
    void test(Grandpa grandpa) {
        System.out.println("grandpa");
    }
    void test(Father father) {
        System.out.println("father");
    }
    void test(Son son) {
        System.out.println("son");
    }
    public static void main(String[] args) {
        Demo d = new Demo();
        Grandpa g1 = new Father();
        Grandpa g2 = new Son();
        d.test(g1);     // 输出grandpa
        d.test(g2);     // 输出grandpa
        d.test((Father) g2);    // 输出father
        d.test(new Father());   // 输出father
        d.test(new Son());      // 输出son
    }
}
class Grandpa {}
class Father extends Grandpa {}
class Son extends Father {}
```
#### 方法重写-方法的动态分派
* 重写(override/overwrite)方法在字节码中由invokevirtual指令来执行调用
* 调用方法是在运行期动态地确定的，方法重写是**动态**的，是**运行期行为**。
```java
// java代码
    class Fruit {
        void test() {
            System.out.println("fruit");
        }
    }
    class Apple extends Fruit {
        @Override
        void test() {
            System.out.println("apple");
        }
    }
    class Orange extends Fruit {
        @Override
        void test() {
            System.out.println("orange");
        }
    }
    // main函数
    public static void main(String[] args) {
        Fruit fruit = new Apple();
        fruit.test();
    }
// main函数Code的字节码
    new #2 <com/zq/jvm/Apple>
    // dup就是复制一份操作数栈顶值一份再压入栈，就是说此时栈顶至少有两份val
    // 再复制一份的目的就是为了作为后面invokespecial调用构造函数作为this传入使用，从而消耗一个栈顶Apple实例ref
    dup
    invokespecial #3 <com/zq/jvm/Apple.<init>>
    astore_1    // 将处理后的obj ref存放在局部变量表中的index=1的位置
    aload_1     // 从local var table(array)中加载obj ref到栈顶
    invokevirtual #4 <com/zq/jvm/Fruit.test> // 实际类型是Apple，在runtime动态调用的是Apple.test
    return
----------------------------------------
// invokevirtual的动态分派流程
1. 首先寻找到操作数栈顶的第一个元素所指向的实际的对象的真正的类型
2. 在实际/真正的类型中寻找到所调用的方法并权限校验通过，并调用该方法（如下，虽然字节码中标识的是Fruit.test，
    但在runtime时，先找到真实类型为Apple，然后在Apple类中找到了test方法并权限校验通过，则调用Apple.test方法）
3. 若在真正的类中找不到,就按继承的层次关系，从子类往父类重复查找是否存在满足要求的方法，然后去执行。若找不到则抛异常
```
#### 虚方法表，接口方法表
* 针对动态分派（invokevirtual），jvm会在类的方法区中建立一个虚方法表的数据结构(virtual method table, vtable)
    * vtable是在类加载的链接阶段（把符号引用转为直接引用）完成初始化
    * 在vtable中，若子类继承的父类的方法但是没有重写，则在vtable中，子类的该方法入口会指向父类中该方法的入口地址
* 针对invokeinterface指令来说，jvm会建立一个叫做接口方法表的数据结构（interface method table, itable）
    * itable与vtable类似



