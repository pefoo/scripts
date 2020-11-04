#!/bin/bash

#
# Create a bash script 
#

main() {
	local script_name="$1"
  if [ -z "$script_name" ]; then 
    usage
    exit 1
  fi
  if [ -f "$script_name" ]; then 
    echo "The file $script_name alread exists!"
    exit 1
  fi
  
  cat << EOF > "$script_name"
#!/bin/bash

#
# TODO Description
#

# Entry point 
# Globals 
#		None
# Arguments:
#   None
# Returns:
#   None
main() {
	while getopts "TODO add arguments here" o; do
		case "\$o" in
      \?)
        usage
        exit 1
        ;;
    esac
  done
  shift \$((OPTIND - 1))

}

# Get this script path as absolute path 
# Arguments: 
#   None 
# Returns:
#   The absolute path to this script
get_script_path() {
  pushd "\$(dirname "\${BASH_SOURCE[0]}")" > /dev/null
  pwd
  popd > /dev/null
}

usage() {
	echo 'Usage:'
  echo "\$(basename "\${BASH_SOURCE[0]}")"
}

main "\$@"; exit
EOF

}

usage() {
	echo 'Usage:'
  echo "$(basename "${BASH_SOURCE[0]}") script_name"
}

main "$@"; exit
