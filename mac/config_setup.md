#### 安装homebrew（一个软件包管理工具，类似yum，apt）
* 在命令行输入安装
    ```shell script
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    ```

#### 安装git
* 通过brew安装
    ```shell script
    brew install git
    ```
#### 安装oh my zsh
* 由于mac系统自带的terminal功能简陋，使用基于zsh的terminal包装
* 安装（注意系统上需要先安装git）
    1. 通过curl
        ```shell script
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        ```
    2. 通过wget
        ```shell script
        sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        ```
   * 安装完后就可以使用oh my zsh了（原来的terminal就被替换了）
* 修改PATH
    * 是安装完oh my zsh后，对path的修改由原来的.bash_profile文件->.zshrc文件，
        通过修改.zshrc文件下的PATH环境变量然后保存再  . .zshrc即可
