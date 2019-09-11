#!/bin/bash

#
# This is a wrapper script for several setup / utility scripts that provides
# basic functionality behind a minimal UI 
#

readonly THIS_PATH=$(dirname $(realpath $0))
source "$THIS_PATH/../functions/log.sh"
source "$THIS_PATH/../functions/assert_run_as_root.sh"

export NEWT_COLORS="
root=,gray
title=black,
window=,lightgray
border=lightgray,black
textbox=black,
button=white,gray
listbox=black,lightgray
checkbox=black,lightgray
actcheckbox=white,gray
actlistbox=white,gray
actsellistbox=white,gray
sellistbox=red,gray
"

#
# Press enter to continue
#
function pause() {
  read -p 'Press [Enter] to continue'
}

function get_user() {
  local user=$SUDO_USER
  if [ -z "$user" ];then 
    clear 
    log_error "Failed to get the invoking user name. Gnome extensions are installed local."
    pause
    exit 1
  fi
  echo "$user"
}

#
# Implementation of Update packages menu item 
# Update exsting packes using the package_management script
#
function mi_update_packages() {
  clear 
  source "$THIS_PATH/package_management.sh"
  update_packages
  pause
}

#
# Implementation of Install packages menu item 
# Provide a list of common packages and install the selected ones 
#
function mi_install_packages() {
  selection=$(whiptail --title "Select common packages to install" --checklist \
    "Use space to select packages" 25 100 16 \
    "vim"               "Good old vim"                ON \
    "tmux"              "Terminal multiplexer"        ON \
    "git"               "Source control"              ON \
    "openssh-server"    "The open ssh server"         OFF \
    "monit"             "A log file watcher"          OFF \
    "fail2ban"          "Ban IPs that fail to login"  OFF \
    "nfs-kernel-server" "Network file system server"  OFF \
    "nfs-common"        "Network file system client"  OFF \
    "ntfs-3g"           "NTFS driver"                 OFF \
    3>&1 1>&2 2>&3)

  # Cancel 
  [ "$?" -eq 1 ] && return 0
  # Nothing was selected 
  [ -z "$selection" ] && return 0

  clear 
  source "$THIS_PATH/package_management.sh"
  # Remove quotes (") from the selection and install the packages 
  install_packages $(echo "$selection" | tr -d '"')
  pause
}

#
# Implementation of the install gnome extensions menu item
# Provide a list of common extensions and install the selected ones
#
function mi_install_gnome_extensions() {
  user=$(get_user)

  # Run the gnome extension management in a subshell that is owned by the actual user (not root)
  # current path and the whiptail color scheme is passed to the subshell 
  sudo -H -u "$user" bash -c '
    source "$0/install_gnome_extensions.sh" -i
    export NEWT_COLORS="$1"

    # Build the menu using the extensions provided by the script 
    c=0
    for extension in "${!EXTENSIONS[@]}"; do
      items[$(((c++)))]="${EXTENSIONS[$extension]}"
      items[$(((c++)))]="$extension"
      items[$(((c++)))]=ON
    done

    selection=$(whiptail --title "Select gnome extensions to install" --checklist \
      "Use space to select extensions" 25 100 16 \
      "${items[@]}" \
      3>&1 1>&2 2>&3)

    # Cancel 
    [ "$?" -eq 1 ] && exit 0
    # Nothing was selected 
    [ -z "$selection" ] && exit 0

    clear 
    install_prerequisites
    install_extensions $(echo "$selection" | tr -d "\"")
  ' "$THIS_PATH" "$NEWT_COLORS"
  pause
}

#
# Implementation of the install vim plugins menu item 
#
function mi_install_vim_plugins() {
  user=$(get_user)

  sudo -H -u "$user" bash -c '
    clear
    source "$0/install_vim_plugins.sh" -i
    export NEWT_COLORS="$1"
    c=0
    for plugin in "${!PLUGINS[@]}"; do
      items[$(((c++)))]="$plugin"
      items[$(((c++)))]=""
      items[$(((c++)))]=ON
    done
    selection=$(whiptail --title "Select vim plugins to install" --checklist \
      "Use space to select plugins" 25 100 16 \
      "${items[@]}" \
      3>&1 1>&2 2>&3)

    # Cancel 
    [ "$?" -eq 1 ] && exit 0
    # Nothing was selected 
    [ -z "$selection" ] && exit 0

    clear 
    for s in $selection; do
      plugin=$(echo "$s" | tr -d "\"")
      install_plugin "$plugin" "${PLUGINS[$plugin]}"
    done
  ' "$THIS_PATH" "$NEWT_COLORS"
  pause
}

#
# Implementation of the setup dot files menu item 
#
function mi_setup_dot_files() {
TO BE DONE
}

assert_run_as_root

#
# Menu loop 
#
while true; do
  menu_items[0]="1"; menu_items[1]="Update packages"
  menu_items[2]="2"; menu_items[3]="Install packages"
  menu_items[4]="3"; menu_items[5]="Install gnome extensions"
  menu_items[6]="4"; menu_items[7]="Install vim plugins"
  menu_items[8]="5"; menu_items[9]="Setup dot files"

  selection=$(whiptail --title "System setup" --menu "Main menu" --cancel-button "Exit" \
    25 100 16 "${menu_items[@]}" 3>&1 1>&2 2>&3)
  ret=$?

  # 1 -> closed using exit 
  # 255 -> closed using esc (even though the doc states something else)
  if [ "$ret" -eq 1 ] || [ "$ret" -eq 255 ];then 
    exit 0
  fi

  
  case "$selection" in
    "1")
      mi_update_packages
      ;;
    "2")
      mi_install_packages
      ;;
    "3")
      mi_install_gnome_extensions
      ;;
    "4")
      mi_install_vim_plugins
      ;;
    "5")
      mi_setup_dot_files
      ;;
    *)
      clear
      log_error "How the heck did you get here?!"
      exit 1;
  esac
done

