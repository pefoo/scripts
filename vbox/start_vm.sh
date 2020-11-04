#!/bin/bash

#
# Start a VM. 
#
# Requires guest additions to be installed. 
# If the VM is NOT configured to automatically log in a user, set the no_wait (-n) flag. 
#

main() {
  # shellcheck source=../functions/log.sh
  source "$(get_script_path)/../functions/log.sh"
  # shellcheck source=./vbox_helper.sh
  source "$(get_script_path)/vbox_helper.sh"

  local no_wait=false
  local headless=false
  local verbose=false
  local stdout='/dev/tty'
  while getopts "qvnh" o; do
    case "$o" in
      n)
        no_wait=true
        ;;
      v)
        verbose=true
        ;;
      h)
        headless=true
        ;;
      q)
        stdout='/dev/null'
        ;;
      \?)
        usage
        exit 1
        ;;
    esac
  done
  shift $((OPTIND - 1))
  
  local vm_name="$1"
  if [ -z "$vm_name" ]; then 
    log_error "Specify a vm name!"
    usage
    exit 1
  fi

  if ! vm_exists "$vm_name"; then 
    log_error "VM $vm_name does not exist!"
    exit 1
  fi

  if vm_is_running "$vm_name"; then 
    log_warn "VM $vm_name is already running!"
    exit 1
  fi
  
  if "$headless"; then 
    vboxmanage startvm "$vm_name" --type headless 1> $stdout
  else 
    vboxmanage startvm "$vm_name" 1> $stdout
  fi
  local result=$?

  if [ ! $result -eq 0 ]; then 
    log_error "Failed to start the VM $vm_name"
    exit 1
  fi

  if "$no_wait"; then 
    exit 0
  fi
  echo "Waiting for user to login ..." 1> $stdout
  vboxmanage guestproperty wait "$vm_name" "$GUESTPROPERTY_LOGGED_IN_USERS" > /dev/null

  local ip
  local hostname
  local logged_in_users
  ip=$(guestproperty_get "$vm_name" "$GUESTPROPERTY_IP_V4")
  while [ -z "$ip" ]; do
    sleep 5
    ip=$(guestproperty_get "$vm_name" "$GUESTPROPERTY_IP_V4")
  done
  hostname=$(nslookup "$ip" | grep -oP 'name = \K.*\b')
  # <3 VirtualBox! Even though we just waited for LoggedInUsers, the user did not actually log in yet. 
  logged_in_users=$(guestproperty_get "$vm_name" "$GUESTPROPERTY_LOGGED_IN_USERS_LIST")
  while [ -z "$logged_in_users" ]; do
    sleep 5
    logged_in_users=$(guestproperty_get "$vm_name" "$GUESTPROPERTY_LOGGED_IN_USERS_LIST")
  done 

  if $verbose; then 
    echo -e "\e[32mHostname:\t $hostname"
    echo -e "User:\t\t $logged_in_users\e[0m"
  fi
}

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

usage() {
  echo "$(basename "${BASH_SOURCE[0]}") [OPTION] vm_name"
  echo "Options:"
  echo -e "\t-h Start the VM in headless mode"
  echo -e "\t-n Do NOT wait for the VM user to login"
  echo -e "\t-v Verbose output. Print basic VM info after starting it"
  echo -e "\t-q Quiet. Do not output anything but errors"
}

main "$@"; exit
