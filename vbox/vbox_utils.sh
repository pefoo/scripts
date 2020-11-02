#
# VBox utilities 
#

# Check if vm exists 
# Arguments:
#   The vm name (may contain grep compatible wildcards)
# Returns:
#   0 (true), if the VM exists
#   1 (false), if the VM does not exists
#   error code + message otherwise 
#   
vm_exists() {
  local vm_name="$1"
  if [ -z "$vm_name" ]; then 
    echo "Specify a VM name!"
    return 2
  fi

  if vboxmanage list vms | grep -q "\"$vm_name\""; then
    return 0
  else
    return 1
  fi
}

# Check if vm is running  
# Arguments:
#   The vm name 
# Returns:
#   0 (true), if the VM is running
#   1 (false), if the VM is not running
#   error code + message otherwise 
#   
vm_is_running() {
  local vm_name="$1"
  if [ -z "$vm_name" ]; then 
    echo "Specify a VM name!"
    return 2
  fi
  
  if vboxmanage list runningvms | grep -q "\"$vm_name\""; then
    return 0
  else
    return 1
  fi
}
