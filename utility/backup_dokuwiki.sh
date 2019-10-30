#!/bin/bash
#
# Backup dokuwiki
#
# Args:
#   1) Path the the diki
#   2) Path to backup to 
#   3) Max backups to keep 

readonly THIS_PATH=$(dirname $(realpath $0))
source "$THIS_PATH/../functions/backup_utils.sh"

readonly WIKIPATH="$1"
readonly BACKUPPATH=$(realpath "$2")
readonly MAXBACKUPS="$3"

# using -v/-z doesnt do the trick here. No idea why
[[ "$WIKIPATH" == "" ]] && echo "Provide the path to the dokuwiki installation" && exit 1
[[ ! -d "$WIKIPATH" ]] && echo "The wiki path was not found" && exit 1
[[ "$BACKUPPATH" == "" ]] && echo "Provide the path to the backup destination" && exit 1
[[ "$MAXBACKUPS" == "" ]] && echo "Provide the max backup count" && exit 1
mkdir -p "$BACKUPPATH"

backup_file=$(get_backup_file_name 'dokuwiki' 'tar.bz2')

pushd "$WIKIPATH/.." > /dev/null
tar -cjf "$BACKUPPATH/$backup_file" "$(basename "$WIKIPATH")"
popd > /dev/null
cleanup_backups "$MAXBACKUPS" "$BACKUPPATH" 'dokuwiki*.tar.bz2'
