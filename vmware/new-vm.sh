#!/bin/bash
set -e

function usage() {
  cat << EOF
Usage: new-vm.sh [options] RefVm VmName

Clones a cloud-init prepared virtual machine. 
Takes care of injecting cloud-init data and waiting for cloud-init to finish. 

Options: 
  -l      Create a linked clone
  -f      Fast(er) mode. Does not remove the iso used for cloud init (saves us a reboot)

Parameter: 
  RefVm   The vm to clone 
  VmName  The new name for the vm
EOF
}

function get_script_path() {
  pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null
  pwd
  popd > /dev/null
}

source "$(get_script_path)/vmware-utils.sh"
if ! command -v cloud-localds &>/dev/null; then
  vmware::log_error 'command: loud-localds not found. Please install cloud-utils'
  exit 1
fi

linked=false
fast=false
while getopts "lf" flag; do
  case "$flag" in
    l) linked=true; ;;
    f) fast=true; ;;
    *) usage; exit 0;;
  esac
done

ref_name=${*:$OPTIND:1}
vm_name=${*:$OPTIND+1:1}
seed_iso='/tmp/seed.iso'

if [ -z "$vm_name" ]; then usage; exit 1; fi
if [ -z "$ref_name" ]; then usage; exit 1; fi
if $linked; then 
  additional_clone_args='linked'
else
  additional_clone_args='full'
fi

if [[ "$ref_name" != '*.vmx' ]]; then
  vmx=$(vmware::get_vmx "$ref_name")
else
  vmx=$ref_name
fi
destinationDir="$VMLOCATION/$vm_name"
destinationVmx="$destinationDir/$vm_name.vmx"

# If the vm exists, just start it
if [ -f "$destinationVmx" ]; then
  vmware::log_msg 'VM already exists. Starting it...'
  vmware::start_vm "$destinationVmx"
  ip=$(vmrun getGuestIpAddress "$destinationVmx" -wait 2>/dev/null)
  json=$(jq -n \
    --arg vmname "$vm_name" \
    --arg ip "$ip" \
    '$ARGS.named'
  )
  echo "$json"
  exit 0
fi

vmware::log_msg 'Creating cloud-init data iso'
cat > /tmp/meta-data << EOF
instance-id: $vm_name
local-hostname: $vm_name
hostname: $vm_name
EOF

cat > /tmp/user-data << EOF
EOF

cloud-localds "$seed_iso" '/tmp/user-data' '/tmp/meta-data'

vmware::log_msg "Cloning $ref_name to $vm_name"
vmrun clone "$vmx" "$destinationVmx" $additional_clone_args -cloneName="$vm_name"

vmware::log_msg 'Attaching cloud init iso'
vmcli "$destinationVmx" Sata SetPresent sata0 1
vmcli "$destinationVmx" Disk SetBackingInfo sata0:0 cdrom_image "$seed_iso" 1
vmcli "$destinationVmx" Disk SetPresent sata0:0 1

vmware::log_msg 'Starting VM'
vmware::start_vm "$destinationVmx"

vmware::log_msg 'Cleaning up...'
if ! $fast; then
  vmrun stop "$destinationVmx"
  vmcli "$destinationVmx" disk setpresent sata0:0 0
fi
rm '/tmp/user-data' '/tmp/meta-data' "$seed_iso"

if ! $fast; then
  vmware::log_msg 'Starting vm'
  vmware::start_vm "$destinationVmx"
fi

ip=$(vmrun getGuestIpAddress "$destinationVmx" -wait 2>/dev/null)
json=$(jq -n \
  --arg vmname "$vm_name" \
  --arg ip "$ip" \
  '$ARGS.named'
)
echo "$json"