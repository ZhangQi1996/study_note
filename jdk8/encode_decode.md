* 流读取文件，具有转换编码功能的有：OutputStreamWriter 和 InputStreamReader 
    * 构造器如下：
    ```
    // 创建指定字符集的 InputStreamReader
    InputStreamReader(InputStream in, String charsetName)
    // 创建使用指定字符集的 OutputStreamWriter
    OutputStreamWriter(OutputStream out, String charsetName)
    ```


* 处理字符串编码问题
```
//a. 重新对获取的字符串进行编码
Byte[] bytes = str.getBytes(String encodeCharName);

//b. 重新对bytes进行解码，创建新的字符串对象
str = new String(Byte[] bytes, String decodeCharsetName);

// 一般结合使用
str = new String(str.getBytes(String encodeName), String decodeCharsetName);
```
* 处理请求参数传递编码问题 
    * java中编码：URLEncoder.encode(strUri, “UTF-8”); 
    * java中解码：URLDecoder.decode(strUri, “UTF-8”);