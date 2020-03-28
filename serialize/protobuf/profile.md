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
                * **注意：由于程序的兼容与拓展问题，尽量使用Optional而不是required**，因为在开发中
                    将required->optional是不可以的，而Optional->required是可以的
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
        3. 对于字段推荐使用indent方式的写法，而不是驼峰命名方式
    * 对于生成的java类
        * 生成命令
            * protoc [-I=<import_dir1> [-I=<import_dir2> ...]] --java_out=<dst_path> <proto_file_path>
            * -I: 用于指定import所需的目录，可以指定多个，若未指定，则当前目录就是import目录
            * --java_out: 指定java文件的生成目的地目录
            * proto_file_path: 将被编译的proto文件
        * 对于一个proto文件定义的message
            * 在java文件中，proto文件定义的所有内容均由java的一个外部类囊括，每一个proto文件中定义的
                message就对应了这个java外部类中的一个静态内部类，对于所有这些内部静态类（对应每种message）其
                实例化的方式都是通过（这里以Outer.Foo静态内部类举例）：
                1. 实例化该静态内部类中的Builder类实例
                    * Outer.Foo.Builder builder = Outer.Foo.newBuilder();
                2. 当需要为该内部静态类Outer.Foo实例进行域赋值（set）
                    * builder.setXXX(...);
                3. 当赋值完后，实例化Outer.Foo
                    * Outer.Foo foo = builder.build();
            * 对于实例化后的proto对象是immutable
            ```java
            // 方法链形式实例化java bean举例
            Outer.Foo foo = Outer.Foo.newBuilder() // builder的创建只能是工厂方法
                .setName("foo")
                .setAttr("stateless")
                .setIsSingleton(false)
                .build();
            ```
        * 常见方法
            * 以下Message类就是proto文件中的message编译为java文件中的Message内部静态类
            1. Message::isInitialized()
                * 检查是否所有required域都赋值了
            2. Message::toString()
            3. MessageBuilder::mergeFrom(Message other)
                * 将other的内容merge到自身的message
                * Message newMessage = message.toBuilder().mergeFrom(other).build();
                1. 重写单一标量域
                2. 合并复合域
                3. 拼接重复域
            4. MessageBuilder::clear()
                * 将所有的域清为空的状态
                * message = message.toBuilder().clear().build();
            5. Message::toByteArray()
                * 将Message对象实例转为byte[]
            6. Message::parseFrom(byte[] data)
                * 从byte[]中解析出Message实例
            7. Message::writeTo(OutputStream out)
                * 将Message实例序列化写入到输出流当中
            8. Message::parseFrom(InputStream in)
                * 从输入流中解析出Message实例
    * 文件代码示例
    ```
    // 语法版本
    syntax = "proto2";
    // 通用包名（用于另一个.proto文件的import）
    package tutorial;   
    // 编译优化
    option optimize_for = SPEED; // 有SPEED, CODE_SIZE, LITE_RUNTIME默认SPEED
    // 当通过protoc编译成java类文件的时候所在的包目录
    option java_package = "com.example.tutorial";
    // 输出的外部java类名，proto文件中定义的所有message都会成为这个外部类的内部类
    option java_outer_classname = "AddressBookProtos";
    
    // 以下的类均是内部类
    message Person {
        required string name = 1; // 数字标识1
        required int32 id = 2;
        optional string email = 3;
        
        enum PhoneType { // 枚举
        MOBILE = 0;
        HOME = 1;
        WORK = 2;
        }
        
        message PhoneNumber {
        required string number = 1;
        optional PhoneType type = 2 [default = HOME]; // 可选字段可以设置默认值
        }
        
        repeated PhoneNumber phones = 4;
        
        oneof obj { // oneof关键字相当于c语言中union, 由于其中就只有一个会被选中故编号递增
            PhoneNumber numver = 4;
            AddressBook book = 5;
        }
    }
    
    message AddressBook {
        repeated Person people = 1;
    }
    ```
* 为protobuf的一个Message添加更多功能，不要使用继承去实现这个添加功能的目的，
    应该使用组合的方式去实现。