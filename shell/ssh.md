### ssh的配置
* 启动本地的ssh服务，以供远程主机ssh连接本主机
    * service sshd start
    * systemctl start sshd
* 配置服务器上的ssh属性，用于可以远程主机进行root连接
    * 
    * 配置完成后，service restart sshd   
* 生成ssh共秘钥对
    * ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
        * -t rsa 使用rsa算法
        * -P '' 秘钥口令为空
        * -f 将生成的秘钥放到指定文件中
        * 注：配套生成的公钥放在 ~/.ssh/id_rsa.pub中

* 将公钥分发到远程主机上（即远程主机可以访问进行ssh连接）
    * ssh-copy-id user@machine （默认方式）
    * ssh-copy-id -i ~/.ssh/id_rsa.pub root@server
    * -i 就是本地主机上的公钥位置