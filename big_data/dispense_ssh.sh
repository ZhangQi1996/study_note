#!/usr/bin/env bash
# 将本主机上的不带密码的公钥分发到目标主机上
function usage {
  cat << EOF
Usage: sh dispense_ssh.sh <hosts_file>
Tips: hosts_file contains hosts you wanna dispense your pub_key and its relevent pw used to login.
the format of hosts_file just like below:
ATTENTION: save an extra blank line
======================
      hosts_file
----------------------
user@host1  password1
user@host2 password2
======================
EOF
}

usage
echo 'Tips: 第二次运行本脚本，若全部主机均为**已互信，无需复制公钥**则完全成功'
if [[ $# < 1 || ! -e $1 ]]; then
  echo '你应该提供一个有效的hosts_file' >&2
  exit 1
fi

CUR_DIR=$(pwd)
cd ~
USER_HOME=$(pwd)
cd $CUR_DIR

# 检查本地是否存在ssh的公秘钥
if [[ ! (-e ~/.ssh/id_rsa && -e ~/.ssh/id_rsa.pub) ]]; then
  if ! ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa; then  # 生成公秘钥
    echo '自动生成基于RSA算法的公秘钥失败' >&2
    exit 1
  fi
fi

# 是否安装expect
if ! which expect 2>/dev/null >&2; then
  printf 'expect未在本主机上找到..\n请先安装expect：\n1. yum install -y expect\n2.apt-get install -y -f expect\n'
  exit 1
fi

function copyPubIdToTargetHost() {
  local user_host=$1
  local pw=$2
  if [[ -z $user_host || -z $pw ]]; then
    echo 'hosts_file文件格式不正确' >&2
    usage >&2
    return 1;
  fi
  echo "开始向主机$user_host复制公钥"
  echo "正在检查本主机是否与目标主机$user_host互信"
  # 由于ssh存在从stdin读取数据的现象，-n解决将输入重定向到/dev/null,就是使用/dev/null做输入
  if ssh -n -o ConnectTimeout=2 -o ConnectionAttempts=1 \
   -o PasswordAuthentication=no -o StrictHostKeyChecking=no $user_host exit 2>err.log >&2; then
    echo "本主机是否与目标主机$user_host已互信，无需复制公钥"
    return 0
  fi
  # 复制公钥
  expect 2>err.log >&2 << EOF
  set timeout 5
  spawn ssh-copy-id -i $USER_HOME/.ssh/id_rsa.pub -o StrictHostKeyChecking=no $user_host
  expect password {
    send $pw\n
  }
  expect eof
  exit 0
EOF
  if [[ -z $(cat err.log | grep 'Number of key(s) added: 1') ]]; then
    echo "向主机$user_host复制公钥失败，请检查密码是否正确或者是否目标主机已打开22端口以及若您是root连接是否允许root登录" >&2
    echo '也可查看同级的err.log查看出错问题' >&2
    return 1
  fi
  echo "成功向主机$user_host复制公钥"
  return 0
}

if cat $1 | grep -Ev '^\s*#|^\s*$' | sed 's/#.*//' | while read line
  do
    if ! copyPubIdToTargetHost $(echo -n $line | xargs); then # 复制失败
      exit 1
    fi
  done; then
  echo '复制成功'
  exit 0
else
  echo '失败' >&2
  exit 1
fi