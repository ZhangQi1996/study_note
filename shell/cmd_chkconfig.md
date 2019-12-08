#### chkconfig用于管理自启动
```
服务要在哪一个执行等级中开启或关毕
等级0表示：表示关机
等级1表示：单用户模式
等级2表示：无网络连接的多用户命令行模式
等级3表示：有网络连接的多用户命令行模式
等级4表示：不可用
等级5表示：带图形界面的多用户模式
等级6表示：重新启动
```
* 过程
    1. 先编写service脚本，包含start,stop,reload,restart等等
    2. 脚本中必须有一行注释为
        ```
        # chkconfig - 85 15
        ```    
        * 第一个参数指定服务的配置
            1. - 为关闭
            2. 85 启动的优先级（越大优先级越高）
            3. 15 关闭的优先级
    2.5 将脚本放到/etc/init.d/目录下
    3. 将脚本chmod为可执行 chmod u+x script
    4. chkconfig -add service-name   添加服务
    5. chkconfig --level 2345 service-name on
        * 设置在2345情况下启动
* E.G.
```
chkconfig –list        #列出所有的系统服务
chkconfig –add httpd        #增加httpd服务
chkconfig –del httpd        #删除httpd服务
chkconfig –level httpd 2345 on        #设置httpd在运行级别为2、3、4、5的情况下都是on（开启）的状态
chkconfig –list        #列出系统所有的服务启动情况
chkconfig –list mysqld        #列出mysqld服务设置情况
chkconfig –level 35 mysqld on        #设定mysqld在等级3和5为开机运行服务，–level 35表示操作只在等级3和5执行，on表示启动，off表示关闭
chkconfig mysqld on        #设定mysqld在各等级为on，“各等级”包括2、3、4、5等级
```