#!/bin/bash
# 用于启动/停止kafka集群中的broker
function usage {
  cat << EOF
确保ssh无秘配置
Usage: sh kafka_op.sh <-b broker_list [-n] [-f server.properties] start> | <-b broker_list stop>
Tips: currently, this script do not supports overriding properties in starting kafka brokers.
E.G.
[START]
  1. sh kafka_op.sh -b 'host1,host2' start
    EQUALS EXEC
    $KAFKA_HOME/bin/kafka-server-start.sh -daemon $KAFKA_HOME/config/server.properties start
    IN host1 AND host2
  2. sh kafka_op.sh -b 'host1,host2' -n -f 'xxx/xxx.properties' start
    EQUALS EXEC
    $KAFKA_HOME/bin/kafka-server-start.sh xxx/xxx.properties start
    IN host1 AND host2
[STOP]
  1. sh kafka_op.sh -b 'host1,host2' stop
    EQUALS EXEC
    $KAFKA_HOME/bin/kafka-server-stop.sh stop
    IN host1 AND host2
EOF
}

(($# == 0)) && usage && exit 1

. /etc/init.d/functions

[[ -e $KAFKA_HOME ]] || action "请配置KAFKA_HOME的环境变量" false || exit 1

# 默认选项
broker_list=
svr_props='$KAFKA_HOME/config/server.properties'
daemon='-daemon'

start_check_before() {
  [[ -n $broker_list && -n $svr_props && -n $daemon ]] && return 0
  return 1
}

stop_check_before() {
  [[ -n $broker_list ]] && return 0
  return 1
}

RETVAL=0
while (($# > 0)); do
  case $1 in
  -b)
    if [[ -z $2 ]]; then
      action 'the format of args you input is illegal.. ' false
      usage
      RETVAL=1
      break 2
    fi
    broker_list=$(echo $2 | tr ',' ' ' | xargs)
    shift 2
    ;;
  -n)
    daemon=
    shift
    ;;
  -f)
    if [[ -z $2 ]]; then
      action 'the format of args you input is illegal.. ' false
      usage
      RETVAL=1
      break 2
    fi
    svr_props=$2
    shift 2
    ;;
  start)
    start_check_before
    if [[ $? == 1 ]]; then
      action 'the format of args you input is illegal.. ' false
      usage
      RETVAL=1
      break 2
    fi
    for b in $broker_list; do
      echo "[BROKER:$b]"
      ssh -n root@$b "
      [[ ! -d \$KAFKA_HOME ]] && echo '未配置kafka的环境变量' >&2 && exit 1;
      [[ -d \$KAFKA_HOME/logs ]] || mkdir -p \$KAFKA_HOME/logs;
      if \$KAFKA_HOME/bin/kafka-server-start.sh $daemon $svr_props >> \$KAFKA_HOME/logs/start.out 2>&1 && sleep 2 && jps | grep 'Kafka' >/dev/null 2>&1; then
        echo 'start successfully';
        exit 0;
      else
        echo 'start in failure, and to acquire more details plz see '\$KAFKA_HOME/logs/start.out >&2;
        exit 1;
      fi;
      "
    done
    break 2
    ;;
  stop)
    stop_check_before
    if [[ $? == 1 ]]; then
      action 'the format of args you input is illegal.. ' false
      usage
      RETVAL=1
      break 2
    fi
    for b in $broker_list; do
      echo "[BROKER:$b]"
      ssh -n root@$b "
      [[ ! -d \$KAFKA_HOME ]] && echo '未配置kafka的环境变量' >&2 && exit 1;
      [[ -d \$KAFKA_HOME/logs ]] || mkdir -p \$KAFKA_HOME/logs;
      if \$KAFKA_HOME/bin/kafka-server-stop.sh >> \$KAFKA_HOME/logs/stop.out 2>&1; then
        echo 'stop successfully';
        exit 0;
      else
        echo 'stop in failure, and to acquire more details plz see '\$KAFKA_HOME/logs/stop.out >&2;
        exit 1;
      fi;
      "
    done
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
