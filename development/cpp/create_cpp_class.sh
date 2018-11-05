#!/bin/bash

if [ "$#" -le 1 -o "$#" -ge 4 ]; then
	echo "Usage: $0 {header dir} [optional: source dir] {class name}" 
	exit 1
fi

header_dir="$1"
source_dir="$1"

# change source dir if argument is present
if [ "$#" -eq 3 ]; then
	source_dir="$2"
fi

# class name is last argument
class_name="${!#}"
include_guard=$(echo "${class_name}_H" | tr '[:lower:]' '[:upper:]')
file_name_base="$(echo "$class_name" | tr '[:upper:]' '[:lower:]')"

# build the file paths 
# file names are class name (lower case)
header_file="${header_dir}/${file_name_base}.hpp"
source_file="${source_dir}/${file_name_base}.cpp"

mkdir -p "$header_dir"
mkdir -p "$source_dir"

# source file
cat << EOF > "$source_file"
#include "${file_name_base}.hpp"
EOF


# header file
cat << EOF > "$header_file"
#ifndef ${include_guard}
#define ${include_guard}

///
/// \\brief TODO
///
class ${class_name}
{
public:

private:
};

#endif //${include_guard}
EOF
