#!/bin/bash
# 用于启动/停止storm集群
function usage {
  cat << EOF
确保ssh无秘配置
Usage: sh storm_op.sh <[cl]|ui start|stop>
Tips: it supports a launch happended at any machine, and just launchs
      according to the storm.yaml file and the supervisors file.
e.g.
start/stop storm cluster:
  1. sh storm_op.sh cl start/stop
  2. sh storm_op.sh start/stop
start/stop storm ui:
  sh storm_op.sh ui start/stop
EOF
}

. /etc/init.d/functions

[[ -e $STORM_HOME ]] || action "请配置STORM_HOME的环境变量" false || exit 1

nimbus_host=
supervisors_hosts=
get_nimbus() {
  [[ -f $STORM_HOME/conf/storm.yaml ]] || action '$STORM_HOME/conf/storm.yaml文件不存在' false || exit 1
  # 去除注释
  local nimbus=$(cat $STORM_HOME/conf/storm.yaml | grep -Ev '^\s*#|^\s*$' | sed 's/#.*//' | grep -E '^nimbus.host')
  [[ -n $nimbus ]] || action '$STORM_HOME/conf/storm.yaml文件中未配置nimbus.host项' false || exit 1
  nimbus_host=$(echo $nimbus | sed 's/^\s*nimbus.host:\s*//' | sed 's/"//g')
  [[ -n $nimbus_host ]] || action '$STORM_HOME/conf/storm.yaml文件中配置的nimbus.host项为空' false || exit 1
}

get_supervisors() {
  [[ -f $STORM_HOME/conf/supervisors ]] || action '$STORM_HOME/conf/supervisors文件不存在,请将您的supervisors配置在该文件下' false || exit 1
  # 去除注释
  supervisors_hosts=$(cat $STORM_HOME/conf/supervisors | grep -Ev '^\s*#|^\s*$' | sed 's/#.*//' | xargs)
  [[ -n $supervisors_hosts ]] || action '$STORM_HOME/conf/supervisors文件内容为空,请重新配置' false || exit 1
}

nimbus_start_cmd="
  [[ -f /var/run/storm_nimbus.pid ]] && echo 'nimbus已正在运行' >&2 && exit;
  [[ -d \$STORM_HOME/logs ]] || mkdir -p \$STORM_HOME/logs;
  \$STORM_HOME/bin/storm nimbus >> \$STORM_HOME/logs/nimbus.out & 2>&1;
  if [[ \$? == 0 ]]; then
    echo \$! > /var/run/storm_nimbus.pid;
    touch /var/lock/subsys/storm_nimbus;
    for i in {1..8}; do
      echo -n '.';
      sleep 1;
    done;
    echo -e '\n启动nimbus成功';
  else
    echo 'ERROR 启动nimbus失败' >&2;
  fi;
  exit;
"
nimbus_stop_cmd="
  if ! [[ -f /var/run/storm_nimbus.pid ]]; then
    echo 'nimbus未在运行状态，关闭失败..' >&2 && exit;
  fi;
  [[ -d \$STORM_HOME/logs ]] || mkdir -p \$STORM_HOME/logs;
  pid=\$(xargs < /var/run/storm_nimbus.pid);
  if kill -QUIT \$pid >> \$STORM_HOME/logs/nimbus.out 2>&1 && sleep 1 && [[ ! -e /proc/\$pid ]]; then
    echo '已正常关闭nimbus';
    rm -f /var/run/storm_nimbus.pid /var/lock/subsys/storm_nimbus;
  elif kill -9 \$pid >> \$STORM_HOME/logs/nimbus.out 2>&1 && sleep 1 && [[ ! -e /proc/\$pid ]]; then
    echo '已强制关闭nimbus';
    rm -f /var/run/storm_nimbus.pid /var/lock/subsys/storm_nimbus;
  else
    echo 'ERROR:关闭nimbus失败' >&2;
  fi;
  exit;
"

supervisor_start_cmd="
  [[ -f /var/run/storm_supervisor.pid ]] && echo 'supervisor已正在运行' >&2 && exit;
  [[ -d \$STORM_HOME/logs ]] || mkdir -p \$STORM_HOME/logs;
  \$STORM_HOME/bin/storm supervisor >> \$STORM_HOME/logs/supervisor.out & 2>&1;
  if [[ \$? == 0 ]]; then
    echo \$! > /var/run/storm_supervisor.pid;
    touch /var/lock/subsys/storm_supervisor;
    for i in {1..4}; do
      echo -n '.';
      sleep 1;
    done;
    echo -e '\n启动supervisor成功';
  else
    echo 'ERROR 启动supervisor失败' >&2;
  fi;
  exit;
