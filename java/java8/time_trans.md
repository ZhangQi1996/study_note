#### java8之前的时间
* 日期格式
    1. Y与y
        * Y表示基于星期的年份，比如当天所在周跨年，那么Y就返回实际的下一年
        * y就是实际的年份
    2. M与m
        * M是实际的月份
        * m是时间的分钟数
    3. D与d
        * D表示当前天是该年的第几天
        * d表示day of month
    4. W与w
        * W表示该年的第几周
        * w表示该月的第几周
    5. H与h
        * H是24机制
        * h是12进制
    6 S与s
        * S表示sec of minute的毫秒后缀
        * s表示sec of minute
    * 常见
        * 单写一个就是紧凑写法
            * y-M-d H:m:s.S
                * 2020-3-23 17:40:36.291
        * 格式化写法
            * yyyy-MM-dd HH:mm:ss.SSS
                * 2020-03-23 17:40:36.291
            * yyyy-MM-dd'T'HH:mm:ss.SSS
                * 2020-03-23T17:40:36.291

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

#### java8的日期与时间
* 在java8之前常用于时间处理的第三方库是joda time，是java8之前默认的日期时间标准
* 关于日期与时间
    1. 格林威治时间（Greenwich Mean Time，GMT）
        * 是世界时间的基准，精度为MS
    2. UTC时间（Coordinated Universal  Time，协调世界时）
        * 精度为NM
        * 字符串表示
            1. yyyy-MM-ddTHH:mm:ss.SSSZ
                * 表示当前时刻的标准时间，Z表示时间偏移量为zero
                * 2020-03-23T09:40:36.291Z
            2. yyyy-MM-ddTHH:mm:ss.SSS+08:00
                * 2020-03-23T17:40:36.291+08:00
                * 表示东八区
* 在新的jdk8中的日期时间类是线程安全的，因为只是可读的。而之前的Date是可写的，故不是线程安全的。
* 时区
    * 获取所有时区
        * ZoneId.getAvailableZoneIds() -> Set<String>
    * ZoneId类
        * static of(String zoneIdStr) -> ZoneId
            * 比如传入  Asia/Shanghai
        
        
* 常用时间与日期的类
    1. LocalDate
        * 私有构造方法
        * 仅仅表示年月日的日期,就是yyyy-MM-dd
        * 常用方法
            1. static now() -> LocalDate
            2. static of(year, month/Month, day) -> LocalDate
                * ofEpochDay(long) 距离1970-1-1的天数
                * ofDayOfYear(year, dayOfYear)
            3. getYear/MonthValue/DayOfMonth() -> int
                * 注意：getMonthValue() -> 是1-12的数值，不是从0开始的，至于Date类中的区别
                * 注意：getMonth() -> Month的枚举值（e.g. Month.MARCH）
            4. static parse(dateStr\[, dateFormatStr\]) -> LocalDate
            5. plus(long amountToAdd, TemporalUnit unit) -> LocalDate
                ```java
                // ChronoUnit是一个实现TemporalUnit接口的枚举类
                LocalDate.now().plus(12, ChronoUnit.DAYS);
                ```
            6. isBefore(LocalDate) -> boolean
            7. isAfter(LocalDate) -> boolean
    2. MonthDay
        * 私有构造方法
        * 只关注月与日，常常用于特定日期比如生日，特定月日的节日等等
        * 常用方法
            0. static now() -> MonthDay
            1. static of(month, day) -> MonthDay
            2. static from(LocalDate)
                * 取该日期的月与日
                ```java
                public class Demo {
                
                    public static void main(String[] args) {
                        MonthDay day = MonthDay.of(3, 23);
                        MonthDay day1 = MonthDay.from(LocalDate.of(2019, 3, 23));
                
                        System.out.println(Objects.requireNonNull(day).equals(day1)); // true
                    }
               }
                ```
    3. YearMonth
        * 常见方法
            1. isLeapYear() -> boolean
    4. LocalTime
        * 私有构造方法
        * 就是HH:mm:ss.SSS
        * 常用方法
            1. static now() -> LocalTime
            2. plusHours(hours) -> LocalTime
                * 在当期的时间减去hours得到新的时间
            3. minusMinutes(minutes) -> LocalTime
    5. LocalDateTime
        * 就是yyyy-MM-dd'T'HH:mm:ss.SSS
    6. ZonedDateTime
        * 就是yyyy-MM-dd'T'HH:mm:ss.SSS\[后面带一个时区\]
        * 常用方法
            1. static of(LocalDateTime, ZoneId) -> ZonedDateTime
    7. Clock
        *  A clock providing access to the current instant, date and time using a time-zone.
            通常使用各个类.now方法获取当前的instant，date and time.
        * 常用方法
            1. static systemDefaultZone() -> Clock
            2. millis() -> long
                * 返回时刻的总毫秒数
    8. Period
        * This class models a quantity or amount of time in terms of years, months and days.
        * 常用方法
            1. static between(LocalDate, LocalDate) -> Period
            2. getMonths() -> 返回月份的间隔
            3. getYears() -> 返回年的间隔
    9. Duration
        * This class models a quantity or amount of time in terms of seconds and nanoseconds.
    9. Instant
        * This class models a single instantaneous point on the time-line.
          This might be used to record event time-stamps in the application.
        * 常见方法
            1. static now() -> Instant
                * 获得的是不带时区的UTC
        
            