* 创建用户
    * useradd user1
    * 直接在创建用户的时候就指定用户组
        * useradd -g/G group2 user2
```
在使用useradd命令创建用户的时侯可以用-g 和-G 指定用户所属组和附属组。
基本组：如果没有指定用户组，创建用户的时候系统会默认同时创建一个和这个用户名同名的组，这个组就是基本组，不可以把用户从基本组中删除。在创建文件时，文件的所属组就是用户的基本组。
附加组：除了基本组之外，用户所在的其他组，都是附加组。用户是可以从附加组中被删除的。
用户不论为与基本组中还是附加组中，就会拥有该组的权限。一个用户可以属于多个附加组。但是一个用户只能有一个基本组。
```
* 删除用户
    * userdel -r username
    * 注意，这里的-r 是连同user一道，将 /home/user1/ 目录也删除；如果不加 -r，
        就只删除用户 user1，而不删除目录 /home/user1/
* 为用户设置密码
    1. passwd user1
    2. 输入新密码
* 查看用户的相关信息，包括用户组
    * id user1
* 创建新的用户组
    * groupadd supergroup
* 将用户添加到用户组当中
    * gpasswd -a user3 group3
    * gpasswd -a $USER group
* 查看用户所在的组，以及组内成员：
    * groups 用户名
* 将一个user从一个group中删除：
    * gpasswd -d username groupname
* 删除一个group：
    * groupdel groupname
    * 注意，如果要删除的group中还有成员user，该操作会失败。解决办法：先删除group下的所有user，
        然后再删group；或者，将group下的所有user放到其他group下，再删当前group。
* 用户切换
    * su -l user: shell中切换用户
    * su: shell中切换root用户
    