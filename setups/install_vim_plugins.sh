#!/bin/bash

#
# Install vim 8 plugins (using the native plugin manager)
#

while getopts "i" o; do
  case "$o" in
    i)
      # This file was sourced from some interactive scrip. Skip actual execution
      interactive_mode=true
      ;;
  esac
done

[ -d "$0" ] && readonly THIS_PATH="$0" || readonly THIS_PATH=$(dirname $(realpath $0))
source "$THIS_PATH/../functions/log.sh"

# List of common plugins 
declare -Ar PLUGINS=(
  # A linter 
  [ale]="https://github.com/w0rp/ale.git"
  # Auto complete 
  [completor]="https://github.com/maralla/completor.vim.git"
  # Color scheme 
  [gruvbox]="https://github.com/morhetz/gruvbox.git"
  # Status line 
  [airline]="https://github.com/vim-airline/vim-airline"
  # Search for files / (c)tags
  [ctrlp]="https://github.com/ctrlpvim/ctrlp.vim.git"
  # Tree navigation 
  [nerdtree]="https://github.com/scrooloose/nerdtree.git"
  # Tree navigation git integraiton 
  [nerdtree_git]="https://github.com/Xuyuanp/nerdtree-git-plugin.git"
  # Auto generate tags 
  [gutentags]="https://github.com/ludovicchabant/vim-gutentags.git"
  # Indent guides]
  [indent_guides]="https://github.com/nathanaelkane/vim-indent-guides.git"
  # Auto save 
  [autosave]="https://github.com/907th/vim-auto-save.git"
  # Signify - display line change indicators 
  [signify]="https://github.com/mhinz/vim-signify.git"
  # Tagbar - display outline 
  [tagbar]="https://github.com/majutsushi/tagbar.git"
  )

readonly PLUGIN_BASE_DIR="$HOME/.vim/pack/default"

# Install a single vim plugin using git
# Args:
#   1) The plugin name 
#   2) The source url (most likely a github repo)
function install_plugin() {
  local plugin="$1"
  local source_url="$2"

  if [ -z "$plugin" ] || [ -z "$source_url" ]; then 
    log_error "Provide a plugin name and source url for the vim plugin you want to install"
    return 1
  fi

  plugin_dir="${PLUGIN_BASE_DIR}/start/${plugin}"
  if [ -d "$plugin_dir" ]; then 
    log_msg "The plugin $plugin is already installed."
  else
    mkdir -p "$plugin_dir"
    git clone -q "${source_url}" "$plugin_dir"
    log_msg "Installed plugin $plugin"
  fi
}

if [ ! "$interactive_mode" == true ];then 
  for plugin in "${!PLUGINS[@]}"; do
    install_plugin "$plugin" "${PLUGINS[$plugin]}"
  done 
fi

