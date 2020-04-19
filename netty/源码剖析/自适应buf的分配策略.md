#### class AdaptiveRecvByteBufAllocator extends DefaultMaxMessagesRecvByteBufAllocator
* 介绍
    * The RecvByteBufAllocator 可以根据反馈自动增加或者减少预测buf的大小，若之前的从某源中读取的字节
        完全填满已分配的buf，则会逐渐增加本buf的大小，若连续两次从某源中读取的字节不能填充到本buf的某一
        特定大小的界限，则会逐渐减少本buf的大小。否则会维持相同的预测值。
* 默认的buf大小的静态值
    1. static final int DEFAULT_MINIMUM = 64;
        * buf默认最小值
    2. static final int DEFAULT_INITIAL = 1024; 
        * buf默认初始值
    3. static final int DEFAULT_MAXIMUM = 65536;
        * buf的默认最大值
* SIZE_TABLE(用于调节buf大小的辅助数组)
    * int[] SIZE_TABLE = [i=16, .., i+=16, .., 512, .., i*=2, .., 0x7fffffff)