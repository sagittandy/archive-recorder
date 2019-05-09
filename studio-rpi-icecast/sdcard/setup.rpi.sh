#!/bin/bash
#-----------------------------------------------------------------------
# This script is intended to be run on the RPI with 
# freshly-flashed Micro SD card.
#
# Invoke:
#	sudo su -
#	cd /boot/studio-rpi-icecast/sdcard 
# 	./setup.rpi.sh <PASSWORD> <HOSTNAME>
#	where
#		<PASSWORD> is used for both pi and root
#		<HOSTNAME> is the new hostname of the RPI
#
# Run as root.
#
# Run this script from folder sdcard.
#
# AD 2019-0506-2100 Created
#-----------------------------------------------------------------------
export DELIMITER="----------------------------------------------------------------------------------"


echo ${DELIMITER}
echo "Confirming user root..."
sleep 3
if [[ $EUID -ne 0 ]]; then
   echo "EXIT ERROR: This script must be run as user root." 
   exit 1
fi
echo "Confirmed user root."


echo ${DELIMITER}
echo "Checking parameter count..."
sleep 3
if [ $# -ne 2 ] ; then
	echo "USER ERROR: Wrong number of parameters. Enter ./setup.rpi.sh <PASSWORD> <HOSTNAME> "
	exit 9
fi
echo "Confirmed parameter count."


echo ${DELIMITER}
echo "Getting password."
sleep 3
PASSWORD=${1}
echo "PASSWORD=${PASSWORD}"
 

echo ${DELIMITER}
echo "Getting hostname."
sleep 3
HOSTNAME=${2}
echo "HOSTNAME=${HOSTNAME}"


echo ${DELIMITER}
echo "Ensuring required prereq files..."
sleep 3
for FILENAME in authorized_keys id_rsa.pub.rpi id_rsa.rpi
do
	ls ${FILENAME}
	rc=$?
	if [ 0 != ${rc} ] ; then
		echo "ERROR ${rc} Required prereq file does not exist: ${FILENAME}"
		exit 1
	fi
done


echo ${DELIMITER}
echo "Changing root password..."
sleep 3
echo -e "${PASSWORD}\n${PASSWORD}" | passwd
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} could not change root password."
	exit 1
fi


echo ${DELIMITER}
echo "Changing user pi password..."
sleep 3
echo -e "${PASSWORD}\n${PASSWORD}" | passwd pi 
rc=$?
if [ 0 != ${rc} ] ; then
        echo "ERROR ${rc} could not change user pi password."
        exit 1
fi


echo ${DELIMITER}
echo "Changing hostname in /etc/hosts..."
sleep 3
sed -ie "s:raspberrypi:${HOSTNAME}:g" /etc/hosts
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} Could not set hostname in /etc/hosts."
	exit 1
fi
cat /etc/hosts


echo ${DELIMITER}
echo "Changing hostname in /etc/hostname..."
sleep 3
sed -ie "s:raspberrypi:${HOSTNAME}:g" /etc/hostname 
rc=$?
if [ 0 != ${rc} ] ; then
        echo "ERROR ${rc} Could not set hostname in /etc/hostname."
        exit 1
fi
cat /etc/hostname


echo ${DELIMITER}
echo "Adding dobmir to /etc/hosts..."
sleep 3
echo "165.227.56.205  dobmir" >> /etc/hosts
rc=$?
if [ 0 != ${rc} ] ; then
        echo "ERROR ${rc} Could not append dobmir to /etc/hosts."
        exit 1
fi
cat /etc/hosts


echo ${DELIMITER}
echo "Creating SSH keys for user pi..."
sleep 3
su -c "ssh-keygen -t rsa -N \"\" -f ~/.ssh/id_rsa" pi
rc=$?
if [ 0 != ${rc} ] ; then
        echo "ERROR ${rc} could not create SSH keys for user pi."
        exit 1
fi
echo "ok"



echo ${DELIMITER}
echo "Copying authorized_keys file to /home/pi/.ssh/..."
sleep 3
cp authorized_keys /home/pi/.ssh/
chown pi /home/pi/.ssh/authorized_keys
chgrp pi /home/pi/.ssh/authorized_keys
chmod 644 /home/pi/.ssh/authorized_keys
echo "Assume ok"


echo ${DELIMITER}
echo "Copying ID_RSA files to /home/pi/.ssh/..."
# -rw------- 1 pi pi 1679 May  6 20:09 id_rsa
# -rw-r--r-- 1 pi pi  396 May  6 20:09 id_rsa.pub
sleep 3

cp id_rsa.pub.rpi /home/pi/.ssh/id_rsa.pub
chown pi /home/pi/.ssh/id_rsa.pub
chgrp pi /home/pi/.ssh/id_rsa.pub
chmod 644 /home/pi/.ssh/id_rsa.pub

cp id_rsa.rpi /home/pi/.ssh/id_rsa
chown pi /home/pi/.ssh/id_rsa
chgrp pi /home/pi/.ssh/id_rsa
chmod 600 /home/pi/.ssh/id_rsa

echo "Assume ok"
ls -al /home/pi/.ssh/


echo ${DELIMITER}
echo "Copying tools files from github to /home/pi/..."
sleep 3
cp -rp /boot/studio-rpi-icecast /home/pi/
rc=$?
if [ 0 != ${rc} ] ; then
        echo "ERROR ${rc} could not copy tools files from github to /home/pi/."
        exit 1
fi
chown -R pi /home/pi/studio-rpi-icecast
chgrp -R pi /home/pi/studio-rpi-icecast
ls -l /home/pi/
echo "ok"


echo ${DELIMITER}
echo "Setting timezone to US PACIFIC..."  
sleep 3
timedatectl set-timezone America/Los_Angeles
rc=$?
if [ 0 != ${rc} ] ; then
        echo "ERROR ${rc} could not set timezone."
        exit 1
fi


echo ${DELIMITER}
echo "Creating directory /home/pi/bin..."
sleep 3
su -c "mkdir -p /home/pi/bin" pi
rc=$?
if [ 0 != ${rc} ] ; then
        echo "ERROR ${rc} could not create /home/pi/bin."
        exit 1
fi


echo ${DELIMITER}
echo "Updating raspbian operating system, then will need to reboot..."
sleep 3
apt-get update
apt-get -y dist-upgrade
apt-get -y autoremove


echo ${DELIMITER}
echo "Disabling automatic updates of the OS..."
sleep 3
systemctl stop apt-daily.timer
systemctl disable apt-daily.timer
systemctl stop apt-daily-upgrade.timer
systemctl disable apt-daily-upgrade.timer


echo ${DELIMITER}
echo "Installing zip..."
sleep 3
apt-get -y install zip


# Experimental: Install packages required by the archiver so
# they get the benefit of the first reboot before being set up.
echo ${DELIMITER}
echo "Installing misc archiver packages..."
sleep 3
apt-get -y install autossh
apt-get -y install streamripper
apt-get -y install usbmount
# Do not install UFW without configuring, lest we get locked out.


echo ${DELIMITER}
echo "Suppressing interactive configuration during installation..."
sleep 3
export DEBIAN_FRONTEND=noninteractive
apt-get -y install icecast2


echo ${DELIMITER}
echo "Exit. Success!...  "
echo "        Please ssh to dobmir, and enter 'yes' one time."
echo "        Then please reboot:  shutdown -r now"
