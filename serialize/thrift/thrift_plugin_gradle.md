#### Thrift Plugin for Gradle
* https://github.com/jruyi/thrift-gradle-plugin
* 本插件用于编译项目中的*.proto文件，插件的编译过程由：
    1. 装配protoc的命令行以及使用它来编译那些.proto文件从而生成java源文件
    2. 它会将生成好的java源文件添加到你项目中的sourceSet（也就是java编译单元中，e.g. src下）中
* 使用的依赖
    ```groovy
    // build.gradle
    
    // groovy-based DSL
    // the order of the plugins doesn't matter
    plugins {
      id "com.google.protobuf" version "0.8.12"
      id "java"
    }
    // apply-method-based
    /*
    apply plugin: 'java'
    apply plugin: 'com.google.protobuf'
    */
    
    // customizing source dirs containing *.proto files
    sourceSets {
      main {
        proto {
          srcDir 'src/main/protobuf'
        }
        // e.g. java {...}  
      }
      test {
        proto {
          srcDir 'src/test/protobuf'
        }
      }
    }
  
    // customize protobuf compilation
    // protobuf plugin provides protobuf block
    protobuf {
        // Configure the protoc executable
        protoc {
        // Download from repositories
        artifact = 'com.google.protobuf:protoc:3.0.0'
        // path = '/usr/local/bin/protoc' // config local protoc exe
        }

        // Locate the codegen plugins (use protoc to compile .proto) 
        plugins {
            // Locate a plugin with name 'grpc'. This step is optional.
            // If you don't locate it, protoc will try to use "protoc-gen-grpc" from
            // system search path.
            grpc {
                artifact = 'io.grpc:protoc-gen-grpc-java:1.0.0-pre2'
                // or specify local protoc-gen plugin
                // path = 'tools/protoc-gen-grpc-java'
            }
              /*
              By default generated Java files are under $generatedFilesBaseDir/$sourceSet/$builtinPluginName, 
              where $generatedFilesBaseDir is $buildDir/generated/source/proto by default
               */
             generatedFilesBaseDir = "$projectDir/src"
            // specify gen task
             generateProtoTasks {
                 all()*.plugins {
                      // 当使用proto2的时候后面的grpc block可以省略
                     grpc {
                        // Write the generated grpc files(service) under
                        // "$generatedFilesBaseDir/$sourceSet/grpcjava", default 'grpc'
                         outputSubDir = "java"
                     }
                 }
             }
        }
    }
    ```
    * 生成的java文件在build/generated/source下查找，**注意及时将在build中生成的文件剪切到
        src目录中**
    * 由于build默认就是自带编译proto文件的，所以通过执行以下完成不执行proto编译
        ```shell script
        ./gradlew build -x generateProto
        ```