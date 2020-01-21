#!/bin/bash
# 用于启动/停止storm集群/ui/logviewer
function usage {
  cat << EOF
确保ssh无秘配置
Usage: sh storm_op.sh <[cl]|ui|lv start|stop> [options]
Tips: 1. it supports a launch happended at any machine, and just launchs
      according to the storm.yaml file and the supervisors file.
      2. options mean that they will be provided for the corresponding cmd to exec.
E.G.
start/stop storm cluster:
  1. sh storm_op.sh cl start/stop
  2. sh storm_op.sh start/stop
  PS: start/stop storm cluster including nimbus, supervisors and drpc servers
start/stop storm ui:
  sh storm_op.sh ui start/stop
  PS: start/stop storm ui launched just on the machine executing this cmd.
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
drpc_hosts=

get_nimbus() {
  [[ -f $STORM_HOME/conf/storm.yaml ]] || action '$STORM_HOME/conf/storm.yaml文件不存在' false || exit 1
  # 去除注释
  local nimbus=$(cat $STORM_HOME/conf/storm.yaml | grep -Ev '^\s*#|^\s*$' | sed 's/#.*//' | grep -E '^\s*nimbus.host')
  # 在较新版本中nimbus.host项已经过时
  [[ -n $nimbus ]] && echo '[WARNING]$STORM_HOME/conf/storm.yaml文件中配置的nimbus.host项为过时项，请更新为nimbus.seeds项' >&2
  nimbus=$(cat $STORM_HOME/conf/storm.yaml | grep -Ev '^\s*#|^\s*$' | sed 's/#.*//' | grep -E '^\s*nimbus.seeds')
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

get_drpcs() {
  [[ -f $STORM_HOME/conf/storm.yaml ]] || action '$STORM_HOME/conf/storm.yaml文件不存在' false || exit 1
  local is_contain_drpc=false
  local tmp_file='4c4a685c-b475-4107-806a-62e6515e1d7a.tmp'
  # 去除注释并导入零时文件中
  cat $STORM_HOME/conf/storm.yaml | grep -Ev '^\s*#|^\s*$' | sed 's/#.*//' > $tmp_file
  # 若采用管道方式read，则产生子进程，变量作用域不共享，故采用重定向方式
  # 而重定向方式仅仅支持文件/目录的导入方式，故借助临时文件做跳板
  while read line; do
    if ! $is_contain_drpc; then
      echo -n $line | grep -E '^\s*drpc.servers' >/dev/null 2>&1 && is_contain_drpc=true
    else # 要是内容值已经包含了drpc项就向下查找结果
      # 若该行由-开头，则判定为目标行
      if echo -n $line | grep -E '^\s*-' >/dev/null 2>&1; then
        drpc_hosts=$drpc_hosts' '$(echo -n $line | sed 's/^\s*-\s*'// | sed "s/['\"]//g")
      else
        break
      fi
    fi
  done < $tmp_file
  # 删除临时文件
  rm -f $tmp_file
  # 处理可能存在的全部空格的问题
  drpc_hosts=$(echo -n $drpc_hosts | sed 's/^\s*$//' | xargs)
  # 判断是否含有drpc.servers字段
  [[ -n $drpc_hosts ]] || action '[ERROR]storm.yaml中没有配置drpc.servers项或该项值的配置不合法，请配置后再试...' false || exit 1
}

# 传递给ssh的cmd
start_cmd() {
  local sec=
  local caller=$1
  shift
  case $caller in
  nimbus)
    sec=8
    ;;
  logviewer)
    sec=5
    ;;
  *)
    sec=4
    ;;
  esac
  cat << EOF
  [[ -f /var/run/storm_$caller.pid ]] && echo '$caller已正在运行' >&2 && exit;
  [[ -d \$STORM_HOME/logs ]] || mkdir -p \$STORM_HOME/logs;
  touch /var/lock/subsys/storm_$caller || (echo '/var/lock/subsys/storm_$caller已经被锁住，无法start' >&2 && exit 1);
  \$STORM_HOME/bin/storm $caller $@ >> \$STORM_HOME/logs/$caller.out & 2>&1;
  if [[ \$? == 0 ]]; then
    echo \$! > /var/run/storm_$caller.pid;
    for i in {1..$sec}; do
      echo -n '.';
      sleep 1;
    done;
    echo -e '\n启动$caller成功';
    echo '日志记录位置:'\$STORM_HOME/logs/$caller.out,log;
  else
    rm -f /var/lock/subsys/storm_$caller;
    echo 'ERROR:启动$caller失败' >&2;
  fi;
  exit;
EOF
}
stop_cmd() {
  local sec=
  local caller=$1
  shift
  case $caller in
  nimbus)
    sec=8
    ;;
  logviewer)
    sec=5
    ;;
  *)
    sec=4
    ;;
  esac
  cat << EOF
  if ! [[ -f /var/run/storm_$caller.pid ]]; then
    echo '$caller未在运行状态，关闭失败..' >&2 && exit;
  fi;
  [[ -d \$STORM_HOME/logs ]] || mkdir -p \$STORM_HOME/logs;
  pid=\$(xargs < /var/run/storm_$caller.pid);
  if kill -QUIT \$pid >> \$STORM_HOME/logs/$caller.out 2>&1 && sleep 1 && [[ ! -e /proc/\$pid ]]; then
    echo '已正常关闭$caller';
    rm -f /var/run/storm_$caller.pid /var/lock/subsys/storm_$caller;
  elif kill -9 \$pid >> \$STORM_HOME/logs/$caller.out 2>&1 && sleep 1 && [[ ! -e /proc/\$pid ]]; then
    echo '已强制关闭$caller';
    rm -f /var/run/storm_$caller.pid /var/lock/subsys/storm_$caller;
  else
    echo 'ERROR:关闭$caller失败' >&2;
  fi;
  exit;
