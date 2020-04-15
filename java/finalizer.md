#### Finalizer
* 可结束对象（finalizable obj）的生命周期
    1. 当对象被分配，JVM会内部将这个对象记录为可结束的对象，这通常会减慢现代jvm的快速分配路径。
    2. 当GC判断这个对象不可达后且注意到其是可结束的，则将其加入到jvm的结束队列（finalization queue）中.
        会确保所有来自这个对象的可达对象（比如对象中的字段）都被保留，即使它们不可达，也仍然会保留它们（因为它们可能会在finalize
        方法中被访问）。
    3. 在某个时间后，jvm的finalizer线程会出队这些先前入队的对象，并调用其finalize方法，并记录这个对象的
        finalizer被调用。在这个时刻，这个对象就是处于结束状态的（finalized）。
    4. 当GC再一次发现这个对象不可达后，它将回收这个对象的空间，当源自这个对象的其他对象也不可达时也一并回收。
    * 问题：
        1. gc最少需要两轮来回收一个对象，并这这个过程中会保留所有源自这个对象的其他对象。
            若程序猿一不小心，可会创造一个临时的，微妙的，一个不可预测的资源保留问题（比如在finalize方法中再一次
            让一些原来准备回收的对象又可达了）。此外，jvm并不保证对于所有已分配的可结束对象都调用其finalizer，
            JVM也可能在GC发现一些对象不可达之前就已经退出了。
        2. 同时对于子类，由于finalize方法的访问修饰符是protected，故子类也可以继承这个方法，
            故这可能也会影响子类的某些对象的回收。（就算真的真的想在对象总使用finalizer来完成资源回收，
            注意一定不要使用基于继承的结构，经历拆分多个类，让实现资源回收的finalizer落在final类中）
            ```java
            public class A {
                static private A a;
                protected void finalize() {
                    a = this;
                }
            }
          
            class B extends A {
                private byte[] bigData; // 可能会一值得不到回收
            }
            ```
        3. **按序问题**：由于jvm不保证当jvm调用那些位于finalization queue中对象的finalizer是按序的
            (来自所有类的finalizer都是平等对待的)。这就可能导致那些把持着大量内存的或者稀缺原生资源的待回收
            对象一直卡在finalization queue中（由于这些对象前面有那些处理贼慢的finalizer的对象需要先处理回收完）。
            这个问题可能并非是由于恶意造成，仅仅是由于草率编程造成的。  
    * 所以，谨慎使用finalize方法作为资源回收手段
#### Finalization的替代方案
* 为了避免这一系列的不确定性，可以使用弱引用机制（引用类型见jvm/物理内存与GC/内存分配与gc.md####内存回收）
    来代替finalization作为postmortem notification mechanism. 通过这种方式，你完全可以控制原生资源的
    自先后回收而代替依靠jvm来做这些。
* 更多参见
    * https://www.oracle.com/technical-resources/articles/javase/finalization.html
    