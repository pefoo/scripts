#!/bin/bash
#
# The configuration helper. 
# Provides means to access the configuration associative arrays in a more convenient way. 
#
# Every configuration is a associative array with a key and a value. 
# The value is a string with different items separated by a semicolon. 
# [key]="VALUE;DESCRIPTION;FLAG" 
# The flag may be used for arbitrary purpose. 
#

# The item index in the configuration value string 
readonly VALUE=0
readonly DESCRIPTION=1
readonly FLAG=2

# Get an arbitrary configuration field item 
# Arguments:
#   The configuration field (a string with semicolons to separate items)
#   The index of the item to get
# Returns:
#   The value of the configuration item
get_config_item(){
  if [[ -z $1 ]]; then 
    echo "No configuration string provided!"
    return 1
  fi

  if [[ -z $2 ]]; then 
    echo "No configuration field index provided!"
    return 1
  fi

  local ifs_old=$IFS
  IFS=';'
  read -r -a ar <<< "$1"
  if [[ -z "${ar[$2]}" ]]; then 
    echo "None"
  else 
    echo "${ar[$2]}"
  fi
  IFS=$ifs_old

  return 0
}

# Get the value of a configuration field 
# Arguments:
#   The configuration field (a string with semicolons to separate items)
# Returns:
#   The value of the configuration field
get_config_value() {
  get_config_item "$1" "$VALUE"
}

# Get the description of a configuration field 
# Arguments:
#   The configuration field (a string with semicolons to separate items)
# Returns:
#   The description of the configuration field
get_config_description() {
  get_config_item "$1" "$DESCRIPTION"
}

# Get the flag of a configuration field 
# Arguments:
#   The configuration field (a string with semicolons to separate items)
# Returns:
#   The flag of the configuration field
get_config_flag() {
  get_config_item "$1" "$FLAG"
}

# Print the configuration
# Arguments: 
#   The configuration key 
#   The configuration associative array value (as a whole)
# Returns:
#   None
print_config() {
  if [[ -z $1 ]]; then 
    echo "No configuration key provided!" 
    return 1
  fi
  if [[ -z $2 ]]; then 
    echo "No configuration value provided!"
    return 1
  fi

  echo -e "\e[1;32m${1}\e[0m"
  printf "  \e[1m%-15s\e[0m%s\n" "value:" "$(get_config_value "$2")"
  printf "  \e[1m%-15s\e[0m%s\n" "description:" "$(get_config_description "$2")"
  printf "  \e[1m%-15s\e[0m%s\n" "flag:" "$(get_config_flag "$2")"
}
