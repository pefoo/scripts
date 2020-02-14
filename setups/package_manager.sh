#!/bin/bash

#
# Anything package managemt relates goes here. 
# Provides means to update exsting apps, install environments
#

# Entry point 
# Globals 
#   APT_QUIET 
#   OFFICIAL_PACKAGE
#   ENV_MINIMAL
#   ENV_DESKTOP
#   ENV_SERVER
#   ENV_ODROID
#   ENV_ALL
#   PACKAGES
# Arguments:
#   None
# Returns:
#   None
main() {
  source "$(get_script_path)/../functions/log.sh"

  while getopts "vh" o; do
    case "$o" in
      v)
        local verbose
        verbose=true
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

  if [[ "$verbose" == "true" ]]; then
    APT_QUIET=""
  else
    APT_QUIET="-qq"
  fi

  source "$(get_script_path)/config/packages.sh"
  local instruction
  instruction="$1"

  case "$instruction" in
    # Install the provided environment
    install)
      local env
      env="$2"
      if [[ -z "$env" ]]; then
        echo "Provide a environment to install."
        exit
      fi
      install_environment "$env"
      ;;
    # Simply update everything 
    update)
      update_packages
      ;;
    # List all available environments
    list)
      echo "Available environments: $ENV_ALL"
      ;;
    # Display the packages of an environment
    show)
      local env
      env="$2"
      if [[ -z "$env" ]]; then
        echo "Provide a environment to show."
        exit 1
      fi
      print_env "$env"
      ;;
    # Failed to parse instruction
    *)
      [ ! -z "$instruction" ] && echo -e "Instruction $instruction is invalid.\n"
      usage
      exit 1
      ;;
  esac
}

usage() {
  echo "$(basename "${BASH_SOURCE[0]}") [OPTION] install {ENVIRONMENT} | update | list | show {ENVIRONMENT}"
  echo "Options:"
  echo -e "\t-v\tVerbose output (display more output of apt)"
  echo -e "\t-h\tShow this help"
  echo "Instructions:"
  echo -e "\tinstall\tInstall the configured vim plugins"
  echo -e "\tupdate\tUpdate the configured vim plugins"
  echo -e "\tlist\tList all available environments"
  echo -e "\tshow\tShow the packages of an environment"
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

# Update existing packages 
# Arguments:
#   NONE
update_packages() {
  sudo apt update $APT_QUIET
  local updates
  updates=$(apt list --upgradable 2>/dev/null | grep -v "Listing\|Done")
  sudo apt upgrade -y $APT_QUIET
  log_msg "$updates"
}

# Just install some packages
# Arguments
#  The packages to install 
install_packages() {
  sudo apt install -y $APT_QUIET "$@"
}

# Install a environment
# Arguments:
#   The environment name to install 
# Returns:
#   None 
install_environment() {
  local env
  env="$1"
  if [[ -z $env ]]; then 
    echo "Select an environment to install"
    return 1
  fi
  

  for package in "${!PACKAGES[@]}"; do
    local tag
    tag="$(get_config_flag "${PACKAGES[$package]}")"
    local value
    value="$(get_config_value "${PACKAGES[$package]}")"

    if [[ "$tag" == *"$env"* ]]; then 
      if [[ "$value" == "$OFFICIAL_PACKAGE" ]]; then 
        log_msg "Installing package using official repositories:"
        print_config "$package" "${PACKAGES[$package]}" | sed -e 's/^/    /'
        install_packages "$package"
      else 
        log_msg "Installing package using custom script: $value"
        print_config "$package" "${PACKAGES[$package]}" | sed -e 's/^/    /'
        if ! source "$value"; then 
          log_error "Failed to install package ${package}!"
        fi 
      fi
    fi
  done
}

main "$@"; exit
