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

log_msg "Installing vim plugins"
source "$this_path/../install_vim_plugins.sh"

# Link dot files, if the config directory exists
if [ -d "$HOME/configs" ];then
  source $HOME/configs/dotfiles/link_dotfiles.sh -b "$HOME/configs/dotfiles"
else 
  log_warn "Failed to find the configs directory. Skipping dot file configurations." 
fi
