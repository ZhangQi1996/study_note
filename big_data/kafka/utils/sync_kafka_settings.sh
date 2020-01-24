#!/bin/bash
#!/usr/bin/env bash
# 本脚本用于同步KAFKA集群中的一些常见配置文件
function usage() {
	cat <<EOF
保证本节点到其他节点的ssh相关配置
Usage: bash sync_kafka_settings.sh <-f svrs_file | -e svrs_pair> [-b broker_id-begin-num] [-h]
Tips:
  [OPT]-f svrs_file: the file lists all the hostname that will be synced, and notes will be ignored.
  [OPT]-e svrs_pair: just like 'hosts1,host2', kafka server on these hosts will be synced.
  [OPT]-b broker_id-begin-num: 0 in default
  [OPT]-h it will set $(hostname) to (advertised.)?listeners in server.properties on target machine if -h is provided.
      e.g.   (advertised.)?listeners=PROTO://$(hostname):PORT
      else just be set by the host provided
  PS: the broker id will begin from zero and increase one by one in these host provided in order, and
      the content synced according to the content existing in the host executing this script.
  ATTENTION: usually, svrs_pair and svrs_file should include this host executing this script.
EOF
}

(( $# == 0 )) && usage && exit 0

if [[ -z $KAFKA_HOME ]]; then
	echo 'ERROR:请配置环境变量KAFKA_HOME' >&2
	exit 1
fi

# 全体参数的列表
args=$@

# 需要同步的目录
sync_arr=(
	$KAFKA_HOME/config/server.properties
)

# 同步到目标主机的路径，当目标主机的路径不一致时，需要修改
target_arr=(
	$KAFKA_HOME/config/server.properties
)

svrs=
hostname='$(hostname)'
_h=false
broker_id=0

while (($# > 0)); do
  case $1 in
  -f)
    [[ $# < 2 ]] && echo 'the format of args provided is illegal, plz see the help.' >&2 && exit 1
    [[ ! -f $2 ]] && echo 'the opt of -f should provide a svrs_file. to get more details plz see the help.' >&2 && exit 1
    svrs=$(cat $2 | grep -Ev '^\s*#|^\s*$' | sed 's/#.*//' | xargs)
    shift 2
    ;;
  -e)
    [[ $# < 2 ]] && echo 'the format of args provided is illegal, plz see the help.' >&2 && exit 1
    svrs=$(echo $2 | tr ',' ' ' | xargs)
    shift 2
    ;;
  -b)
    [[ $# < 2 || ! $2 =~ ^([0-9]|[1-9][0-9]+)$ ]] && echo 'the format of args provided is illegal, plz see the help.' >&2 && exit 1
    broker_id=$2
    shift 2
    ;;
  -h)
    _h=true
    shift
    ;;
  help)
    usage
    exit 0
    ;;
  *)
    usage
    exit 1
    ;;
  esac
done

[[ -z $svrs ]] && echo 'any hosts are not provided, plz see the help to get more details.' >&2 && exit 1

# 同步更新broker.id与(advertised.)?listeners中的host
update_broker_id_and_host_cmd() {
  cat << EOF
    [[ ! -d \$KAFKA_HOME ]] && 'ERROR:请配置环境变量KAFKA_HOME' >&2 && exit 1;
    sed -i 's/\(broker.id\).*/\1=$1/' \$KAFKA_HOME/config/server.properties;
    sed -i "s/\(\(advertised.\)\?listeners\s*=\s*[a-zA-Z_\-]\+:\/\/\)[a-zA-Z_\-]\+\(:[0-9]\+\)/\1$hostname\3/" \$KAFKA_HOME/config/server.properties;
    exit;
EOF
}

for svr in $svrs; do
	# 同步
	for ((i=0; i<${#sync_arr[@]}; i++)); do
	  $_h || hostname=$svr
		scp ${sync_arr[$i]} root@$svr:${target_arr[$i]} >/dev/null && ssh -n root@$svr $(update_broker_id_and_host_cmd $broker_id)
		if (($? == 0)); then
			echo "已经完成同步:本主机${sync_arr[$i]}--->root@$svr:${target_arr[$i]}，且其server的broker_id=$broker_id"
		else
			echo "本主机${sync_arr[$i]}--->root@$svr:${target_arr[$i]}的同步异常!" >&2
			echo "请检查本主机到root@$svr的防火墙设置以及ssh连接配置!" >&2
			exit 1 # 异常退出
		fi
		((broker_id++))
	done
done

if (($? == 0)); then
  echo 同步完毕!
  exit 0
else
  echo 同步失败! >&2
  exit 1
fi
