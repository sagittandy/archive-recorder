#!/bin/bash
#-----------------------------------------------------------------------
# Installs icecast2 and streamripper on Ubuntu Linux 16.04 64bit
# (from deb packages)
#
# Usage: 
#	Run this script as root: sudo ./install.icecast.streamripper.sh
#	Optional: Change the default passwords below.
#
# Prereq: Move the mp3 files enclosed to /tmp/mp3
# 
# AD 2017-0321-2115  Copyright BMIR 2017, 2018
#-----------------------------------------------------------------------
export DELIMITER="-----------------------------------------------------"


# Define custom values for Icecast config file.
export ICECAST_CONFIG_FILE="/etc/icecast2/icecast.xml"
export ICECAST_LOG_FILE_DIRECTORY="/var/log/icecast2"
export ICECAST_PORT="8000"
export ICECAST_HOSTNAME="localhost"
export ICECAST_RELAY_PASSWORD="relaypw"
export ICECAST_SOURCE_PASSWORD="sourcepw"
export ICECAST_ADMIN_PASSWORD="adminpw"
### export ICECAST_USER_NAME="icecastuser"
### export ICECAST_USER_PASSWORD="userpw"
export MP3_DIR="/home/ding/bmir2018"


echo ${DELIMITER}
ls ${MP3_DIR}
rc=$?
if [ 0 != ${rc} ] ; then
        echo "ERROR ${rc} MP3 file directory does not exist: ${MP3_DIR}"
        exit 1
fi


echo ${DELIMITER}
echo "Update apt-get."
apt-get update
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} apt-get update."
	exit 1
fi

echo ${DELIMITER}
echo "apt-get dist upgrade."
apt-get -y dist-upgrade
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} apt-get dist-upgrade."
	exit 1
fi


### echo ${DELIMITER}
### echo "Create unix user ${ICECAST_USER_NAME}"
### adduser ${ICECAST_USER_NAME}  --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
### rc=$?
### if [ 0 != ${rc} ] ; then
### 	echo "ERROR ${rc} creating unix user ${ICECAST_USER_NAME}"
### 	exit 1
### fi


### echo ${DELIMITER}
### echo "Set password for unix user ${ICECAST_USER_NAME}"
### echo "${ICECAST_USER_NAME}:${ICECAST_USER_PASSWORD}" | chpasswd
### rc=$?
### if [ 0 != ${rc} ] ; then
### 	echo "ERROR ${rc} setting password for unix user ${ICECAST_USER_NAME}"
### 	exit 1
### fi


echo ${DELIMITER}
echo "apt-get -y install streamripper."
apt-get -y install streamripper
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} apt-get -y install streamripper."
	exit 1
fi


echo ${DELIMITER}
echo "Verify streamripper is installed."
which streamripper
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} which streamripper."
	exit 1
fi


echo ${DELIMITER}
echo "Fetch the icecast2 debian package."
curl -o /tmp/icecast2.deb http://ftp.gwdg.de/pub/opensuse/repositories/multimedia:/xiph/Debian_8.0/amd64/icecast2_2.4.2-2_amd64.deb
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} fetching icecast2 debian package."
	exit 1
fi


echo ${DELIMITER}
echo "Verify icecast2 deb file exists."
ls /tmp/icecast2.deb
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} File /tmp/icecast2.deb does not exist."
	exit 1
fi


echo ${DELIMITER}
echo "Intall the icecast2 debian package, non-interactively."
DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/icecast2.deb
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} from dpkg installing icecast2.deb."
	exit 1
fi

echo ${DELIMITER}
echo "Assimilate it."
apt-get update
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} from apt-get update."
	exit 1
fi


echo ${DELIMITER}
echo "Verify icecast2 is installed."
which icecast2
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} which icecast2."
	exit 1
fi


echo ${DELIMITER}
echo "Verify icecast2 config file exists. ${ICECAST_CONFIG_FILE}"
ls ${ICECAST_CONFIG_FILE}
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} File ${ICECAST_CONFIG_FILE} does not exist."
	exit 1
fi

#Make a backup
echo "Making backup of icecast config file."
cp -p ${ICECAST_CONFIG_FILE} /tmp/icecast.config.file.orig.xml


