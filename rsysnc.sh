#!/bin/bash

passwd=$(cat hostkey)
ip=172.16.99.1
IP=$(ifconfig | grep "Bcast" | awk -F: '{print $2}' | cut -d " " -f1)
source /etc/profile
source /etc/bashrc
cp /mydata /$IP
expect -c "
    spawn rsync -r /$IP root@$ip:/backup/mysql_datadir/
    expect {
        \"*(yes/no)?\" { send \"yes\r\" ; exp_continue}
        \"*password\" { send \"$passwd\r\" ; exp_continue }
}
" 

