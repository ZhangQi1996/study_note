#### expect脚本解释器
* 用于交互的环境
```
命 令	说 明
spawn	启动新的交互进程, 后面跟命令或者指定程序
expect	从进程中接收信息, 如果匹配成功, 就执行expect后的动作
send	向进程发送字符串
send exp_send	用于发送指定的字符串信息
exp_continue	在expect中多次匹配就需要用到
send_user	用来打印输出 相当于shell中的echo
interact	允许用户交互
exit	退出expect脚本
expect eof 执行结束, 退出
set	定义变量
puts	输出变量
set timeout	设置超时时间
```
```
/usr/bin/expect <<EOF
    set time 30
    spawn ssh $username@$ip df -Th # 运行ssh  成功后执行命令df -Th
    expect {
        "*yes/no" { send "yes\r"; exp_continue } # 匹配到了*yes/no继续匹配*password:
        "*password:" { send "$password\r" }
    }
    expect eof
EOF
```
```
expect "]#" {
    send "ls\n" # \r跟\n均可
    send "pwd"
}
```