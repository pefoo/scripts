#!/bin/bash

#
# Anything package managemt relates goes here. 
# Provides means to update exsting apps, install my common apps... 
#


# If log_msg is defined, use it for logging. 
# Args:
#   1) The message to print 
function default_log () {
  $(declare -fF log_msg > /dev/null && echo 'log_msg' || echo 'echo') "$1"
}

# Update existing packages 
# Args:
#   NONE
function update_packages() {
  apt update -q
  local updates=$(apt list --upgradable 2>/dev/null | grep -v "Listing\|Done")
  apt upgrade -yq
  default_log "$updates"
}

# Just install some packages
# Args:
#  *) The packages to install 
function install_packages() {
  sudo apt install -yqq $@
}
