#!/bin/bash
# current_ip=`ifconfig |grep -A1 "bond"|tail -1|awk -F: '{print $2}'|awk '{print $1}'`
# current_user=`who am i |awk '{print $1}'`

while read host_ip host_user host_passwd
do
    if ping -c2 $host_ip &>/dev/null
    then
expect <<EOF
        set timeout -1
        spawn ssh ${host_user}@${host_ip}
        expect {
            "*yes/no" { send "yes\r";exp_continue}
            "*password:" { send "${host_passwd}\r"}
        }
        expect "*#" 
        send "mkdir -p /tmp/${host_ip}\r"
        expect "*#"
        send "cat /etc/issue > /tmp/${host_ip}/os_info ;ifconfig > /tmp/${host_ip}/network_info;hostname >/tmp/${host_ip}/host_info;route -n >/tmp/${host_ip}/route_info;cat /proc/cpuinfo>/tmp/${host_ip}/cpu_info;free >/tmp/${host_ip}/memory_info;fdisk -l>/tmp/${host_ip}/disk_info;df -lhTP >/tmp/${host_ip}/file_system_info;ps aux >/tmp/${host_ip}/progress_info;uname -r>/tmp/${host_ip}/core_version;mount >/tmp/${host_ip}/file_system_rw\r"
        send "exit\r"
        expect eof
EOF
        if ! [ -e ~/backup_info ]
        then
            mkdir -p ~/backup_info
        fi
        
expect <<EOF
        set timeout -1
        spawn bash -c "scp -r ${host_user}@${host_ip}:/tmp/${host_ip} ~/backup_info/"
        expect {
            "*yes/no" { send "yes\r" ; exp_continue }
            "*password:" { send "${host_passwd}\r" }
        }
        expect eof
EOF
#################健康报告
        cd ~/backup_info/${host_ip}
        gateway=`cat route_info|awk '$1=="0.0.0.0",$3="0.0.0.0"{print $2}'`
        core_version=`cat core_version`
        cpu_sum=`cat cpu_info  |grep "processor"|wc -l `
        cpu_phy=`cat cpu_info |grep "physical id"|sort |uniq|wc -l `
        cpu_core=`cat cpu_info|grep "cores"|uniq|awk '{print $4}'`
        cpu="`cat cpu_info |awk '/model name/{print $6}'|uniq`×${cpu_phy} ${cpu_core}cores"
        memory_total=`cat memory_info |awk '/Mem/{print$2}'`
        memory_total_g=$(( $memory_total/1024/1024 ))
        swap_use=`cat memory_info|awk '/Swap/{print $3}'`
        disk_use=`cat file_system_info|tr -s " " |tail -n +2|awk -F'[ %]' '{if($6>80) print $8"空间超过80%"}'|tr "\n" ","`
        file_system_rw=`cat file_system_rw|awk '$6~/\<(ro)\>/{print $1"只读"}'`
        
        if [ -z $gateway ]
        then
            gateway="null"
        fi
        if (( ${cpu_sum} == ${cpu_phy}*${cpu_core} ))
        then
            cpu_ch="OK"
        else
            cpu_ch="异常"
        fi
        
        if [ $swap_use = "0" ]
        then
            mem_ch="OK"
        else
            swap_use=$(( $swap_use/1024 ))
            mem_ch="异常 , swap空间使用为：${swap_use}"
        fi
        if [ -z $disk_use ]
        then
            disk_ch="正常"
        else
            disk_ch="异常,${disk_use}"
        fi
        if [ -z $file_system_rw ]
        then
            file_system_ch="正常"
        else
            file_system_ch="异常,${file_system_rw}"
        fi
        if cat progress_info |egrep  "/bin/mysqld\b" &>/dev/null
        then
            progress_ch="正常"
        else
            progress_ch="异常,无mysqld进程服务"
        fi
cat << EOF >"${host_ip}_`date +%Y%m%d%H%M`_HealthReport.csv"
基本信息：
主机名：,`cat host_info`
IP地址：,${host_ip}
默认网关：,${gateway}
内核版本：,${core_version}
CPU：,${cpu}
内存：,${memory_total_g}G

健康检查
CPU检查：,,${cpu_ch}
内存检查:,,${mem_ch}
硬盘空间:,,${disk_ch}
文件系统读写检查:,,${file_system_ch}
进程检查:,,${progress_ch}
EOF
    else
        echo -e "\e[31m$host_ip的网络不能连接，获取不了信息\e[0m"
        continue
    fi  
done <host

echo "123456" > /etc/.rsync.passwd
chmod 600 /etc/.rsync.passwd
host_passwd=123456
tar  -zcvf /root/backup/`date '+%Y%m%d%H%M'`.tar /root/backup_info/* 
# chmod -R 777
expect << EOD
# 推荐设置超时为 -1 
set timeout -1
spawn  bash -c "rsync -acv /root/backup/* root@172.16.99.1:/backup/system_check/"
expect "password:*"
send "${host_passwd}\r"
# 等待文件结束符（远程服务器处理完了所有事情）
expect eof
# 结束 expect 脚本
EOD



ls -ctl /root/backup/|awk 'NR>4 { system("rm -rf /root/backup/*" $9) }'




echo "DONE"

