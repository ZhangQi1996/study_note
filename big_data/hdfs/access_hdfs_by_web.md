## 在hdfs-site.xml修改配置
```
<property>
    <name>dfs.webhdfs.enabled</name>
    <value>true</value>
    <description>使得可以通过http方式访问HDFS</description>
</property>
```