**(时间格式化时注意H，H表示24小时制，h表示12小时制)**

* 获取系统当前时间并转为字符串类型
    * 使用Calendar类
    ```
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    Calendar calendar = Calendar.getInstance();
    Date date = calendar.getTime(); 
    String dateStr = sdf.format(date);
    ```
    * 用java.util工具包中的Date
    ```
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    Date date = new Date();
    String dateStr = sdf.format(date);
    // 获取当前时间
    long curtime = System.currentTimeMillis();
    ```
* 获取系统当前时间的前一天
    ```
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    Calendar calendar = Calendar.getInstance();
    calendar.add(Calendar.DATE, -1);
    Date date2 = calendar.getTime(); 
    String dt = sdf.format(date2);
    ```