#!/bin/bash

function log_console {
  echo -e "\e[93m${1}\e[39m"
}

#
# ale
#
if [ ! -d "/home/${USER}/.vim/pack/ale" ]; then
  log_console "Installing ale"
  mkdir -p ~/.vim/pack/ale/start
  git clone https://github.com/w0rp/ale.git ~/.vim/pack/ale/start
else
  log_console "Ale is already installed"
fi

#
# completor
#
if [ ! -d "/home/${USER}/.vim/pack/completor/" ]; then
  log_console "Installing completor"
  mkdir -p ~/.vim/pack/completor/start
  git clone https://github.com/maralla/completor.vim.git ~/.vim/pack/completor/start
else
  log_console "Completor is already installed"
fi

#
# gruvbox
#
if [ ! -d "/home/${USER}/.vim/pack/default/start/gruvbox" ]; then
  log_console "Installing gruvbox theme"
  git clone https://github.com/morhetz/gruvbox.git ~/.vim/pack/default/start/gruvbox
else
  log_console "Gruvbox is already installed"
fi

#
# airline
#
if [ ! -d "/home/${USER}/.vim/pack/dist/start/vim-airline" ]; then
  log_console "Installing airline"
  git clone https://github.com/vim-airline/vim-airline ~/.vim/pack/dist/start/vim-airline
else
  log_console "Airline is already installed"
fi

