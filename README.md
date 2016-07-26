# ansibleSetup

1. sudo apt-get install ansible
2. sudo pip install paramiko --upgrade
3. ansible-playbook -vvv setup.yml -i hosts --ask-pass --sudo -c paramiko

# Changing UbiServer (system already installed)

1. ssh into the RaspberryPi
2. sudo vim /lib/systemd/system/ubigate.service
3. sudo systemclt daemon-reload
4. sudo systemctl restart ubigate
