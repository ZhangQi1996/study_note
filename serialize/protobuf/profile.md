#### protobuf
* doc网址https://developers.google.com/protocol-buffers/docs/overview
* 下载目录
    * https://github.com/protocolbuffers/protobuf/releases
* 步骤
    1. 根据需求写出结构化的.proto文件
    2. 用protoc将.proto文件编译成目标语言类文件  
* .proto文件
    * 编写语法
        1. 关键字
            1. required
                * **必须提供该字段的值**，否则该消息将被视为“未初始化”。
                尝试构建未初始化的消息将引发RuntimeException。
                解析未初始化的消息将引发IOException。除此之外，必填字段的行为与可选字段完全相同。
            2. optional
                * **可能会或可能不会设置该字段。如果未设置可选字段值，则使用默认值。**
                对于简单类型，您可以指定自己的默认值，就像type在示例中为电话号码所做的那样。
                否则，将使用系统默认值：数字类型为零，字符串为空字符串，布尔值为false。
                对于嵌入式消息，默认值始终是消息的“默认实例”或“原型”，没有设置任何字段。
                调用访问器以获取未显式设置的可选（或必填）字段的值始终会返回该字段的默认值。
            3 repeated
                * 该字段可以重复任意次（包括零次）。重复值的顺序将保留在协议缓冲区中。
                    将重复字段视为动态大小的数组。
        2. 标识
            * 对字段的数字标识，>15的数字标识需要的字节数多余1-15
            * 故对于频繁使用的字段使用<15的数字标识
    * 对于生成的java类
        * 生成命令
            * protoc <src_path> --java_out=<dst_path>
        * setter：使用Foo.Builder来进行set
        ```
        // 获得java bean
        Outer.Foo.Builder builder = Outer.Foo.newBuilder();
        builder.setXXX(...);
        // 生成byte[]
        byte[] data = builder.build().toByteArray();
        ```
        * getter：使用Foo来get
        ```
        // 从byte数组中解析出java bean
        Outer.Foo foo = Outer.Foo.parseFrom(data); 
        ```
    * 文件代码示例
    ```
    // 语法版本
    syntax = "proto2";
    // 通用包名
    package tutorial;   
    // 当通过protoc编译成java类文件的时候所在的包目录
    option java_package = "com.example.tutorial";
    // 输出的java类名
    option java_outer_classname = "AddressBookProtos";
    
    // 以下的类均是内部类
    message Person {
      required string name = 1; // 数字标识1
      required int32 id = 2;
      optional string email = 3;
    
      enum PhoneType {
        MOBILE = 0;
        HOME = 1;
        WORK = 2;
      }
    
      message PhoneNumber {
        required string number = 1;
        optional PhoneType type = 2 [default = HOME]; // 可选字段可以设置默认值
      }
    
      repeated PhoneNumber phones = 4;
    }
    
    message AddressBook {
      repeated Person people = 1;
    }
    ```