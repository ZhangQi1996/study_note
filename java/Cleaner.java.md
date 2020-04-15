#### Cleaner源码分析
* 简介
    * 基于虚引用的清理器
    * 对于finalization，清理器是一个轻量级的，更具鲁棒性的一个可替代方案，
        它的轻量级是由于：它不有VM创建，故其不需要创建一个JNI的上调（也就是c调用java，
        通常downcall快于10于upcall）, 清理器的清理代码是直接由**引用处理器（reference-handler）**
        线程来调用的而不是finalizer线程。清理器更具有鲁棒性是因为它使用的是虚引用（引用对象中最弱的类型），
        因此其避免了finalization内在恶心的排序问题（见java/finalizer.md关于排序的问题）
        * 引用处理器线程
            * finalizer线程用于处理finalizer方法，而引用线程也有类似的作用。
            * 一个高优先级的线程，用于将处于闲置状态的引用放入队列中：
                1. GC创建一个用于存放引用的简单链表
                2. 引用处理线程快速地将链表中的引用其添加进一个适当的队列中。
                * 分为两个阶段来完成这个动作是因为：GC什么都没有做，仅仅只是去查找闲置引用，
                    这个线程去调用处理这些闲置引用的代码（比如：调用Cleaner，通知引用队列监听器）
    * 一个清理器用于追踪一个引用对象，清理器封装了一团任意的清理代码。当GC探测到一个清理器的引用已经
        变成了虚可达（phantom-reachable），则引用处理线程将云心跟这个清理器。此外，清理器也可以被
        直接调用，它们是线程安全的并且确保最多运行其清理代码一次。
    * 注意：清理器并非是finalization的替代品，清理器应该在清理代码极其简单和直接时被使用。
        非常规的清理器是不建议使用的，因为这会存在卡顿引用处理线程以及推迟后续清理和finalization的风险
        （由于这样清理将非常耗时）。
* 源代码加注释
```java
public class Cleaner
    extends PhantomReference<Object>
{
    /**
    Reference queues
    当GC探测到已经注册到本引用队列中的对象已经发生适当的可达性改变时（比如：不可达，变为可回收时），
    就将该对象入队。

    这是一个假的引用队列，在这里定义它仅仅是因为对于PhantomReference的构建一定需要传入一个引用队列，
    而由于引用处理线程会显式调用处理器，故不会有任何东西放置到这个引用队列上
    */
    private static final ReferenceQueue<Object> dummyQueue = new ReferenceQueue<>();

    /**
    这是一个用于存可能存活的清理器链表（不带头结点的双向链表），其用于阻止这些清理器早于其管理的引用对象被GC回收
    */
    static private Cleaner first = null;

    /**用于标识清理器双向链表的单节点的指针*/
    private Cleaner
        next = null,
        prev = null;

    /**用于向可能存活的清理器链表中添加节点，使用不带头结点的头插法*/
    private static synchronized Cleaner add(Cleaner cl) {
        if (first != null) {
            cl.next = first;
            first.prev = cl;
        }
        first = cl;
        return cl;
    }

    /**从链表中清除这个清理器节点*/
    private static synchronized boolean remove(Cleaner cl) {

        // If already removed, do nothing
        if (cl.next == cl)
            return false;

        // Update list
        if (first == cl) {
            if (cl.next != null)
                first = cl.next;
            else
                first = cl.prev;
        }
        if (cl.next != null)
            cl.next.prev = cl.prev;
        if (cl.prev != null)
            cl.prev.next = cl.next;

        // 通过清理后，将这个节点的前后指向自身
        cl.next = cl;
        cl.prev = cl;
        return true;

    }

    /**用于运行清理代码*/
    private final Runnable thunk;

    /**初始化一个清理器，传入一个由这个清理器清理的对象，以及一个用于清理这个对象的清理代码*/
    private Cleaner(Object referent, Runnable thunk) {
        super(referent, dummyQueue);
        this.thunk = thunk;
    }

    /**
     * Creates a new cleaner.
     *
     * @param  ob the referent object to be cleaned
     * @param  thunk
     *         The cleanup code to be run when the cleaner is invoked.  The
     *         cleanup code is run directly from the reference-handler thread,
     *         so it should be as simple and straightforward as possible.
     *
     * @return  The new cleaner
     */
    public static Cleaner create(Object ob, Runnable thunk) {
        if (thunk == null)
            return null;
        return add(new Cleaner(ob, thunk));
    }

    /**
     * Runs this cleaner, if it has not been run before.
     */
    public void clean() {
        if (!remove(this))
            return;
        try {
            thunk.run();
        } catch (final Throwable x) {
            AccessController.doPrivileged(new PrivilegedAction<Void>() {
                    public Void run() {
                        if (System.err != null)
                            new Error("Cleaner terminated abnormally", x)
                                .printStackTrace();
                        System.exit(1);
                        return null;
                    }});
        }
    }

}
```