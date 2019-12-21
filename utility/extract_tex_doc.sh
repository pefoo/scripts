#!/bin/bash

#
# This script extracts the table of contents as well as further information provided in \iffalse ... \fi blocks. 
# Output is written to a markdown file.
#
# Only .tex files that start with a number are considered.
#

if [ "$#" -ne 1 ]; then 
  echo "Provide a path to the tex files."
fi

readonly WORKING_DIR="$1" 
readonly OUTPUT_FILE="$WORKING_DIR/tex_doc.md"

if [ -f "$OUTPUT_FILE" ];then rm "$OUTPUT_FILE"; fi

cat << EOF > "$OUTPUT_FILE"
[//]: # (################################################################################################)
[//]: # (THIS FILE WAS AUTO GENERATED USING $(basename "$0"). DO NOT MODIFY IT DIRECTLY)
[//]: # (################################################################################################)
EOF

find "$WORKING_DIR" -type f -name '[0-9]*.tex' -print0 |
  sort -z | 
  xargs -0 cat |
  grep -Pzo '(?s)(\\(sub)*section|\\chapter){([\w\s\d]+)}\s*(\\iffalse(.*?)\\fi)?\s?'  >> "$OUTPUT_FILE"
 

# Replace null characters with new lines 
sed -i -e 's/\x0/\n/g' "$OUTPUT_FILE"
# Replace section types 
sed -i -e 's/\\chapter/\n# /g' "$OUTPUT_FILE"
sed -i -e 's/\\section/\n## /g' "$OUTPUT_FILE"
sed -i -e 's/\\subsection/\n### /g' "$OUTPUT_FILE"
sed -i -e 's/\\subsubsection/\n#### /g' "$OUTPUT_FILE"
# Replace remaining latex stuff 
sed -i -e 's/{//g' -e 's/}//g' "$OUTPUT_FILE"
sed -i -e 's/\\iffalse//g' -e 's/\\fi//g' "$OUTPUT_FILE"

