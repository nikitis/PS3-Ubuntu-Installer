#!/bin/ash

## My first attempt at a distribution installer

## Please note that this is a work in progress

## Version 0.95
clear
echo " "
echo "PPPPPP    SSSSSSS   3333333"
echo "PP   PP   SS             33"
echo "PPPPPP    SSSSSSS   3333333"
echo "PP             SS        33"
echo "PP        SSSSSSS   3333333"
echo " "
echo "UU   UU   BBBBBB    UU   UU   NN    NN   TTTTTTT   UU   UU"
echo "UU   UU   BB   BB   UU   UU   NNNN  NN     TTT     UU   UU" 
echo "UU   UU   BBBBBB    UU   UU   NN NN NN     TTT     UU   UU"
echo "UU   UU   BB   BB   UU   UU   NN  NNNN     TTT     UU   UU"
echo " UUUUU    BBBBBB     UUUUU    NN    NN     TTT      UUUUU"
echo " "
echo "Written By: nikitis"
echo " "
echo " "
echo "Installer is in testing phase.  You may experience issues, but should not brick"
echo "your console as it only works within the /dev/ps3dd environment."
echo " "
echo "If you have not yet created the /dev/ps3dd region by running the create_hdd_region.sh"
echo "script, please hit ctrl-c now and do this first before running this script"
echo " "
echo "This installer will create a /dev/ps3dd1 dedicated for swap,"
echo "and /dev/ps3dd2 dedicated for root (/). If you have already created a"
echo "partitioning scheme this script will attempt to remove them and setup the default"
echo "scheme listed above.  In furture releases I will provide choice of schema."
echo " "
echo "The only script that should be run is ubuntu-installer.sh  Do not attempt to run"
echo "any other files that have come with this installer."
echo " "
echo "Please hit ctrl-c now to cancel this script if this does not work for you."
echo " "
read -p "Press any key to continue."


