#!/bin/bash

############# Section 2 of Ubuntu Installer ###########
## Had to add this section due to chrooting process. ##
#######################################################


## Adding color to terminal

export TERM=xterm-color

###################### End of Chrooting Process ######################



## Setting up fstab

echo " "
echo "Setting up fstab entries. . ."
echo " "
echo -e "/dev/ps3dd2	/		extextvar	defaults		0 1\n/dev/ps3vram	none		swap	sw			0 0\n/dev/ps3dd1	none		swap	sw			0 0\n/dev/sr0	/mnt/cdrom	auto	noauto,ro		0 0\nproc		/proc		proc	defaults		0 0\nshm		/dev/shm	tmpfs	nodev,nosuid,noexec	0 0\n" > /etc/fstab


## Setting up timezone

echo "Setting up timezone data"
echo " "
dpkg-reconfigure tzdata


## Configuring Network Data

read -p "Please enter the name of your Playstation 3 Ubuntu Box. (No spaces or odd characters): " D
echo " "
echo "Saving $D into /etc/hostname"
echo $D > /etc/hostname


## Setting up /etc/network/interfaces

echo " "
echo "Setting up network interfaces"
echo " "
echo -e "auto lo\niface lo inet loopback\n\nauto eth0\niface eth0 inet dhcp\n" > /etc/network/interfaces


## Setting up /etc/resolv.conf

read -p "If you have a different nameserver other than 192.168.1.1, please enter it now, or press (n): " E
if [ "$E" = n ]; then
	echo "nameserver 192.168.1.1" > /etc/resolv.conf
else
	echo -e "nameserver $E" > /etc/resolv.conf
fi
echo " "

## Configuring aptitude sources in /etc/apt/sources.list

echo " "
echo "Creating entries for sources.list"
echo " "
echo -e "deb http://ports.ubuntu.com/ubuntu-ports/ lucid main restricted\ndeb-src http://ports.ubuntu.com/ubuntu-ports/ lucid-updates restricted\ndeb http://ports/ubuntu.com/ubuntu-ports/ lucid universe\ndeb http://ports.ubuntu.com/ubuntu-ports/ lucid-updates universe\ndeb http://ports.ubuntu.com/ubuntu-ports/ lucid multiverse\ndeb http://ports.ubuntu.com/ubuntu-ports/ lucid-updates multiverse\ndeb http://ports.ubuntu.com/ubuntu-ports/ lucid-security main restricted\ndeb-src http://ports.ubuntu.com/ubuntu-ports/ lucid-security main restricted\ndeb http://ports.ubuntu.com/ubuntu-ports/ lucid-security universe\ndeb-src http://ports.ubuntu.com/ubuntu-ports/ lucid-security universe\ndeb http://ports.ubuntu.com/ubuntu-ports/ lucid-security multiverse\ndeb-src http://ports.ubuntu.com/ubuntu-ports/ lucid-security multiverse\n" > /etc/apt/sources.list


## Updating packages for Debian install

echo " "
echo "Updating base install package index."
echo " "
aptitude update
echo " "
echo "Setting up locales and console-data.  For english set en-us-UTF8."
echo " "

aptitude -y install locales
dpkg-reconfigure locales
aptitude -y install console-data
dpkg-reconfigure console-data


## Finishing touches

echo " "
echo "Installing other packages that are needed."
echo " "
sleep 2

echo " "
echo "Starting tasksel. . ."
sleep 3

tasksel install standard
echo "Cleaning up install packages to save space on HDD. . ."
aptitude clean


## User creation and password setting
echo "Starting user creation and password entries..."

echo "Please set a new root password."
passwd
echo " "

read -p "Please enter in a username you would like to use: " F
if [ "$F" = "" ]; then
	echo "That username was not valid"
else
	echo "Creating user $F"
	adduser $F
fi 


echo " "
echo "Installing development packages for kernel build"
echo " "
aptitude -y install git build-essential ncurses-dev git-core gitosis


## Creating Swap Parition and Enabling

echo " "
echo "Setting Swap Parition and Enabling."
echo " "
mkswap /dev/ps3dd1
swapon /dev/ps3dd1


## Git cloning of Kernal)
echo "Downloading kernel source from git and creating symlink"

wget -O linux-2.6.tgz http://git.gitbrew.org/ps3/?p=ps3linux/linux-2.6.git\;a=snapshot\;h=HEAD\;sf=tgz
tar -C /usr/src -xvf linux-2.6.tgz
ln -sf /usr/src/linux-2.6 /usr/src/linux
cp /usr/src/linux/ps3_linux_config /usr/src/linux/.config


## Kernel compilation

echo " "
echo "Starting compilation of kernel. (Takes around 30 mins or less.)"
cd /usr/src/linux
make menuconfig
make
make install
make modules_install
cd /
echo " "
echo "Kernel compiling is done if no errors occured."
echo " "


## Creating kboot.conf entry

echo " "
echo "Creating kboot.conf entries. . ."
echo " "

E=`ls /boot | grep vmlinux`

echo -e "Ubuntu=/boot/$E root=/dev/ps3dd2\ndebian_Hugepages=/boot/$E root=/dev/ps3dd2 hugepages=1" > /etc/kboot.conf


## Creating /dev/ps3flash device for ps3-utils

echo " "
echo -e "Creating udev device \"ps3vflash\" for ps3-utils"
echo " "
echo -e "KERNEL==\"ps3vflash\", SYMLINK+=\"ps3flash\"" > /etc/udev/rules.d/70-persistent-ps3flash.rules


## Finished

echo " "
echo "Installation is complete. Upon reboot, select your new kboot entry to boot Ubuntu."
echo " "
read -p "Press any key to reboot.  (If system hangs, hold power button for 8 seconds.)"

echo " " 
echo "Enjoy!"

reboot