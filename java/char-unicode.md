* java中一个char字符占2个字节
    * 用unicode表示法
        * char c = '\uxxxx'; // \u0000-\uffff
    * 传统unicode字符均能用两个字节来表示，但是随着新的unicode字符加入，一个char（两个字节）已经不够用了，
        故有一个字符由一个unicode码点来表示
    * 即有些unicode字符不能由一个char来表示，此时就需要用两个char来表示
    * e.g. String s = "\uxxxx\uyyyy"; 假如这个字符串中只表示一个unicode字符，但是其char长度为2
        * 有s.length() // 计算的是s的char的数量就是2
        * 用s.codePointCount(0, s.length()); // 计算得到的是s的码点数量即unicode字符数量为1
    * 其实unicode不用于存储，是由于通常每个字符都用两个字节表示太浪费内存空间了。所以unicode是编码方式，
        而像UTF-8与GBK等就是存储方式
    * 对于文件字符编码以大端还是小端存储，比如以UTF-16LE(little endian, 小端)，UTF-16BE(big endian, 大端)
        也就是数据的高字节在内存中的存储位置。
        * Zero Width No-Break Space: 零宽度不换行的空白符（也是一个BOM(byte order mark)头）
            * 就在文件最开始第一个字符通过0xfeff表示以小端格式存储的文件，大端以0xfffe存储
    * UTF-8边长字节的编码存储，中文一般是3个字节
        * 对于带不带BOM的UTF-8，一般出现在windows os上，就是文件的首个字符用来表示字节存储顺序（大端还是小端存储），
            而对于utf-8其实不需要BOM（因为其他操作系统一般对于UTF-8都不使用带BOM的），所以常常因为utf-8文件带bom
            而造成解析失败。
        
        