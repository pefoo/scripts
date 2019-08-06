#!/bin/bash

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

log_console "Installing vim plugins"
source "../../vim/install_plugins.sh"

if [ ! -d "/home/${USER}/configs" ]; then 
  log_console "Configs folder /home/${USER}/configs not found - getting the repository"
  git clone https://peepe@bitbucket.org/peepe/configs.git ~/configs
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
  if [ -f "${dot_files[$file]}" ]; then
  mv "${dot_files[$file]}" "${dot_files[$file]}.bak"
  fi
  cp "$file" "${dot_files[$file]}"
done

log_console "Setting console completion to case insesitive"
if [ ! -a ~/.inputrc ]; then 
  echo '$include /etc/inputrc' > ~/.inputrc; 
fi
echo 'set completion-ignore-case On' >> ~/.inputrc
