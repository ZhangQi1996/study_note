* 设置全局LOGGER
```
private/public static final Logger LOGGER = LoggerFactory.getLogger(Caller.class);
LOGGER.debug/info/warn/error/fatal(..);
// 带格式的
LOGGER.info("my name is {}, and I'm {} years old and my gender is {}", "david", 23, "male");
```
* log4j.properties
```
# 日记级别(单个级别) 控制台 文件 邮箱 数据库
log4j.rootLogger=info, console,file, mail, datasource

# to console
log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p %c{1}:%L - %m%n

# to file
log4j.appender.file=org.apache.log4j.RollingFileAppender
log4j.appender.file.File=test.log
log4j.appender.file.MaxFileSize=5MB
log4j.appender.file.MaxBackupIndex=10
log4j.appender.file.layout=org.apache.log4j.PatternLayout
log4j.appender.file.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p %c{1}:%L - %m%n

# to mail
log4j.appender.mail=org.apache.log4j.net.SMTPAppender
log4j.appender.mail.Threshold=ERROR
log4j.appender.mail.BufferSize=1
log4j.appender.mail.From=XXX@XXXX.com
log4j.appender.mail.SMTPHost=smtp.XXXX.com
log4j.appender.mail.Subject=ErrorMessage
log4j.appender.mail.SMTPUsername=XXXXX
log4j.appender.mail.SMTPPassword=XXXX
log4j.appender.mail.To=XXXX@XXX.com
log4j.appender.mail.layout=org.apache.log4j.PatternLayout
log4j.appender.mail.layout.ConversionPattern=%d{yy-MM-dd HH:mm:ss}:%-5p [%t] (%F:%L) - %m%n

# to db
log4j.appender.datasource=org.apache.log4j.jdbc.JDBCAppender
log4j.appender.datasource.layout=org.apache.log4j.PatternLayout
log4j.appender.datasource.driver=com.mysql.jdbc.Driver
#定义什么级别的错误将写入到数据库中
log4j.appender.datasource.BufferSize=1
#设置缓存大小，就是当有1条日志信息是才忘数据库插一次，我设置的数据库名和表名均为user
log4j.appender.datasource.URL=jdbc\:mysql\://localhost\:3306/user?characterEncoding\=UTF8&zeroDateTimeBehavior\=convertToNull
log4j.appender.datasource.user=root
log4j.appender.datasource.password=root
log4j.appender.datasource.sql=insert into user (class,method,create_time,log_level,log_line,msg) values ('%C','%M','%d{yyyy-MM-dd HH:mm:ss}','%p','%l','%m')
```