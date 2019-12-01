#!/usr/bin/env bash
# 本脚本用于将HMaster主机上的hbase目录复制到所有RegionServers主机中
function usage {
  cat << EOF
保证本节点到其他节点的ssh相关配置
Usage: bash cp_hm2rss.sh [ignore_host ...]
Tips: ignore_hosts will not be synced..
EOF
}

usage

if [[ -z $HBASE_HOME ]]; then
	echo '请配置环境变量HBASE_HOME' >&2
	exit 1
fi

# 全体参数的列表
args=$@

if [[ $HBASE_HOME =~ .*/$ ]]; then
	HBASE_HOME=${HBASE_HOME:0:${#HBASE_HOME}-1} # 去除末尾的/
fi

# 复制到目标主机的路径，当目标主机的路径不一致时，需要修改
# 默认master与rss上的路径一致
target_dir=${HBASE_HOME%/*}
if [[ -z $target_dir ]]; then
	target_dir=/
fi

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

RSS_FILE_PATH=$HBASE_HOME/conf/regionservers

# rss文件中那些存在于ignore_hosts的主机忽略同步
for rs in $(cat $RSS_FILE_PATH | xargs); do
	isExistInIgnoreHosts $rs
	if (($? == 1)); then
		echo 已经忽略$rs的同步
		continue # 存在就忽略
	fi
	echo "正在将目录$HBASE_HOME 复制到root@$rs:$target_dir目录下"
	# 复制
	scp -r $HBASE_HOME root@$rs:$target_dir 2>/dev/null >&2
	if (($? == 0)); then
		echo "已经完成同步:本主机$HBASE_HOME--->root@$rs:$target_dir"

	else
		echo "本主机$HBASE_HOME--->root@$rs:$target_dir 的同步异常!" >&2
		echo "请检查本主机到root@$rs 的防火墙设置以及ssh连接配置!" >&2
		exit 1 # 异常退出
	fi
done

if (($? == 0)); then
  echo 复制完毕!
  exit 0
else
  echo 复制失败! >&2
  exit 1
fi
