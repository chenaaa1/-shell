#!/bin/bash

# 要传监控脚本和expect脚本才能安装监控脚本所需！

# 你要把文件下载到那个目录？
localPath='/tmp/'
# root密码和ip
password=123456
ip=192.168.1.30
# 监控目录
ads=/mnt/share/

# 把上面的信息填入你需要的即可开始运行测试
#------------------------------------------------------------------


# 把监控目录传入monitor.sh中
sed -i 2iinopath="'$ads'" monitor.sh 


# 检查本机是否安装expect脚本
if [ -z "$(rpm -qa | grep expect)" ]
then
	echo "开始下载expect脚本";
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

# 检查本机是否安装好sshpass服务
if [ -z "$(rpm -qa | grep sshpass)" ]
then
        echo "开始下载sshpass";
        yum -y install sshpass
        # 未安装成功的话请自行更换源
        if [ -z "$(rpm -qa | grep sshpass)" ]
        then
                echo "安装失败，请自行更换源重新安装sshpass!"
        else
                echo "sshpass包安装成功!"
        fi    

else
        echo "sshpass包已安装!";
fi


# 用scp传入监控脚本到/mnt下
/usr/bin/expect <<EOF
        set timeout -1
        spawn scp -r monitor.sh root@$ip:/mnt/
        expect {
        "*yes/no" { send "yes\r"; exp_continue}
        "*password:" {send "$password\r"}
        }
        expect eof
EOF
echo "已传送监控脚本到云服务器"


# 运行服务器上的监控脚本
sshpass -p $password ssh root@$ip << eeooff
sh /mnt/monitor.sh>&out.txt &
# 退出ssh
exit
eeooff
echo "已在服务器上运行监控脚本"


# 删除monitor.sh上的监控目录信息，避免下次使用时会写入错误信息
sed -i '2d' monitor.sh


#------------------------------------以下均用while循环使得程序持续进行
while :
do


# 将monitor.log复制到/tmp下，然后清除日志内容
sshpass -p $password ssh root@$ip > /dev/null 2>&1 << eeooff
# 删除/tmp内原日志
rm -rf /tmp/monitor.log
# 剪切日志
cp /mnt/monitor.log /tmp/monitor.log
cat /dev/null > /mnt/monitor.log
exit
eeooff
echo "已剪切monitor.log文件"

# 复制monitor.log文件到本地
/usr/bin/expect  > /dev/null 2>&1<<EOF
        set timeout -1
        spawn scp -r root@$ip:/tmp/monitor.log /
        expect {
        "*yes/no" { send "yes\r"; exp_continue}
        "*password:" {send "$password\r"}
        }
        expect eof
EOF
echo "已获取到monitor.log文件"


#-------------------------------------------
#将关于删除的日志信息输出到c.log中
cat /monitor.log | grep DELETE >> /c.log

# 将关于删除信息的日志文件去重按序放入b.log
cut -d " " -f 3 /c.log | sort -u >> b.log;

# 将增改信息的日志文件去重按序放入a.log
cut -d " " -f 3 /monitor.log | sort -u >> a.log;

# 计算文件内的行数，用于循环变量大小的设置
I=$(grep -c "" a.log);
J=$(grep -c "" b.log);
# echo "本次共获取到${I}个新文件";



#----------------------------------------------与服务器同步删除操作（先检查删除再检查下载，防止文件被遗漏）------------------------
echo ""
echo ""
echo "开始删除操作"
echo ""
echo ""

for (( j=1;j<=$J;j=$[$j+1] ))
do
        #每次最多获取5个文件，因为无法用for循环创建变量名（因为变量名的命名不能为变量）
        F=$(sed -n ${j}p b.log);
        if [ ! -n "$F" ]; then 
                F=0
        fi 
        j=$[$j+1];

        G=$(sed -n ${j}p b.log);
        if [ ! -n "$G" ]; then 
                G=0
        fi 
        j=$[$j+1];

        H=$(sed -n ${j}p b.log);
        if [ ! -n "$H" ]; then 
                H=0
        fi 
        j=$[$j+1];
        
        K=$(sed -n ${j}p b.log);
        if [ ! -n "$K" ]; then 
                K=0
        fi 
        j=$[$j+1];

        L=$(sed -n ${j}p b.log);   
        if [ ! -n "$L" ]; then 
                L=0
        fi  
	
	# 开始根据信息删除本地的文件
        SUM2=$F" "$G" "$H" "$K" "$L
        cd /tmp/
        rm -rf $SUM2;
        cd -

done




#---------------------------------------------------下载文件操作------------
# 逐行获取数据放入变量(考虑使用for循环）
for (( i=1;i<=$I;i=$[$i+1] ))
do
        #变量后面如果要加东西做参数的话用中括号
        #每次最多获取5个文件，因为无法用for循环创建变量名（因为变量名的命名不能为变量）
        A=$(sed -n ${i}p a.log);
        if [ ! -n "$A" ]; then 
                A=0
        fi 
        i=$[$i+1];

        B=$(sed -n ${i}p a.log);
        if [ ! -n "$B" ]; then 
                B=0
        fi 
        i=$[$i+1];

        C=$(sed -n ${i}p a.log);
        if [ ! -n "$C" ]; then 
                C=0
        fi 
        i=$[$i+1];
        
        D=$(sed -n ${i}p a.log);
        if [ ! -n "$D" ]; then 
                D=0
        fi 
        i=$[$i+1];

        E=$(sed -n ${i}p a.log);   
        if [ ! -n "$E" ]; then 
                E=0
        fi  
	
	# 开始下载文件,下载的目录为当前目录
        SUM=$A","$B","$C","$D","$E
        # 复制文件到本地
        /usr/bin/expect <<EOF
        set timeout -1
        spawn scp -r root@$ip:$ads\{$SUM\} $localPath
        expect {
        "*yes/no" { send "yes\r"; exp_continue}
        "*password:" {send "$password\r"}
        }
        expect eof
EOF

done

# 利用重定向清除文件内内容(此时已下载完所有文件)
cat /dev/null > a.log
cat /dev/null > b.log
cat /dev/null > /c.log


echo "本次共检查到${I}个新文件,已下载到${localPath}"
echo "本次共检查到${J}个文件被删除,已从${localPath}中删除相同的文件"
echo "本次搜寻已完成，30s后再次寻找"
echo ""
echo ""
echo ""
echo ""
echo ""

#while循环中每30秒执行一次
sleep 30
done

