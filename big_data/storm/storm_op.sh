#!/bin/bash
# 用于启动/停止storm集群
function usage {
  cat << EOF
确保ssh无秘配置
Usage: sh storm_op.sh <[cl]|ui|lv start|stop> [options]
Tips: 1. it supports a launch happended at any machine, and just launchs
      according to the storm.yaml file and the supervisors file.
      2. options mean that they will be provided the corresponding cmd to exec.
E.G.
start/stop storm cluster:
  1. sh storm_op.sh cl start/stop
  2. sh storm_op.sh start/stop
start/stop storm ui:
  sh storm_op.sh ui start/stop
start/stop storm log viewer
  1. sh storm_op.sh lv start/stop PS: means launching/shutdowning log viewer on every supervisor
  2. sh storm_op.sh lv start/stop --supervisors="host1,host2" PS: means launching/shutdowning log viewer on host1 and host2
  3. sh storm_op.sh lv start/stop -s "host1,host2" PS: means launching/shutdowning log viewer on host1 and host2
EOF
}

. /etc/init.d/functions

[[ -e $STORM_HOME ]] || action "请配置STORM_HOME的环境变量" false || exit 1

nimbus_seeds=
supervisors_hosts=
get_nimbus() {
  [[ -f $STORM_HOME/conf/storm.yaml ]] || action '$STORM_HOME/conf/storm.yaml文件不存在' false || exit 1
  # 去除注释
  local nimbus=$(cat $STORM_HOME/conf/storm.yaml | grep -Ev '^\s*#|^\s*$' | sed 's/#.*//' | grep -E '^nimbus.host')
  # 在较新版本中nimbus.host项已经过时
  [[ -n $nimbus ]] && echo '[WARNING]$STORM_HOME/conf/storm.yaml文件中配置的nimbus.host项为过时项，请更新为nimbus.seeds项' >&2
  nimbus=$(cat $STORM_HOME/conf/storm.yaml | grep -Ev '^\s*#|^\s*$' | sed 's/#.*//' | grep -E '^nimbus.seeds')
  if [[ -z $nimbus ]]; then
    echo '[WARNING]由于storm.yaml中没有配置nimbus.seeds项，故采用默认配置(启动localhost作为nimbus leader)' >&2
    nimbus_seeds='localhost'
  else
    nimbus_seeds=$(echo $nimbus | sed 's/^\s*nimbus.seeds:\s*\[//' | sed 's/\]\s*$//' | sed "s/['\"]//g" | tr ',' ' ' | xargs)
    [[ -n $nimbus_seeds ]] || action '$STORM_HOME/conf/storm.yaml文件中配置的nimbus.seeds项为空' false || exit 1
  fi
}

get_supervisors() {
  [[ -f $STORM_HOME/conf/supervisors ]] || action '$STORM_HOME/conf/supervisors文件不存在,请将您的supervisors配置在该文件下' false || exit 1
  # 去除注释
  supervisors_hosts=$(cat $STORM_HOME/conf/supervisors | grep -Ev '^\s*#|^\s*$' | sed 's/#.*//' | xargs)
  [[ -n $supervisors_hosts ]] || action '$STORM_HOME/conf/supervisors文件内容为空,请重新配置' false || exit 1
}

nimbus_start_cmd() {
  cat << EOF
  [[ -f /var/run/storm_nimbus.pid ]] && echo 'nimbus已正在运行' >&2 && exit;
  [[ -d \$STORM_HOME/logs ]] || mkdir -p \$STORM_HOME/logs;
  \$STORM_HOME/bin/storm nimbus $@ >> \$STORM_HOME/logs/nimbus.out & 2>&1;
  if [[ \$? == 0 ]]; then
    echo \$! > /var/run/storm_nimbus.pid;
    touch /var/lock/subsys/storm_nimbus;
    for i in {1..8}; do
      echo -n '.';
      sleep 1;
    done;
    echo -e '\n启动nimbus成功';
    echo '日志记录位置:'\$STORM_HOME/logs/nimbus.log;
  else
    echo 'ERROR 启动nimbus失败' >&2;
  fi;
  exit;
EOF
}
nimbus_stop_cmd() {
  cat << EOF
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
EOF
}

