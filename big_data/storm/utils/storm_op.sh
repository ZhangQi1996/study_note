#!/bin/bash
# 用于启动/停止storm集群/ui/logviewer
function usage {
  cat << EOF
确保ssh无秘配置
Usage: sh storm_op.sh <cl [--no-drpc] | ui [--ui-host=hostname] | lv [lv-options]> [--storm-opts=storm-opts] start|stop
Tips: 1. it supports a launch happended at any machine, and just launchs
      according to the storm.yaml file and the supervisors file.
      2. lv-options include:
        --supervisors=hosts_list
        -s hosts_list
      3. --storm-opts=<storm-opts> PS: this will be provided to storm exec program.
      4. --no-drpc: see E.G.
      5. --ui-host=hostname: see E.G.
E.G.
start/stop storm cluster:
  1. sh storm_op.sh cl start/stop
  PS: start/stop storm cluster including nimbus, supervisors and drpc servers
  2. sh storm_op.sh cl start/stop [--no-drpc]
  PS: start/stop storm without drpc servers if '--no-drpc' opt is provided.
start/stop storm ui:
  1. sh storm_op.sh ui start/stop
  PS: start/stop storm ui launched just on the machine executing this cmd.
  2. sh storm_op.sh ui --ui-host=host1 start/stop
  PS: start/stop storm ui on host1.
start/stop storm log viewer
  1. sh storm_op.sh lv start/stop PS: means launching/shutdowning log viewer on every supervisor
  2. sh storm_op.sh lv --supervisors="host1,host2" start/stop PS: means launching/shutdowning log viewer on host1 and host2
  3. sh storm_op.sh lv -s "host1,host2" start/stop PS: means launching/shutdowning log viewer on host1 and host2
EOF
}

. /etc/init.d/functions

[[ -e $STORM_HOME ]] || action "请配置STORM_HOME的环境变量" false || exit 1

nimbus_seeds=
supervisors_hosts=
drpc_hosts=
_no_drpc=false
_lv_hosts=
_ui_host='localhost'
_storm_opts=

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

# 用于嵌套在ssh的cmd中
_proc_is_running() {
  cat << EOF
proc_is_running() {
  local pid_file=\$1;
  local pid=;
  local lock_file=;
  [[ -f \$2 ]] && lock_file=\$2;
  if [[ -f \$pid_file ]]; then
    pid=\$(xargs < \$pid_file);
    if [[ -e /proc/\$pid ]]; then
      return 0;
    else
      rm -f \$pid_file;
      [[ -f \$lock_file ]] && rm -f \$lock_file;
      return 1;
    fi;
  else
    return 1;
  fi;
};
EOF
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
  $(_proc_is_running)
  proc_is_running /var/run/storm_$caller.pid /var/lock/subsys/storm_$caller && echo '$caller已正在运行' >&2 && exit 1;
  ! touch /var/lock/subsys/storm_$caller && echo '/var/lock/subsys/storm_$caller已经被锁住，无法start' >&2 && exit 1;
  \$STORM_HOME/bin/storm $caller $@ >> \$STORM_HOME/logs/$caller.out & 2>&1;
  if [[ \$? == 0 ]] && sleep 1 && [[ -e /proc/\$! ]]; then
    echo \$! > /var/run/storm_$caller.pid;
    for i in {1..$sec}; do
      echo -n '.';
      sleep 1;
    done;
    echo -e '\n启动$caller成功';
    echo '启动日志记录位置:'\$STORM_HOME/logs/$caller.out;
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
  $(_proc_is_running)
  ! proc_is_running /var/run/storm_$caller.pid /var/lock/subsys/storm_$caller && echo '$caller未在运行状态，关闭失败..' >&2 && exit 1;
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
    echo "[STORM NIMUBS:$i]"
    ssh -n root@$i $(start_cmd 'nimbus' $@)
  done
  # 启动supervisor
  for i in $supervisors_hosts; do
    echo "[STORM SUPERVISOR:$i]"
    ssh -n root@$i $(start_cmd 'supervisor' $@)
  done
  if ! $_no_drpc; then
    # 启动drpc server
    for i in $drpc_hosts; do
      echo "[STORM DRPC SVR:$i]"
      ssh -n root@$i $(start_cmd 'drpc' $@)
    done
  fi
}

