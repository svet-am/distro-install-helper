#!/bin/bash

#set debug level
DEBUG=0

#check for root - this is done since apt/dpkg are called to install system-level things.
#the check is done first so the script fails early if sudo is not available
CURRENT_USER=`whoami`;
NEEDED_USER="root";
if [ $CURRENT_USER != $NEEDED_USER ] 
   then
	echo 'ERROR: this script must be run as root/sudo!'
	exit 0
fi

#Declare the general script-wide variables
#These help the script know its operating environment
CURRENT_DIR=`pwd`;
SYSVENDOR=`sudo dmidecode | grep -A 5 "System Information" | grep Manufacturer | cut -d: -f2- | xargs`
SYSMODEL=`sudo dmidecode | grep -A 5 "System Information" | grep -E "Product Name" | cut -d: -f2- | xargs`
CPUVENDOR=`lscpu | grep -E "Vendor ID" | cut -d: -f2- | xargs`
CPUMODEL=`lscpu | grep -E "Model name" | cut -d: -f2- | xargs`
CPUARCH=`uname -i`

DISTRONAME=`cat /etc/*release | grep -E "NAME" | head -1 | cut -d= -f2- | xargs`
DISTROID=`cat /etc/*release | grep -E "ID" | head -1 | cut -d= -f2- | xargs`
DISTROVERSION=`cat /etc/*release | grep -E "VERSION_ID" | head -1 | cut -d= -f2- | xargs`
DISTROBASE=`cat /etc/*release | grep -E "ID_LIKE" | head -1 | cut -d= -f2- | xargs`