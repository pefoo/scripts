# /bin/bash

ssid=$(iwgetid -r)
monitor=$(xrandr | grep VGA-0)

if [[ $ssid == "FRITZ!Box 7362 SL" ]]
then
	if [[ $monitor == "VGA-0 connected"* ]]
	then 
		xrandr --newmode "1920x1080_60.00" 173.00 1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
		xrandr --addmode VGA-0 "1920x1080_60.00"
	fi
fi
