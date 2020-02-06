#!/usr/bin/env bash
# 在hosts_file文件中指定的主机山执行特定命令
function usage {
  cat << EOF
确保ssh无秘配置
Usage: sh dis_op.sh <-f hosts_file|-e host_pairs> <-c shell_cmd | -r> [-i] [--bg] [-h|--help]
Tips: host_pairs just like 'host1,host2', -r means execing reboot cmd.
      -i means ignoring errs happenning on hosts, and not ignores in default.
      --bg means execing cmd in background, and ignores all errs.
EOF
}

(( $# == 0 )) && usage && exit 1

RETVAL=0
HOSTS=
SHELL_CMD=
IGNORE_ERRS=false
RUN_BG=false


while (( $# > 0 )); do
  case $1 in
  -f)
    (( $# < 2 )) && echo 'the format of opts you input is illegal, plz see help to acquire more details.' && exit 1
    if [[ -e $2 ]]; then
      HOSTS=$(cat $1 | grep -Ev '^/s*#' | xargs)
    else
      echo "ERROR:the file $1 not exists" >&2
      RETVAL=1
    fi
    shift 2
    ;;
  -e)
    (( $# < 2 )) && echo 'the format of opts you input is illegal, plz see help to acquire more details.' && exit 1
    HOSTS=$(echo $2 | tr ',' ' ' | xargs)
    shift 2
    ;;
  -c)
    (( $# < 2 )) && echo 'the format of opts you input is illegal, plz see help to acquire more details.' && exit 1
    SHELL_CMD=$2
    shift 2
    ;;
  -r)
    SHELL_CMD='reboot; exit;'
    shift
    ;;
  -i)
    IGNORE_ERRS=true
    shift
    ;;
  --bg)
    RUN_BG=true
    shift
    ;;
  -h|--help)
    usage
    shift
    exit 0
    ;;
  *)
    echo 'ERROR: the args you input are illegal..' >&2
    usage
    exit 1
    ;;
  esac
done

if ! [[ -n $HOSTS && -n $SHELL_CMD && $RETVAL == 0 ]]; then
  echo 'ERROR: the args you input are illegal..' >&2
  usage
  exit $RETVAL
fi

for host in $HOSTS; do
  echo -e "\033[32mTHE INFO FEEDBACKED FROM root@$host LISTS AS BELOW...\033[0m"
  if ! $RUN_BG; then  # 不后台运行
    if ! ssh -n root@$host $SHELL_CMD; then
      ! $IGNORE_ERRS && echo "ERROR happens on execing cmds in root@$host" >&2 && exit 1
    fi
  else  # 后台运行
    ssh -n root@$host $SHELL_CMD &
  fi
done

exit $RETVAL