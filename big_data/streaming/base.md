* 基本形式
    * hadoop jar hadoop-streaming-*.jar [genericOptions] [streamingOptions]
    * genericOptions
    ```
    Parameter	Optional/Required	Description
    -conf 配置文件	Optional	Specify an application configuration file
    -D property=value	Optional	Use value for given property
    -fs host:port or local	Optional	Specify a namenode
    -files	Optional	Specify comma-separated files to be copied to the Map/Reduce cluster
    -libjars	Optional	Specify comma-separated jar files to include in the classpath
    -archives	Optional	Specify comma-separated archives to be unarchived on the compute machines
    
    ```
    * streamingOptions
    ```
    Parameter	Optional/Required	Description
    -input directoryname or filename	Required	Input location for mapper
    -output directoryname	Required	Output location for reducer
    -mapper executable or JavaClassName	Required	Mapper executable
    -reducer executable or JavaClassName	Required	Reducer executable
    -file filename	Optional	Make the mapper, reducer, or combiner executable available locally on the compute nodes
    -inputformat JavaClassName	Optional	Class you supply should return key/value pairs of Text class. If not specified, TextInputFormat is used as the default
    -outputformat JavaClassName	Optional	Class you supply should take key/value pairs of Text class. If not specified, TextOutputformat is used as the default
    -partitioner JavaClassName	Optional	Class that determines which reduce a key is sent to
    -combiner streamingCommand or JavaClassName	Optional	Combiner executable for map output
    -cmdenv name=value	Optional	Pass environment variable to streaming commands
    -inputreader	Optional	For backwards-compatibility: specifies a record reader class (instead of an input format class)
    -verbose	Optional	Verbose output
    -lazyOutput	Optional	Create output lazily. For example, if the output format is based on FileOutputFormat, the output file is created only on the first call to Context.write
    -numReduceTasks	Optional	Specify the number of reducers
    -mapdebug	Optional	Script to call when map task fails
    -reducedebug	Optional	Script to call when reduce task fails
    ```
    * 注意：executable（可执行文件），若在集群MR中要使用到这些，需要在-file进行导入
    ```
    // e.g.1
    hadoop jar hadoop-streaming-2.7.7.jar \
     -input myInputDirs \
     -output myOutputDir \
     -inputformat org.apache.hadoop.mapred.KeyValueTextInputFormat \
     -mapper org.apache.hadoop.mapred.lib.IdentityMapper \
     -reducer /usr/bin/wc
    
    // e.g.2
    hadoop jar hadoop-streaming-2.7.7.jar \
      -input myInputDirs \
      -output myOutputDir \
      -mapper myPythonScript.py \
      -reducer /usr/bin/wc \
      -file myPythonScript.py \
      -file myDictionary.txt
  
    // e.g.3
    // add other plugins
    -inputformat JavaClassName
    -outputformat JavaClassName
    -partitioner JavaClassName
    -combiner streamingCommand or JavaClassName
    
    // e.g.4
    // set a env var
    -cmdenv EXAMPLE_DIR=/home/example/dictionaries/
    ```