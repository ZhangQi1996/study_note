#### 将相关设备挂载到特定目录下
```
我们虽然可以在一些图形桌面系统里找到他的位置，浏览管理里面的文件，但在命令行却不知怎么访问它的目录，比如无法使用cd或者ls。
也无法在编程时指定一个目录对它操作。
```
* 一般情况将新的设备都挂在到/mnt目录下
* mount
    * -t 指定挂载的文件系统的类型
        * minix linux最早使用的文件系统
        * ext2 linux目前常用的文件系统
        * msdos MS-DOS的fat，就是fat16
        * vfat windows98常用的fat32
        * nfs 网络文件系统
        * iso9660 CD-ROM光盘标准文件系统
        * ntfs windows NT 2000的文件系统
        * hpfs OS/2文件系统
        * auto 自动检测文件系统   
    * -o 指定挂载的一些选项，选项之间用逗号隔开
        * codepage=XXX 代码页
        * iocharset=XXX 字符集
        * ro 以只读方式挂载
        * rw 以读写方式挂载
        * nouser 使一般用户无法挂载
        * user 可以让一般用户挂载设备
* e.g.
```
# mk /mnt/winc
# mk /mnt/floppy
# mk /mnt/cdrom
# mount -t vfat /dev/hda1 /mnt/winc
# mount -t msdos /dev/fd0 /mnt/floppy
# mount -t iso9660 /dev/cdrom /mnt/cdrom
```
        