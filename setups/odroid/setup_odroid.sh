#! /bin/bash

#
# Fresh odroid setup
#   - update / install apps 
#   - setup Intenso nfs export 
#

this_path=$(dirname $(realpath $0))
source "$this_path/../../functions/log.sh"
source "$this_path/../../functions/assert_run_as_root.sh"

assert_run_as_root 

# Update exsting software 
log_msg "Updating software"
apt-get -qq update
apt-get -qq -y upgrade

# Install software 
software="openssh-server monit nfs-kernel-server ntfs-3g vim"
log_msg "Installing software: $software"
apt-get -y -qq install $software

# Setup nfs
$this_path/../create_nfs_export.sh Intenso


