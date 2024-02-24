#!/bin/bash
set -e

function usage() {
  cat << EOF
Usage: vbox-clone.sh [options] RefVm VmName

Clones a cloud-init prepared virtual machine. 
The machine to clone has to have a snapshot named 'prepared'. Takes care of injecting cloud-init data and waiting for 
cloud-init to finish. 

Options: 
  -l      Create a linked clone 

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

source "$(get_script_path)/../functions/log.sh"
source "$(get_script_path)/../vbox/vbox_helper.sh"

linked=false
while getopts "l" flag; do
  case "$flag" in
    l) linked=true; ;;
    *) usage; exit 0;;
  esac
done

if ! command -v cloud-localds &>/dev/null; then
  log_error 'command: loud-localds not found. Please install cloud-utils'
  exit 1
fi

ref_name=${*:$OPTIND:1}
vm_name=${*:$OPTIND+1:1}
seed_iso='/tmp/seed.iso'

if [ -z "$vm_name" ]; then usage; exit 1; fi
if [ -z "$ref_name" ]; then usage; exit 1; fi
if $linked; then additional_clone_args='--options=Link'; fi

if ! vm_exists "$ref_name"; then
  log_error "Failed to find the reference vm $ref_name"
  exit 2
fi

log_msg 'Creating cloud-init data iso'
cat > /tmp/meta-data << EOF
instance-id: $vm_name
local-hostname: $vm_name
hostname: $vm_name
EOF

cat > /tmp/user-data << EOF
EOF

cloud-localds "$seed_iso" '/tmp/user-data' '/tmp/meta-data'

log_msg "Cloning $ref_name to $vm_name"
VBoxManage clonevm "$ref_name" --name="$vm_name" --register --snapshot='init' $additional_clone_args

log_msg 'Attaching cloud init iso'
vboxmanage storageattach "$vm_name" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium "$seed_iso"

bridge_adapter=$(ip -o -4 route show to default | awk '{print $5}')
log_msg "Setting VM network to bridge $bridge_adapter"
vboxmanage modifyvm "$vm_name" --nic1 bridged --bridgeadapter1 "$bridge_adapter"

log_msg 'Starting vm (cloud-init phase)'
vboxmanage startvm "$vm_name" --type headless

log_msg 'Wating for the VM to obtain an IP'
ip=''
ip=$(guestproperty_get "$vm_name" "$GUESTPROPERTY_IP_V4")
while [ -z "$ip" ]; do
  sleep 3
  ip=$(guestproperty_get "$vm_name" "$GUESTPROPERTY_IP_V4")
done
log_msg "Found VM ip: $ip"

log_msg 'Shutting down vm'
vboxmanage controlvm "$vm_name" poweroff

# Clean up
log_msg 'Clean up'
vboxmanage storageattach "$vm_name" --storagectl "SATA Controller" --port 1 --device 0 --medium none
vboxmanage closemedium dvd "${seed_iso}"
rm '/tmp/user-data' '/tmp/meta-data' "$seed_iso"

log_msg 'Starting vm'
vboxmanage startvm "$vm_name"