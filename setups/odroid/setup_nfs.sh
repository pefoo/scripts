#/bin/bash

source ../../snippets/assert_run_as_root.sh

assert_run_as_root

read -p "Enter the user name to setup the drive for: " user
if [ -z "user" ];then
  echo "Empty user name not allowed!"
  exit 1
fi

echo "Setting up nfs"
found=$(blkid | grep Intenso)

if [ -n "$found" ]; then
	echo -e "\tFound external drive Intesno"
	echo -e "\tRemointing the drive. Settings up exports and fstab ..."
	mkdir -p /home/"$user"/Intenso 
  chown $user /home/"$user"/Intenso
	hwa=$(sed 's/: .*//g' <<<$found)
	umount $hwa
	mount $hwa /home/$user/Intenso 
	echo "LABEL=Intenso /home/$user/Intenso ntfs defaults 0 0" >> /etc/fstab
	echo "home/$user/Intenso 192.168.178.0/255.255.255.0(rw,async)" >> /etc/exports
  echo -e "\tReloading the exports ..."
  exportfs -ra
else
  echo "External drive Intenso not found!"
  exit 1
fi

