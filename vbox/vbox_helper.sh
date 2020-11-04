#
# VBox utilities 
#

# Some guestproperties 
export readonly GUESTPROPERTY_IP_V4='/VirtualBox/GuestInfo/Net/0/V4/IP'
export readonly GUESTPROPERTY_OS_PRODUCT='/VirtualBox/GuestInfo/OS/Product'
export readonly GUESTPROPERTY_OS_VERSION='/VirtualBox/GuestInfo/OS/Version'
export readonly GUESTPROPERTY_OS_RELEASE='/VirtualBox/GuestInfo/OS/Release'
export readonly GUESTPROPERTY_LOGGED_IN_USERS='/VirtualBox/GuestInfo/OS/LoggedInUsers'
export readonly GUESTPROPERTY_LOGGED_IN_USERS_LIST='/VirtualBox/GuestInfo/OS/LoggedInUsersList'

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

# Get a guestproperty
# Arguments:
#   The vm name 
#   The property name 
# Returns:
#   The property value or an empty string 
#   
guestproperty_get() {
  local vm_name="$1"
  if [ -z "$vm_name" ]; then 
    echo "Specify a VM name!"
    exit 1
  fi
  local property="$2"
  if [ -z "$property" ]; then 
    echo "Specify a parameter to get!"
    exit 1
  fi
  echo "$(vboxmanage guestproperty get "$vm_name" "$property" | grep -oP 'Value:\s\K.*')"
}
