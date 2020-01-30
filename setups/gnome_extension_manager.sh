#!/bin/bash

#
# This script installs my common gnome extension. For a list of exntesion see the EXNTENSIONS array. 
# The extensions are installed for local user only, in order to install them system wide change the content of 
# EXTENSION_FOLDER to /usr/local/share/gnome-shell/extensions
#
# For more information about gnome shell extensions and their installation visit 
# http://www.bernaerts-nicolas.fr/linux/76-gnome/345-gnome-shell-install-remove-extension-command-line-script
#
# Once installed, restart the gnome shell (alt-f2 -> r). The new extensions will appear in gnome tweak tools
#


# Entry point
# Globals: 
#   VERBOSE_MODE
#   EXTENSIONS
#   APT_QUIET
# Arguments:
#   None
# Returns:
#   None 
main() {
  while getopts "vh" o; do
    case "$o" in
      v)
        VERBOSE_MODE=true
        ;;
      h)
        usage
        exit 0
        ;;
      \?)
        usage
        exit 1
        ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ $VERBOSE_MODE == "true" ]]; then
    APT_QUIET=""
  else
    APT_QUIET="-qq"
  fi

  source "$(get_script_path)/../functions/log.sh"
  source "$(get_script_path)/config/gnome_extensions.sh"

  local instruction
  instruction="$1"
  case "$instruction" in
    install)
      install_all_extensions
      ;;
    update)
      update_all_extensions
      ;;
    *)
      [ ! -z "$instruction" ] && echo -e "Instruction $instruction is invalid.\n"
      usage
      exit 1
      ;;
  esac

}

usage() {
  echo "$(basename "${BASH_SOURCE[0]}") [OPTION] install | update"
  echo "Options:"
  echo -e "\t-v\tVerbose output"
  echo -e "\t-h\tShow this help"
  echo "Instructions:"
  echo -e "\tinstall\tInstall the configured gnome extensions"
  echo -e "\tupdate\tUpdate the configured gnome extensions"
}

# Get this script path as absolute path 
# Arguments: 
#   None 
# Returns:
#   The absolute path to this script
get_script_path() {
  pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null
  pwd
  popd > /dev/null
}

# Install extension prerequisites 
# Arguments:
#   The package list to install
# Returns:
#   None
function install_prerequisites() {
  log_msg "Installing extension prerequisites: $1"
  if [[ -z "$1" ]]; then
    log_error "Proviade a package list to install."
    return 1
  fi
  sudo apt install -y $APT_QUIET  "$1"
}

# Install gnome extension 
# Args:
#   The extension ID
#   The extension configuration string 
# Returns:
#   None
function install_extension {
  local -r EXTENSION_SITE="https://extensions.gnome.org"
  local -r EXTENSION_FOLDER="$HOME/.local/share/gnome-shell/extensions"
  # Get gnome shell version 
  local -r GNOME_VERSION=$(gnome-shell --version | grep -oP '\d\.\d{2}')
  if [ -z "$GNOME_VERSION" ];then 
    log_error "Failed to get gnome shell version"
    exit 1
  fi

  local extension="$1"
  local id
  id=$(get_config_value "$2")
  local dependencies
  dependencies=$(get_config_flag "$2")

  if [[ ! "$dependencies" == "None" ]]; then 
    install_prerequisites $dependencies
  fi

  local extension_params
  extension_params=$(wget -O- "${EXTENSION_SITE}/extension-info/?pk=${id}&shell_version=$GNOME_VERSION" 2>&1 \
    || grep -i "failed\|error"; exit ${PIPESTATUS[0]})
  if [ "$?" -ne 0 ];then 
    log_error "Failed to get the extension parameters"
    log_error "$extension_params"
    exit 1
  fi

  local extension_uuid
  extension_uuid=$(grep -oP '(?<=uuid":\s").*?(?=")' <<< "$extension_params")
  if [ -z "$extension_uuid" ];then
    log_error "Failed to extract the extension uuid."
    exit 1
  fi

  local download_url
  download_url=$(grep -oP '(?<=download_url":\s").*?(?=")' <<< "$extension_params")
  if [ -z "$download_url" ];then
    log_error "Failed to extract the download url."
    exit 1
  fi

  local ext_path
  ext_path="${EXTENSION_FOLDER}/${extension_uuid}"
  
  if [ -d "$ext_path" ];then
    log_msg "The extension $extension_uuid is already installed in $ext_path"
    return 0
  fi

  mkdir -p "$ext_path"
  wget -qO ext.zip "${EXTENSION_SITE}${download_url}"
  if [ "$?" -ne 0 ];then 
    log_error "Failed to download the extension using the url ${EXTENSION_SITE}${download_url}"
    exit 1
  fi

  unzip -q ext.zip -d "$ext_path"
  log_msg "Installed extension $extension_uuid to $ext_path"
  if [[ "$VERBOSE_MODE" == "true" ]]; then 
    print_config "$extension" "$2" | sed -e 's/^/    /'
  fi
  rm ext.zip
}

install_all_extensions() {
  for extension in "${!EXTENSIONS[@]}"; do
    install_extension "$extension" "${EXTENSIONS[$extension]}"
  done 
}

update_all_extensions() {
  log_error "Not implemented"
  exit 255
}

main "$@"; exit
