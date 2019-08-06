#!/bin/bash

source ../../snippets/assert_run_as_root.sh
assert_run_as_root

function log_console {
  echo -e "\e[93m${1}\e[39m"
}


applications="
  tmux
  vim
  git
"
log_console "Installing applications $applications"
sudo apt install -y $applications

if [ ! -d "/home/${USER}/configs" ];then 
  log_console "Configs folder /home/${USER}/configs not found - getting the repository"
  git clone https://peepe@bitbucket.org/peepe/configs.git
fi

log_console "Setting up dot files"
config_dir="/home/${USER}/configs"
declare -A dot_files=(
  [${config_dir}/system/bashrc_tower]="/home/${USER}/.bashrc"
  [${config_dir}/apps/tmux/tmux.conf]="/home/${USER}/.tmux.conf"
  [${config_dir}/apps/vim/vimrc_tower]="/home/${USER}/.vimrc"
)
for file in "${!dot_files[@]}";do
  log_console "Installing $file to ${dot_files[$file]}"
  cp $file ${dot_files[$file]}
done

