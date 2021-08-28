#!/bin/bash

#set debug level
DEBUG=0

#check for root - this is done since apt/dpkg are called to install system-level things.
#the check is done first so the script fails early if sudo is not available
CURRENT_USER=`whoami`;
NEEDED_USER="root";
REAL_USER=`who am i | awk '{print $1}'`
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

#set the package command
#TODO: make this programmatic to support non-Debian OS
packageCommand="apt";

#this array contains the list of packages to install
#TODO: break this list out into sub-lists that are domain-specific (eg, games, office, engineering)
debPackages=(gedit pinta hexchat hexchat-indicator audacity audacity-data freecad handbrake-* cifs-utils net-tools openssh-server vnc4server screen xterm openscad openscad-mcad png23d pcb-rnd xine notepadqq p7zip* openttd* vlc vlc-plugin-* gimp* xine-ui xine-console xine-plugin clementine dosbox qjackctl arduino* calibre* nasm obs-studio gnumeric abiword planner filezilla ardour musescore xtrkcad opl3-soundfont flashrom kicad geda* ngspice easyspice octave* indicator-cpufreq cpufreq cpufrequtils sensord xsensors steam build-essential scribus inkscape inkscape-open-symbols bless putty libreoffice gtkvncviewer gerbv sdcc dia wings3d blender 0ad focuswriter trousers tpm-tools scorched3d);

#add the package list to a general array
#TODO: make this programmtic for other OS (eg, RPM-based)
packageList=(${debPackages[@]});

#update the package cache
sudo $packageCommand update;


#install the packages
#TODO: make generic for non-Debian OS
for package in "${packageList[@]}"; do
	echo "######";
	echo "NOTE: Processing package: "$package;
	echo -n "NOTE: Checking to see if package is already installed..."
	installPackage=0;
	
	#check if the package is already installed,
	#skip if it is
	if [[ $($packageCommand -qq list $package | grep installed) ]]; then
		echo "INSTALLED! Skipping."
	else
		echo "NOT INSTALLED!";
		echo "Starting installation of package $package";
		packageInstallCommand="$packageCommand install";
		if [ $debug -eq 1 ]; then 
			packageInstallCommand+=" --dry-run";
		else
			packageInstallCommand+=" -y";
		fi;
		sudo $packageInstallCommand $package;
	fi;

	echo "Package installation complete for package $package";
	echo -e "######\n";

done;

#Clean Up Repo Cache after installing/updating the big package list
#TODO: make generic for non-Debian OS
sudo apt-get autoremove;

#fix the default shell from bash to dash
#TODO: change this to be programmatic and only do it on Ubuntu-based OS
echo -n "NOTE: Checking for DASH shell as default...";
if echo `echo $0` | grep 'dash'; then
	echo "FOUND!";
	echo -n "NOTE: Changing default shell to from DASH to BASH...";
	export DEBIAN_FRONTEND=noninteractive;
	export DEBCONF_NONINTERACTIVE_SEEN=true;
	echo "dash dash/sh boolean false" | debconf-set-selections;
	dpkg-reconfigure dash;
	unset DEBIAN_FRONTEND;
	unset DEBCONF_NONINTERACTIVE_SEEN;
	echo "DONE!";
	echo "INFO: You must log out of this shell and back in for change to take effect";
else
	echo "NOT FOUND!";
fi;

#fix the global vimrc file to have CentOS style editing in VI
echo "" >> /etc/vim/vimrc ;
echo "set nocompatible" >> /etc/vim/vimrc ;

#add the calling user to any new needed groups for applications
newGroup=(dialout audio);
echo "Adding $REAL_USER to new groups..."
for group in "${newGroup[@]}"; do
	echo "Adding to $group...";
	sudo usermod -a -G group $REAL_USER;
done;
echo "DONE!";
