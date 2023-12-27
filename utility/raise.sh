#!/bin/bash

# Raise the passed window / start it if not running
# 
# param:  The process to focus / start

# process id of this script
PID=$$

# Running x11 - use xdotool
if [[ "$XDG_SESSION_TYPE" == 'x11' ]]; then
  # search for the passed window / process
  xdotool search --class $1 | while read line
  do
    xdotool windowactivate $line 
  done
# Most likely wayland: invoke gnome API using gdbus
elif [[ "$XDG_CURRENT_DESKTOP" == 'GNOME' ]]; then
  gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval \
    "global.get_window_actors().map(a=>a.meta_window).find(w=>w.get_wm_class()==\"$1\").activate(0)"
  exit
fi
