#!/bin/bash

function log_console {
  echo -e "\e[93m${1}\e[39m"
}

# Dot files to copy 
config_dir="/home/${USER}/configs"
declare -A dot_files=(
  [${config_dir}/system/bashrc_tower]="/home/${USER}/.bashrc"
  [${config_dir}/apps/tmux/tmux.conf]="/home/${USER}/.tmux.conf"
  [${config_dir}/apps/vim/vimrc_tower]="/home/${USER}/.vimrc"
)

if [ ! -d "$config_dir" ]; then 
  log_console "Configs folder $config_dir not found - getting the repository"
  git clone https://peepe@bitbucket.org/peepe/configs.git "$config_dir"
fi

log_console "Setting up dot files"
for file in "${!dot_files[@]}";do
  log_console "Installing $file to ${dot_files[$file]}"
  if [ -f "${dot_files[$file]}" ]; then
    mv "${dot_files[$file]}" "${dot_files[$file]}.bak"
  fi
  ln -s "$file" "${dot_files[$file]}"
done
