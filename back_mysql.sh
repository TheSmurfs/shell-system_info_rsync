#!/bin/bash

[ -d /opt/scripts ] || mkdir -p /opt/scripts

cp      mysqld.tar  /opt/scripts/mysqld.tar 

tar -xf /opt/scripts/mysqld.tar  -C /opt/scripts/

tar -xf /opt/scripts/mysqld.tar

chmod  +x  /opt/scripts/mysql.sh

source /opt/scripts/mysql.sh