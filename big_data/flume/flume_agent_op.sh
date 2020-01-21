#!/bin/bash
# 用于启动/停止flume中的agent
function usage {
  cat << EOF
确保ssh无秘配置
Usage: sh flume_agent_op.sh <-n agent-name> [-c conf-dir] [-f conf-file] [--opts flume_agent_opts] <start|stop>
Tips:
  --opts: 包含的参数将会给'flume-ng agent'作为附加参数，其中是包含除-n, -f之外的参数
E.G.
[START]
  1. sh flume_agent_op.sh start -n my_agent
    EQUALS EXEC
    $FLUME_HOME/bin/flume-ng agent -n my_agent -f $FLUME_HOME/conf/my_agent.conf & >> $FLUME_HOME/logs/agent_start.out 2>&1
[STOP]
  1. sh flume_agent_op.sh stop
EOF
}

(($# == 0)) && usage && exit 1

. /etc/init.d/functions

[[ -e $FLUME_HOME ]] || action "请配置FLUME_HOME的环境变量" false || exit 1

_n=
_f=
_c="-c $FLUME_HOME/conf"
_opts=
agent_name=
RETVAL=0

# 参见my_func.sh
proc_is_running() {
  local pid_file=$1
  local pid=
  local lock_file=
  [[ -n $2 && -f $2 ]] && lock_file=$2
  if [[ -f $pid_file ]]; then
    pid=$(xargs < $pid_file)
    if [[ -e /proc/$pid ]]; then
      return 0
    else
      rm -f $pid_file
      [[ -z $lock_file ]] && rm -f $lock_file
      return 1
    fi
  else
    return 1
  fi
}

start_check_before() {
  agent_name=$(echo $_n | sed 's/^\s*-n\s*//')
  if [[ -z $agent_name ]]; then
    action 'the format of args you input is illegal.. ' false
    usage
    return 1
  fi
  if proc_is_running /var/run/flume_$agent_name.pid /var/lock/subsys/flume_$agent_name.lock; then
    action "FLUME:$agent_name is running.." false
    return 1
  else
    return 0
  fi
}

stop_check_before() {
  agent_name=$(echo $_n | sed 's/^\s*-n\s*//')
  if [[ -z $agent_name ]]; then
    action 'the format of args you input is illegal.. ' false
    usage
    return 1
  fi
  if ! proc_is_running /var/run/flume_$agent_name.pid /var/lock/subsys/flume_$agent_name.lock; then
    action "FLUME:$agent_name is not running.." false
    return 1
  else
    return 0
  fi
}

while (($# > 0)); do
  case $1 in
  -n)
    if [[ -z $2 ]]; then
      action 'the format of args you input is illegal.. ' false
      usage
      RETVAL=1
      break 2
    fi
    _n="-n $2"
    shift 2
    ;;
  -c)
    if [[ -z $2 ]]; then
      action 'the format of args you input is illegal.. ' false
      usage
      RETVAL=1
      break 2
    fi
    _c="-c $2"
    shift 2
    ;;
  -f)
    if [[ -z $2 ]]; then
      action 'the format of args you input is illegal.. ' false
      usage
      RETVAL=1
      break 2
    fi
    _f="-f $2"
    shift 2
    ;;
  --opts)
    if [[ -z $2 ]]; then
      action 'the format of args you input is illegal.. ' false
      usage
      RETVAL=1
      break 2
    fi
    _opts=$2
    shift 2
    ;;
  start)
    if ! start_check_before; then
      RETVAL=1
      break 2
    fi
    [[ -d $FLUME_HOME/logs ]] || mkdir -p $FLUME_HOME/logs
    [[ -z $_f ]] && _f="-f $FLUME_HOME/conf/$agent_name.conf"
    touch /var/lock/subsys/flume_$agent_name.lock || action "/var/lock/subsys/flume_$agent_name.lock锁住，无法start" false || exit 1
    $FLUME_HOME/bin/flume-ng agent $_n $_c $_f $_opts >> $FLUME_HOME/logs/agent_start.out 2>&1 &
    if [[ $? == 0 ]]; then
      echo $! > /var/run/flume_$agent_name.pid
      action 'start successfully' true
    else
      action 'ERROR: start in failure' false
      RETVAL=1
    fi
    break 2
    ;;
  stop)
    if ! stop_check_before; then
      RETVAL=1
      break 2
    fi
    pid=$(xargs < /var/run/flume_$agent_name.pid)
    if kill -QUIT $pid && sleep 1 && [[ ! -e /proc/$pid ]]; then
      action 'stop successfully in braceful way' true
    elif kill -9 $pid && sleep 1 && [[ ! -e /proc/$pid ]]; then
      action 'stop successfully in brute way' true
    else
      action 'ERROR: stop in failure' false
      break 2
    fi
    rm -f /var/run/flume_$agent_name.pid /var/lock/subsys/flume_$agent_name.lock
    break 2
    ;;
  *)
    usage
    RETVAL=1
    break 2
    ;;
  esac
done
exit $RETVAL