supervisor_start_cmd() {
  cat << EOF
  [[ -f /var/run/storm_supervisor.pid ]] && echo 'supervisor已正在运行' >&2 && exit;
  [[ -d \$STORM_HOME/logs ]] || mkdir -p \$STORM_HOME/logs;
  \$STORM_HOME/bin/storm supervisor $@ >> \$STORM_HOME/logs/supervisor.out & 2>&1;
  if [[ \$? == 0 ]]; then
    echo \$! > /var/run/storm_supervisor.pid;
    touch /var/lock/subsys/storm_supervisor;
    for i in {1..4}; do
      echo -n '.';
      sleep 1;
    done;
    echo -e '\n启动supervisor成功';
    echo '日志记录位置:'\$STORM_HOME/logs/supervisor.log;
  else
    echo 'ERROR 启动supervisor失败' >&2;
  fi;
  exit;
EOF
}
supervisor_stop_cmd() {
  cat << EOF
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
EOF
}

lv_start_cmd() {
  cat << EOF
  echo '[STORM LOGVIEWER:'\$(hostname)']正在启动storm log viewer';
  [[ -f /var/run/storm_logviewer.pid ]] && echo 'storm log viewer已正在运行' >&2 && exit;
  [[ -d \$STORM_HOME/logs ]] || mkdir -p \$STORM_HOME/logs;
  \$STORM_HOME/bin/storm logviewer $@ >> \$STORM_HOME/logs/logviewer.out & 2>&1;
  if [[ \$? == 0 ]]; then
    echo \$! > /var/run/storm_logviewer.pid;
    touch /var/lock/subsys/storm_logviewer;
    for i in {1..5}; do
      echo -n '.';
      sleep 1;
    done;
    echo -e '\n启动storm log viewer成功';
    echo '日志记录位置:'\$STORM_HOME/logs/logviewer.log;
  else
    echo 'ERROR 启动storm log viewer失败' >&2;
  fi;
  exit;
EOF
}

lv_stop_cmd() {
  cat << EOF
  echo '['\$(hostname)']正在关闭storm log viewer';
  if ! [[ -f /var/run/storm_logviewer.pid ]]; then
    echo 'storm log viewer未在运行状态，关闭失败..' >&2 && exit;
  fi;
  [[ -d \$STORM_HOME/logs ]] || mkdir -p \$STORM_HOME/logs;
  pid=\$(xargs < /var/run/storm_logviewer.pid);
  if kill -QUIT \$pid >> \$STORM_HOME/logs/logviewer.out 2>&1 && sleep 1 && [[ ! -e /proc/\$pid ]]; then
    echo '已正常关闭storm log viewer';
    rm -f /var/run/storm_logviewer.pid /var/lock/subsys/storm_logviewer;
  elif kill -9 \$pid >> \$STORM_HOME/logs/logviewer.out 2>&1 && sleep 1 && [[ ! -e /proc/\$pid ]]; then
    echo '已强制关闭storm log viewer';
    rm -f /var/run/storm_logviewer.pid /var/lock/subsys/storm_logviewer;
  else
    echo 'ERROR:关闭storm log viewer失败' >&2;
  fi;
  exit;
EOF
}

get_nimbus
get_supervisors
cl_start() {
  for i in $nimbus_seeds; do
    echo "[NIMUBS:$i]"
    ssh -n root@$i $(nimbus_start_cmd $@)
  done
  for i in $supervisors_hosts; do
    echo "[SUPERVISOR:$i]"
    ssh -n root@$i $(supervisor_start_cmd $@)
  done
}

