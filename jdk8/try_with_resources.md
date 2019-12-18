* try-catch-finally
```
// AC AC2 实现Closable接口
AC ac = null;
AC2 ac2 = null;
try {
    ac = new AC();
    ac2 = new AC2();
} catch (Exception e) {
} finally {
    ac.close();
    ac2.close();
}
```
* try-with-resources
```
// AC AC2 实现AutoClosable接口
try (
    AC ac = new AC();
    AC2 ac2 = new AC2()) {
} catch (Exception e) {
}
// 则ac ac2的类时实现了AutoClosable的类的实例，则在try-catch块中，在碰到catch块之前就会自动调用close方法
```