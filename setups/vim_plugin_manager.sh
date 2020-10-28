#!/bin/bash

#
# Vim-8 configuration based plugin management. 
# Capable of installing / updating the configured vim plugins. 
#
# All vim plugins are installed / updated using git.
#

# Entry point
# Globals:
#   VERBOSE_MODE
#   VIM_PLUGINS
# Arguments:
#   None
# Returns:
#   None
main() {
  source "$(get_script_path)/../functions/log.sh"
  source "$(get_script_path)/config/vim.sh"
  readonly PLUGIN_BASE_DIR="$HOME/.vim/pack/default"

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

  local instruction
  instruction="$1"
  case "$instruction" in
    install)
      install_all_plugins
      ;;
    update)
      update_all_plugins
      ;;
    show)
      show_all_plugins
      ;;
    *)
      [ ! -z "$instruction" ] && echo -e "Instruction $instruction is invalid.\n"
      usage
      exit 1
      ;;
  esac
}

usage() {
  echo "$(basename "${BASH_SOURCE[0]}") [OPTION] install | update | show"
  echo "Options:"
  echo -e "\t-v\tVerbose output"
  echo -e "\t-h\tShow this help"
  echo "Instructions:"
  echo -e "\tinstall\tInstall the configured vim plugins"
  echo -e "\tupdate\tUpdate the configured vim plugins"
  echo -e "\tshow\tShow all configured plugins"
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

# Install a single vim plugin using git
# Arguments:
#   The plugin name (this name is used as installation folder name)
#   The plugin configuration string
# Returns: 
#   None
install_plugin() {
  local plugin="$1"
  local source_url
  source_url="$(get_config_value "$2")"

  if [ -z "$plugin" ] || [ -z "$source_url" ]; then 
    log_error "Provide a plugin name and source url for the vim plugin you want to install"
    return 1
  fi

  local plugin_dir
  plugin_dir="${PLUGIN_BASE_DIR}/start/${plugin}"
  if [ -d "$plugin_dir" ]; then 
    log_msg "The plugin $plugin is already installed in $plugin_dir"
    if [ "$VERBOSE_MODE" == true ]; then 
      print_config "$plugin" "$2" | sed -e 's/^/    /'
    fi
  else
    mkdir -p "$plugin_dir"
    git clone -q "${source_url}" "$plugin_dir"
    log_msg "Installed plugin to $plugin_dir"
    if [ "$VERBOSE_MODE" == true ]; then 
      print_config "$plugin" "$2" | sed -e 's/^/    /'
    fi
  fi
}

# Update a single vim plugin using git pull and the current branch (most likely master)
# Arguments:
#   The plugin name (this name is used as installation folder name)
#   The plugin configuration string
# Returns: 
#   None
update_plugin() {
  local plugin="$1"
  local source_url
  source_url="$(get_config_value "$2")"

  if [ -z "$plugin" ] || [ -z "$source_url" ]; then 
    log_error "Provide a plugin name and source url for the vim plugin you want to update"
    return 1
  fi

  local plugin_dir
  plugin_dir="${PLUGIN_BASE_DIR}/start/${plugin}"
  if [ ! -d "$plugin_dir" ]; then 
    log_msg "The plugin $plugin is not installed"
    return 1
  fi

  pushd "${plugin_dir}" > /dev/null
  log_msg "Updating plugin $plugin"
  if [ "$VERBOSE_MODE" == true ]; then 
    print_config "$plugin" "$2" | sed -e 's/^/    /'
    git pull
  else
    git pull -q
  fi
  popd > /dev/null
}

# Install all configured vim plugins 
# Arguments:
#   None
# Returns: 
#   None
install_all_plugins() {
  for plugin in "${!VIM_PLUGINS[@]}"; do
    install_plugin "$plugin" "${VIM_PLUGINS[$plugin]}"
  done 
}

# Update all configured vim plugins 
# Arguments:
#   None 
# Returns: 
#   None
update_all_plugins() {
  for plugin in "${!VIM_PLUGINS[@]}"; do
    update_plugin "$plugin" "${VIM_PLUGINS[$plugin]}"
  done 
}

# Show all configured vim plugins 
# Arguments:
#   None 
# Returns: 
#   None
show_all_plugins() {
  for plugin in "${!VIM_PLUGINS[@]}"; do
    print_config "$plugin" "${VIM_PLUGINS[$plugin]}"
  done 
}

main "$@"; exit
