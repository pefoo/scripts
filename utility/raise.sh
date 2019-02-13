# Raise the passed window / start it if not running
# 
# param:  The process to focus / start

# process id of this script
PID=$$

# search for the passed window / process
xdotool search --class $1 | while read line
do
  # Try to activate the window
  if [ `xdotool windowactivate $line 2> /dev/stdout | grep -c fail` -eq 0 ]
    then
    kill $PID
    exit
  fi
done
# launch the program if we reach here
$1 & disown
