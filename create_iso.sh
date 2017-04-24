#!/bin/bash
##########################################################
#   creation iso image of raspbian with necessary packages
#   Based on http://beagleboard.org/Getting%20Started#step3 .
#
#   @date       22/04/2014
#   @copyright  PAWN International
#   @author     Hamdi Aloulou
#   @author     Mickael Germain
#   @author     Anastasia Lieva
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
h1 'create ubi_raspbian image'

VAR=""
until [ "$VAR" = "y" -o "$VAR" = "n" ]; do
    read -r -p "Would you want to create an ubi_rasbian image of the installed system ? (Y/n) " VAR
    VAR=`echo "$VAR" | tr '[:upper:]' '[:lower:]'`
done
if [ "$VAR" = "y" ]; then
    h2 'Finding the micro SD card'
    OK=0
    until [ $OK = 1 ]; do
        read -r -p 'Unplug the micro SD card if it is already pluged into computer then Press [Enter] key.' VAR
        # Save disk status.
        fdisk -l > fdisk1.tmp
        read -r -p 'Plug the micro SD card into computer then Press [Enter] key.' VAR
        # Save new disk status.
        fdisk -l > fdisk2.tmp
        # Keep the differences between both snapshot.
        FDISK=`diff fdisk1.tmp fdisk2.tmp`
        rm fdisk1.tmp fdisk2.tmp
        # grep keeps description line of SD card. ex : "> Disque /dev/mmcblk0 : 8 Go, 858993492 octets".
        # cut1 keeps all before ":" (cut2 strangely keeps the ":").
        # cut2 keeps device name. ex : "/dev/mmcblk0".
        DISK=`echo "$FDISK" | grep -e 'Dis.*mmcblk[0-9]' | cut -d ':' -f 1 | cut -d ' ' -f 3`
        if [ -z "$DISK" ]; then
            echo "New SD card undetected."
        else
            if [ `echo "$DISK" | wc -l` != 1 ]; then
                echo "More than one new SD card detected."
            else
                echo "New SD card detected : $DISK ."
                VAR=""
                until [ "$VAR" = "y" -o "$VAR" = "n" ]; do
                    read -r -p "Does the device $DISK is the right one ? (Y/n) " VAR
                    VAR=`echo "$VAR" | tr '[:upper:]' '[:lower:]'`
                done
                if [ "$VAR" = "y" ]; then
                    OK=1
                fi
            fi
        fi
    done

    # dd duplicates partition into bootable image
    # bs=byte size per block count=number of blocks
    # actual Raspbian partition size 2,6 Gb, so count=3000 otherwise use loop with commande below or change manually
    # SIZE= echo "$(df -h /mmcblk | tail -1 | awk '{print $3}')"
    h2 'Creating new directory: raspberry_image'
    if [ ! -d "raspberry_image" ]; then
        mkdir raspberry_image
    fi
    h2 'Burning ISO of ubi_raspbebian in raspberry_image'
    UBI_IMG='raspberry_image/ubi_raspbian.img'
    if [ -f "$UBI_IMG" ]; then
        rm $UBI_IMG
    fi
    dd bs=4M if="$DISK" of="$UBI_IMG"
    if [ $? = 0 ]; then
        echook 'Burning done.'
    else
        echofail 'Burning has failed.'
        echo "Leaving script $0 ..."
        exit 1
    fi

    # Some setpoints :
    h2 'Setpoints'
    read -r -p 'Power down the Raspberry Pi.'
    read -r -p 'Plug the micro SD card in Raspberry Pi.'
    read -r -p 'Start the Raspberry Pi.'
fi

h2 'Installation done...'


