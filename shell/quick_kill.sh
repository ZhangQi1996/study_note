#!/usr/bin/env bash
# 用于kill那些设计符合正则关键字的所有进程
function usage {
  cat << EOF
Usage: sh quick_kill.sh <reg> [-y]
Tips: kill those processes containing key words just like REG.
       REG is a ext regex.
       -y means killing the processes in a brute way
EOF
}

if (( $# == 0 || $# > 2 )); then
  echo '输入的参数不合法' >&2
  usage
  exit 1
fi

kill_param='-QUIT'
reg=

for arg in $@; do
  if [[ $arg == '-y' ]]; then
    kill_param='-9'
  else
    reg=$arg
  fi
done

if [[ -z $reg ]]; then
  echo '请输入REG' >&2
  usage
  exit 1
fi

# 父进程号
ppids=()

function pid_is_in_ppids() { # 返回0就是存在返回1就是不存在
  for i in ${ppids[@]}; do
    if [[ $1 == $i ]]; then
      return 0
    fi
  done
  return 1
}

for pid in $(ps -ef | grep -E $reg | grep -Ev grep\|$$ | awk '{print $2}'); do
  # 若是pid不在ppids中
  if ! pid_is_in_ppids $pid; then
    if ! kill $kill_param $pid; then
      echo 'KILL ERROR'
      exit 1
    fi
  fi
  ppids[${#ppids[@]}]=$pid
done




