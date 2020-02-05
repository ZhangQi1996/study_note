javap -c xxxx.class ls
其中-c是反编译xxxx.class文件
若要将反编译的数据放到文件可以
* javap -c xxx.class | cat > xxx.txt 将内容覆盖到xxx.txt
* javap -c xxx.class | tee xxx.txt 将输入写入文件xxx.txt
