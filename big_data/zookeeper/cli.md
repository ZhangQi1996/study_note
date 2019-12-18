#### 通过键入zkCli.sh进入zk的shell环境
* 在shell环境下
    * **注意目录均是绝对路径**
    * 键入help查看帮助
    * 创建节点(可以理解为目录，但是这个**节点是可以带数据的**，而且可以拥有子节点)
        * create [-s|e] node_path [data]
            * -e 创建临时节点
            * -s 创建带编号的节点
                * 这种形式可以创建同名的节点但是最终zk会给这个节点带一个递增的后缀戳
                * 为了解决一个zk上运行多种不同的集群而勋在大家创建同名的节点
    * ls [-s|w|R] node_path
        * 查看节点目录结构（不带数据）
        * -s 查看节点的详细事务信息（不带数据）
        * ls -w path等价于ls path 查看该节点的子目录（节点）
        * -R 递归
    * get [-s|w] node_path 查看node所携带的数据
        * -s 详细事务
    * set [-s|-v version] node_path new_val 给节点赋予一个新值
    
        