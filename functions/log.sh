#!/bin/bash

#
# Provides log messages in different colors 
#

# Write green message 
# Arguemtns:
#   Message to display
function log_msg {
  echo -e "\e[92m${1}\e[39m"
}

# Write yellow message 
# Arguemtns:
#   Message to display
function log_warn {
  echo -e "\e[93m${1}\e[39m"
}

# Write red message 
# Arguemtns:
#   Message to display
function log_error {
  echo -e "\e[91m${1}\e[39m"
}
