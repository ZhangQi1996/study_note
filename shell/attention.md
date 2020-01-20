* 由于ubuntu的shell默认使用的是dash，故在sh文件最开始添加#!/bin/bash
    * 若还是无用1. ./xxx.sh  2. bash xxx.sh
* 若在yum中已经预装了某软件但是用不了，可以通过yum reinstall -y xxx 来解决问题
* 使用管道符 | 的方法相当于启动了一个独立的子进程，因此循环中的变量FILENUM是属于自进程中的，与循环外的FILENUM虽然同名，但是值却不同。
* 使用重定向 < 的方法则不会有这种现象，在脚本启动时并没有子进程出现，因此循环内部变量FILENUM与循环外的FILENUM变量在同一个bash shell中。