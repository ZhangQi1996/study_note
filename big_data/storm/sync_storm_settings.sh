#!/usr/bin/env bash
# 本脚本用于同步STORM集群中的一些常见配置文件
function usage() {
	cat <<EOF
保证本节点到其他节点的ssh相关配置
Usage: bash sync_storm_settings.sh [ignore_host ...]
Tips: ignore_hosts will not be synced..
EOF
}

usage

if [[ -z $STORM_HOME ]]; then
	echo '请配置环境变量STORM_HOME' >&2
	exit 1
fi

# 全体参数的列表
args=$@

# 需要同步的目录
sync_arr=(
	$STORM_HOME/conf/storm.yaml
	$STORM_HOME/conf/supervisors
)

# 同步到目标主机的路径，当目标主机的路径不一致时，需要修改
target_arr=(
	$STORM_HOME/conf/storm.yaml
	$STORM_HOME/conf/supervisors
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

SLAVES_FILE_PATH=$STORM_HOME/conf/supervisors

# slaves文件中那些存在于ignore_hosts的主机忽略同步
for slave in $(xargs < $SLAVES_FILE_PATH); do
	isExistInIgnoreHosts $slave
	if (($? == 1)); then
		echo 已经忽略$slave的同步
		continue # 存在就忽略
	fi
	# 同步
	for ((i = 0; i < ${#sync_arr[@]}; i++)); do
		scp ${sync_arr[$i]} root@$slave:${target_arr[$i]} 2>/dev/null >&2
		if (($? == 0)); then
			echo "已经完成同步:本主机${sync_arr[$i]}--->root@$slave:${target_arr[$i]}"
		else
			echo "本主机${sync_arr[$i]}--->root@$slave:${target_arr[$i]}的同步异常!" >&2
			echo "请检查本主机到root@$slave的防火墙设置以及ssh连接配置!" >&2
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
