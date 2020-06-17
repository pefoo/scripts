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
"1267;\
Remove the application title when window is maximized;\
"

[User_themes]=\
"19;\
Load shell themes from user directory;\
"

[Workspace_grid]=\
"484;\
Display workspaces as grid;\
"

[Multi_monitor_fix]=\
"1066;\
Fix multi monitor setups;\
"

[System_monitor]=\
"120;\
System monitor in top panel;\
gir1.2-gtop-2.0 gir1.2-networkmanager-1.0  gir1.2-clutter-1.0"

[Do_not_disturb_button]=\
"964;\
Do not disturb buttin;\
"
)
