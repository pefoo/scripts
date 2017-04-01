from Constants import *
from Logwriter import *
from subprocess import call
import os
import re

#TODO: pass username via script parameter
#TODO: add more verbose logging

##################################################################################
#                       Software update / install
##################################################################################

# Initial Software update
os.system("apt-get -qq update")
out = os.popen("apt-get -s upgrade | grep 'Inst'")
os.system("apt-get -qq -y upgrade")
Logwriter.write("################# Update #################")
Logwriter.write(out.read())

# Install Software
softwareToInstall = [
    "openssh-server",
    "monit",
    "nfs-kernel-server",
    "apache2",
    "apache2-doc",
    "ntfs-3g",
    "x11vnc",
    "vim"
]

print("Installing software:")
print(" ".join(softwareToInstall))

Logwriter.write("################# Install #################")
Logwriter.write("Installed software:")
Logwriter.write(" ".join(softwareToInstall))
os.system("apt-get -y -qq install " + " ".join(softwareToInstall))

##################################################################################
#                       Configurations
##################################################################################

# configure openssh server
# disable passwords, copy keys
print("Setting up ssh server")
os.system("cp ./res/ssh/* /home/odroid/.ssh")
os.system("chown odroid /home/odroid/.ssh/authorized_keys")
os.system("chown odroid /home/odroid/.ssh/known_hosts")
os.system("sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config")
os.system("sed -i 's/PubkeyAuthentication no/PubkeyAuthentication yes/g' /etc/ssh/sshd_config")
os.system("service sshd restart")

# configure monit
# setup atuostart
print("Settings up monit")
with open("/etc/default/monit", 'a') as writer:
    writer.write("startup=1")

# configure monit watchlist and alert system
with open("/etc/monit/monitrc", 'a') as writer:
    writer.write ("# Mail server setup. Used to send mails\n")
    writer.write("set mailserver smtp.mailgun.org port 587\n")
    writer.write(" username \"postmaster@sandbox927c1c2e0b5c4a8085f75d247f70d6b1.mailgun.org\" password \"1b6f77bc258256136cc08b1ed143fa5d\"\n")
    writer.write(" using tlsv12\n")
    writer.write("\n")
    writer.write("# Send me alert email\n")
    writer.write("set alert pepus.halt@gmail.com\n")
    writer.write("\n")
    writer.write("# Monitor ssh server status\n")
    writer.write("check process sshd with pidfile /var/run/sshd.pid\n")
    writer.write("start program \"/bin/systemctl start sshd.service\"\n")
    writer.write("stop program \"/bin/systemctl stop sshd.service\"\n")
    writer.write("\n")
    writer.write("check file auth.log with path /var/log/auth.log\n")
    writer.write(" ignore match \".* sshd.* Accepted password for .* from 192\.168.* port .*\"\n")
    writer.write(" if match \".* sshd.* Accepted password for .* from .* port .*\" then alert\n")

os.system("/etc/init.d/monit restart")

# configure nfs
#TODO: setup fstab for nfscd
#TODO: Check exports with sudo exportfs -ra

print("Setting up nfs")
os.system("mkdir /home/odroid/Intenso")
out = os.popen("blkid | grep Intenso").read()
if len(out) >= 0:
    print("Found external drive Intenso")
    hdd = re.search("/dev/sd\w\d", out).group()
    os.system("umount "+hdd)
    os.system("mount " +hdd+ " /home/odroid/Intenso")
    with open("/etc/exports", 'a') as writer:
        writer.write("/home/odroid/Intenso  192.168.178.0/255.255.255.0(rw,async)")

# configure x11vnx
#TODO: seems not to work as intended. at least one manual server start is required
print("Setting up x11vnx autostart")
pw = input("Enter new x11vnc server password: ")
os.system("cp ./res/x11vnc.desktop /etc/xdg/autostart")
os.system("x11vnc -storepasswd "+pw+" /etc/x11vnc.pass")

# configure bashrc
with open("/home/odroid/.bashrc", 'a') as writer:
    writer.write("# Bash promp color\n")
    #TODO following 2 lines do not work yet
    #writer.write("PS1 = '\[\033[1;37m\]\u@\h:\w $ \[\033[0m\]'\n")
    #writer.write("PROMPT_DIRTRIM = 4\n")
    writer.write("alias l='ls -lh --group-directories-first'\n");

os.system("source /home/odroid/.bashrc")

# configure vimrc
print("Settings up vimrc")
os.system("cp ./res/.vimrc /home/odroid/.vimrc")

