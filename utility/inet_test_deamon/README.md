# Description
A systemd based daemon that tests internet connectivity. 
Logs a written to /var/log/inet\_connectivity.
A one (1) means internet connectivity is present. 

# Install
Run
```
bash install_deamon.sh
```
to copy the service definition and the script.

# Run the deamon 
Run
```
systemctl start inet_test_daemon.service
```
to start the service.
