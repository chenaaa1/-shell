#!/bin/bash

if [ -z "$(rpm -qa | grep expect)" ]
then
	echo "此处写入下载expect的命令";
        yum -y install tcl
        yum -y install expect 
        # 未安装成功的话请自行更换源
	if [ -z "$(rpm -qa | grep expect)" ]
        then
                echo "安装失败，请自行更换源重新安装expect!"
        else
                echo "expect包安装成功!"
        fi          
else
	echo "expect包已安装!";
fi


if [ -z "$(rpm -qa | grep inotify-tools)" ]
then
        echo "开始下载inotify-tools";
        mv -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo_bak
        wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
        yum clean all
        yum makecache

        
        /usr/bin/expect <<EOF
        set timeout -1
        spawn yum install epel-release 
        expect {
        "*y/d/N*" { send "y\r"; exp_continue}
        }
        expect eof
EOF
        # yum search inotify-tools
	# yum info inotify-tools
	/usr/bin/expect <<EOF
        set timeout -1
        spawn yum install inotify-tools 
        expect {
        "*ok*" { send "y\r"; exp_continue}
        "*y/N*" { send "y\r"; }
        }
        expect eof
EOF
        # 未安装成功的话请自行更换源
	if [ -z "$(rpm -qa | grep inotify-tools)" ]   
        then
                echo "安装失败，请自行更换源重新安装inotify-tools!"
        else
                echo "inotify-tools包安装成功!"
        fi    

else
        echo "inotify-tools包已安装!";
fi