## Umounting /dev/ps3dd2 in case of previous attempts at installs
echo "Attempting to umount /dev/ps3dd2 in case of previous attempts were made at installation..."
umount /dev/ps3dd1
umount /dev/ps3dd2
rm -rf /tmp/petitboot/mnt/ps3dd1/*
rm -rf /tmp/petitboot/mnt/ps3dd2/*



## Setting up device variable

DEVICE="/dev/ps3dd"


## parted commands
read -p "Have you already created partitions on your PS3 after running create_hdd_script.sh for Linux? (y/n): " G
if [ "$G" = n ]; then
	parted ${DEVICE} --script -- mklabel GPT
	parted ${DEVICE} --script -- mkpart primary 0 2GB
	parted ${DEVICE} --script -- mkpart primary 2GB -1
	parted ${DEVICE} --script -- print
elif [ "$G" = y ]; then
	read -p "How many partitions were created? " H
	if [ "$H" = 1 ]; then
		parted ${DEVICE} --script -- rm 1
		dd if=/dev/zero of=${DEVICE} bs=512 count=200
		parted ${DEVICE} --script -- mklabel GPT
		parted ${DEVICE} --script -- mkpart primary 0 2GB
		parted ${DEVICE} --script -- mkpart primary 2GB -1
		parted ${DEVICE} --script -- print
	elif [ "$H" = 2 ]; then
		parted ${DEVICE} --script -- rm 2
		parted ${DEVICE} --script -- rm 1
		dd if=/dev/zero of=${DEVICE} bs=512 count=200
		parted ${DEVICE} --script -- mklabel GPT
		parted ${DEVICE} --script -- mkpart primary 0 2GB
		parted ${DEVICE} --script -- mkpart primary 2GB -1
		parted ${DEVICE} --script -- print
	elif [ "$H" >= 3 ]; then
		echo "If you have 3 or more partitions this installer will not currently work for you unless"
		echo "you are willing to wipe them and start over."
		echo " "
		read -p "To continue press enter.  To quit press (x): " X
		if [ "$X" = x ]; then
			killall debian-installer.sh
		else
			echo " "
			echo "Attempting to remove all partitions created for ps3dd.  Ignore any errors."
			parted ${DEVICE} --script -- rm 5
			parted ${DEVICE} --script -- rm 4
			parted ${DEVICE} --script -- rm 3
			parted ${DEVICE} --script -- rm 2
			parted ${DEVICE} --script -- rm 1
			dd if=/dev/zero of=${DEVICE} bs=512 count=200
			parted ${DEVICE} --script -- mklabel GPT
			parted ${DEVICE} --script -- mkpart primary 0 2GB
			parted ${DEVICE} --script -- mkpart primary 2GB -1
			parted ${DEVICE} --script -- print
		fi
	else
		read -p "You have failed to enter a proper number and have crashed the installer.  Please reboot and start over."
		reboot
	fi
else
	echo "You have failed to enter in a (y) or (n).  Please try again, rebooting..."
	reboot
fi


## Unmounts the partition
echo "Attempting to unmount the partitions on /dev/ps3dd. If it errors it should be okay."
echo "Unmounting partitions from /dev/ps3dd"
umount /dev/ps3dd2
echo " "


## Creates the directory to chroot to.
echo "Creating chroot directory /mnt/ubuntu"
mkdir /mnt/ubuntu
echo " "

## Choice of type of formatting to be used on ps3dd2
read -p "Which filesystem type do you wish "root" to have?  ext(2/3/4) (s)kip: " A
if [ "$A" = 2 ]; then
        echo "Formatting ext2"
	umount /dev/ps3dd2
	mkfs.ext2 /dev/ps3dd2
elif [ "$A" = 3 ]; then
        echo "Formatting ext3"
	umount /dev/ps3dd2
	mkfs.ext3 /dev/ps3dd2
elif [ "$A" = 4 ]; then
        echo "Formatting ext4"
	umount /dev/ps3dd2
	mkfs.ext4 /dev/ps3dd2
elif [ "$A" = s ]; then
	read -p "Have you already formatted your HDD?  This is different from partitioning. Are you sure you want to skip? (y/n) " B
	if [ "$B" = n ]; then
		read -p "Which filesystem? ext(2/3/4) " A
		if [ "$A" = 2 ]; then
                        echo "Formatting ext2"
			umount /dev/ps3dd2
			mkfs.ext2 /dev/ps3dd2
		elif [ "$A" = 3 ]; then
                        echo "Formatting ext3"
			umount /dev/ps3dd2
			mkfs.ext3 /dev/ps3dd2
		elif [ "$A" = 4 ]; then
                        echo "Formatting ext4"
			umount /dev/ps3dd2
			mkfs.ext4 /dev/ps3dd2
		else
			echo "You failed to hit 2, 3, 4.  You've crashed the script.  Start over."
		fi
	elif [ "$B" = y ]; then
		read -p "Since you have already formatted your parition, what filesytem was used? ext(2/3/4)? " A
			echo "Skipping formatting process."
	else 
		echo "You did not hit y or n.  You have crashed the script."
	fi
else
	echo "You failed to select 2, 3, 4, or s.  You probably shouldn't be installing linux on your PS3"
fi


## Mounts / to /mnt/ubuntu/
echo " "
echo "Mounting /dev/ps3dd2 to the chroot dir."
mount /dev/ps3dd2 /mnt/ubuntu


## This step is used for when the script is re-run
echo " "
echo "Cleaning formatted drive (In case there was previous install attempt.)."
rm -rf /mnt/ubuntu/*
echo " "


## Setting tcp_enc to 0
echo "Disabling tcp_enc for older petitboot installs to fix debootstrap"
echo "0" > /proc/sys/net/ipv4/tcp_ecn
echo " "


## Debootstrap

echo "Debootstrapping... This process can take a couple of minutes."
debootstrap --arch powerpc lucid /mnt/ubuntu http://ports.ubuntu.com
echo " "

echo "Copying 2nd half of installer and variables over to post-chrooted environment"
cp ./ubuntu-installer-2.sh /mnt/ubuntu/tmp/ubuntu-installer-2.sh
sed -i "s/extvar/$A/g" /mnt/ubuntu/tmp/ubuntu-installer-2.sh
cat /etc/resolv.conf > /mnt/ubuntu/etc/resolv.conf

## Mounting proc as part of chroot.

echo "chrooting. . ."
sleep 1
mount -t proc none /mnt/ubuntu/proc
mount --rbind /dev /mnt/ubuntu/dev
LANG=C chroot /mnt/ubuntu /tmp/ubuntu-installer-2.sh

