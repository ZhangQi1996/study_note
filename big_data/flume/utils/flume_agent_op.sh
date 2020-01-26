#!/bin/bash
# 用于启动/停止flume中的agent
function usage {
  cat << EOF
确保ssh无秘配置
Usage: sh flume_agent_op.sh <-n agent-name> [--host=host] [-c conf-dir] [-f agent-conf-file|--lcf=local-conf-file] [--opts=flume_agent_opts] <start|stop>
Tips:
  --host=host: 指定操作的主机，默认是localhost
  -n agent-name:
  -c conf-dir: 指定加载的conf目录，默认就是$FLUME_HOME/conf
  -f agent-conf-file: 指定agent的配置文件，默认是$FLUME_HOME/conf/${agent-name}.conf
  --lcf=local-conf-file: 指定本地的一个agent文件，会将其上传至${host}的/tmp/{file}，作为agent-conf-file
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
_c='-c $FLUME_HOME/conf'
_opts=
_host='localhost'
_local_conf_file=
agent_name=
RETVAL=0

# 参见my_func.sh
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

start_check_before() {
  agent_name=$(echo $_n | sed 's/^\s*-n\s*//')
  if [[ -z $agent_name ]]; then
    action 'the format of args you input is illegal.. ' false
    usage
    return 1
  fi
}

stop_check_before() {
  agent_name=$(echo $_n | sed 's/^\s*-n\s*//')
  if [[ -z $agent_name ]]; then
    action 'the format of args you input is illegal.. ' false
    usage
    return 1
  fi
}

# 注意后台运行的&标志的所放位置，不可以在;之前，也尽量不要放在参数的后面
start_cmd() {
  local caller=$1
  shift
  cat << EOF
  [[ ! -d \$FLUME_HOME ]] && echo "\$FLUME_HOME未配置或未安装flume" >&2 && exit 1;
  $(_proc_is_running)
  proc_is_running /var/run/flume_$caller.pid /var/lock/subsys/flume_$caller && echo 'FLUME AGENT:$caller已正在运行' >&2 && exit 1;
  ! touch /var/lock/subsys/flume_$caller && echo '/var/lock/subsys/flume_$caller已经被锁住，无法start' >&2 && exit 1;
  [[ -d \$FLUME_HOME/logs ]] || mkdir -p \$FLUME_HOME/logs;
  \$FLUME_HOME/bin/flume-ng agent $@ >> \$FLUME_HOME/logs/start_$caller.out & 2>&1;
  if [[ \$? == 0 ]] && sleep 1 && [[ -e /proc/\$! ]]; then
    echo \$! > /var/run/flume_$caller.pid;
    for i in {1..3}; do
      echo -n '.';
      sleep 1;
    done;
    echo -e '\n启动$caller成功';
    echo '启动日志记录位置:'\$FLUME_HOME/logs/start_$caller.out;
  else
    rm -f /var/lock/subsys/flume_$caller;
    echo 'ERROR:启动$caller失败' >&2;
    exit 1;
  fi;
  exit 0;
EOF
}


stop_cmd() {
  local caller=$1
  shift
  cat << EOF
  [[ ! -d \$FLUME_HOME ]] && echo "\$FLUME_HOME未配置或未安装flume" >&2 && exit 1;
  $(_proc_is_running)
  ! proc_is_running /var/run/flume_$caller.pid /var/lock/subsys/flume_$caller && echo 'FLUME AGENT:$caller未在运行状态，关闭失败..' >&2 && exit 1;
  [[ -d \$FLUME_HOME/logs ]] || mkdir -p \$FLUME_HOME/logs;
  pid=\$(xargs < /var/run/flume_$caller.pid);
  if kill -QUIT \$pid >> \$FLUME_HOME/logs/stop_$caller.out 2>&1 && sleep 1 && [[ ! -e /proc/\$pid ]]; then
    echo '已正常关闭$caller';
    rm -f /var/run/flume_$caller.pid /var/lock/subsys/flume_$caller;
  elif kill -9 \$pid >> \$FLUME_HOME/logs/stop_$caller.out 2>&1 && sleep 1 && [[ ! -e /proc/\$pid ]]; then
    echo '已强制关闭$caller';
    rm -f /var/run/flume_$caller.pid /var/lock/subsys/flume_$caller;
  else
    echo 'ERROR:关闭$caller失败' >&2;
    echo '启动日志记录位置:'\$FLUME_HOME/logs/stop_$caller.out;
    exit 1;
  fi;
  exit 0;
EOF
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
  --host=?*)
    if [[ -z $2 ]]; then
      action 'the format of args you input is illegal.. ' false
      usage
      RETVAL=1
      break 2
    fi
    _host=$(echo $1 | sed 's/--host=//' | sed "s/['\"]//g")
    shift
    ;;
  --lcf=?*)
    if [[ -z $2 ]]; then
      action 'the format of args you input is illegal.. ' false
      usage
      RETVAL=1
      break 2
    fi
    _local_conf_file=$(echo $1 | sed 's/--lcf=//' | sed "s/['\"]//g")
    shift
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
  --opts=?*)
    if [[ -z $2 ]]; then
      action 'the format of args you input is illegal.. ' false
      usage
      RETVAL=1
      break 2
    fi
    _opts=$(echo $1 | sed 's/--opts=//' | sed "s/['\"]//g")
    shift
    ;;
  start)
    if ! start_check_before; then
      RETVAL=1
      break 2
    fi
    # 若local conf file不为空，则先将本地目标文件上传至目标主机的tmp目录下，注意确保tmp目录下没有相同文件
    if [[ -n $_local_conf_file ]]; then
      if scp $_local_conf_file root@$_host:/tmp/${_local_conf_file##*/} >/dev/null 2>&1; then
        action "已将本地$_local_conf_file上传至$_host:/tmp/${_local_conf_file##*/}" true
        _f="-f /tmp/${_local_conf_file##*/}"
      else
        action "将本地$_local_conf_file上传至$_host:/tmp/${_local_conf_file##*/}失败" false
        RETVAL=1
        break 2
      fi
    fi
    [[ -z $_f ]] && _f='-f $FLUME_HOME/conf/$agent_name.conf';
    echo "[FLUME AGENT:$_host]"
    ssh -n root@$_host $(start_cmd $agent_name $_n $_c $_f $_opts)
    RETVAL=$?
    break 2
    ;;
  stop)
    if ! stop_check_before; then
      RETVAL=1
      break 2
    fi
    echo "[FLUME AGENT:$_host]"
    ssh -n root@$_host $(stop_cmd $agent_name)
    RETVAL=$?
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
