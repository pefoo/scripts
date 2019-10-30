#!/bin/bash
#
# Some utility functions for backup management 
#

# Generate backup file name with current date with the 
# following format: {base file name}-{date}.{extension}
# File names created using this function are sortable and thus the cleanup function
# in this script may be used. 
# Args:
#   1) The base file name 
#   2) The extension
get_backup_file_name() {
  local base="$1"
  local ext="$2"
  echo "$base-$(date '+%d-%m-%Y').$ext"
}

# Cleanup old backups 
# To decide which backup the delete, it is assumed that the file names 
# a sortable (contain a time stamp). 
# The oldes entries that exceed max_backups will be removed
# Args:
#   1) The amount of backups to keep 
#   2) The folder to search for backups (default is current folder)
#   3) The backup file match pattern (default is *. Provide your backups extension like *.tar.gz)
cleanup_backups() {
  local max_backups="$1"
  [[ -z "$max_backups" ]] && echo "Max backup count not provided!" && return 1
  local folder="${2:-.}"
  local match_pattern="${3:-*}"
  local backups=()
  
  for file in $folder/$match_pattern; do
    [[ -e "$file" ]] || continue
    local backups+=($(realpath "$file"))
  done
  
  if [ "${#backups[@]}" -gt "$max_backups" ]; then
    local sorted=($(printf '%s\n' "${backups[@]}" | sort -r))
    for i in $(seq "$max_backups" $((${#sorted[@]}-1))); do
      echo "Removing ${sorted[$i]}"
      rm "${sorted[$i]}"
    done
  fi
}
