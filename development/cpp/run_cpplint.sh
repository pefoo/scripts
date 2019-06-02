#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 {root folder path}";
  exit 1;
fi

linter="/home/${USER}/apps/cpplint/cpplint.py"
echo "$linter"
if [ ! -f "$linter" ];then
  echo "Make sure to clone the linter to ~/apps/cpplint"
  exit 1
fi

read -d '' ignored << EOF
-legal/copyright,
-readability/todo,
-build/c++11,
-build/include_order,
-whitespace/braces,
-build/header_guard
EOF

python ~/apps/cpplint/cpplint.py --extensions=cpp,hpp --filter="$ignored" $(find "$1"/include "$1"/src -name *.cpp -o -name *.hpp) | grep -v 'Done processing'
exit ${PIPESTATUS[0]}

