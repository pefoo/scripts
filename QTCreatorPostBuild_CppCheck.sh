#! /bin/bash

echo $(cppcheck --enable=all -v . | grep -v 'Checking\|\d')
