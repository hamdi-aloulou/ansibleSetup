#!/bin/bash
##########################################################
#   Install UbiGATE on Beaglebone Debian 7
#
#   @date       29/04/2014
#   @copyright  PAWN International
#   @author     Hamdi Aloulou
#   @author     Mickael Germain
#   @author     Romain Endelin
#   @author     Anastasia Lieva
#   @todo
#   @bug
#
##########################################################

. utils.sh

#---------------------------------------------------------
# Weaved

wget https://github.com/weaved/installer/raw/master/binaries/weaved-nixinstaller_1.2.13.bin &&
chmod +x weaved-nixinstaller_1.2.13.bin &&
sudo apt-get install bc &&
spawn ./weaved-nixinstaller_1.2.13.bin
expect "Please select from the above options (1-5):"
send "1\r"
expect "Would you like to continue with the default port assignment? [y/n]"
send "y\r"
expect "Please enter your Weaved Username (email address):"
send "pawmint.fr@gmail.com"
expect "Now, please enter your password:"
send "pawmintsgfr"
expect "Please provide an alias for your device:"
send "lirmm_raspberryPi"
#---------------------------------------------------------
# End of File.
