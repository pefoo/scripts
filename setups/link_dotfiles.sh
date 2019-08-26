#!/bin/bash

# Log the console (yellow)
function log_console {
  echo -e "\e[93m${1}\e[39m"
}

# print linked dot files 
# Arg1: The source dot file 
# Arg2: The target dot file 
function log_dot_file {
  printf "\e[92m%-50s %2s %s\e[39m\n" "${1}" "->" "${2}"
}

# Create local git user config (contains user name and mail)
function make_gitconfig_local {
  local guser gmail
  echo -en "\e[92mEnter your git user name:\e[39m "
  read guser
  echo -en "\e[92mEnter your git email:\e[39m "
  read gmail

  local gc_local="/home/${USER}/.gitconfig.local"
  if [ -f "$gc_local" ]; then
    mv "$gc_local" "$gc_local.bak"
  fi

  cat << EOF > "$gc_local"
[user]
  mail = $gmail
  name = $guser
  email = $gmail
EOF
  log_console "Your local git user was created in $gc_local"
  echo "You may make local changes to your git config using this file"
}

# Dot files to link
config_dir="/home/${USER}/configs"
declare -A dot_files=(
  [${config_dir}/dotfiles/bashrc]="/home/${USER}/.bashrc"
  [${config_dir}/dotfiles/tmux.conf]="/home/${USER}/.tmux.conf"
  [${config_dir}/dotfiles/vimrc]="/home/${USER}/.vimrc"
  [${config_dir}/dotfiles/inputrc]="/home/${USER}/.inputrc"
  [${config_dir}/dotfiles/gitconfig]="/home/${USER}/.gitconfig"
)

# Get the dot file repo 
if [ ! -d "$config_dir" ]; then 
  log_console "Configs folder $config_dir not found - getting the repository"
  git clone https://peepe@bitbucket.org/peepe/configs.git "$config_dir"
else 
  pushd "$config_dir"
  git pull 
  popd
fi

make_gitconfig_local 

log_console "Setting up dot files"
for file in "${!dot_files[@]}";do
  log_dot_file $file ${dot_files[$file]}
  # If the dot file exists and is no symlink, create a backup
  if [ -f "${dot_files[$file]}" -a ! -L "${dot_files[$file]}" ]; then
    mv "${dot_files[$file]}" "${dot_files[$file]}.bak"
  fi
  # If the dot file exists and IS a symlink, remove it first 
  if [ -L "${dot_files[$file]}" ]; then
    rm "${dot_files[$file]}"
  fi
  ln -s "$file" "${dot_files[$file]}"
done
