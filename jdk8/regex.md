#### 正则
1. 匹配
```
// target串是否匹配regexString
// 1
target.matches(regexString);
// 2
Pattern.matches(regexString, target);
```    
2. 捕获组
```
// E.G.
String target = "((A)(B(C)))";
// 1. ((A)(B(C)))
// 2. (A)
// 3. (B(C))
// 4. (C)
// 可以看出捕获组是从左到右匹配括号来实现的
// matcher.group(0)总是代表整个字符串



// 实例代码
public static void main( String args[] ){
    
    // 按指定模式在字符串查找
    String line = "This order was placed for QT3000! OK?";
    String pattern = "(\\D*)(\\d+)(.*)";
    
    // 创建 Pattern 对象
    Pattern r = Pattern.compile(pattern);
    
    // 现在创建 matcher 对象
    Matcher m = r.matcher(line);
    if (m.find()) {
        System.out.println("Found value: " + m.group(0) );
        System.out.println("Found value: " + m.group(1) );
        System.out.println("Found value: " + m.group(2) );
        System.out.println("Found value: " + m.group(3) ); 
    } else {
        System.out.println("NO MATCH");
    }
}

```