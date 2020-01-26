#!/usr/bin/env bash
# 本脚本用于操作ZK集群{start|stop|restart|status}
function usage {
  cat << EOF
保证本节点到其他节点的ssh相关配置
默认按照zoo.cfg中按照server.x中先后顺序启动zk
Usage: bash zk_cluster.sh [start|stop|restart|status]
EOF
}

check() {
  if [[ -z $ZOOKEEPER_HOME ]]; then
    echo '请配置环境变量ZOOKEEPER_HOME' >&2
    exit 1
  fi

  if [[ ! -e $ZOOKEEPER_HOME/conf/zoo.cfg ]]; then
    echo 请确保存在$ZOOKEEPER_HOME/conf/zoo.cfg文件 >&2
    exit 1
  fi

  ZK_SERVERS=$(cat $ZOOKEEPER_HOME/conf/zoo.cfg | grep -Ev '^\s*#' | grep -E '^\s*server.[0-9]+=' | sed 's/\s*server.[0-9]\+=//' | sed 's/:.*//')
}

op() {
  if [[ $1 == 'start' ]]; then
    for server in $ZK_SERVERS; do
      echo -n "[$server]"
      ssh -n root@$server "zkServer.sh $1" &
    done
  else
    for server in $ZK_SERVERS; do
      echo -n "[$server]"
      ssh -n root@$server "zkServer.sh $1"
    done
  fi
}

case $1 in
start)
  check
  op start
  ;;
stop)
  check
  op stop
  ;;
restart)
  check
  op restart
  ;;
status)
  check
  op status
  ;;
*)
  usage
  ;;
esac
