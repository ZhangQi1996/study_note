#!/bin/bash
# chkconfig: 2345 80 20
. /etc/init.d/functions

NTPDATE_URL=ntp1.aliyun.com

start() {
  if which ntpdate >/dev/null 2>&1; then
    ntpdate $NTPDATE_URL
    action 'sync date sccessful' true
  else
    action '请先安装ntpdate' false
    exit 1
  fi
}

stop() {
  return 0
}

RETVAL=0
case $1 in
start)
  start || action 'start sync_date in failure..' false || RETVAL=1
  ;;
stop)
  stop
  ;;
*)
  cat <<EOF
  Usage: service sync_date stop/start
EOF
  RETVAL=1
  ;;
esac
exit $RETVAL