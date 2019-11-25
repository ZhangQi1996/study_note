#### Class.forName(String) and Class.forName(String name, boolean initialize, ClassLoader loader)
* Class.forName(String name)
    * e.g.
    ```
    class Demo {
        main() {
            Class.forName("Foo");
        }
    }
    ```
    * 即加载这个name="Foo"的类的加载器就是加载Demo类的类加载器
    ```
    public static Class<?> forName(String className)
                throws ClassNotFoundException {
        // 获取调用该方法的类的class对象，比如在Demo的main函数中调用了Reflection.getCallerClass()则返回的就是Demo的Class对象
        Class<?> caller = Reflection.getCallerClass();
        // ClassLoader.getClassLoader(caller)就是获取这个caller的类加载器
        // forName0这个方法是原生方法
        return forName0(className, true, ClassLoader.getClassLoader(caller), caller);
    }
    ```
* Class.forName(String name, boolean initialize, ClassLoader loader)
    * name是给定的类的全限定名，initialize表示是否进行初始化，
    * loader表示加载这个类所用的类加载器，当传入null时，则由bootstrap classloader进行加载
    * 不用来加载原子/void类型
    * 如果是name表示的是一个数组类，它的组件类型会被加载，而不会被初始化
    