cl_stop() {
  for i in $nimbus_seeds; do
    echo "[NIMUBS:$i]"
    ssh -n root@$i $(nimbus_stop_cmd)
  done
  for i in $supervisors_hosts; do
    echo "[SUPERVISOR:$i]"
    ssh -n root@$i $(supervisor_stop_cmd)
  done
}

ui_start() {
  echo "[STORM UI:$(hostname)]正在启动storm UI"
  [[ -f /var/run/storm_ui.pid ]] && echo 'storm UI已正在运行' >&2 && return 1
  [[ -d $STORM_HOME/logs ]] || mkdir -p $STORM_HOME/logs
  $STORM_HOME/bin/storm ui $@ >> $STORM_HOME/logs/ui.out 2>&1 &
  if [[ $? == 0 ]]; then
    echo $! > /var/run/storm_ui.pid
    touch /var/lock/subsys/storm_ui
    for i in {1..10}; do
      echo -n '.'
      sleep 1
    done
    echo -e "\n启动storm UI成功"
    echo "日志记录位置:$STORM_HOME/logs/ui.log"
  else
    echo 'ERROR 启动storm UI失败' >&2
    return 1
  fi
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

lv_start() {
  local lv_hosts=
  case $1 in
  --supervisors=?*)
    lv_hosts=$(echo $1 | sed 's/--supervisors=//' | sed "s/['\"]//g" | tr ',' ' ' | xargs)
    shift
    for i in $lv_hosts; do
      echo "[LOGVIEWER:$i]"
      ssh -n root@$i $(lv_start_cmd $@)
    done
    ;;
  -s)
    (( $# >= 2 )) || action 'args format error: plz see sh storm_op.sh help' false || return 1
    lv_hosts=$(echo $2 | tr ',' ' ' | xargs)
    shift 2
    for i in $supervisors_hosts; do
      echo "[LOGVIEWER:$i]"
      ssh -n root@$i $(lv_start_cmd $@)
    done
    ;;
  *)
    echo '[DEFAULT MODE: START LOGVIEWER ON ALL SUPERVISORS]'
    for i in $supervisors_hosts; do
      echo "[LOGVIEWER:$i]"
      ssh -n root@$i $(lv_start_cmd $@)
    done
    ;;
  esac
  return 0
}

lv_stop() {
  local lv_hosts=
  case $1 in
  --supervisors=?*)
    lv_hosts=$(echo $1 | sed 's/--supervisors=//' | sed "s/['\"]//g" | tr ',' ' ' | xargs)
    shift
    for i in $lv_hosts; do
      echo "[LOGVIEWER:$i]"
      ssh -n root@$i $(lv_stop_cmd)
    done
    ;;
  -s)
    (( $# >= 2 )) || action 'args format error: plz see sh storm_op.sh help' false || return 1
    lv_hosts=$(echo $2 | tr ',' ' ' | xargs)
    shift 2
    for i in $lv_hosts; do
      echo "[LOGVIEWER:$i]"
      ssh -n root@$i $(lv_stop_cmd)
    done
    ;;
  *)
    echo '[DEFAULT MODE: STOP LOGVIEWER ON ALL SUPERVISORS]'
    for i in $supervisors_hosts; do
      echo "[LOGVIEWER:$i]"
      ssh -n root@$i $(lv_stop_cmd)
    done
    ;;
  esac
  return 0
}

RETVAL=0
case $1 in
start)
  shift
  cl_start $@
  ;;
stop)
  cl_stop
  ;;
cl)
  (( $# >= 2 )) || action 'args format error: plz see sh storm_op.sh help' false || exit 1
  case $2 in
  start)
    shift 2
    cl_start $@
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
    shift 2
    ui_start $@
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
lv)
  (( $# >= 2 )) || action 'args format error: plz see sh storm_op.sh help' false || exit 1
  case $2 in
  start)
    shift 2
    lv_start $@
    RETVAL=$?
    ;;
  stop)
    shift 2
    lv_stop $@
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
