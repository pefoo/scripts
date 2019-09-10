#!/bin/bash

#
# This script installs my common gnome extension. For a list of exntesion see the EXNTENSIONS array. 
# The extensions are installed for local user only, in order to install them system wide change the content of 
# EXTENSION_FOLDER to /usr/local/share/gnome-shell/extensions
#
# For more information about gnome shell extensions and their installation visit http://www.bernaerts-nicolas.fr/linux/76-gnome/345-gnome-shell-install-remove-extension-command-line-script
#
# Once installed, restart the gnome shell (alt-f2 -> r). The new extensions will appear in gnome tweak tools
#

while getopts "i" o; do
  case "$o" in
    i)
      # This file was sourced from some interactive scrip. Skip actual execution
      interactive_mode=true
      ;;
  esac
done

readonly EXTENSION_SITE="https://extensions.gnome.org"
readonly EXTENSION_FOLDER="$HOME/.local/share/gnome-shell/extensions"

[ -d "$0" ] && readonly THIS_PATH="$0" || readonly THIS_PATH=$(dirname $(realpath $0))
source "$THIS_PATH/../functions/log.sh"

# Extension IDs taken from https://extensions.gnome.org
declare -Ar EXTENSIONS=(
  # https://EXTENSIONS.gnome.org/extension/1317/alt-tab-switcher-popup-delay-removal/
  [Alt tab switcher]=1317
  # https://extensions.gnome.org/extension/755/hibernate-status-button/
  [Hibernate button]=755
  # https://extensions.gnome.org/extension/1267/no-title-bar/
  [No title bar]=1267
  # https://extensions.gnome.org/extension/19/user-themes/
  [User themes]=19
  # https://extensions.gnome.org/extension/484/workspace-grid/
  [Workspace grid]=484
  # https://extensions.gnome.org/extension/1066/fix-multi-monitors/
  [Multi monitor fix]=1066
  # https://extensions.gnome.org/extension/120/system-monitor/
  [System monitor]=120
)

# Install extension prerequisites 
# Args:
#   NONE
function install_prerequisites() {
  log_msg "Installing extension prerequisites"
  sudo apt install -y -qq  gir1.2-gtop-2.0 gir1.2-networkmanager-1.0  gir1.2-clutter-1.0
}

# Install gnome extension 
# Args
#   *) The extension ID(s) to install 
function install_extensions {
  # Get gnome shell version 
  readonly GNOME_VERSION=$(gnome-shell --version | grep -oP '\d\.\d{2}')
  if [ -z "$GNOME_VERSION" ];then 
    log_error "Failed to get gnome shell version"  
  fi

  # Iterate over extensions and install them 
  for extension in "$@"; do
    extension_params=$(wget -O- "${EXTENSION_SITE}/extension-info/?pk=${extension}&shell_version=$GNOME_VERSION" 2>&1 || grep -i "failed\|error"; exit ${PIPESTATUS[0]})
    if [ "$?" -ne 0 ];then 
      log_error "Failed to get the extension parameters"
      log_error "$extension_params"
      exit 1
    fi

    extension_uuid=$(grep -oP '(?<=uuid":\s").*?(?=")' <<< "$extension_params")
    if [ -z "$extension_uuid" ];then
      log_error "Failed to extract the extension uuid."
      exit 1
    fi

    download_url=$(grep -oP '(?<=download_url":\s").*?(?=")' <<< "$extension_params")
    if [ -z "$download_url" ];then
      log_error "Failed to extract the download url."
      exit 1
    fi
    ext_path="${EXTENSION_FOLDER}/${extension_uuid}"
    
    if [ -d "$ext_path" ];then
      log_warn "The extension $extension_uuid is already installed in $ext_path"
      continue
    fi

    mkdir -p "$ext_path"
    wget -qO ext.zip "${EXTENSION_SITE}${download_url}"
    if [ "$?" -ne 0 ];then 
      log_error "Failed to download the extension using the url ${EXTENSION_SITE}${download_url}"
      exit 1
    fi

    unzip -q ext.zip -d "$ext_path"
    log_msg "Installed extension $extension_uuid to $ext_path"
    rm ext.zip
  done 
}

if [ ! "$interactive_mode" == true ];then 
  install_extensions "${EXTENSIONS[@]}"
fi
