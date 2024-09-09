#!/bin/bash
set -e

function usage() {
  cat << EOF
Usage: delete-vm.sh VmName

Delete a VM

Parameter: 
  VmName  The vm to delete
EOF
}
function get_script_path() {
  pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null
  pwd
  popd > /dev/null
}

source "$(get_script_path)/../functions/log.sh"
source "$(get_script_path)/vmware-utils.sh"
if ! command -v cloud-localds &>/dev/null; then
  log_error 'command: loud-localds not found. Please install cloud-utils'
  exit 1
fi

vm_name=${*:$OPTIND:1}
vmx=$(vmware::get_vmx "$vm_name")

if [ -z "${vmx}" ]; then
  log_error "VM $vm_name not found"
  exit 1
fi

>&2 log_msg "Deleting $vmx"

if vmware::vm_is_running "$vmx"; then
  vmrun stop "$vmx" hard
fi
# Got permission denied errors at some point. 
chmod -R 777 "$(dirname $vmx)"
vmrun deleteVM "$vmx"