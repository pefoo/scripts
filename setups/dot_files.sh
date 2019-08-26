#!/bin/bash

function log_console {
  echo -e "\e[93m${1}\e[39m"
}

function log_dot_file {
  printf "\e[92m%-50s %2s %s\e[39m\n" "${1}" "->" "${2}"
}

# Dot files to link
config_dir="/home/${USER}/configs"
declare -A dot_files=(
  [${config_dir}/system/bashrc_tower]="/home/${USER}/.bashrc"
  [${config_dir}/apps/tmux/tmux.conf]="/home/${USER}/.tmux.conf"
  [${config_dir}/apps/vim/vimrc_tower]="/home/${USER}/.vimrc"
  [${config_dir}/system/inputrc]="/home/${USER}/.inputrc"
)

if [ ! -d "$config_dir" ]; then 
  log_console "Configs folder $config_dir not found - getting the repository"
  git clone https://peepe@bitbucket.org/peepe/configs.git "$config_dir"
fi

log_console "Setting up dot files"
for file in "${!dot_files[@]}";do
  log_dot_file $file ${dot_files[$file]}
  if [ -f "${dot_files[$file]}" ]; then
    mv "${dot_files[$file]}" "${dot_files[$file]}.bak"
  fi
  ln -s "$file" "${dot_files[$file]}"
done
