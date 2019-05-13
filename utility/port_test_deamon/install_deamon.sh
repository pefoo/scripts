#!/bin/bash

sudo cp ./port_test.sh /usr/bin/port_test.sh
sudo chmod +x /usr/bin/port_test.sh
sudo cp ./port_test_daemon.service /etc/systemd/system/port_test_daemon.service
