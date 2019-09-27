### web层次结构
* parent
    * dao
    * service
    * web

* 先建立一个gradle项目
* 在该（parent）项目的gradle的build配置文件中配置
```
// parent_gradle_proj/build.gradle
allprojects { // 使得所有项目均有如下配置
    plugins {
        id 'java'
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
        compile group: 'com.google.code.gson', name: 'gson', version: '2.8.5'
    }
}
```
* 由于在parent一级中配置了全局的依赖信息，故3个子模块的build.gradle文件内容可以先清空
* 由于dao，service均为jar包的打包方式，而在web模块中，其应该打包成war包。而在全局配置中配置的全部都是打包成jar包的方式
* 故在web的空build.gradle文件中写入
```
plugins {
    id 'war'
}
```
* 由于包的依赖关系为dao->service->web, 故在service与dao的build.gradle配置文件要追加
```
// 在service的build.gradle追加
dependencies {
    compile project(":定义的dao模块的architectid名")
}
// 在web的build.gradle追加
dependencies {
    compile project(":定义的service模块的architectid名")
}
```
* 在web/src/main/下新建webapp目录
* 在webapp目录下放置WEB-INF文件夹（webapp下的结构参照普通的mvn项目下的结构）
* 将配置文件均放置在web/src/main/resources目录下