#!/bin/bash

#
# Export a folder as network file system 
# Args:
#   1) The folder to share 
#

this_path=$(dirname $(realpath $0))
source "$this_path/../functions/assert_run_as_root.sh"
source "$this_path/../functions/log.sh"
assert_run_as_root

function usage {
  echo "Usage: $0 share"
  echo "share - The folder to share"
  exit 1
}

share="$1"
if [ -z "$share" ];then 
  usage
  exit 0
fi 

if [ -d "$share" ];then 
  log_error "The folder $share does not exist."
  exit 0
fi

# Setup exports 
log_msg "Adding the new folder to the list of exports. A backup of the file is availab eunder /etc/exports.bak"
cp /etc/exports /etc/exports.bak 
# I bet there is a way to get this without the cut 
# This generates an ip range (full access for all ips that start with the first three octets of the current machines ip)
ip_net="$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}' | cut -c1-12)0/255.255.255.0"
echo "$drive $ip_net(rw,async)" >> /etc/exports

# Reload exports 
log_msg "Reloading the exports"
exportfs -ra 
