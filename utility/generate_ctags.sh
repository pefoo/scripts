#!/bin/bash

#
# This script generates ctags for a directory and automatically adds the path to the file
# to the ~/.vimtags file 
#
# Args:
#   1) The root path of the project to generate ctags for (default is current working dir)
#


readonly ROOT_DIR=${1:-$(pwd)}

ctags -R "$ROOT_DIR"
echo "set tags+=${ROOT_DIR}/tags" >> "$HOME/.vimtags"
