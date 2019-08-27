#!/bin/bash

#
# Setup a vm 
#   - Update applications
#   - Install applications (see $applications)
#   - link dot files 
#

this_path=$(dirname $(realpath $0))
source "$this_path/../../functions/log.sh"

# update applications
sudo apt update
sudo apt -y upgrade 

# applications to install 
applications="
  tmux
  vim
  git
"

log_msg "Installing applications $applications"
sudo apt install -y $applications

log_msg "Installing vim plugins"
source "../install_plugins.sh"

# Link dot files, if the config directory exists
if [ -d "$HOME/configs" ];then
  source $HOME/configs/dotfiles/link_dotfiles.sh -b "$HOME/configs/dotfiles"
else 
  log_warn "Failed to find the configs directory. Skipping dot file configurations." 
fi


