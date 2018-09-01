# bin/sh

#
#	Mount network share in case iam at home
#
network=$(iwgetid -r)
[ "$network" == "FRITZ!Box 7362 SL" ] && sudo mount odroid:/home/odroid/Intenso /home/peepe/inteso_NetworkDrive

