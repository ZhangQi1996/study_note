#### 运行
* ~~在spark2.0之前采用SparkConf+SparkContext来运行spark job~~
* 在2.0开始使用SparkSession开进行统一管理，SparkConf、SparkContext和SQLContext都已经被封装在SparkSession当中。
    处理要导入spark-core包，还要导入spark-sql包，由于SparkSession封装在sql包中。
    ```
    val sparkConf = new SparkConf()
      .set(MyConf.SPARK_MASTER_CONF_KEY, MyConf.SPARK_MASTER_CONF_VAL)
      .set(MyConf.SPARK_APPNAME_CONF_KEY, MyConf.SPARK_APPNAME_CONF_VAL)

    var session = SparkSession
      .builder()
      .config(sparkConf)
      .getOrCreate()

    // set new runtime options（不包括master配置等等）
    // session.conf.set("spark.sql.shuffle.partitions", 6)
    // session.conf.set("spark.executor.memory", "2g")

    var sparkContext = session.sparkContext

    val n = 100000
    // 生成0~1之间的double随机数组
    val doubleRandArray = new Array[(Double, Double)](n).map(_ => (Math.random(), Math.random()))

    val m = sparkContext.parallelize(doubleRandArray, 10).map(tp =>
      if (tp._1 * tp._1 + tp._2 * tp._2 <= 1) 1 else 0).reduce(Integer.sum)
    println(s"PI is equal roundly to ${4D * m / n}")
    session.stop()
    ```
    
