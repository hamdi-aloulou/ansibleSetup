#!/bin/sh
sudo -s <<EOF
chmod +x .oh-my-zsh
cd /home/pi/.oh-my-zsh
sh tools/upgrade.sh
>>EOF
