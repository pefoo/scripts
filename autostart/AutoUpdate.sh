#! /bin/bash

# Auto Update script for cron

apt-get update
apt-get -s upgrade | grep 'Inst' >> "/var/log/AutoUpdateLog/""$(date +'%d.%m.%Y'_update.log)"
apt-get -y upgrade
