* 修改文件夹的所有者group（owner group）：
    * chown -R .groupname some-folder
    * 注意，这里的groupname前面要加一个点
    * chgrp -R groupname some-folder
* 同时修改文件夹的所有者（owner）和所有者group（owner group）：
    * chown -R username.groupname some-folder

* chmod
    * u(+,-)(rwx) 对所有者增加/删除某些权限
        * chmod u+rw
    * g(+,-)(rwx) 对组成员增加/删除某些权限
        * chmod g-rwx
    * o(+,-)(rwx) 对其他用户员增加/删除某些权限
        * chmod o+r
    * o(+,-)(rwx) 对所有增加/删除某些权限
        * chmod a+x