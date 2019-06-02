#! /bin/bash

# A script to configure basic system installation from InitialConfigurations.sh
# Either the full set of applications or a subset can be configured (pass the right switches)

# History:
# 01.04.2017: Created script to configure openssh, monit, nfs, x11vnc, bashrc, vimrc
# 01.09.2018: Removed vnc

# THIS IS OUTDATED AS FUCK. 
# todo:
# 	- checkout configs git repo
#		- get config files from git repo 


all=false
openssh=false
monit=false
nfs=false
bashrc=false
vimrc=false

# parse arguments
while getopts "asmnbvh" option
do 
	case $option in
		a)
			all=true	
			;;
		s)
			openssh=true
			;;
		m)
			monit=true
			;;
		n)
			nfs=true
			;;
		b)
			bashrc=true
			;;
		v)
			vimrc=true
			;;
		h)
			echo -e "-a \t all"
			echo -e "-s \t openssh server"
			echo -e "-m \t monit"
			echo -e "-n \t nfs"
			echo -e "-b \t bashrc"
			echo -e "-v \t vimrc"
			echo -e "-h \t display help"
			exit
			;;
		\?)
			echo "Invalid parameter entered!"
			echo -e "-a \t all"
			echo -e "-s \t openssh server"
			echo -e "-m \t monit"
			echo -e "-n \t nfs"
			echo -e "-b \t bashrc"
			echo -e "-v \t vimrc"
			echo -e "-h \t display help"
			exit
			;;
		esac
done

read -p "Enter your username: " user

####################################
# Configure openssh server
####################################
if $openssh || $all; then
	echo "Configuring openssh server"
	echo -e "\tImporting keys ..."
	cp ./res/ssh/* /home/$user/.ssh
	chown $user /home/$user/.ssh/*
	echo -e "\tRemoving PasswordAuthentication"
	sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
	sed -i 's/PubkeyAuthentication no/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
	service sshd restart
fi

####################################
# Monit
####################################
if $monit || $all; then
	echo "Setting up monit"
	cp ./res/monitrc /etc/monit/monitrc
	/etc/init.d/monit restart
fi

####################################
# NFS
####################################
if $nfs || $all; then
	echo "Setting up nfs"
	found=$(blkid | grep Intenso)

	if [ -n "$found" ]; then
		echo -e "\tFound external drive Intesno"
		echo -e "\tRemointing the drive. Settings up exports and fstab ..."
		mkdir /home/$user/Intenso 
		hwa=$(sed 's/: .*//g' <<<$found)
		umount $hwa
		mount $hwa /home/$user/Intenso 
		echo "LABEL=Intenso /home/$user/Intenso ntfs defaults 0 0" >> /etc/fstab
		echo "home/$user/Intenso 192.168.178.0/255.255.255.0(rw,async)" >> /etc/exports
	fi
fi


####################################
# Bashrc
####################################
if $bashrc || $all; then
	echo "Configuring bashrc"
	echo "alias l='ls -lh --group-directories-first'" >> /home/$user/.bashrc
	source /home/$user/.bashrc
fi


####################################
# Vimrc
####################################
if $vimrc || $all; then
	echo "Configuring vimrc"
	cp ./res/.vimrc /home/$user/.vimrc 
fi