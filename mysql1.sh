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
