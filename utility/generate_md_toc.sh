#!/bin/bash

#
# Generate a table of contents for arbitrary markdown files. 
# The toc is replaced everything the script is executed. 
#
# Remarks:
#   Using 1. to create a numbered nested list seems to be quite broken for github. Some nesting levels just wont work. ¯\_(ツ)_/¯
#

# Entry point 
# Globals:
#   None
# Arguments:
#   The file to parse 
# Returns:
#   None
main() {
  local replace_inline
  while getopts "hi" o; do
    case "$o" in
      i)
        replace_inline=true
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

  local doc="$1"
  if [ -z "$doc" ] || [ ! -f "$doc" ]; then
    echo "Provide an existing file to parse"
    exit 1
  fi

  local headings=()
  while IFS='' read -r line; do
    # Line is a heading 
    if [[ "$line" =~ ^[[:space:]]*(#+[[:space:]].+)$ ]]; then
      headings+=("${BASH_REMATCH[1]}")
    fi
  done < "$doc"
  
  if [ ${#headings[@]} -eq 0 ]; then 
    echo "The file does not contains headings"
    exit 2
  fi

  if [ "$replace_inline" == true ]; then 
    # Backup and clear the file 
    cp "$doc" "$doc.bak"
    truncate -s 0 "$doc"

    # Define some markers to be placed in the file 
    local start_marker
    local sed_start_marker
    local end_marker
    local sed_end_marker
    start_marker="[//]: # (###### AUTO GENERATED TOC START ######)"
    end_marker="[//]: # (###### AUTO GENERATED TOC END ######)"
    sed_start_marker="\[\/\/\]: # (###### AUTO GENERATED TOC START ######)"
    sed_end_marker="\[\/\/\]: # (###### AUTO GENERATED TOC END ######)"

    # Create a toc in the (yet empty) file 
    echo "$start_marker" >> "$doc"
    for heading in "${headings[@]}"; do
      build_toc_line "$heading" >> "$doc"
    done 
    # Github requires this newline ;) 
    echo "" >> "$doc"
    echo "$end_marker" >> "$doc"

    # Append the origial file but without the previous toc 
    sed "/$sed_start_marker/,/$sed_end_marker/d" "$doc.bak" >> "$doc"
  else 
    for heading in "${headings[@]}"; do
      build_toc_line "$heading"
    done 
  fi
}

usage() {
  echo "$(basename "${BASH_SOURCE[0]}") [OPTION] {file name}"
  echo "Options:"
  echo -e "\t-i\tInline mode - add the generated toc to the origial file. A backup copy is generated"
  echo -e "\t-h\tShow this help"
}

# Create a single toc line 
# Globals:
#   None
# Arguments:
#   A single heading 
# Returns:
#   A toc line 
build_toc_line() {
  local heading="$1"
  if [ -z "$heading" ]; then 
    echo "Empty heading"
    exit 1
  fi
  # 1. [title](#heading-name-with-minus-not-space)

  local nesting
  # Replace everything from back to first space (get rid of the actual heading text
  nesting=${heading%% *}
  # Replace the LAST # with a dash (-) 
  nesting=$(echo "$nesting" | sed -e 's/\(#*\)#/\1-/')
  # Replace remaining # with whitespace (in order to nest subsections in the list)
  nesting=$(echo "$nesting" | sed -e 's/#/  /g')

  local title
  # Get the title without leading # 
  title="$(echo "$heading" | grep -oP "^\s*#*\s*\K.*$")"
  # Remove trailing whitespace 
  title="$(echo "$title" | sed -e 's/[[:space:]]*$//')"

  local link
  # Replace whitespace in title with - in order to build the page anchor link
  link=${title// /-}
  # Remove special characters from the page anchor link 
  link="$(echo "$link" | sed -e 's/[\(\)\.]//g')"

  echo "$nesting [$title](#${link})"
}

main "$@"; exit
