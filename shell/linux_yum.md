#### 修改yum的源
* 在/etc/yum.conf文件下修改
    * 设置reposdir=[包含 .repo 文件的目录的绝对路径]
    * 默认路径是/etc/yum.repo.d/
* repos目录下的每一个.repo文件就是配置若干repo源的文件
    ```
    # Centos-Base.repo
    [extras]    # 标识唯一的repo ID
    gpgcheck=1  # 是否做gpg检查
    gpgkey=http://mirrors.tencentyun.com/centos/RPM-GPG-KEY-CentOS-7    # gpg key
    enabled=1   # 是否启用该repo源
    # repo源即的基本路径
    # $releasever 发行版本 $basearch 基本架构
    baseurl=http://mirrors.tencentyun.com/centos/$releasever/extras/$basearch/
    name=Qcloud centos extras - $basearch
    ```