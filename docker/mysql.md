* docker run --name mysql -e MYSQL_ROOT_PASSWORD=zq15067522063 -p 0.0.0.0:3306:3306 -p 0.0.0.0:33060:33060 -d mysql:5.7 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
* 若出现Access denied for user 'root'@'localhost' (using password: NO
    * 是因为并不是只要账号密码对了就能连接mysql，还有授权域的问题
    1. docker exec -it mysql_container bash // 进入容器内部
    2. mysql -u root -p
    3. 输入密码--> 登录mysql
    4. grant all privileges on *.* to root@'%' identified by '密码';
    5. flush privileges;
    6. quit; // 退出mysql
    7. ^P + ^Q 退出容器
    