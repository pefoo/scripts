#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 {header dir} {header name}" 
	exit 1
fi

header_dir="$1"
file_name="$2"

include_guard=$(echo "${file_name}_H" | tr '[:lower:]' '[:upper:]')

# build the file paths 
# file names are class name (lower case)
header_file="${header_dir}/${file_name}.hpp"

mkdir -p "$header_dir"

# header file
cat << EOF > "$header_file"
#ifndef ${include_guard}
#define ${include_guard}

#endif //${include_guard}
EOF
