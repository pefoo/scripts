#!/bin/bash

#
# Create a new ssh key pair and add the key with its host to the local ssh config 
#
set -e

# Set a configuration value 
# Args:
#   1) The section 
#   2) The config key 
#   3) The new value 
#   4) The config file 
function set_confg_value() {
  section=${1//\*/\\\\*}
  section=${section//\./\\\\.}
  awk -i inplace -v section="$section" -v key="$2" -v value="$3" '
    BEGIN {
      in_section = 0
    }

    # Set the in_section flag when entering the requested section 
    $0~section {
      in_section = 1
    }

    # Process matched section 
    $0~"^\\s+"key {
      if (in_section) {
        print "  "$1" "value
        skip = 1
      }
    }

    # Reset in_section flag 
    $0~"(?!"section")^\\S" {
      in_section = 0
    }

    # Print the rest 
    /.*/ {
      if (skip)
        skip = 0
      else 
        print $0
    }
    ' "$4"
}

this_path=$(dirname $(realpath $0))
ssh_config="$HOME/.ssh/config"
source "$this_path/../functions/log.sh"

read -p "Enter the user name for this file (default: $USER): " user
read -p "Enter your mail address: " mail
read -p "Enter the host you want to login to using this key (default: *): " host

if [ -z "$host" ];then 
  host="*"
fi

key_file_default="$HOME/.ssh/$([ "$host" == "*" ] && echo "ssh_key" || echo "$host")"
read -p "Enter a file in which to save the key (default: $key_file_default): " key_file 

if [ -z "$key_file" ];then
  key_file=$key_file_default 
fi
if [ -z "$user" ];then
  user=$USER
fi 

if [ -d "$key_file" ] || [ -f "$key_file" ];then 
  log_error "This file already exists or is a directory!"
  exit 1
fi

mkdir -p $(dirname "$key_file")
ssh-keygen -t rsa -b 4096 -C "$mail" -f "$key_file"

# Create backup of old config
if [ -f "$ssh_config" ];then 
  cp "$ssh_config" "${ssh_config}.bak"
fi

# Escape special characters like * and . 
host_line="Host $host"
host_line=${host_line//\*/\\*}
host_line=${host_line//\./\\.}

# Just created entry (host) is present in the config - update it 
if [ -f "$ssh_config" ] && (grep -q "$host_line" "$ssh_config");then 
  echo "Updating the host $host"
  set_confg_value "Host $host" "IdentityFile" "$key_file" "$ssh_config"
  set_confg_value "Host $host" "User" "$user" "$ssh_config"
# Just created entry (host) is new - append it to the file 
else 
  echo "Creating new host $host"
  cat << EOF >> "$ssh_config"
Host $host
  Port 22
  User $user
  IdentityFile $key_file 
EOF
fi

# print the public key
log_msg "${key_file}.pub:"
cat "${key_file}.pub"
