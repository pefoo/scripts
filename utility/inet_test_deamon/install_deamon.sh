#!/bin/bash

sudo cp ./internet_connect_test.sh /usr/bin/internet_connect_test.sh
sudo chmod +x /usr/bin/internet_connect_test.sh
sudo cp ./inet_test_daemon.service /etc/systemd/system/inet_test_daemon.service
