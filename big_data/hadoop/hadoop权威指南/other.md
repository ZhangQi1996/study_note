### 一些hadoop杂七杂八的补充
* 获取$HADOOP_CLASSPATH
    * 执行hadoop classpath
* 外部**配置本机**的全局$HADOOP_CLASSPATH
    * 执行export HADOOP_CLASSPATH=<new-env-var-conf>${HADOOP_CLASSPATH:+:$HADOOP_CLASSPATH}
    * 由于在hadoop-env.sh中配置为export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$f
