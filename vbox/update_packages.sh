#!/bin/bash

#
# Update a (ubuntu) VMs packages.
# The current snapshot is renamed (date and time added) and a new one with the old name is created. 
# The installed upgrades are listed in the new snapshot description.
#
# Requires guest additions to be installed. 
#

main() {
  # shellcheck source=../functions/log.sh
  source "$(get_script_path)/../functions/log.sh"
  # shellcheck source=./vbox_helper.sh
  source "$(get_script_path)/vbox_helper.sh"

  local vm_user="$USER"
  while getopts "u:" o; do
    case "$o" in
      u)
        vm_user="$OPTARG"
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
    exit 1
  fi
  echo -n "Enter the user password for the machine: "
  read -s password
  echo ""

  # Start the VM and get the host name
  echo 'Starting the VM ...'
  # shellcheck source=./start_vm.sh
  bash "$(get_script_path)/start_vm.sh" -qh "$vm_name"
  local result=$?
  if [ ! $result -eq 0 ]; then 
    exit $result
  fi
  local vm_ip
  vm_ip=guestproperty_get "$vm_name" "$GUESTPROPERTY_IP_V4"
  if [ -z "$vm_ip" ]; then 
    log_error "Failed to get the VM ip!!"
    exit 1
  fi
  
  # Update the software packages and shutdown the VM
  local sudo_p="sudo -p '' -S <<< $password"
  local update_script="
$sudo_p apt-get update -qq > /dev/null &&
$sudo_p apt list --upgradable 2>/dev/null 1> ~/updates.txt &&
$sudo_p apt-get upgrade -yqq
  "
  echo 'Starting update process ...'
  ssh -q -o StrictHostKeyChecking=no "$vm_user@$vm_ip" "$update_script"
  result=$?
  if [ ! $result -eq 0 ]; then 
    log_error "Failed to update packages!"
    exit $result
  fi
  local tmpfile
  tmpfile=$(mktemp /tmp/vm-updates.XXXXXX)
  scp -q -o StrictHostKeyChecking=no "$vm_user@$vm_ip:~/updates.txt" "$tmpfile"
  ssh -q -o StrictHostKeyChecking=no "$vm_user@$vm_ip" "$sudo_p shutdown -h now && exit" 2>/dev/null
  while vm_is_running "$vm_name"; do 
    sleep 5
  done

  local update_count
  update_count=$((($(wc -l < "$tmpfile")-1)))
  if [ $update_count -eq 0 ]; then
    print_summary 0
    rm "$tmpfile"
    exit 0
  fi 

  # Update the snapshost 
  echo 'Starting snapshot update process ...'
  local current_snapshot
  local renamed_snapshot='N.a'
  current_snapshot=$(vboxmanage snapshot "$vm_name" list --machinereadable | grep -oP 'CurrentSnapshotName="\K.*\b')
  if [ -z "$current_snapshot" ]; then 
    # Machine has no snapshot yet
    current_snapshot='prepared'
  else
    # Update current snapshot name: append the date 
    renamed_snapshot="${current_snapshot} $(date +"%d-%m-%Y %T")"
    vboxmanage snapshot "$vm_name" edit --current --name "$renamed_snapshot"
  fi
  # Recreate the snapshot name with the new changes 
  vboxmanage snapshot "$vm_name" take "$current_snapshot" --description "$(tail -n +2 "$tmpfile")"

  print_summary "$update_count" "$current_snapshot" "$renamed_snapshot" "$(tail -n +2 "$tmpfile")"
  rm "$tmpfile"
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
  echo -e "\t-u user_name Use the specified user name to log into the vm"
}

print_summary() {
  local update_count=$1
  local new_snapshot=${2:-'N.a'}
  local renamed_snapshot=${3:-'N.a'}
  local installed_updates=${4:-'N.a'}

  echo ''
  echo '################################## SUMMARY ##################################'
  echo 'Installed the following updates:'
  echo "$installed_updates"
  echo ''
  echo -e "New snapshot:\t\t $new_snapshot"
  echo -e "Renamed snapshot:\t $renamed_snapshot"
  echo -e "Installed updates:\t $update_count"
}

main "$@"; exit
