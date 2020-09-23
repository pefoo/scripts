#!/bin/bash

#
# The gnome extensions confgiuration
#
# The associative array keys are the extension names. 
# The value is the extension id, that is used to download the extension. 
# Flag is used to denote dependencies.
#

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

source "$(get_script_path)/config_helper.sh"

# Extension IDs taken from https://extensions.gnome.org
declare -Ar EXTENSIONS=(
[Alt_ tab_switcher]=\
"1317;\
Remove alt tab popup delay;\
"

[Hibernate_button]=\
"755;\
Add a hibernate button to the menu;\
"

[No_title_bar]=\
"723;\
Remove the application title when window is maximized;\
"

[User_themes]=\
"19;\
Load shell themes from user directory;\
"

[Workspace_matrix]=\
"1485;\
Display workspaces as grid;\
"

[System_monitor]=\
"120;\
System monitor in top panel;\
gir1.2-clutter-1.0 gir1.2-clutter-gst-3.0 gir1.2-gtkclutter-1.0 gir1.2-gtop-2.0"
)
