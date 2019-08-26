#!/bin/bash

#
# Setup a vm 
#   - Update applications
#   - Install applications (see $applications)
#   - link dot files 
#

# functions required to link dot files 
source ../link_dotfiles.sh -i

function log_console {
  echo -e "\e[93m${1}\e[39m"
}


# Get git repo passwordd 
prompt_git_pw

# Get user password 
echo -en "\e[92mEnter your user password:\e[39m "
read -s upwd

# Create local git config 
make_gitconfig_local

# update applications
echo $upwd | sudo -S apt install update
echo $upwd | sudo -S apt install upgrade 

# applications to install 
applications="
  tmux
  vim
  git
"

log_console "Installing applications $applications"
echo $upwd | sudo -S apt install -y $applications

log_console "Installing vim plugins"
source "../../vim/install_plugins.sh"

# Link the dot files 
link_dot_files

