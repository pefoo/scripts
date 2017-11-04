#! /bin/bash

# Update clean system
# install required software

echo "Updating software ..."
apt-get -qq update
apt-get -qq -y upgrade
echo "Finished updating software"

software="openssh-server monit nfs-kernel-server apache2 apache2-doc ntfs-3g x11vnc vim"
echo "Installing software:"
echo $software 
apt-get -y -qq install $software
echo "Finished installing new software"



