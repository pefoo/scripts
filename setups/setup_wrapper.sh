#!/bin/bash

#
# This is a wrapper script for several setup / utility scripts that provides
# basic functionality behind a minimal UI 
#
# Certain functionality is executed as the invoking user (not root). Therefore, a new subshell, started as the user, is used.
# Signal a process abort (esc key press or cancel button press) in a subshell by returning 1 from it.
#

readonly THIS_PATH=$(dirname $(realpath $0))
source "$THIS_PATH/../functions/log.sh"
source "$THIS_PATH/../functions/assert_run_as_root.sh"
assert_run_as_root

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
entry=white,gray
"

#
# Check whether the last whiptail dialog was canceled 
#
function if_cancel() {
  ret="$?"
  [ "$ret" -eq 1 ] || [ "$ret" -eq 255 ]
}

#
# Check whether the last whiptail dialog was not canceled 
#
function if_not_cancel() {
  ret="$?"
  [ "$ret" -ne 1 ] && [ "$ret" -ne 255 ]

}

#
# Press enter to continue
#
function pause() {
  read -p 'Press [Enter] to continue'
}

#
# Get the user name that called this script 
#
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
  local selection=$(whiptail --title "Select common packages to install" --checklist \
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
  if_cancel && return 1
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
  local user=$(get_user)

  # Run the gnome extension management in a subshell that is owned by the actual user (not root)
  # current path and the whiptail color scheme is passed to the subshell 
  sudo -H -u "$user" bash -c '
    source "$0/install_gnome_extensions.sh" -i
    export NEWT_COLORS="$1"
    eval "$2"

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
    if_cancel && exit 1
    # Nothing was selected 
    [ -z "$selection" ] && exit 1

    clear 
    install_prerequisites
    install_extensions $(echo "$selection" | tr -d "\"")
  ' "$THIS_PATH" "$NEWT_COLORS" "$(declare -f if_cancel)"
  if_not_cancel && pause
}

#
# Implementation of the install vim plugins menu item 
#
function mi_install_vim_plugins() {
  local user=$(get_user)

  sudo -H -u "$user" bash -c '
    clear
    source "$0/install_vim_plugins.sh" -i
    export NEWT_COLORS="$1"
    eval "$2"

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
    if_cancel && exit 1
    # Nothing was selected 
    [ -z "$selection" ] && exit 1

    clear 
    for s in $selection; do
      plugin=$(echo "$s" | tr -d "\"")
      install_plugin "$plugin" "${PLUGINS[$plugin]}"
    done
  ' "$THIS_PATH" "$NEWT_COLORS" "$(declare -f if_cancel)"
  if_not_cancel && pause
}

#
# Implementation of the setup dot files menu item 
#
function mi_setup_dot_files() {
  local user=$(get_user)
  sudo -H -u "$user" bash -c '
    source "$0/../functions/log.sh"
    export NEWT_COLORS="$1"
    eval "$2"

    readonly CONFIGS_DIR="$HOME/configs"
    readonly LINKER_SCRIPT="${CONFIGS_DIR}/dotfiles/link_dotfiles.sh"

    if [ ! -d "$CONFIGS_DIR" ]; then 
      log_msg "Cloning configuration repository to $CONFIGS_DIR"
      git clone -q https://github.com/pefoo/configs.git "$CONFIGS_DIR"
    fi
    
    if [ ! -f "$LINKER_SCRIPT" ]; then 
      log_error "The dot file linker script is missing. \
        Make sure to checkout the configs repository and check that the linker script is located in $LINKER_SCRIPT"
      exit 2
    fi 

    git_user=$(whiptail --inputbox "Please enter your git user name." 8 78 "$USER" \
      --title "Setup dot files" 3>&1 1>&2 2>&3)

    if_cancel && exit 1
    if [ -z "$git_user" ];then 
      log_error "Empty user name is not allowed"
      exit 1
    fi

    git_mail=$(whiptail --inputbox "Please enter your git email." 8 78 \
      --title "Setup dot files" 3>&1 1>&2 2>&3)
    if_cancel && exit 1
    if [ -z "$git_mail" ];then 
      log_error "Empty email is not allowed"
      exit 1
    fi

    source "$LINKER_SCRIPT" -b "$CONFIGS_DIR/dotfiles" -u "$git_user" -m "$git_mail"
  ' "$THIS_PATH" "$NEWT_COLORS" "$(declare -f if_cancel)"
  if_not_cancel && pause

}

#
# Implementation of the mount nfs share menu item 
# Allows to mount one or more shares per host
#
function mi_mount_nfs_share() {
  local user=$(get_user)
  # Using local inline changes the return value for some reason
  local HOST
  HOST=$(whiptail --inputbox "Enter the server ip or hostname" 8 78 \
    --title "Mount nfs" 3>&1 1>&2 2>&3)
 
  if_cancel && return 1
  source "$THIS_PATH/mount_nfs_share.sh" -i
  
  clear
  prepare_client

  if ! assert_server_running "$HOST";then 
    pause
    return 1
  fi


  local -r EXPORTS=$(get_exports "$HOST")
  local c=0
  local -a items
  while read -r export; do
    items[$(((c++)))]=$(echo "$export" | grep -Po '^[^\s]+')
    items[$(((c++)))]=""
    items[$(((c++)))]=ON
  done <<< "$EXPORTS"
  
  local selection
  selection=$(whiptail --title "Select shares to mount" --checklist \
    "Use space to select a share" 25 100 16 \
    "${items[@]}" \
    3>&1 1>&2 2>&3)

  if_cancel && return 1
  clear 

  for s in $selection; do
    local share=$(echo "$s" | tr -d "\"")
    if ! check_not_mounted "${HOST}:${share}"; then 
      continue
    fi

    local default_dir="/media/${user}/$(basename "$share")"
    local dir
    dir=$(whiptail --inputbox "Enter a path to mount $share"  8 78 "$default_dir"\
      --title "Mount nfs" 3>&1 1>&2 2>&3)
    if_cancel && continue
    if ! mount_share "${HOST}:$share" "$dir"; then 
      continue
    fi
    update_fstab "${HOST}:$share" "$dir"
  done

  pause
}

# 
# Create nfs share menu item implementation 
# Creates a new network file system share 
#
function mi_create_nfs_share() {
  local share
  share=$(whiptail --inputbox "Please enter the path to the folder you want to share." 8 78 "$share" \
    --title "Create nfs share" 3>&1 1>&2 2>&3)

  source "$THIS_PATH/create_nfs_share.sh" "$share"
  pause
  
}

#
# Menu loop 
#
while true; do
  menu_items[0]="1"; menu_items[1]="Update packages"
  menu_items[2]="2"; menu_items[3]="Install packages"
  menu_items[4]="3"; menu_items[5]="Install gnome extensions"
  menu_items[6]="4"; menu_items[7]="Install vim plugins"
  menu_items[8]="5"; menu_items[9]="Setup dot files"
  menu_items[10]="6"; menu_items[11]="Mount nfs share"
  menu_items[12]="7"; menu_items[13]="Create nfs share"

  selection=$(whiptail --title "System setup" --menu "Main menu" --cancel-button "Exit" \
    25 100 16 "${menu_items[@]}" 3>&1 1>&2 2>&3)

  if_cancel && exit 0

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
    "6")
      mi_mount_nfs_share
      ;;
    "7")
      mi_create_nfs_share
      ;;
    *)
      clear
      log_error "How the heck did you get here?!"
      exit 1;
  esac
done

