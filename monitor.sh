#!/bin/bash

#第二行为写入的监控目录信息

#监控本机目录文件的改变，并写入log文件。
 
pwdpath='/mnt'
logpath=$pwdpath'/monitor.log'  #监控日志文件放在当前目录下
 
#只对监控目录中的移动、新建、删除事件进行记录
#对目录中移动，新建，，元数据修改，内容修改，进行监控,然后将数据输入log中
$(inotifywait -mrq -e 'create,moved_to,moved_from,move,attrib,modify,delete' $inopath >> $logpath)
