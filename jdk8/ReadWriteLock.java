package com.zq.lock;


import sun.misc.Lock;

public class ReadWriteLock {
    // 要读的线程等在read上
    private final Object read;
    // 要写的线程等在write上
    private final Object write;
    // 对count操作的互斥锁
    private final Lock countMutex;
    // count>0时，表示有count个读线程在正常操作，=0时表示可读可写，=-1时表示有一个写线程在工作
    private int count;
    // -1表示读优先, 0表示平等, 1表示写优先
    private int prior;

    public ReadWriteLock(int prior) {
        read = new Object();
        write = new Object();
        countMutex = new Lock();
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
        synchronized (read) { // 每个wait/notify操作都要加对象锁
            read.notifyAll();
        }
        synchronized (write) {
            write.notify();
        }
    }

    private void writePriority() {
        synchronized (write) {
            write.notify();
        }
        synchronized (read) {
            read.notifyAll();
        }
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
        synchronized (read) {
            while (count < 0) {
                countMutex.unlock();
                read.wait();
                countMutex.lock();
            }
            count++;
            if (prior == -1)
                synchronized (read) {
                    read.notifyAll();
                }
        }
        countMutex.unlock();
    }

    public void readRelease() throws InterruptedException {
        countMutex.lock();
        if (--count == 0)
            readWriteNotify();
        countMutex.unlock();
    }

    public void writeRequire() throws InterruptedException {
        countMutex.lock();
        synchronized (write) {
            while (count != 0) {
                countMutex.unlock();
                write.wait();
                countMutex.lock();
            }
        }
        if (--count == 0 && prior == 1) // 写优先
            synchronized (write) {
                write.notify();
            }
        countMutex.unlock();
    }

    public void writeRelease() throws InterruptedException {
        countMutex.lock();
        ++count;    // ++必为0
        readWriteNotify();
        countMutex.unlock();
    }
}
