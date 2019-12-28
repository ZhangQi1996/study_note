#!/usr/bin/env bash
# 本脚本用于同步ZK集群中的一些常见配置文件
function usage {
  cat << EOF
保证本节点到其他节点的ssh相关配置
默认myid按照zoo.cfg中按照server.x中先后顺序从1开始指定
Usage: bash sync_zk_settings.sh [-h hosts-pairs] [-i ignore_host-pairs] [-n]
Tips: -h hosts-pairs will be used, and donnot extract hosts from zoo.cfg..(default: extract from zoo.cfg)
      -i ignore_hosts-pairs just like 'host1,host2' will not be synced..(default: no hosts will be ignored)
      -n means myid will not be set...
EOF
}

usage

if [[ -z $ZOOKEEPER_HOME ]]; then
	echo '请配置环境变量ZOOKEEPER_HOME' >&2
	exit 1
fi

# ignore_hosts的列表
args=

# 是否设置myid
is_set_myid=true

if [[ ! -e $ZOOKEEPER_HOME/conf/zoo.cfg ]]; then
	echo 请确保存在$ZOOKEEPER_HOME/conf/zoo.cfg文件 >&2
	exit 1
fi

ZK_SERVERS=$(cat $ZOOKEEPER_HOME/conf/zoo.cfg | grep -Ev '^\s*#' | grep -E '^\s*server.[0-9]+=' | sed 's/\s*server.[0-9]\+=//' | sed 's/:.*//')
ZK_DATADIR=$(cat $ZOOKEEPER_HOME/conf/zoo.cfg | grep -Ev '^\s*#' | grep -E '^\s*dataDir=' | sed 's/\s*dataDir=//')

while [[ $# > 0 ]]; do
  case $1 in
  -h)
    [[ -z $2 ]] && echo '-i 后未带参数' >&2 && exit 1
    ZK_SERVERS=$(echo -n $2 | tr ',' ' ')
    shift 2
    ;;
  -i)
    [[ -z $2 ]] && echo '-i 后未带参数' >&2 && exit 1
    args=$(echo -n $2 | tr ',' ' ')
    shift 2
    ;;
  -n)
    is_set_myid=false
    shift
    ;;
  *)
    usage
    exit 1
  esac
done

# 需要同步的目录
sync_arr=(
	$ZOOKEEPER_HOME/conf/zoo.cfg
)

# 同步到目标主机的路径，当目标主机的路径不一致时，需要修改
target_arr=(
	$ZOOKEEPER_HOME/conf/zoo.cfg
)

function isExistInIgnoreHosts() {
	if [[ -z $args ]]; then
		return 0
	fi
	for i in $args; do
		if [[ $i == $1 ]]; then
			return 1
		fi
	done
	return 0
}

[[ -d $ZK_DATADIR ]] || mkdir -p $ZK_DATADIR

c=1
# server.x指定的那些存在于ignore_hosts的主机忽略同步
for learner in $ZK_SERVERS; do
	isExistInIgnoreHosts $learner
	if (($? == 1)); then
		echo 已经忽略$learner的同步
		continue # 存在就忽略
	fi
	# 同步
	for ((i = 0; i < ${#sync_arr[@]}; i++)); do
		scp ${sync_arr[$i]} root@$learner:${target_arr[$i]} 2>/dev/null >&2
		if (($? == 0)); then
			echo "已经完成同步:本主机${sync_arr[$i]}--->root@$learner:${target_arr[$i]}"
      $is_set_myid && ssh -n root@$learner "echo $c > $ZK_DATADIR/myid; exit" && echo "[root@$learner]$c--->$ZK_DATADIR/myid"
      ((c++))
		else
			echo "本主机${sync_arr[$i]}--->root@$learner:${target_arr[$i]}的同步异常!" >&2
			echo "请检查本主机到root@$learner的防火墙设置以及ssh连接配置!" >&2
			exit 1 # 异常退出
		fi
	done
done

if (($? == 0)); then
  echo 同步完毕!
  exit 0
else
  echo 同步失败! >&2
  exit 1
fi