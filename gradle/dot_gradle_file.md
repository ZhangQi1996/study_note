* gradle工程所有的jar包坐标均在dependencies属性内放置
```$xslt
dependencies {
    testCompile group: 'junit', name: 'junit', version: '4.12'
}
```
* 每一个jar包的坐标都有三个基本元素组成
* group, name, version
* testCompile 表示该包在测试的时候起作用，该属性为jar包的作用域
* 我们在gradle里面添加坐标的时候都要带上jar包的作用域
`sourceCompatibility = 1.8`
* sourceCompatibility是指java版本
```$xslt
repositories {
    // 表明指定的仓库为中央仓库
    mavenCentral()
}
```
* 比如获取gson的gradle依赖
```
dependencies {
    testCompile group: 'junit', name: 'junit', version: '4.12'
    // 添加一个gradle依赖
    compile group: 'com.google.code.gson', name: 'gson', version: '2.8.5'
}
```
* 使得gradle先加载本地的maven仓库中的jar包，没有则区远程仓库pull
```
repositories {
    mavenLocal() // find some jars in the local mvn repo
    maven { url 'http://maven.aliyun.com/nexus/content/groups/public/' }
    maven { url 'http://maven.aliyun.com/nexus/content/repositories/jcenter'}
    mavenCentral() // otherwise, pull the spec jars from a remote mvn repo
}
```
