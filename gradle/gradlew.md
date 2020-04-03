#### gradlew (gradle wrapper)
* 使用情形
    * 不需要本地安装gradle并配置path，对于gradle项目，直接通过直接通过执行gradlew的脚本
        来直接实现gradle的本地项目化以及相关依赖的下载，同时对于执行类似的gradle命令，
        则通过./gradlew <cmd>的方式来间接执行。
    * 主要是对第三方无gradle安装，以及解决对gradle版本要求的问题
* gradlew的生成
    * 对于没有gradlew的gradle项目（即通过本地的gradle创建的项目），通过执行gradle wrapper命令
        就会生成gradle文件夹与gradlew与gradlew.bat文件
    1. gradle文件夹（必须放入版本库中的）
        1. wrapper文件夹
            1. gradle-wrapper.jar
                * 里面存放着gradlew脚本/批处理文件所需的jar包
            2. gradle-wrapper.properties
                * 用于gradle-wrapper.jar的读取
                1. distributionUrl=https\://services.gradle.org/distributions/gradle-5.2.1-all.zip
                    * 指的是当执行gradlew的关于构建的脚本命令时就会从这网址下载所需的gradle压缩包
                2. distributionBase=GRADLE_USER_HOME
                    * 指的是~/.gradle目录
                3. distributionPath=wrapper/dists
                    * 指的就是~/.gradle/wrapper/dists
                4. zipStorePath=wrapper/dists
                    * 指的就是~/.gradle/wrapper/dists
                    * 用于存放下载的gradle解压后的
                5. zipStoreBase=GRADLE_USER_HOME
                    * 指的是~/.gradle目录
    2. gradlew/gradlew.bat文件(也必须放入版本库中的)
        * 当使用gradlew的脚本命令时（比如build），会通过执行gradle-wrapper.properties中所指向的
            gradle-x.x.x/bin/gradle的命令