#!/bin/bash
function usage {
  cat << EOF
确保ssh无秘配置
Usage: sh spark_op.sh [<master|slaves|slave|all|hs> [--hosts=hostnames] [--spark-opts=spark-opts] start|stop] [help]
[OPTS]
  hs means history-server
  --spark-opts=<spark-opts> PS: this will be provided to spark exec program.
  --hosts=hostnames exec the cmd in that hosts, hosts=localhost in default.
EOF
}

. /etc/init.d/functions

[[ -e $SPARK_HOME ]] || action "请配置SPARK_HOME的环境变量" false || exit 1

_hosts='localhost'
_spark_opts=
caller=

# 传递给ssh的cmd
start_cmd() {
  cat << EOF
  [[ ! -d \$SPARK_HOME ]] && echo "\$SPARK_HOME未配置或未安装spark" >&2 && exit 1;
  [[ -d \$SPARK_HOME/logs ]] || mkdir -p \$SPARK_HOME/logs;
  \$SPARK_HOME/sbin/start-$1.sh $_spark_opts && echo "start $1 successfully on \$(hostname)" && exit 0;
  echo "start $1 unsuccessfully on \$(hostname)" >&2;
  exit 1;
EOF
}
stop_cmd() {
  cat << EOF
  [[ ! -d \$SPARK_HOME ]] && echo "\$SPARK_HOME未配置或未安装spark" >&2 && exit 1;
  [[ -d \$SPARK_HOME/logs ]] || mkdir -p \$SPARK_HOME/logs;
  \$SPARK_HOME/sbin/stop-$1.sh && echo "stop $1 successfully on \$(hostname)" && exit 0;
  echo "stop $1 unsuccessfully on \$(hostname)" >&2;
  exit 1;
EOF
}

# start caller
# caller=$1
start() {
  for i in $_hosts; do
    echo "[SPARK $1:$i]"
    ssh -n root@$i "$(start_cmd $1 $_spark_opts)"
  done
}

stop() {
  for i in $_hosts; do
    echo "[SPARK $1:$i]"
    ssh -n root@$i "$(stop_cmd $1)"
  done
}

RETVAL=0

case $1 in
master|slave|slaves|all|hs)
  (( $# >= 2 )) || action 'args format error: plz see sh spark_op.sh help' false || exit 1
  if [[ $1 == 'hs' ]]; then
    caller='history-server'
  else
    caller=$1
  fi
  shift
  while true; do
    case $1 in
    --hosts=?*)
      _hosts=$(echo $1 | sed 's/--hosts=//' | sed "s/['\"]//g" | tr ',' ' ' | xargs)
      shift
      ;;
    --spark-opts=?*)
      _spark_opts=$(echo $1 | sed 's/--spark-opts=//' | sed "s/['\"]//g")
      shift
      ;;
    start)
      start "$caller"
      shift
      break 2
      ;;
    stop)
      stop "$caller"
      shift
      break 2
      ;;
    *)
      usage
      RETVAL=1
      shift
      break 2
      ;;
    esac
  done
  ;;
help)
  usage
  shift
  ;;
*)
  usage
  RETVAL=1
  shift
  ;;
esac

exit $RETVAL
