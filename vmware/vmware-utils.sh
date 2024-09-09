#!/bin/bash
export VMLOCATION="$HOME/vmware"

# Note: We log to stderr to preserve stdout for data objects

# Write green message 
# Arguemtns:
#   Message to display
function vmware::log_msg {
  >&2 echo -e "\e[92m${1}\e[39m"
}

# Write yellow message 
# Arguemtns:
#   Message to display
function vmware::log_warn {
  >&2 echo -e "\e[93m${1}\e[39m"
}

# Write red message 
# Arguemtns:
#   Message to display
function vmware::log_error {
  >&2 echo -e "\e[91m${1}\e[39m"
}

# Find the vmx file of a given vm
# Arguments
#   The vm name. If the provided name ends with .vmx, the input is returned
function vmware::get_vmx {
  local vm_name="$1"
  if [[ "$vm_name" != *.vmx ]]; then
    find "$VMLOCATION" -name "$vm_name.vmx"
  else
    echo "$vm_name"
  fi
}

# Check if a vm is running
# Arguments
#   The vm name
# Returns
#   0 if the vm is running
#   1 otherwise
function vmware::vm_is_running {
  local vmx
  local powerstate
  vmx=$(vmware::get_vmx "$1")
  powerstate=$(vmcli "$vmx" power query -f json | jq -r '.PowerState')
  if [[ 'off' == "$powerstate" ]]; then
    return 1
  fi
  return 0
}

# Start a vm
# Arguments
#   The vm name
function vmware::start_vm {
  local vmx
  vmx=$(vmware::get_vmx "$1")
  if ! vmware::vm_is_running "$vmx"; then
    echo 'Starting vm'
    vmrun start "$vmx"

    while [[ 'running' != $(vmrun CheckToolsState "$vmx" 2>/dev/null) ]]; do
      sleep 1
    done
    vmrun getGuestIpAddress "$vmx" -wait &>/dev/null
  fi
}