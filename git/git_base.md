#### git基础
* 文件的三种状态
    1. 已修改(modified，工作区)
    2. 已暂存(staged，暂存区)
    3. 已提交(committed，对象库)
* git常用命令
    1. 获得版本
        * git init
        * git clone
    2. 版本管理
        * git add
        * git commit
            1. 提交所有位于暂存区的文件
                * git commit -m "xxx"
            2. 以另一身份提交信息
                * git commit --amend --reset-author
        * git checkout
            * git checkout -- <file>...
                * 将那些已经修改的文件，丢弃修改
            * git checkout -f
                * 丢弃所有的修改
        * git rm
            * git rm -cache <file>...
                * 当file已经通过git add，当想把文件从暂存区->工作区，就执行这个命令
    3. 查看信息
        * git help
        * git log
            * 查看git提交的日志，同时能看到一个提交的摘要sha1的id值
        * git diff
        * git status
            * 查看当前local repo中状态
    4. 远程协作
        * git pull
        * git push
    5. repo配置
        * git config
            1. 配置当前host的git的全局用户名以及邮箱（位于/etc/gitconfig）
                * git config --system user.name "abc"
                * git config --system user.email abc@gmail.com
            2. (常用)配置当前host用户git的全局用户名以及邮箱（位于~/.gitconfig）
                * git config --global user.name "abc"
                * git config --global user.email abc@gmail.com
            3. (常用)配置当前git repo的用户名以及邮箱（位于.git/config）
                * git config --local user.name "abc"
                * git config --local user.email abc@gmail.com
            * 删除某个/全部config的配置
                * git config \[--local/global/system\] --unset/unset-all <variable>
                