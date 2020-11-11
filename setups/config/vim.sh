#!/bin/bash
#
# The vim setup configuration file 
#

# Get this script path as absolute path 
# Arguments: 
#   None 
# Returns:
#   The absolute path to this script
get_script_path() {
  pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null
  pwd
  popd > /dev/null
}

source "$(get_script_path)/config_helper.sh"

declare -Ar VIM_PLUGINS=(
[ale]="https://github.com/w0rp/ale.git;\
A linter;\
default"

[completor]="https://github.com/maralla/completor.vim.git;\
Auto complete;\
default"

[gruvbox]="https://github.com/morhetz/gruvbox.git;\
A quite dark color scheme;\
default"

[vscode-dark-theme]="https://github.com/tomasiser/vim-code-dark.git;\
A quite dark color scheme;\
default"

[airline]="https://github.com/vim-airline/vim-airline.git;\
A status line;\
default"

[ctrlp]="https://github.com/ctrlpvim/ctrlp.vim.git;\
Search for files and (c)tags;\
default"

[nerdtree]="https://github.com/scrooloose/nerdtree.git;\
A file system tree;\
default"

[nerdtree_git]="https://github.com/Xuyuanp/nerdtree-git-plugin.git;\
Git icons for nerdtree;\
default"

[gutentags]="https://github.com/ludovicchabant/vim-gutentags.git;\
Auto generate ctags;\
default"

[indent_guides]="https://github.com/nathanaelkane/vim-indent-guides.git;\
Indent guides;\
default"

[autosave]="https://github.com/907th/vim-auto-save.git;\
Auto save;\
default"

[signify]="https://github.com/mhinz/vim-signify.git;\
Display line change indicators;\
default"

[tagbar]="https://github.com/majutsushi/tagbar.git;\
Display outline with ctags;\
default"

[vim-signature]="https://github.com/kshenoy/vim-signature.git;\
Display (jump) marks in gutter;\
default"

[fugitive]="https://github.com/tpope/vim-fugitive.git;\
Git plugin;\
default"

[floatterm]="https://github.com/voldikss/vim-floaterm.get;\
Floating terminal in vim;\
default"
)
