#!/bin/bash

#
# Export a drive as nfs share 
# This script takes a drive label and creates a nfs export for this drive. 
# The drive is remounted using a new mount point. The new mount point is added to the fstab. 
#

this_path=$(dirname $(realpath $0))
source "$this_path/../functions/assert_run_as_root.sh"
source "$this_path/../functions/log.sh"
assert_run_as_root

function usage {
  echo "Usage: $0 [OPTION] DRIVELABEL"
  echo -e "-u USER \t The user to create the drive for"
  exit 1
}

user=$SUDO_USER
while getopts "u:" arg; do
  case "$arg" in
    # The user name to create the drive for 
    u)
      user="$OPTARG"
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND -1))

drive_name="$1"
if [ -z "$drive_name" ];then 
  usage
fi 

if [ -z "$user" ];then 
  log_error "Failed to get the user that invoked this script. Use the -u USERNAME switch to pass a user name please"
  exit 1
fi 

# Check if the drive actually exists 
found=$(blkid | grep "LABEL=\"$drive_name\"")
if [ ! -n "$found" ]; then
  log_error "The drive $drive_name was not found! Run blkid to get a list of known drives."
  exit 1
fi

# Use positive lookbehind / lookahead perl regex to get the drive type
type=$(echo $found | grep -oP '(?<=TYPE=")[\w\d]+(?=")')
if [ -z "$type" ];then 
  log_error "Failed to identify the drive type!"
  exit 1
fi 

# Setup the new drive mount point 
mount_point="/media/$user/${drive_name}"
if [ -d $mount_point ];then 
  log_error "The directory $mount_point already exists. Make sure this nfs drive is not already registered"
  exit 1
fi
log_msg "Creating new directory to mount the drive: $mount_point"
mkdir -p $mount_point

# Unmount the drive it is mounted already 
hwa=$(sed 's/: .*//g' <<<$found)
if grep -qs "$hwa" /proc/mounts; then 
  umount "$hwa"
fi
# Mount it using the new mount point 
mount "$hwa" "$mount_point"
chown "$user" "$mount_point"

# Setup fstab 
log_msg "Adding the new drive to fstab. A backup is available under /etc/fstab.bak"
cp /etc/fstab /etc/fstab.bak 
echo "LABEL=$drive_name $mount_point $type defaults 0 0" >> /etc/fstab

# Setup exports 
log_msg "Adding the new drive to the list of exports. A backup of the file is availab eunder /etc/exports.bak"
cp /etc/exports /etc/exports.bak 
# I bet there is a way to get this without the cut 
# This generates an ip range (full access for all ips that start with the first three octets of the current machines ip)
ip_net="$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}' | cut -c1-12)0/255.255.255.0"
echo "$mount_point $ip_net(rw,async)" >> /etc/exports

# Reload exports 
log_msg "Reloading the exports"
exportfs -ra 
