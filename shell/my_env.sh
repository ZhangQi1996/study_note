#!/usr/bin/env bash
# 放置在/etc/profile.d/目录下，用于设置所有用户的环境变量
[[ -z $SYS_PATH ]] && SYS_PATH=$PATH
export SYS_PATH
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.222.b10-1.el7_7.x86_64
export JRE_HOME=${JAVA_HOME}/jre
export CLASS_HOME=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export HADOOP_HOME=/big_data/hadoop-2.7.7
export HIVE_HOME=/apache-hive-2.3.6-bin
export HBASE_HOME=/hbase-2.2.2
export ZOOKEEPER_HOME=/apache-zookeeper-3.5.6-bin
export REDIS_HOME=/usr/local/redis-3.2.12
export PATH=$SYS_PATH:$ZOOKEEPER_HOME/bin:$HBASE_HOME/bin:$HIVE_HOME/bin:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$REDIS_HOME/bin