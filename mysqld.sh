#!/bin/bash

source /etc/profile
source /etc/bashrc
if service mysqld status &> /dev/null
then
    echo mysqld is running
else
    service mysqld start
fi
