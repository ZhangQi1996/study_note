#!/usr/bin/env bash
# 在hosts_file文件中指定的主机山执行特定命令
function usage {
  cat << EOF
确保ssh无秘配置
Usage: sh dis_op.sh <-f hosts_file|-e host_pairs> <-c shell_cmd>
Tips: host_pairs just like 'host1,host2'
EOF
}

(( $# == 0 )) && usage && exit 1

RETVAL=0

while (( $# > 0 )); do
  case $1 in
  -f)
    (( $# < 2 )) && usage && exit 1
    if [[ -e $2 ]]; then
      HOSTS=$(cat $1 | grep -Ev '^/s*#' | xargs)
    else
      echo "ERROR:the file $1 not exists" >&2
      RETVAL=1
    fi
    shift 2
    ;;
  -e)
    (( $# < 2 )) && usage && exit 1
    HOSTS=$(echo $2 | tr ',' ' ')
    shift 2
    ;;
  -c)
    (( $# < 2 )) && usage && exit 1
    SHELL_CMD=$2
    shift 2
    ;;
  *)
    usage && exit 1
    ;;
  esac
done

[[ -n $HOSTS && -n $SHELL_CMD && $RETVAL == 0 ]] || exit $RETVAL

for host in $HOSTS; do
  if ! ssh -n root@$host $SHELL_CMD; then
    exit 1
  fi
done
