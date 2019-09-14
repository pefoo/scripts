#!/bin/bash 

#
# Mount a network file system share and add it to fstab 
#

while getopts "i" o; do
  case "$o" in
    i)
      # This file was sourced from some interactive scrip. Skip actual execution
      interactive_mode=true
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "$THIS_PATH" ]; then 
  [ -d "$0" ] && readonly THIS_PATH="$0" || readonly THIS_PATH=$(dirname $(realpath $0))
fi
source "$THIS_PATH/../functions/log.sh"
source "$THIS_PATH/../functions/assert_run_as_root.sh"
assert_run_as_root

readonly NFS_PORT=2049

# Assert that the nfs server is running 
# Args:
#   1) The host to check 
function assert_server_running() {
  nc -zw 3 "$1" "$NFS_PORT" &>/dev/null
  if [ "$?" -ne 0 ];then 
    log_error "Port $NFS_PORT is closed on the server $HOST. This usually means the nfs server is not running"
    return 1
  fi
}

# Get a list of directories, a server exports 
# Args:
#   1) The host to check
function get_exports() {
  showmount -e "$1" | tail -n +2
}

# Check whether the server actually exports the request directory 
# Args:
#   1) The host to check 
#   2) The directory to check 
function check_export() {
  get_exports "$1" | grep -Pq "^${2}\s+.*$"
  if [ "$?" -ne 0 ]; then 
    log_error "The host $HOST does not export the requested path $EXPORT"
    return 1
  fi 
}

# Prepare the client (install nfs-common)
function prepare_client() {
  # check if package nfs-common is installed 
  dpkg -s nfs-common &>/dev/null
  if [ "$?" -ne 0 ]; then 
    log_msg "Package nfs-common not found. Installing it."
    apt install -yqq nfs-common
  fi
}

# Check whether the nfs share is already mounted 
# Args:
#   1) The nfs share to check 
function check_not_mounted() {
  m=$(mount | grep -Po "^$1 on [^\s]+" | sed 's/on/mounted at/g')
  if [ ! -z "$m" ]; then 
    log_error "The share is already mounted: $m"
    return 1
  fi
}

# Mount the network share 
# Args:
#   1) The share to mount 
#   2) The mount point
function mount_share() {
  log_msg "Mounting $1 at $2."
  mkdir -p "$2"
  mount "$1" "$2"
}

# Add the nfs share to fstab 
# Args:
#   1) The share to mount 
#   2) The mount point 
function update_fstab() {
  log_msg "Updating fstab. Backup is available under /etc/fstab.bak"
  cp /etc/fstab /etc/fstab.bak
  echo "$1 $2 nfs rw,nofail 0 0" >> /etc/fstab
}

if [ ! "$interactive_mode" == true ];then 
  # Check arguments 
  if [ "$#" -ne 2 ]; then
    echo "Usage: $0 {share} {dir}" 
    echo "share - The nfs share to mount. {host}:{export}"
    echo "dir   - The directory to mount the share into"
    exit 1
  fi

  readonly SHARE="$1"
  readonly HOST=${SHARE%%:*}
  readonly EXPORT=${SHARE##*:}
  readonly DIR="$2"

  prepare_client
  assert_server_running "$HOST"
  if ! assert_server_running "$HOST";then 
    exit 1
  fi

  if ! check_export "$HOST" "$EXPORT"; then 
    exit 1
  fi

  if ! check_not_mounted "$SHARE";then 
    exit 1
  fi

  if ! mount_share "$SHARE" "$DIR"; then 
    exit 1
  fi
  update_fstab "$SHARE" "$DIR"
fi 





