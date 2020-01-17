#!/usr/bin/env bash
# 在hosts_file文件中指定的主机山执行特定命令
function usage {
  cat << EOF
确保ssh无秘配置
Usage: sh dis_op.sh <-f hosts_file|-e host_pairs> <-c shell_cmd | -r>
Tips: host_pairs just like 'host1,host2', -r means execing reboot cmd
EOF
}

(( $# == 0 )) && usage && exit 1

RETVAL=0

REBOOT=false

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
    HOSTS=$(echo $2 | tr ',' ' ' | xargs)
    shift 2
    ;;
  -c)
    (( $# < 2 )) && usage && exit 1
    SHELL_CMD=$2
    shift 2
    ;;
  -r)
    REBOOT=true
    shift
    ;;
  *)
    usage && exit 1
    ;;
  esac
done

if ! [[ -n $HOSTS && (-n $SHELL_CMD || $REBOOT) && $RETVAL == 0 ]]; then
  echo 'ERROR: the args you input are illegal..' >&2
  usage
  exit $RETVAL
fi

for host in $HOSTS; do
  echo -e "\033[32mTHE INFO FEEDBACKED FROM root@$host LISTS AS BELOW...\033[0m"
  $REBOOT && (ssh -n root@$host 'reboot' || true) && continue
  if ! ssh -n root@$host $SHELL_CMD; then
    echo "ERROR happens on execing cmds in root@$host" >&2
    exit 1
  fi
done
