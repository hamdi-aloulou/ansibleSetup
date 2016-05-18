#!/bin/bash
##########################################################
#   Script for burniing a micro SD card in order to
#   update board with latest software.
#   Based on http://beagleboard.org/Getting%20Started#step3 .
#
#   @date       22/04/2014
#   @copyright  PAWN International
#   @author     Hamdi Aloulou
#   @author     Mickael Germain
#
#   @todo
#   @bug
#
##########################################################

# Same functions as utils.sh, just for standalone.
function h1 ()
{
    echo -e '\033[36m\033[1m'
    echo -e '----------------------------------------------------------'
    echo -e "$1"
    echo -e -n '\033[0m'
    sleep 3
}

function h2 ()
{
    echo -e '\033[34m'
    echo -e "$1"
    echo -e -n '\033[0m'
    sleep 1
}

function echook ()
{
    echo -e -n '[ \033[32mOK\033[0m ] '
    echo -e "$*"
}

function echofail ()
{
    echo -e -n '[\033[31m\033[1mFAIL\033[0m] '
    echo -e "$*"
}

#---------------------------------------------------------
h1 'Burning eMMC flasher of Rasbian for Raspberry Pi on SD card.'

h2 'Finding the micro SD card'
OK=0
until [ $OK = 1 ]; do
    read -r -p 'Unplug the micro SD card if it is already plug then Press [Enter] key.' VAR
    # Save disk status.
    fdisk -l > fdisk1.tmp
    read -r -p 'Plug the micro SD card then Press [Enter] key.' VAR
    # Save new disk status.
    fdisk -l > fdisk2.tmp
    # Keep the differences between both snapshot.
    FDISK=`diff fdisk1.tmp fdisk2.tmp`
    rm fdisk1.tmp fdisk2.tmp
    # grep keeps description line of SD card. ex : "> Disque /dev/mmcblk0 : 8 Go, 858993492 octets".
    # cut1 keeps all before ":" (cut2 strangely keeps the ":").
    # cut2 keeps device name. ex : "/dev/mmcblk0".
    #DISK1=`echo "$FDISK" | grep -e 'Dis.*mmcblk[0-9]' | cut -d ':' -f 1 | cut -d ' ' -f 3`
    DISK=`echo "$FDISK" | grep -e 'Dis.*/dev/*' | cut -d ':' -f 1 | cut -d ' ' -f 3`

    if [ -z "$DISK" ]; then
        echo "New SD card undetected."
    else
        if [ `echo "$DISK" | wc -l` != 1 ]; then
            echo "More than one new SD card detected."
        else
            echo "New SD card detected : $DISK ."
            VAR=""
            until [ "$VAR" = "y" -o "$VAR" = "n" ]; do
                echo "The device $DISK will be burned : All data will be lost."
                read -r -p "Does the device $DISK is the right one ? (Y/n) " VAR
                VAR=`echo "$VAR" | tr '[:upper:]' '[:lower:]'`
            done
            if [ "$VAR" = "y" ]; then
                OK=1
            fi
        fi
    fi
done

h2 'Unmounting micro SD card'
# grep keeps description line of partitions.
# tr replace tabulation by one space.
# cut keeps partition name. ex : "/dev/mmcblk0p1".
#DISK="/dev/mmcblk0"
#echo Disk= $DISK
if [[ $DISK == "/dev/sd"* ]]; then
	PART=`echo "$FDISK" | grep -e 'sd[b-d][1-9]' | tr -s ' ' | cut -d ' ' -f 2`
else 
	PART=`echo "$FDISK" | grep -e 'mmcblk[0-9]p[0-9]' | tr -s ' ' | cut -d ' ' -f 2`
	
fi
	
if [ -z "$PART" ]; then
    # Without partition, the disk is unmounted directly.
    echo "No partition found."
    echo "Unmounting $DISK ."
    umount $DISK
else
    echo "`echo "$PART" | wc -l` partition(s) found on $DISK."
    for i in $PART ; do
        echo "Unmounting partition $i ."
        umount "$i"
    done
fi

UBI_IMG='raspberry_image/ubi_raspbian.img'
if [ -f "$UBI_IMG" ]; then
    h2 'Ubiraspbian image already exist'
    VAR=""
    until [ "$VAR" = "y" -o "$VAR" = "n" ]; do
        read -r -p "An ubiraspbian image already exist, do you want to use it ? (Y/n) " VAR
                VAR=`echo "$VAR" | tr '[:upper:]' '[:lower:]'`
    done
    if [ "$VAR" = "y" ]; then
               IMG_VER='raspberry_image/ubi_raspbian'
    fi
fi
######################################

if [ ! -f "$UBI_IMG" -o "$VAR" != "y" ]; then
    h2 'Getting raspbian firmware image'

    # Find latest version on http://beagleboard.org/latest-images
    # Link to the location of firmware images.
    WEB_IMG='http://downloads.raspberrypi.org/raspbian_latest'
    # Make sure of the file name of the firmware version to be burned.
    if [ -f release_notes.txt ] ; then
        rm release_notes.txt;
    fi

    wget http://downloads.raspberrypi.org/raspbian/release_notes.txt
    VERSION=$(cut -c-10 release_notes.txt|head --lines=1)
    #IMG_VER="$VERSION-raspbian-wheezy"
    IMG_VER="$VERSION-raspbian-jessie"

    if [ -f release_notes.txt ] ; then
        rm release_notes.txt;
    fi

    ZIP_VER='raspbian_latest'


    # If file exist, don't download it again.
    if [ -f "$ZIP_VER" ]; then
        rm "$ZIP_VER"
    fi

    if [ -f "$IMG_VER.img" ]; then
        echook 'Download completed.'
        echook 'Uncompress completed.'
    else
        wget "$WEB_IMG" &&
        # Check download errors with md5.
        md5sum "$ZIP_VER" | md5sum -c
        if [ $? = 0 ]; then
            echook 'Download completed.'
            unzip "$ZIP_VER"
            if [ $? = 0 ]; then
                echook 'Uncompress completed.'
            else
                echofail 'Uncompress has failed.'
                echo "Leaving script $0 ..."
                exit 1
            fi
        else
            echofail 'Download has failed.'
            echo "Leaving script $0 ..."
            exit 1
        fi
    fi
fi

h2 'Burning the micro SD card'
# Disk formatting to FAT32.
mkfs.ext4 "$DISK" &&
# Burning .img on SD Card.
dd bs=4M if="$IMG_VER.img" of="$DISK" &&
# Flushing cache.
sync &&
# rm "$IMG_VER.img"
if [ $? = 0 ]; then
    echook 'Burning done.'
else
    echofail 'Burning has failed.'
    echo "Leaving script $0 ..."
    exit 1
fi

if [ "$IMG_VER" = "raspberry_image/ubi_raspbian" ]; then
    echook 'New ubiraspbian image installed.'
    exit 1
fi

#---------------------------------------------------------
# Some setpoints :
h2 'Setpoints'
read -r -p 'Setting up Raspberry Pi dont unmount your SD card.'
read -r -p 'Configuring Wifi Connection.'
#---------------------------------------------------------
# End of File.