"
supervisor_stop_cmd="
  if ! [[ -f /var/run/storm_supervisor.pid ]]; then
    echo 'supervisor未在运行状态，关闭失败..' >&2 && exit;
  fi;
  [[ -d \$STORM_HOME/logs ]] || mkdir -p \$STORM_HOME/logs;
  pid=\$(xargs < /var/run/storm_supervisor.pid);
  if kill -QUIT \$pid >> \$STORM_HOME/logs/supervisor.out 2>&1 && sleep 1 && [[ ! -e /proc/\$pid ]]; then
    echo '已正常关闭supervisor';
    rm -f /var/run/storm_supervisor.pid /var/lock/subsys/storm_supervisor;
  elif kill -9 \$pid >> \$STORM_HOME/logs/supervisor.out 2>&1 && sleep 1 && [[ ! -e /proc/\$pid ]]; then
    echo '已强制关闭supervisor';
    rm -f /var/run/storm_supervisor.pid /var/lock/subsys/storm_supervisor;
  else
    echo 'ERROR:关闭supervisor失败' >&2;
  fi;
  exit;
"

get_nimbus
get_supervisors
cl_start() {
  echo "[NIMUBS:$nimbus_host]"
  ssh -n root@"$nimbus_host" $nimbus_start_cmd
  for i in $supervisors_hosts; do
    echo "[SUPERVISOR:$i]"
    ssh -n root@$i $supervisor_start_cmd
  done
}

cl_stop() {
  echo "[NIMUBS:$nimbus_host]"
  ssh -n root@"$nimbus_host" $nimbus_stop_cmd
  for i in $supervisors_hosts; do
    echo "[SUPERVISOR:$i]"
    ssh -n root@$i $supervisor_stop_cmd
  done
}

ui_start() {
  echo "[STORM UI:$(hostname)]正在启动storm UI"
  [[ -f /var/run/storm_ui.pid ]] && echo 'storm UI已正在运行' >&2 && return 1
  [[ -d $STORM_HOME/logs ]] || mkdir -p $STORM_HOME/logs
  $STORM_HOME/bin/storm ui >> $STORM_HOME/logs/ui.out 2>&1 &
  if [[ $? == 0 ]]; then
    echo $! > /var/run/storm_ui.pid
    touch /var/lock/subsys/storm_ui
    for i in {1..10}; do
      echo -n '.'
      sleep 1
    done
    echo -e "\n启动storm UI成功"
  else
    echo 'ERROR 启动storm UI失败' >&2
    return 1
  fi;
  return 0
}

ui_stop() {
  echo "[$(hostname)]正在关闭storm UI"
  if ! [[ -f /var/run/storm_ui.pid ]]; then
    echo 'storm UI未在运行状态，关闭失败..' >&2 && return 1
  fi
  [[ -d $STORM_HOME/logs ]] || mkdir -p $STORM_HOME/logs
  local pid=$(xargs < /var/run/storm_ui.pid)
  if kill -QUIT $pid >> $STORM_HOME/logs/ui.out 2>&1 && sleep 1 && [[ ! -e /proc/$pid ]]; then
    echo '已正常关闭storm UI'
    rm -f /var/run/storm_ui.pid /var/lock/subsys/storm_ui
  elif kill -9 $pid >> $STORM_HOME/logs/ui.out 2>&1 && sleep 1 && [[ ! -e /proc/$pid ]]; then
    echo '已强制关闭storm UI'
    rm -f /var/run/storm_ui.pid /var/lock/subsys/storm_ui
  else
    echo 'ERROR:关闭storm UI失败' >&2
    return 1
  fi
  return 0
}

RETVAL=0
case $1 in
start)
  cl_start
  ;;
stop)
  cl_stop
  ;;
cl)
  (( $# >= 2 )) || action 'args format error: plz see sh storm_op.sh help' false || exit 1
  case $2 in
  start)
    cl_start
    ;;
  stop)
    cl_stop
    ;;
  *)
    usage
    RETVAL=1
    ;;
  esac
  ;;
ui)
  (( $# >= 2 )) || action 'args format error: plz see sh storm_op.sh help' false || exit 1
  case $2 in
  start)
    ui_start
    RETVAL=$?
    ;;
  stop)
    ui_stop
    RETVAL=$?
    ;;
  *)
    usage
    RETVAL=1
    ;;
  esac
  ;;
help)
  usage
  ;;
*)
  usage
  RETVAL=1
  ;;
esac
exit $RETVAL
