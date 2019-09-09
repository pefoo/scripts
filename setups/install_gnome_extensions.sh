#!/bin/bash

#
# This script installs my common gnome extension. For a list of exntesion see the EXNTENSIONS array. 
# The extensions are installed for local user only, in order to install them system wide change the content of 
# EXTENSION_FOLDER to /usr/local/share/gnome-shell/extensions
#
# For more information about gnome shell extensions and their installation visit http://www.bernaerts-nicolas.fr/linux/76-gnome/345-gnome-shell-install-remove-extension-command-line-script
#

readonly EXTENSION_SITE="https://extensions.gnome.org"
readonly EXTENSION_FOLDER="$HOME/.local/share/gnome-shell/extensions"

readonly THIS_PATH=$(dirname $(realpath $0))
source "$THIS_PATH/../functions/log.sh"

# Extension IDs taken from https://extensions.gnome.org
declare -Ar EXTENSIONS=(
  # https://EXTENSIONS.gnome.org/extension/1317/alt-tab-switcher-popup-delay-removal/
  [alt_tab_switcher]=1317
  # https://extensions.gnome.org/extension/755/hibernate-status-button/
  [hibernate_button]=755
  # https://extensions.gnome.org/extension/1267/no-title-bar/
  [no_title_bar]=1267
  # https://extensions.gnome.org/extension/19/user-themes/
  [user_themes]=19
  # https://extensions.gnome.org/extension/484/workspace-grid/
  [workspace_grid]=484
  # https://extensions.gnome.org/extension/1066/fix-multi-monitors/
  [multi_monitor_fix]=1066
  # https://extensions.gnome.org/extension/120/system-monitor/
  [system_monitor]=120
)

# Get gnome shell version 
readonly GNOME_VERSION=$(gnome-shell --version | grep -oP '\d\.\d{2}')
if [ -z "$GNOME_VERSION" ];then 
  log_error "Failed to get gnome shell version"  
fi

# Iterate over extensions and install them 
for extension in "${!EXTENSIONS[@]}"; do
  extension_params=$(wget -O- "${EXTENSION_SITE}/extension-info/?pk=${EXTENSIONS[$extension]}&shell_version=$GNOME_VERSION" 2>&1 || grep -i "failed\|error"; exit ${PIPESTATUS[0]})
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
    log_warn "The extension $extension with the uuid $extension_uuid is already installed in $ext_path"
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

