# /bin/bash

# Start programms i usually work with

if ! ps aux | grep -e kile | grep -vq grep; then
	kile &
fi

if ! ps aux | grep -e spotify | grep -vq grep; then
	spotify &
fi

if ! ps aux | grep -e chrome | grep -vq grep; then
	google-chrome &
fi
