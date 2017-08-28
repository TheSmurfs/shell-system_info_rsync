#!/bin/bash

if rpm -q crontabs
then
    echo ok
else
    if yum list &> /dev/null
    then
    yum install crontabs << eof
y
eof
    else
    touch /etc/yum.repos.d/yum1.repo
echo << eof > /etc/yum.repos.d/yum1.repo
[local]
name=local yum
baseurl=file:///mnt
gpgcheck=0
enabled=1
eof
mount /dev/sr0 /mnt &> /dev/null
yum list && echo "yum is ok"
    yum install crontabs << eof
y
eof
    fi
fi
chmod a+x rsysnc.sh
chmod a+x mysqld.sh 
echo "0 4 * * * /opt/scripts/rsysnc.sh" > /var/spool/cron/root
echo "* * * * * /opt/scripts/mysqld.sh" >> /var/spool/cron/root
IP=$(ifconfig | grep "Bcast" | awk -F: '{print $2}' | cut -d " " -f1)
while read host_ip host_user host_passwd
do
if [[ $IP == $host_ip ]]
then
    continue
else
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
            send "cat /etc/issue > /tmp/${host_ip}/os_info ;ifconfig > /tmp/${host_ip}/network_info;hostname >/tmp/${host_ip}/host_info;route -n >/tmp/${host_ip}/route_info;cat /proc/cpuinfo>/tmp/${host_ip}/cpu_info;free >/tmp/${host_ip}/memory_info;fdisk -l>/tmp/${host_ip}/disk_info;df -lhT >/tmp/${host_ip}/file_system_info;ps aux >/tmp/${host_ip}/progress_info\r"
            expect "*#"
            send "mkdir -p /opt/scripts\r"
            expect "*#"
            send "exit\r"
            expect eof
EOF
    
    expect -c "
        spawn rsync /opt/scripts/mysqld.tar root@${host_ip}:/opt/scripts/
        expect {
            \"*(yes/no)?\" { send \"yes\r\" ; exp_continue}
            \"*password\" { send \"${host_passwd}\r\" ; exp_continue }
    }
    " 
    expect <<EOF
        set timeout -1
        spawn ssh ${host_user}@${host_ip}
        expect {
            "*(yes/no)?" { send "yes\r" ; exp_continue}
            "*password:" { send "${host_passwd}\r"}
        }
        expect "*#" 
        send "cd /opt/scripts\r"
        expect "*#" 
        send "tar -xf mysqld.tar\r"
        expect "*#" 
        send "cd /opt/scripts\r"
        expect "*#" 
        send "bash mysql1.sh\r"
        expect "*#"
        send "exit\r"
        expect eof
EOF
    fi
fi
done <host

