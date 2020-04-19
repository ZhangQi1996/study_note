#### git基础
* 文件的三种状态
    1. 已修改(modified/modified，工作区)
        * 当暂存区/对象库中的文件修改后->工作区(modified)
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
            2. 修改上一次的msg
                * git commit --amend -m "yyy"
            2. 以另一身份提交上一次的信息
                * git commit --amend --reset-author
        * git checkout
            * git checkout -- <file>...
                * 将那些已经修改的文件，丢弃修改，即丢弃所有位于暂存区的先前修改
            * git checkout -f
                * 丢弃所有的暂存区的修改,恢复到
        * git rm
            * git rm <file>...
                * 将文件从工作树目录（对象库）中删除（真实目录中也会删除这个文件），使用git commit提交这个删除
                    (此时这个删除处于暂存区)
                * 可以使用git restore --staged|-S <file>...
                    * 将位于暂存区中处于删除状态的文件->位于工作区处于删除状态的文件
            * git rm --cached <file>...
                * 当file已经通过git add，当想把文件从暂存区->工作区，就执行这个命令(仅用于add)
        * git reset <index> <file>...
            * 将当前git工作树目录恢复到index版本状态，将处于暂存区中的改变file...文件移至工作区
        * git mv <file1> <file2>
            * 移动/重命名文件
            * 一个放置在暂存区中的操作
            * 等价于2个动作
                1. mv file1 file2
                2. git add file1 file2
            * 恢复
                ```shell script
                git restore -S file1 file2 & git restore -W file1 & rm -f file2
                ```
        ```
        # 示例1. 工作区中存在新增的文件2.txt, 暂存区中存在已被删除文件1.txt，恢复被删除的文件1.txt
        1. git checkout -f        
        2. git reset HEAD 1.txt/git restore --staged 1.txt  && # 前一步骤用于staged->unstaged
            git checkout -- 1.txt/git restore \[-W|--worktree\] 1.txt # 后一骤用于从unstage状态恢复
        
        ```
        * **总结**
            1. 恢复索引index（也就是版本库的版本位置，指的是将当前位于暂存区（staged）的内容全部恢复移至工作区（worktree，unstaged））
                * 常见恢复index的操作
                1. git restore --staged|-S <file>...
                2. git reset <index> <file>...
                3. git rm --cached <file>...
                    * 注：这个恢复操作只支持add操作之后从staged->unstaged
            2. 恢复工作区(worktree, 也是从处于工作区的修改恢复至先前状态)
                1. git restore \[--worktree|-W\] <file>...
                2. git checkout -- <file>...
            * 直接将位于暂存区的所有文件变为先前版本库状态
                * git checkout -f
            * **注意**对于之前未纳入版本库的位于工作区的文件（比如新增的文件），git是控制不到的。
    3. 查看信息
        * git help
        * git log
            * 查看git提交的日志，同时能看到一个提交的摘要sha1的id值
            * git log -n(n是数字)表示查看前n条log
            * git log --graph: 以图像化的方式查看提交框图
        * git diff
        * git status
            * 查看当前local repo中状态
        * git branch
            * 查看分支
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
    6. .gitignore
        ```gitignore
        # 注意所有的文件或者目录均不能以./开头不然无法识别
        # 要么使用xxx/xxx/yyy或者/xxx/xxx/yyy
       
        # 这的是忽略本repo中所有第一级目录下的1.txt文件
        /*/1.txt
        
        # 这的是忽略本repo中所有第n级目录下的1.txt文件(n=1,2,...) 
        /**/1.txt
       
        # 忽略除a.b文件之外的所有以.b结尾的文件
        *.b
        !a.b
        ```
    
        
                