cl_stop() {
  # 关闭nimbus
  for i in $nimbus_seeds; do
    echo "[STORM NIMUBS:$i]"
    ssh -n root@$i $(stop_cmd 'nimbus')
  done
  # 关闭supervisor
  for i in $supervisors_hosts; do
    echo "[STORM SUPERVISOR:$i]"
    ssh -n root@$i $(stop_cmd 'supervisor')
  done
  if ! $_no_drpc; then
    # 关闭drpc server
    for i in $drpc_hosts; do
      echo "[STORM DRPC SVR:$i]"
      ssh -n root@$i $(stop_cmd 'drpc')
    done
  fi
}

ui_start() {
  echo "[STORM UI:$_ui_host]"
  ssh -n root@$_ui_host $(start_cmd 'ui' $_storm_opts)
}

ui_stop() {
  echo "[STORM UI:$_ui_host]"
  ssh -n root@$_ui_host $(stop_cmd 'ui')
}

lv_start() {
  if [[ -z $_lv_hosts ]]; then
    echo '[DEFAULT MODE: START LOGVIEWER ON ALL SUPERVISORS]'
    _lv_hosts=$supervisors_hosts
  fi
  for i in $_lv_hosts; do
    echo "[STORM LOGVIEWER:$i]"
    ssh -n root@$i $(start_cmd 'logviewer' $_storm_opts)
  done
}

lv_stop() {
  if [[ -z $_lv_hosts ]]; then
    echo '[DEFAULT MODE: STOP LOGVIEWER ON ALL SUPERVISORS]'
    _lv_hosts=$supervisors_hosts
  fi
  for i in $_lv_hosts; do
    echo "[STORM LOGVIEWER:$i]"
    ssh -n root@$i $(stop_cmd 'logviewer')
  done
}

RETVAL=0

case $1 in
cl)
  (( $# >= 2 )) || action 'args format error: plz see sh storm_op.sh help' false || exit 1
  shift
  while true; do
    case $1 in
    --no-drpc)
      _no_drpc=true
      shift
      ;;
    --storm-opts=?*)
      _storm_opts=$(echo $1 | sed 's/--storm-opts=//' | sed "s/['\"]//g")
      shift
      ;;
    start)
      cl_start
      shift
      break 2
      ;;
    stop)
      cl_stop
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
ui)
  (( $# >= 2 )) || action 'args format error: plz see sh storm_op.sh help' false || exit 1
  shift
  while true; do
    case $1 in
    --ui-host=?*)
      _ui_host=$(echo $1 | sed 's/--ui-host=//' | sed "s/['\"]//g" | xargs)
      shift
      ;;
    --storm-opts=?*)
      _storm_opts=$(echo $1 | sed 's/--storm-opts=//' | sed "s/['\"]//g")
      shift
      ;;
    start)
      ui_start
      shift
      break 2
      ;;
    stop)
      ui_stop
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
lv)
  (( $# >= 2 )) || action 'args format error: plz see sh storm_op.sh help' false || exit 1
  shift
  while true; do
    case $1 in
    --supervisors=?*)
      _lv_hosts=$(echo $1 | sed 's/--supervisors=//' | sed "s/['\"]//g" | tr ',' ' ' | xargs)
      shift
      ;;
    -s)
      (( $# >= 2 )) || action 'args format error: plz see sh storm_op.sh help' false || exit 1
      _lv_hosts=$(echo $2 | tr ',' ' ' | xargs)
      shift 2
      ;;
    --storm-opts=?*)
      _storm_opts=$(echo $1 | sed 's/--storm-opts=//' | sed "s/['\"]//g")
      shift
      ;;
    start)
      lv_start
      shift
      break 2
      ;;
    stop)
      lv_stop
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
