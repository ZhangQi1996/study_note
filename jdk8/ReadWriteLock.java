package com.zq.jvm;

import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

class A {
    static int a;
}

public class Demo extends A {

    private static ReadWriteLock lock = new ReadWriteLock(-1);

    private static void run1() {
        try {
            while (true) {
                lock.readRequire();
                System.out.println(Thread.currentThread().getId() + "开始读");
                Thread.sleep(1000);
                System.out.println(Thread.currentThread().getId() + "完成读");
                lock.readRelease();
                Thread.sleep(1000);
            }
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }

    private static void run2() {
        try {
            while (true) {
                lock.writeRequire();
                System.out.println(Thread.currentThread().getId() + "开始写");
                Thread.sleep(1000);
                System.out.println(Thread.currentThread().getId() + "完成写");
                lock.writeRelease();
                Thread.sleep(1000);
            }
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }

    public static void main(String[] args) {
        new Thread(Demo::run1).start();
        new Thread(Demo::run2).start();
        new Thread(Demo::run1).start();
        new Thread(Demo::run2).start();

    }

}


class ReadWriteLock {
    // 要读的线程等在read上
    private final Condition read;
    // 要写的线程等在write上
    private final Condition write;
    // 对count操作的互斥锁
    private final ReentrantLock countMutex;
    // count>0时，表示有count个读线程在正常操作，=0时表示可读可写，=-1时表示有一个写线程在工作
    private int count;
    // -1表示读优先, 0表示平等, 1表示写优先
    private int prior;

    public ReadWriteLock(int prior) {
        countMutex = new ReentrantLock(true);
        read = countMutex.newCondition();
        write = countMutex.newCondition();
        count = 0;
        this.prior = prior;
    }

    /**
     * 默认平衡
     */
    public ReadWriteLock() {
        this(0);
    }

    private void readPriority() {
        read.signalAll();
        write.signal();
    }

    private void writePriority() {
        write.signal();
        read.signalAll();
    }

    private void inEquity() {
        if (Math.random() <= 0.5)
            readPriority();
        else
            writePriority();
    }

    private void readWriteNotify() {
        if (prior == -1)
            readPriority();
        else if (prior == 0)
            inEquity();
        else
            writePriority();
    }

    public void readRequire() throws InterruptedException {
        countMutex.lock();
        try {
            while (count < 0)
                read.await();
            count++;
            if (prior == -1)
                read.signalAll();
        } finally {
            countMutex.unlock();
        }
    }

    public void readRelease() throws InterruptedException {
        countMutex.lock();
        if (--count == 0)
            readWriteNotify();
        countMutex.unlock();
    }

    public void writeRequire() throws InterruptedException {
        countMutex.lock();
        try {
            while (count != 0)
                write.await();
            if (--count == 0 && prior == 1) // 写优先
                write.signal();
        } finally {
            countMutex.unlock();
        }
    }

    public void writeRelease() throws InterruptedException {
        countMutex.lock();
        ++count;    // ++必为0
        readWriteNotify();
        countMutex.unlock();
    }
}