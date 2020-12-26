#!/bin/bash
#
# The (ubuntu) package setup configuration file 
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

# Package flags are used to setup different environments. 
# Currently supported environments are: 
#   minimal   Just the bare minimum 
#   desktop   Everything that is required for a desktop setup
#   server    Everything that is required for a server (odroid) setup
#   odroid    Everything that is only required by odroid (c1)
#
# Value field is used to denote the installation method.
# If the package is available in the official ubuntu repository, it can be installed without
# further information. Set the value to $OFFICIAL_PACKAGE. 
# If the package is NOT available in the official repositories, set a script to install the package
# as value. Use the get_script_path function to get the absolute path to this file and continue with the
# path to the installation script.
# The script is sourced without arguments. 
# 
# The key is the actual package name to install. 

readonly OFFICIAL_PACKAGE="official ubuntu repository"
readonly ENV_MINIMAL="minimal"
readonly ENV_DESKTOP="desktop"
readonly ENV_SERVER="server"
readonly ENV_ODROID="odroid"
readonly ENV_LATEX_DEV="latex"
readonly ENV_ALL="${ENV_MINIMAL},${ENV_DESKTOP},${ENV_SERVER},${ENV_ODROID},${ENV_LATEX_DEV}"

declare -Ar PACKAGES=(
[google-chrome]=\
"$(get_script_path)/../install/google-chrome.sh;\
Google chrome;\
${ENV_DESKTOP}"

[spotify]=\
"$(get_script_path)/../install/spotify.sh;\
Spotify;\
${ENV_DESKTOP}"

[keepassxc]=\
"$OFFICIAL_PACKAGE;\
KeePassXC ;\
${ENV_DESKTOP}"

[vim-nox]=\
"$OFFICIAL_PACKAGE;\
Good old vim;\
$ENV_ALL"

[fonts-powerline]=\
"$OFFICIAL_PACKAGE;\
Patched and adjusted fonts for vim powerline / airline;\
$ENV_ALL"

[exuberant-ctags]=\
"$OFFICIAL_PACKAGE;\
exuberant-ctags ;\
$ENV_ALL"

[tmux]=\
"$OFFICIAL_PACKAGE;\
Terminal multiplexer;\
$ENV_ALL"

[git]=\
"$OFFICIAL_PACKAGE;\
Git source control;\
$ENV_ALL"

[nfs-common]=\
"$OFFICIAL_PACKAGE;\
Network file system - client;\
${ENV_DESKTOP},${ENV_SERVER},${ENV_ODROID}"

[copyq]=\
"$OFFICIAL_PACKAGE;\
Clipboard manager;\
${ENV_DESKTOP}"

[openssh-server]=\
"$OFFICIAL_PACKAGE;\
Open SSH server;\
${ENV_SERVER},${ENV_ODROID}"

[monit]=\
"$OFFICIAL_PACKAGE;\
Log file watcher + live notifications;\
${ENV_SERVER},${ENV_ODROID}"

[fail2ban]=\
"$OFFICIAL_PACKAGE;\
Ban IP that continue to fail login attempts;\
${ENV_SERVER},${ENV_ODROID}"

[nfs-kernel-server]=\
"$OFFICIAL_PACKAGE;\
Network file system - server;\
${ENV_SERVER},${ENV_ODROID}"

[ntfs-3g]=\
"$OFFICIAL_PACKAGE;\
NTFS driver;\
${ENV_ODROID}"

[latexmk]=\
"$OFFICIAL_PACKAGE;\
Latexmk - build latex docs;\
${ENV_LATEX_DEV}"

[texlive-latex-extra]=\
"$OFFICIAL_PACKAGE;\
Latex packages;\
${ENV_LATEX_DEV}"

[texlive-bibtex-extra]=\
"$OFFICIAL_PACKAGE;\
Latex packages;\
${ENV_LATEX_DEV}"

[texlive-lang-german]=\
"$OFFICIAL_PACKAGE;\
Latex packages for german text;\
${ENV_LATEX_DEV}"

[biber]=\
"$OFFICIAL_PACKAGE;\
BibTex replacement for BibLaTeX;\
${ENV_LATEX_DEV}"
)

# Print an environment configuration 
# Arguments:
#   The environment name 
# Returns:
#   None 
print_env() {
  local env
  env="$1"
  if [[ -z $env ]]; then 
    echo "No environment provided!"
    return 1
  fi

  for package in "${!PACKAGES[@]}"; do
    local tag
    tag="$(get_config_flag "${PACKAGES[$package]}")"

    if [[ "$tag" == *"$env"* ]]; then 
      print_config "$package" "${PACKAGES[$package]}"
    fi
  done
}
