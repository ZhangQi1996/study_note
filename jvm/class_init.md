* 当jvm初始化一个类的时候，要求它的所有父类都已经初始化，但是这条规则不适用于接口
    * 在初始化一个类时，并不会初始化它所实现的接口
    * 在初始化一个接口时，并不会先初始化它额父接口
    ```
    class A {}
    interface C {
        A a = new A() {
            {
                System.out.println(123);
            }
        };
    }
    
    class B {
        public final static A a = new A() {
            {
                System.out.println(321);
            }
        };
    }
    
    
    public class Test extends B implements C{
        public static void main(String[] args) throws DateTemprParseException, IOException {
    
        }
    }
    // 仅仅打印321
    ```
    因此，一个父接口并不会因为它的子接口或者实现类的初始化而初始化，只有当程序首次使用特定接口的静态变量时，才会导致接口的初始化
------
* 调用CLassLoader类的loadClass方法加载一个类，并不是对类的中东使用，不会导致类的初始化
