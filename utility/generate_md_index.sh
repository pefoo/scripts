#!/bin/bash
#
# This script generates a index file with links to markdown files 
# The index file is created in the current directory. 
#

readonly FILTER='*.md'
readonly OUT_FILE='index.md'

if [ -f "$OUT_FILE" ];then 
  mv "$OUT_FILE" "${OUT_FILE}.bak"
fi

# Generate a markdown link
# Args:
#   1) The display name 
#   2) The link target 
function make_link(){
  echo "[$1]($2)"
}

files=()
# Get a list of files. Sorted based on their path (including nesting level)
while read -r file; do
  files+=("$file")
done < <(find . -name "$FILTER" -type f -printf '%h\0%d\0%p\n' | sort -t '\0' -n | awk -F '\0' '{print $3}')

cat << EOF > "$OUT_FILE"
[//]: # (################################################################################################)
[//]: # (THIS FILE WAS AUTO GENERATED USING $(basename "$0"). DO NOT MODIFY IT DIRECTLY)
[//]: # ($(date '+%d.%m.%Y %H:%M:%S'))
[//]: # (################################################################################################)
EOF

last_dir=""
for file in "${files[@]}";do
  current_dir=$(dirname "$file")
  nest_level="$(awk -F"/" '{print NF-1}'<<< "$current_dir")"
  # Root level files 
  if [ "$current_dir" == "." ]; then
    echo "- $(make_link "$(basename "$file")" "$file")" >> "$OUT_FILE"
    continue
  fi

  # Create a new folder node
  if [ ! "$current_dir" == "$last_dir" ]; then 
    dir_name="${current_dir##*/}"
    if [ "$nest_level" -gt 1 ];then
      echo "$(printf '\t%.0s' $(seq 1 $((nest_level-1))))- \[$dir_name\]" >> "$OUT_FILE"
    else 
      echo "- \[$dir_name\]" >> "$OUT_FILE"
    fi
    last_dir="$current_dir"
  fi
  echo "$(printf '\t%.0s' $(seq 1 $((nest_level))))- $(make_link "$(basename "$file")" "$file")" >> "$OUT_FILE"
done
