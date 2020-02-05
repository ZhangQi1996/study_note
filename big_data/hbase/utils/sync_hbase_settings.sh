#!/bin/bash
# 本脚本用于同步STORM集群中的一些常见配置文件
function usage() {
	cat <<EOF
保证本节点到其他节点的ssh相关配置
Usage: bash sync_hbase_settings.sh [-i ignore_hosts] [-e sync_hosts] [-h|--help]
Tips: ignore_hosts will not be synced
EOF
}

. /etc/init.d/functions

[[ -d $HBASE_HOME ]] || action '请配置环境变量HBASE_HOME' false || exit 1
[[ -f $HBASE_HOME/conf/regionservers ]] || action "$HBASE_HOME/conf/regionservers文件不存在" false || exit 1

RETVAL=0
ignore_hosts=
sync_hosts=$(cat $HBASE_HOME/conf/regionservers | grep -Ev '^\s*#|^\s*$' | sed 's/#.*//' | xargs)

# 需要同步的目录
sync_arr=(
	$HBASE_HOME/conf/hbase-env.sh
	$HBASE_HOME/conf/hbase-site.xml
)

# 同步到目标主机的路径，当目标主机的路径不一致时，需要修改
target_arr=(
	$HBASE_HOME/conf/hbase-env.sh
	$HBASE_HOME/conf/hbase-site.xml
)

function isExistInIgnoreHosts() {
	if [[ -z $ignore_hosts ]]; then
		return 1
	fi
	for i in $ignore_hosts; do
		if [[ $i == $1 ]]; then
			return 0
		fi
	done
	return 1
}

while (($# > 0)); do
  case $1 in
  -i)
    [[ -n $2 ]] || action 'opts format is wrong..' false || exit 1
    ignore_hosts=$(echo $2 | tr ',' ' ' | xargs)
    shift 2
    ;;
  -e)
    [[ -n $2 ]] || action 'opts format is wrong..' false || exit 1
    sync_hosts=$(echo $2 | tr ',' ' ' | xargs)
    shift 2
    ;;
  -h|--help)
    usage
    shift
    ;;
  *)
    usage
    exit 1;
    ;;
  esac
done

for host in $sync_hosts; do
	if isExistInIgnoreHosts $host; then
		echo 已经忽略$host的同步
		continue # 存在就忽略
	fi
	# 同步
	for ((i = 0; i < ${#sync_arr[@]}; i++)); do
		if scp ${sync_arr[$i]} root@$host:${target_arr[$i]} 2>/dev/null >&2; then
		  echo "已经完成同步:本主机${sync_arr[$i]}--->root@$host:${target_arr[$i]}"
		else
			echo "本主机${sync_arr[$i]}--->root@$host:${target_arr[$i]}的同步异常!" >&2
			echo "请检查本主机到root@$host的防火墙设置以及ssh连接配置!" >&2
			RETVAL=1
			break
		fi
	done
done

(($RETVAL == 0)) && echo 同步完毕! && exit 0
echo 同步失败! >&2
exit 1
