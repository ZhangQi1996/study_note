* 将字符串转成特定编码的字节流
```
String s = "你好，世界";
InputStream in = ByteArrayInputStream(s.getBytes(StandardCharset.UTF_8));
```
* 将输入的字节流编码成特定的字符流
```
InputStream in = new FileInputStream(f);
BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8));
```