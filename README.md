# ansibleSetup

1. sudo apt-get install ansible
2. sudo pip install paramiko --upgrade
3. ansible-playbook -vvv setup.yml -i hosts --ask-pass --sudo -c paramiko
