#### 建立基于gradle构建的scala项目
1. 在idea中建立基于java的gradle项目
2. 将src与test目录下的java文件夹删除
3. 在build.gradle中
    ```
    plugins {
        id 'scala'
    }
    
    group 'com.zq'
    version '1.0-SNAPSHOT'
    
    sourceCompatibility = 1.8
    
    repositories {
        mavenLocal()
        maven { url 'http://maven.aliyun.com/nexus/content/groups/public/' }
        maven { url 'http://maven.aliyun.com/nexus/content/repositories/jcenter'}
        mavenCentral()
    }
    
    dependencies {
        testCompile group: 'junit', name: 'junit', version: '4.12'
        // https://mvnrepository.com/artifact/org.scala-lang/scala-library
        compile group: 'org.scala-lang', name: 'scala-library', version: '2.12.10'
    }
    ```