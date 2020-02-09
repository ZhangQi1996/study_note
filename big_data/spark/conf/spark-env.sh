#!/usr/bin/env bash

# Options read when launching programs locally with
# ./bin/run-example or ./bin/spark-submit
# Ensure that HADOOP_CONF_DIR or YARN_CONF_DIR points to
# the directory which contains the (client side) configuration files for the Hadoop cluster.
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export SPARK_LOCAL_IP=local
# - SPARK_PUBLIC_DNS, to set the public dns name of the driver program

# Options read by executors and drivers running inside the cluster
# - SPARK_LOCAL_IP, to set the IP address Spark binds to on this node
# - SPARK_PUBLIC_DNS, to set the public DNS name of the driver program
export SPARK_LOCAL_DIRS=/var/spark/data
# - MESOS_NATIVE_JAVA_LIBRARY, to point to your libmesos.so if you use Mesos

# Options read in YARN client/cluster mode
# - SPARK_CONF_DIR, Alternate conf dir. (Default: ${SPARK_HOME}/conf)
# - HADOOP_CONF_DIR, to point Spark towards Hadoop configuration files

# Ensure that HADOOP_CONF_DIR or YARN_CONF_DIR points to
# the directory which contains the (client side) configuration files for the Hadoop cluster.
export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop
# - SPARK_EXECUTOR_CORES, Number of cores for the executors (Default: 1).
export SPARK_EXECUTOR_MEMORY=640M
export SPARK_DRIVER_MEMORY=512M

# Options for the daemons used in the standalone deploy mode
export SPARK_MASTER_HOST=master
# SPARK_MASTER_PORT / SPARK_MASTER_WEBUI_PORT
export SPARK_WORKER_CORES=1
# 当启动的是standalone cluster模式的时候driver放置于worker内
export SPARK_WORKER_MEMORY=1408M
# - SPARK_WORKER_PORT / SPARK_WORKER_WEBUI_PORT, to use non-default ports for the worker
export SPARK_WORKER_DIR=/var/spark/worker
export SPARK_DAEMON_MEMORY=512M
export SPARK_DAEMON_JAVA_OPTS="-XX:+UseSerialGC"
# export SPARK_DAEMON_CLASSPATH=$(hadoop classpath) # 引入hadoop cp可能会造成老的jar引入导致类方法冲突/不存在等
# - SPARK_PUBLIC_DNS, to set the public dns name of the master or workers

# Generic options for the daemons used in the standalone deploy mode
# - SPARK_CONF_DIR      Alternate conf dir. (Default: ${SPARK_HOME}/conf)
# - SPARK_LOG_DIR       Where log files are stored.  (Default: ${SPARK_HOME}/logs)
export SPARK_PID_DIR=/var/run
# - SPARK_IDENT_STRING  A string representing this instance of spark. (Default: $USER)
# - SPARK_NICENESS      The scheduling priority for daemons. (Default: 0)
# - SPARK_NO_DAEMONIZE  Run the proposed command in the foreground. It will not output a PID file.
# Options for native BLAS, like Intel MKL, OpenBLAS, and so on.
# You might get better performance to enable these options if using native BLAS (see SPARK-21305).
# - MKL_NUM_THREADS=1        Disable multi-threading of Intel MKL
# - OPENBLAS_NUM_THREADS=1   Disable multi-threading of OpenBLAS

# 配置hadoop原生相关库
export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native:$JAVA_HOME/lib/amd64