# Todo someday: Create a function to do this, and add better checking.
echo ${DELIMITER}
echo "Customize hostname in icecast config file."
sed -ie "s:<hostname>localhost</hostname>:<hostname>${ICECAST_HOSTNAME}</hostname>:g" ${ICECAST_CONFIG_FILE}
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} customizing hostname in icecast config file."
	exit 1
fi


echo ${DELIMITER}
echo "Customize source password in icecast config file."
sed -ie "s:<source-password>hackme</source-password>:<source-password>${ICECAST_SOURCE_PASSWORD}</source-password>:g" ${ICECAST_CONFIG_FILE}
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} customizing source password in icecast config file."
	exit 1
fi


echo ${DELIMITER}
echo "Customize relay password in icecast config file."
sed -ie "s:<relay-password>hackme</relay-password>:<relay-password>${ICECAST_RELAY_PASSWORD}</relay-password>:g" ${ICECAST_CONFIG_FILE}
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} customizing relay password in icecast config file."
	exit 1
fi


echo ${DELIMITER}
echo "Customize admin password in icecast config file."
sed -ie "s:<admin-password>hackme</admin-password>:<admin-password>${ICECAST_ADMIN_PASSWORD}</admin-password>:g" ${ICECAST_CONFIG_FILE}
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} customizing admin password in icecast config file."
	exit 1
fi


echo ${DELIMITER}
echo "Uncomment changeowner in icecast config file, step 1 of 2."
sed -ie "s:<changeowner>: --> <changeowner>:g" ${ICECAST_CONFIG_FILE}
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} uncommenting changeowner in icecast config file, step 1 of 2."
	exit 1
fi


echo ${DELIMITER}
echo "Uncomment changeowner in icecast config file, step 2 of 2."
sed -ie "s:</changeowner>:</changeowner> <!-- :g" ${ICECAST_CONFIG_FILE}
rc=$?
if [ 0 != ${rc} ] ; then
    echo "ERROR ${rc} uncommenting changeowner in icecast config file, step 2 of 2."
	exit 1
fi


echo ${DELIMITER}
echo "Verify icecast2 log file directory exists ${ICECAST_LOG_FILE_DIRECTORY}"
ls ${ICECAST_LOG_FILE_DIRECTORY}
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} Log file directory {ICECAST_LOG_FILE_DIRECTORY} does not exist."
	exit 1
fi


echo ${DELIMITER}
echo "Open permissions to write icecast log files. ${ICECAST_LOG_FILE_DIRECTORY}"
chmod 777 ${ICECAST_LOG_FILE_DIRECTORY}
rc=$?
if [ 0 != ${rc} ] ; then
    echo "ERROR ${rc} opening permissions to write icecast log files. ${ICECAST_LOG_FILE_DIRECTORY}"
	exit 1
fi


echo ${DELIMITER}
echo "Starting the server in 7 seconds... (else ctrl-c)"
sleep 7


echo ${DELIMITER}
echo "Starting the icecat2 server."
icecast2 -b -c ${ICECAST_CONFIG_FILE}
rc=$?
if [ 0 != ${rc} ] ; then
    echo "ERROR ${rc} starting the icecast2 server."
	exit 1
fi


echo ${DELIMITER}
echo "Wait briefly for the server to start."
sleep 3


echo ${DELIMITER}
echo "Verify the icecast port ${ICECAST_PORT} is listening."
netstat -na | grep LISTEN | grep ${ICECAST_PORT} | grep -v grep
rc=$?
if [ 0 != ${rc} ] ; then
    echo "ERROR ${rc} verifying the icecast port ${ICECAST_PORT} is listening."
	exit 1
fi


echo ${DELIMITER}
echo "Verify we can fetch statistics from the icecast server."
curl http://admin:${ICECAST_ADMIN_PASSWORD}@localhost:${ICECAST_PORT}/admin/stats
rc=$?
if [ 0 != ${rc} ] ; then
    echo "ERROR ${rc} verifying we can fetch statistics from the icecast server."
	exit 1
fi


#------- for test purposes --------


echo ${DELIMITER}
echo "Installing liquidsoap streaming client."
apt-get -y install liquidsoap
rc=$?
if [ 0 != ${rc} ] ; then
	echo "ERROR ${rc} apt-get -y install liquidsoap streaming client."
	exit 1
fi


echo ${DELIMITER}
echo "Success. Exit."
