#!/bin/bash

#
# Setup a vm 
#   - Update applications
#   - Install applications (see $applications)
#   - link dot files 
#

function log_console {
  echo -e "\e[93m${1}\e[39m"
}

# Link dot files, if the config directory exists
if [ -d "$HOME/configs" ];then
  source $HOME/configs/dotfiles/link_dotfiles.sh 
else 
  log_console "Failed to find the configs directory. Skipping dot file configurations." 
fi

# update applications
sudo apt update
sudo apt upgrade 

# applications to install 
applications="
  tmux
  vim
  git
"

log_console "Installing applications $applications"
sudo apt install -y $applications

log_console "Installing vim plugins"
source "../../vim/install_plugins.sh"