EOF
}

get_nimbus
get_supervisors
get_drpcs

cl_start() {
  # 启动nimbus
  for i in $nimbus_seeds; do
    echo "[NIMUBS:$i]"
    ssh -n root@$i $(start_cmd 'nimbus' $@)
  done
  # 启动supervisor
  for i in $supervisors_hosts; do
    echo "[SUPERVISOR:$i]"
    ssh -n root@$i $(start_cmd 'supervisor' $@)
  done
  # 启动drpc server
  for i in $drpc_hosts; do
    echo "[DRPC SVR:$i]"
    ssh -n root@$i $(start_cmd 'drpc' $@)
  done
}

cl_stop() {
  # 关闭nimbus
  for i in $nimbus_seeds; do
    echo "[NIMUBS:$i]"
    ssh -n root@$i $(stop_cmd 'nimbus')
  done
  # 关闭supervisor
  for i in $supervisors_hosts; do
    echo "[SUPERVISOR:$i]"
    ssh -n root@$i $(stop_cmd 'supervisor')
  done
  # 关闭drpc server
  for i in $drpc_hosts; do
    echo "[DRPC SVR:$i]"
    ssh -n root@$i $(stop_cmd 'drpc')
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
    echo "日志记录位置:$STORM_HOME/logs/ui.out,log"
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
      ssh -n root@$i $(start_cmd 'logviewer' $@)
    done
    ;;
  -s)
    (( $# >= 2 )) || action 'args format error: plz see sh storm_op.sh help' false || return 1
    lv_hosts=$(echo $2 | tr ',' ' ' | xargs)
    shift 2
    for i in $lv_hosts; do
      echo "[LOGVIEWER:$i]"
      ssh -n root@$i $(start_cmd 'logviewer' $@)
    done
    ;;
  *)
    echo '[DEFAULT MODE: START LOGVIEWER ON ALL SUPERVISORS]'
    for i in $supervisors_hosts; do
      echo "[LOGVIEWER:$i]"
      ssh -n root@$i $(start_cmd 'logviewer' $@)
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
      ssh -n root@$i $(stop_cmd 'logviewer')
    done
    ;;
  -s)
    (( $# >= 2 )) || action 'args format error: plz see sh storm_op.sh help' false || return 1
    lv_hosts=$(echo $2 | tr ',' ' ' | xargs)
    shift 2
    for i in $lv_hosts; do
      echo "[LOGVIEWER:$i]"
      ssh -n root@$i $(stop_cmd 'logviewer')
    done
    ;;
  *)
    echo '[DEFAULT MODE: STOP LOGVIEWER ON ALL SUPERVISORS]'
    for i in $supervisors_hosts; do
      echo "[LOGVIEWER:$i]"
      ssh -n root@$i $(stop_cmd 'logviewer')
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
