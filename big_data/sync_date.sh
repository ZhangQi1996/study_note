#!/bin/bash
# chkconfig 2345 80 20
. /etc/init.d/functions

NTPDATE_URL=ntp1.aliyun.com

start() {
  if which ntpdate >/dev/null 2>&1; then
    ntpdate $NTPDATE_URL
    action 'sync date sccessful' true
  else
    action '请先安装ntpdate' false
    exit 1
}

stop() {

}

case $1 in
start)
  start
  ;;
stop)
  stop
  ;;
*)
  cat <<EOF
  Usage: service sync_date stop/start
EOF
  ;;
esac