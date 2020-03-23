* java中一个char字符占2个字节
    * 用unicode表示法
        * char c = '\uxxxx'; // \u0000-\uffff
    * 传统unicode字符均能用两个字节来表示，但是随着新的unicode字符加入，一个char（两个字节）已经不够用了，
        故有一个字符由一个unicode码点来表示
    * 即有些unicode字符不能由一个char来表示，此时就需要用两个char来表示
    * e.g. String s = "\uxxxx\uyyyy"; 假如这个字符串中只表示一个unicode字符，但是其char长度为2
        * 有s.length() // 计算的是s的char的数量就是2
        * 用s.codePointCount(0, s.length()); // 计算得到的是s的码点数量即unicode字符数量为1
        