#!/bin/bash

function log_console {
  echo -e "\e[93m${1}\e[39m"
}

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

source ../dot_files.sh

log_console "Setting console completion to case insesitive"
if [ ! -a ~/.inputrc ]; then 
  echo '$include /etc/inputrc' > ~/.inputrc; 
fi
echo 'set completion-ignore-case On' >> ~/.inputrc
